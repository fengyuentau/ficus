/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

import Ast

@ccode {
#include <alloca.h>
#include "ficus_nn_common.h"
}

fun run_softmax(inp: Ast.nntensor_t, out: Ast.nntensor_t, ntasks: int): void
@ccode {
    const fx_arr_t* inp_shape_ = &inp->shape.shape;
    const fx_arr_t* out_shape_ = &out->shape.shape;
    const int_* inp_shape = (const int_*)(inp_shape_->data);
    const int_* out_shape = (const int_*)(out_shape_->data);
    int_ ndims = inp_shape_->dim[0].size;
    const fx_arr_t* inp_data = &inp->data.u.NN_Data_I8;
    const fx_arr_t* out_data = &out->data.u.NN_Data_I8;
    int inp_typ = inp->data.tag, out_typ = out->data.tag;
    int_ N, C, Ca, plane_size = 1;

    if (ndims < 2 || ndims != out_shape_->dim[0].size)
        return FX_SET_EXN_FAST(FX_EXN_SizeMismatchError);

    if ((inp_typ != FX_F32 && inp_typ != FX_F16) || out_typ != inp_typ)
        return FX_SET_EXN_FAST(FX_EXN_NotImplementedError);

    N = inp_shape[0];
    C = inp_shape[1];
    Ca = (C + 7) & -8;
    for (int_ i = 0; i < ndims; i++) {
        if (inp_shape[i] != out_shape[i])
            return FX_SET_EXN_FAST(FX_EXN_SizeMismatchError);
        if (i >= 2) plane_size *= inp_shape[i];
    }

    if (plane_size*N < 100000) ntasks = 1;

    #pragma omp parallel for num_threads(ntasks)
    for (int_ task_id = 0; task_id < ntasks; task_id++)
    {
        float* buf = (float*)alloca(Ca*sizeof(float));
        int_ pix0 = task_id*(N*plane_size)/ntasks;
        int_ pix1 = (task_id+1)*(N*plane_size)/ntasks;
        //printf("pix0=%d, pix1=%d, C=%d, plane_size=%d\n", (int)pix0, (int)pix1, (int)C, (int)plane_size);
        for (; pix0 < pix1; pix0++) {
            int_ sample_idx = pix0 / plane_size;
            int_ ofs = pix0 - sample_idx * plane_size;
            ofs += sample_idx * (plane_size * C);
            float maxval = -FLT_MAX, s = 0.f;
            int_ j = 0;

            if (inp_typ == FX_F32) {
                const float* inptr = (const float*)inp_data->data + ofs;
                for(; j < C; j++) {
                    float x = inptr[j*plane_size];
                    buf[j] = x;
                }
            } else {
                const fx_f16* inptr = (const fx_f16*)inp_data->data + ofs;
                for(; j < C; j++) {
                    float x = FX_FLOAT(inptr[j*plane_size]);
                    buf[j] = x;
                }
            }
            #ifdef __ARM_NEON
            {
            float vbuf[4];
            float32x4_t vmax = vdupq_n_f32(maxval);
            float32x4_t vs = vdupq_n_f32(0.f);
            for (; j < Ca; j++)
                buf[j] = maxval;
            for (j = 0; j < C; j += 4)
                vmax = vmaxq_f32(vmax, vld1q_f32(buf + j));
            vst1q_f32(vbuf, vmax);
            maxval = vbuf[0];
            maxval = maxval >= vbuf[1] ? maxval : vbuf[1];
            maxval = maxval >= vbuf[2] ? maxval : vbuf[2];
            maxval = maxval >= vbuf[3] ? maxval : vbuf[3];
            vmax = vdupq_n_f32(maxval);
            for (j = 0; j < C; j += 4) {
                float32x4_t t = vld1q_f32(buf + j);
                t = _fx_vexpq_f32(vsubq_f32(t, vmax));
                vs = vaddq_f32(vs, t);
                vst1q_f32(buf + j, t);
            }
            vst1q_f32(vbuf, vs);
            s = vbuf[0] + vbuf[1] + vbuf[2] + vbuf[3];
            }
            #else
            for (j = 0; j < C; j++) {
                float x = buf[j];
                maxval = maxval >= x ? maxval : x;
            }
            for (j = 0; j < C; j++) {
                float x = expf(buf[j] - maxval);
                buf[j] = x;
                s += x;
            }
            #endif
            s = 1.f/s;
            //printf("maxval=%.5g, s=%.5g\n", maxval, s);
            if (inp_typ == FX_F32) {
                float* outptr = (float*)out_data->data + ofs;
                for (j = 0; j < C; j++)
                    outptr[j*plane_size] = buf[j]*s;
            } else {
                fx_f16* outptr = (fx_f16*)out_data->data + ofs;
                for (j = 0; j < C; j++)
                    outptr[j*plane_size] = FX_FLOAT16(buf[j]*s);
            }
        }
    }
    return FX_OK;
}

