
// this is autogenerated file, do not edit it.
#include "ficus/ficus.h"

typedef struct _fx_Ta2S  { fx_str_t t0; fx_str_t t1; } _fx_Ta2S;

typedef struct  { int_ rc; int_ data; } _fx_E4Exit_data_t;

typedef struct  { int_ rc; fx_str_t data; } _fx_E4Fail_data_t;

static void _fx_free_Ta2S(_fx_Ta2S* dst)
{ fx_free_str(&dst->t0); fx_free_str(&dst->t1);
}

static void _fx_copy_Ta2S(_fx_Ta2S* src, _fx_Ta2S* dst)
{ fx_copy_str(&src->t0, &dst->t0); fx_copy_str(&src->t1, &dst->t1);
}

static void _fx_make_Ta2S(fx_str_t* t0, fx_str_t* t1, _fx_Ta2S* fx_result)
{ fx_copy_str(t0, &fx_result->t0); fx_copy_str(t1, &fx_result->t1);
}

FX_EXTERN_C int_ _fx_F6lengthi1S(fx_str_t* s, void* fx_fv);

FX_EXTERN_C bool _fx_M6StringFM8endswithB2SS(fx_str_t* s, fx_str_t* suffix, void* fx_fv);

FX_EXTERN_C bool _fx_F6__eq__B2SS(fx_str_t* a, fx_str_t* b, void* fx_fv);

FX_EXTERN_C int_ _fx_M6StringFM5rfindi3SSi(fx_str_t* s, fx_str_t* part, int_ from_pos, void* fx_fv);

FX_EXTERN_C bool _fx_M6StringFM10startswithB2SS(fx_str_t* s, fx_str_t* prefix, void* fx_fv);

FX_EXTERN_C int_ _fx_M6StringFM4findi3SSi(fx_str_t* s, fx_str_t* part, int_ from_pos, void* fx_fv);

FX_EXTERN_C int _fx_M8FilenameFM7dir_sepS0(fx_str_t* fx_result, void* fx_fv)
{
   
const char sep[] =
#if defined _WIN32 || defined WINCE
        {92, 0} // back slash
#else
        {47, 0} // slash
#endif
    ;
    return fx_cstr2str(sep, -1, fx_result);

}