fun run_softmax(model: Ast.nnmodel_t, op: Ast.nnop_t) =
match op {
| Ast.NN_SoftMax {axis, t_inp, t_out} =>
    val inp = model.get_tensor(t_inp)
    val out = model.get_tensor(t_out)
    assert(`inp.shape.shape.size() >= 2`)
    assert(`axis == 1 || axis == -1`)
    run_softmax(inp, out, *model.ntasks)
| _ => throw Ast.NNError(f"unsupported operation '{op.name()}'")
}

@private fun run_batchnorm(inp_shape: int [], inp_data: float [],
                           inp_mean_data: float [], inp_var_data: float [],
                           scale_data: float [], B_data: float [],
                           out_shape: int [], out_data: float [],
                           epsilon: float, ntasks: int): void
@ccode {
    int_ i, ndims = inp_shape->dim[0].size;
    const int_* inp_shape_ = (const int_*)inp_shape->data;
    int_ N = ndims > 0 ? inp_shape_[0] : 1;
    int_ C = ndims > 1 ? inp_shape_[1] : 1;
    int_ out_ndims = out_shape->dim[0].size;
    const int_* out_shape_ = (const int_*)out_shape->data;
    const float* inptr0 = (const float*)inp_data->data;
    float* outptr0 = (float*)out_data->data;
    const float* inp_mean = (const float*)inp_mean_data->data;
    const float* inp_var = (const float*)inp_var_data->data;
    const float* scales = (const float*)scale_data->data;
    const float* biases = (const float*)B_data->data;
    size_t planesize = 1;

    if (ndims != out_ndims || ndims < 2 ||
        inp_mean_data->dim[0].size != C ||
        inp_var_data->dim[0].size != C ||
        scale_data->dim[0].size != C ||
        B_data->dim[0].size != C)
        return FX_SET_EXN_FAST(FX_EXN_SizeMismatchError);

    for (i = 0; i < ndims; i++) {
        if (inp_shape_[i] != out_shape_[i])
            return FX_SET_EXN_FAST(FX_EXN_SizeMismatchError);
        if (i > 1) planesize *= (size_t)inp_shape_[i];
    }

    #pragma omp parallel for num_threads(ntasks)
    for (i = 0; i < N*C; i++) {
        int_ c = i % C;
        float alpha = scales[c]/sqrt(inp_var[c] + epsilon);
        float beta = biases[c] - inp_mean[c]*alpha;
        const float* inptr = inptr0 + i*planesize;
        float* outptr = outptr0 + i*planesize;
        for(size_t j = 0; j < planesize; j++)
            outptr[j] = inptr[j]*alpha + beta;
    }

    return FX_OK;
}

fun run_batchnorm(model: Ast.nnmodel_t, op: Ast.nnop_t) =
match op {
| Ast.NN_BatchNorm {epsilon, momentum,
        t_inp, t_scale, t_B, t_mean, t_var, t_out} =>
    val inp = model.get_tensor(t_out)
    val inp_mean = model.get_tensor(t_mean)
    val inp_var = model.get_tensor(t_var)
    val scale = model.get_tensor(t_scale)
    val B = model.get_tensor(t_B)
    val out = model.get_tensor(t_out)
    match (inp.data, inp_mean.data, inp_var.data, scale.data, B.data, out.data) {
    | (Ast.NN_Data_FP32 inp_data,
       Ast.NN_Data_FP32 inp_mean_data, Ast.NN_Data_FP32 inp_var_data,
       Ast.NN_Data_FP32 scale_data, Ast.NN_Data_FP32 B_data,
       Ast.NN_Data_FP32 out_data) =>
        run_batchnorm(inp.shape.shape, inp_data, inp_mean_data,
                      inp_var_data, scale_data, B_data,
                      out.shape.shape, out_data, epsilon, *model.ntasks)
    | _ => throw NotImplementedError
    }
| _ => throw Ast.NNError(f"unexpected op {op.name()}")
}