FX_EXTERN_C int _fx_M8FilenameFM5splitTa2S1S(fx_str_t* path_0, _fx_Ta2S* fx_result, void* fx_fv)
{
   _fx_Ta2S res_0 = {  };
   fx_str_t path_1 = {  };
   int fx_status = 0;
   fx_copy_str(path_0, &path_1);
   for (;;) {
      fx_str_t path_2 = {  };
      fx_str_t sep_0 = {  };
      _fx_Ta2S result_0 = {  };
      fx_str_t v_0 = {  };
      _fx_Ta2S result_1 = {  };
      fx_str_t v_1 = {  };
      fx_str_t v_2 = {  };
      _fx_Ta2S result_2 = {  };
      fx_str_t v_3 = {  };
      fx_str_t v_4 = {  };
      _fx_Ta2S result_3 = {  };
      fx_copy_str(&path_1, &path_2);
      FX_CALL(_fx_M8FilenameFM7dir_sepS0(&sep_0, 0), _fx_catch_0);
      int_ v_5 = _fx_F6lengthi1S(&sep_0, 0);
      if (!(v_5 == 1)) { FX_FAST_THROW(FX_EXN_AssertError, _fx_catch_0);
      }
      bool v_6;
      if (_fx_M6StringFM8endswithB2SS(&path_2, &sep_0, 0)) { v_6 = true;
      }
      else {
         bool v_7;
         fx_str_t slit_0 = FX_MAKE_STR("/");
         v_7 = _fx_F6__eq__B2SS(&sep_0, &slit_0, 0);
         if (!v_7) { fx_str_t slit_1 = FX_MAKE_STR("/"); v_6 = _fx_M6StringFM8endswithB2SS(&path_2, &slit_1, 0);
         }
         else { v_6 = false;
         }
      }
      if (v_6) {
         int_ v_8 = _fx_F6lengthi1S(&path_2, 0);
         if (v_8 == 1) {
            _fx_make_Ta2S(&sep_0, &sep_0, &result_0);
            _fx_free_Ta2S(&res_0);
            _fx_copy_Ta2S(&result_0, &res_0);
            FX_BREAK(_fx_catch_0);
         }
         else {
            FX_CALL(fx_substr(&path_2, 0, FX_STR_LENGTH(path_2) - 1, 1, 1, &v_0), _fx_catch_0);
            FX_FREE_STR(&path_1);
            fx_copy_str(&v_0, &path_1);
         }
      }
      else {
         int_ v_9 = _fx_F6lengthi1S(&path_2, 0);
         int_ pos_0 = _fx_M6StringFM5rfindi3SSi(&path_2, &sep_0, v_9 - 1, 0);
         bool v_10;
         fx_str_t slit_2 = FX_MAKE_STR("/");
         v_10 = _fx_F6__eq__B2SS(&sep_0, &slit_2, 0);
         int_ pos0_0;
         if (v_10) { pos0_0 = pos_0;
         }
         else {
            int_ v_11 = _fx_F6lengthi1S(&path_2, 0);
            fx_str_t slit_3 = FX_MAKE_STR("/");
            pos0_0 = _fx_M6StringFM5rfindi3SSi(&path_2, &slit_3, v_11 - 1, 0);
         }
         int_ pos_1;
         if (pos_0 < 0) { pos_1 = pos0_0;
         }
         else if (pos0_0 < 0) { pos_1 = pos_0;
         }
         else if (pos_0 >= pos0_0) { pos_1 = pos_0;
         }
         else { pos_1 = pos0_0;
         }
         if (pos_1 < 0) {
            fx_str_t slit_4 = FX_MAKE_STR(".");
            _fx_make_Ta2S(&slit_4, &path_2, &result_1);
            _fx_free_Ta2S(&res_0);
            _fx_copy_Ta2S(&result_1, &res_0);
            FX_BREAK(_fx_catch_0);
         }
         else {
            bool t_0;
            if (pos_1 == 0) { t_0 = true;
            }
            else {
               int_ v_12 = pos_1 - 1; FX_STR_CHKIDX(path_2, v_12, _fx_catch_0); t_0 = FX_STR_ELEM(path_2, v_12) == (char_)58;
            }
            if (t_0) {
               FX_CALL(fx_substr(&path_2, 0, pos_1 + 1, 1, 1, &v_1), _fx_catch_0);
               FX_CALL(fx_substr(&path_2, pos_1 + 1, 0, 1, 2, &v_2), _fx_catch_0);
               _fx_make_Ta2S(&v_1, &v_2, &result_2);
               _fx_free_Ta2S(&res_0);
               _fx_copy_Ta2S(&result_2, &res_0);
               FX_BREAK(_fx_catch_0);
            }
            else {
               FX_CALL(fx_substr(&path_2, 0, pos_1, 1, 1, &v_3), _fx_catch_0);
               FX_CALL(fx_substr(&path_2, pos_1 + 1, 0, 1, 2, &v_4), _fx_catch_0);
               _fx_make_Ta2S(&v_3, &v_4, &result_3);
               _fx_free_Ta2S(&res_0);
               _fx_copy_Ta2S(&result_3, &res_0);
               FX_BREAK(_fx_catch_0);
            }
         }
      }

   _fx_catch_0: ;
      _fx_free_Ta2S(&result_3);
      FX_FREE_STR(&v_4);
      FX_FREE_STR(&v_3);
      _fx_free_Ta2S(&result_2);
      FX_FREE_STR(&v_2);
      FX_FREE_STR(&v_1);
      _fx_free_Ta2S(&result_1);
      FX_FREE_STR(&v_0);
      _fx_free_Ta2S(&result_0);
      FX_FREE_STR(&sep_0);
      FX_FREE_STR(&path_2);
      FX_CHECK_BREAK();
      FX_CHECK_EXN(_fx_cleanup);
   }
   _fx_copy_Ta2S(&res_0, fx_result);

_fx_cleanup: ;
   _fx_free_Ta2S(&res_0);
   FX_FREE_STR(&path_1);
   return fx_status;
}

FX_EXTERN_C int _fx_M8FilenameFM8basenameS1S(fx_str_t* path_0, fx_str_t* fx_result, void* fx_fv)
{
   _fx_Ta2S v_0 = {  };
   int fx_status = 0;
   FX_CALL(_fx_M8FilenameFM5splitTa2S1S(path_0, &v_0, 0), _fx_cleanup);
   fx_copy_str(&v_0.t1, fx_result);

_fx_cleanup: ;
   _fx_free_Ta2S(&v_0);
   return fx_status;
}

FX_EXTERN_C int _fx_M8FilenameFM9normalizeS2SS(fx_str_t* dir_0, fx_str_t* fname_0, fx_str_t* fx_result, void* fx_fv)
{
   fx_str_t res_0 = {  };
   fx_str_t dir_1 = {  };
   fx_str_t fname_1 = {  };
   int fx_status = 0;
   fx_copy_str(dir_0, &dir_1);
   fx_copy_str(fname_0, &fname_1);
   for (;;) {
      fx_str_t dir_2 = {  };
      fx_str_t fname_2 = {  };
      fx_str_t sep_0 = {  };
      fx_str_t v_0 = {  };
      fx_str_t v_1 = {  };
      fx_str_t v_2 = {  };
      fx_str_t v_3 = {  };
      _fx_Ta2S v_4 = {  };
      fx_str_t v_5 = {  };
      fx_str_t v_6 = {  };
      fx_str_t sep_1 = {  };
      fx_str_t result_0 = {  };
      fx_copy_str(&dir_1, &dir_2);
      fx_copy_str(&fname_1, &fname_2);
      FX_CALL(_fx_M8FilenameFM7dir_sepS0(&sep_0, 0), _fx_catch_0);
      int_ v_7 = _fx_F6lengthi1S(&sep_0, 0);
      if (!(v_7 == 1)) { FX_FAST_THROW(FX_EXN_AssertError, _fx_catch_0);
      }
      FX_CALL(_fx_M8FilenameFM7dir_sepS0(&v_0, 0), _fx_catch_0);
      bool v_8;
      bool t_0;
      if (_fx_M6StringFM10startswithB2SS(&fname_2, &v_0, 0)) { t_0 = true;
      }
      else { fx_str_t slit_0 = FX_MAKE_STR("/"); t_0 = _fx_M6StringFM10startswithB2SS(&fname_2, &slit_0, 0);
      }
      if (t_0) { v_8 = true;
      }
      else {
         int_ v_9; fx_str_t slit_1 = FX_MAKE_STR(":"); v_9 = _fx_M6StringFM4findi3SSi(&fname_2, &slit_1, 0, 0); v_8 = v_9 >= 0;
      }
      if (v_8) { FX_FREE_STR(&res_0); fx_copy_str(&fname_2, &res_0); FX_BREAK(_fx_catch_0);
      }
      else {
         fx_str_t slit_2 = FX_MAKE_STR(".");
         {
         const fx_str_t strs_0[] = { slit_2, sep_0 }; FX_CALL(fx_strjoin(0, 0, 0, strs_0, 2, &v_1), _fx_catch_0);
         }
         bool v_10;
         if (_fx_M6StringFM10startswithB2SS(&fname_2, &v_1, 0)) { v_10 = true;
         }
         else {
            bool v_11;
            fx_str_t slit_3 = FX_MAKE_STR("/");
            v_11 = _fx_F6__eq__B2SS(&sep_0, &slit_3, 0);
            if (!v_11) { fx_str_t slit_4 = FX_MAKE_STR("./"); v_10 = _fx_M6StringFM10startswithB2SS(&fname_2, &slit_4, 0);
            }
            else { v_10 = false;
            }
         }
         if (v_10) {
            FX_CALL(fx_substr(&fname_2, 2, 0, 1, 2, &v_2), _fx_catch_0);
            FX_FREE_STR(&dir_1);
            fx_copy_str(&dir_2, &dir_1);
            FX_FREE_STR(&fname_1);
            fx_copy_str(&v_2, &fname_1);
         }
         else {
            fx_str_t slit_5 = FX_MAKE_STR("..");
            {
            const fx_str_t strs_1[] = { slit_5, sep_0 }; FX_CALL(fx_strjoin(0, 0, 0, strs_1, 2, &v_3), _fx_catch_0);
            }
            bool v_12;
            if (_fx_M6StringFM10startswithB2SS(&fname_2, &v_3, 0)) { v_12 = true;
            }
            else {
               bool v_13;
               fx_str_t slit_6 = FX_MAKE_STR("/");
               v_13 = _fx_F6__eq__B2SS(&sep_0, &slit_6, 0);
               if (!v_13) { fx_str_t slit_7 = FX_MAKE_STR("../"); v_12 = _fx_M6StringFM10startswithB2SS(&fname_2, &slit_7, 0);
               }
               else { v_12 = false;
               }
            }
            if (v_12) {
               FX_CALL(_fx_M8FilenameFM5splitTa2S1S(&dir_2, &v_4, 0), _fx_catch_0);
               fx_copy_str(&v_4.t0, &v_5);
               FX_CALL(fx_substr(&fname_2, 3, 0, 1, 2, &v_6), _fx_catch_0);
               FX_FREE_STR(&dir_1);
               fx_copy_str(&v_5, &dir_1);
               FX_FREE_STR(&fname_1);
               fx_copy_str(&v_6, &fname_1);
            }
            else {
               FX_CALL(_fx_M8FilenameFM7dir_sepS0(&sep_1, 0), _fx_catch_0);
               bool v_14;
               if (_fx_M6StringFM8endswithB2SS(&dir_2, &sep_1, 0)) { v_14 = true;
               }
               else { fx_str_t slit_8 = FX_MAKE_STR("/"); v_14 = _fx_M6StringFM8endswithB2SS(&dir_2, &slit_8, 0);
               }
               if (v_14) {
                  const fx_str_t strs_2[] = { dir_2, fname_2 }; FX_CALL(fx_strjoin(0, 0, 0, strs_2, 2, &result_0), _fx_catch_0);
               }
               else {
                  const fx_str_t strs_3[] = { dir_2, sep_1, fname_2 };
                  FX_CALL(fx_strjoin(0, 0, 0, strs_3, 3, &result_0), _fx_catch_0);
               }
               FX_FREE_STR(&res_0);
               fx_copy_str(&result_0, &res_0);
               FX_BREAK(_fx_catch_0);
            }
         }
      }

   _fx_catch_0: ;
      FX_FREE_STR(&result_0);
      FX_FREE_STR(&sep_1);
      FX_FREE_STR(&v_6);
      FX_FREE_STR(&v_5);
      _fx_free_Ta2S(&v_4);
      FX_FREE_STR(&v_3);
      FX_FREE_STR(&v_2);
      FX_FREE_STR(&v_1);
      FX_FREE_STR(&v_0);
      FX_FREE_STR(&sep_0);
      FX_FREE_STR(&fname_2);
      FX_FREE_STR(&dir_2);
      FX_CHECK_BREAK();
      FX_CHECK_EXN(_fx_cleanup);
   }
   fx_copy_str(&res_0, fx_result);

_fx_cleanup: ;
   FX_FREE_STR(&res_0);
   FX_FREE_STR(&dir_1);
   FX_FREE_STR(&fname_1);
   return fx_status;
}