fun run_gemm(A: Ast.nntensor_t, B: Ast.nntensor_t, C: Ast.nntensor_t,
             out: Ast.nntensor_t, alpha: float, beta: float,
             transA: bool, transB: bool, ntasks: int): void
@ccode {
    const int_* A_shape = (const int_*)A->shape.shape.data;
    const int_* B_shape = (const int_*)B->shape.shape.data;
    const int_* C_shape = (const int_*)C->shape.shape.data;
    const int_* out_shape = (const int_*)out->shape.shape.data;
    const fx_arr_t* A_data = &A->data.u.NN_Data_I8;
    const fx_arr_t* B_data = &B->data.u.NN_Data_I8;
    const fx_arr_t* C_data = &C->data.u.NN_Data_I8;
    fx_arr_t* out_data = &out->data.u.NN_Data_I8;
    int A_typ = A->data.tag, B_typ = B->data.tag;
    int C_typ = C->data.tag, out_typ = out->data.tag;
    int_ C_ndims = C_typ == FX_Notype ? 0 : C->shape.shape.dim[0].size;

    if ((A_typ != FX_F32 && A_typ != FX_F16) ||
        (B_typ != FX_F32 && B_typ != FX_F16) ||
        (C_typ != FX_F32 && C_typ != FX_F16 && C_typ != FX_Notype) ||
        (out_typ != FX_F32 && out_typ != FX_F16))
        return FX_SET_EXN_FAST(FX_EXN_NotImplementedError);

    if (A->shape.shape.dim[0].size != 2 ||
        B->shape.shape.dim[0].size != 2 ||
        out->shape.shape.dim[0].size != 2 ||
        (C_ndims != 2 && C_ndims != 1 && C_ndims != 0))
        return FX_SET_EXN_FAST(FX_EXN_SizeError);

    if (C_ndims == 1 && (C_shape[0] != out_shape[1]))
        return FX_SET_EXN_FAST(FX_EXN_SizeMismatchError);

    if (C_ndims == 2 &&
        (C_shape[0] != out_shape[0] ||
         C_shape[1] != out_shape[1]))
        return FX_SET_EXN_FAST(FX_EXN_SizeMismatchError);

    if (C_ndims == 0 || beta == 0.f || C_typ == FX_Notype) {
        beta = 0.f;
    } else {
        int_ nrows = out_shape[0], ncols = out_shape[1];
        size_t out_esz = out_data->dim[1].step;
        // [TODO] provide convenient Ficus C API to convert
        // arrays from one type to another with broadcasting support
        for (int_ i = 0; i < nrows; i++) {
            const char* c_i_ = C_data->data + (C_ndims == 2 ? C_data->dim[0].step : 0)*i;
            char* out_i_ = out_data->data + out_data->dim[0].step*i;
            if (out_typ == C_typ) {
                if (out_i_ != c_i_)
                    memcpy(out_i_, c_i_, ncols*out_esz);
            } else if (C_typ == FX_F16 && out_typ == FX_F32) {
                const fx_f16* c_i = (const fx_f16*)c_i_;
                float* out_i = (float*)out_i_;
                for (int_ j = 0; j < ncols; j++)
                    out_i[j] = FX_FLOAT(c_i[j]);
            } else if (C_typ == FX_F32 && out_typ == FX_F16) {
                const float* c_i = (const float*)c_i_;
                fx_f16* out_i = (fx_f16*)out_i_;
                for (int_ j = 0; j < ncols; j++)
                    out_i[j] = FX_FLOAT16(c_i[j]);
            } else {
                return FX_SET_EXN_FAST(FX_EXN_NotImplementedError);
            }
        }
    }

    return fx_mpgemm(transA, transB, alpha, beta,
            A_shape[0], A_shape[1], A_typ, A_data->data, A_shape[1], 1,
            B_shape[0], B_shape[1], B_typ, B_data->data, B_shape[1], 1,
            out_typ, out_data->data, out_shape[1], (int)ntasks);
}

fun run_gemm(model: Ast.nnmodel_t, op: Ast.nnop_t) =
match op {
| Ast.NN_Gemm {alpha, beta, transA, transB, t_A, t_B, t_bias, t_out} =>
    val A = model.get_tensor(t_A), B = model.get_tensor(t_B)
    val bias = model.get_tensor(t_bias)
    val out = model.get_tensor(t_out)
    run_gemm(A, B, bias, out, alpha, beta, transA, transB, *model.ntasks)
| _ => throw Ast.NNError(f"unsupported operation '{op.name()}'")
}