FX_EXTERN_C int _fx_M8FilenameFM16remove_extensionS1S(fx_str_t* path_0, fx_str_t* fx_result, void* fx_fv)
{
   fx_str_t sep_0 = {  };
   int fx_status = 0;
   FX_CALL(_fx_M8FilenameFM7dir_sepS0(&sep_0, 0), _fx_cleanup);
   int_ v_0 = _fx_F6lengthi1S(path_0, 0);
   int_ dotpos_0;
   fx_str_t slit_0 = FX_MAKE_STR(".");
   dotpos_0 = _fx_M6StringFM5rfindi3SSi(path_0, &slit_0, v_0 - 1, 0);
   if (dotpos_0 < 0) { fx_copy_str(path_0, fx_result);
   }
   else {
      int_ v_1 = _fx_F6lengthi1S(path_0, 0);
      int_ pos_0 = _fx_M6StringFM5rfindi3SSi(path_0, &sep_0, v_1 - 1, 0);
      bool v_2;
      fx_str_t slit_1 = FX_MAKE_STR("/");
      v_2 = _fx_F6__eq__B2SS(&sep_0, &slit_1, 0);
      int_ pos0_0;
      if (v_2) { pos0_0 = pos_0;
      }
      else {
         int_ v_3 = _fx_F6lengthi1S(path_0, 0);
         fx_str_t slit_2 = FX_MAKE_STR("/");
         pos0_0 = _fx_M6StringFM5rfindi3SSi(path_0, &slit_2, v_3 - 1, 0);
      }
      int_ pos_1;
      if (pos_0 < 0) { pos_1 = pos0_0;
      }
      else if (pos0_0 < 0) { pos_1 = pos_0;
      }
      else if (pos_0 >= pos0_0) { pos_1 = pos_0;
      }
      else { pos_1 = pos0_0;
      }
      if (dotpos_0 <= pos_1 + 1) { fx_copy_str(path_0, fx_result);
      }
      else { FX_CALL(fx_substr(path_0, 0, dotpos_0, 1, 1, fx_result), _fx_cleanup);
      }
   }

_fx_cleanup: ;
   FX_FREE_STR(&sep_0);
   return fx_status;
}

FX_EXTERN_C int fx_init_Filename(void)
{ int fx_status = 0; return fx_status;
}

FX_EXTERN_C void fx_deinit_Filename(void)
{
}

