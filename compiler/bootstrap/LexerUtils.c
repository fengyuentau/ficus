
// this is autogenerated file, do not edit it.
#include "ficus/ficus.h"


static int decodeoct(char_ c)
    {
        return ('0' <= c && c <= '7') ? c - '0' : -1;
    }
    static int decodehex(char_ c)
    {
        return ('0' <= c && c <= '9') ? c - '0' :
                ('a' <= c && c <= 'f') ? c - 'a' + 10 :
                ('A' <= c && c <= 'F') ? c - 'A' + 10 : -1;
    }

struct _fx_N20LexerUtils__stream_t_data_t;

static void _fx_free_N20LexerUtils__stream_t(struct _fx_N20LexerUtils__stream_t_data_t** dst);

typedef struct _fx_Ta2i {
   int_ t0;
   int_ t1;
} _fx_Ta2i;

typedef struct _fx_T2Ta2iS {
   struct _fx_Ta2i t0;
   fx_str_t t1;
} _fx_T2Ta2iS;

typedef struct _fx_T4SiiS {
   fx_str_t t0;
   int_ t1;
   int_ t2;
   fx_str_t t3;
} _fx_T4SiiS;

typedef struct _fx_N20LexerUtils__stream_t_data_t {
   int_ rc;
   union {
      struct _fx_T4SiiS stream_t;
   } u;
} _fx_N20LexerUtils__stream_t_data_t, *_fx_N20LexerUtils__stream_t;

typedef struct _fx_T3CiB {
   char_ t0;
   int_ t1;
   bool t2;
} _fx_T3CiB;

typedef struct _fx_T5ildiC {
   int_ t0;
   int64_t t1;
   double t2;
   int_ t3;
   char_ t4;
} _fx_T5ildiC;

typedef struct _fx_T4iSiB {
   int_ t0;
   fx_str_t t1;
   int_ t2;
   bool t3;
} _fx_T4iSiB;

typedef struct {
   int_ rc;
   int_ data;
} _fx_E4Exit_data_t;

typedef struct {
   int_ rc;
   fx_str_t data;
} _fx_E4Fail_data_t;

static void _fx_free_T2Ta2iS(struct _fx_T2Ta2iS* dst)
{
   fx_free_str(&dst->t1);
}

static void _fx_copy_T2Ta2iS(struct _fx_T2Ta2iS* src, struct _fx_T2Ta2iS* dst)
{
   dst->t0 = src->t0;
   fx_copy_str(&src->t1, &dst->t1);
}

static void _fx_make_T2Ta2iS(struct _fx_Ta2i* t0, fx_str_t* t1, struct _fx_T2Ta2iS* fx_result)
{
   fx_result->t0 = *t0;
   fx_copy_str(t1, &fx_result->t1);
}

static void _fx_free_T4SiiS(struct _fx_T4SiiS* dst)
{
   fx_free_str(&dst->t0);
   fx_free_str(&dst->t3);
}

static void _fx_copy_T4SiiS(struct _fx_T4SiiS* src, struct _fx_T4SiiS* dst)
{
   fx_copy_str(&src->t0, &dst->t0);
   dst->t1 = src->t1;
   dst->t2 = src->t2;
   fx_copy_str(&src->t3, &dst->t3);
}

static void _fx_make_T4SiiS(fx_str_t* t0, int_ t1, int_ t2, fx_str_t* t3, struct _fx_T4SiiS* fx_result)
{
   fx_copy_str(t0, &fx_result->t0);
   fx_result->t1 = t1;
   fx_result->t2 = t2;
   fx_copy_str(t3, &fx_result->t3);
}

static void _fx_free_N20LexerUtils__stream_t(struct _fx_N20LexerUtils__stream_t_data_t** dst)
{
   if (*dst && FX_DECREF((*dst)->rc) == 1) {
      _fx_free_T4SiiS(&(*dst)->u.stream_t); fx_free(*dst);
   }
   *dst = 0;
}

static void _fx_free_T4iSiB(struct _fx_T4iSiB* dst)
{
   fx_free_str(&dst->t1);
}

static void _fx_copy_T4iSiB(struct _fx_T4iSiB* src, struct _fx_T4iSiB* dst)
{
   dst->t0 = src->t0;
   fx_copy_str(&src->t1, &dst->t1);
   dst->t2 = src->t2;
   dst->t3 = src->t3;
}

static void _fx_make_T4iSiB(int_ t0, fx_str_t* t1, int_ t2, bool t3, struct _fx_T4iSiB* fx_result)
{
   fx_result->t0 = t0;
   fx_copy_str(t1, &fx_result->t1);
   fx_result->t2 = t2;
   fx_result->t3 = t3;
}

int _FX_EXN_E22LexerUtils__LexerError = 0;
FX_EXTERN_C int _fx_M4FileFM9read_utf8S1S(fx_str_t* fname, fx_str_t* fx_result, void* fx_fv);

FX_EXTERN_C_VAL(int FX_EXN_OverflowError)
FX_EXTERN_C_VAL(int FX_EXN_BadArgError)
FX_EXTERN_C int _fx_F6stringS1E(fx_exn_t* a, fx_str_t* fx_result, void* fx_fv);

fx_exn_info_t _fx_E22LexerUtils__LexerError_info = {0};
typedef struct {
   int_ rc;
   struct _fx_T2Ta2iS data;
} _fx_E22LexerUtils__LexerError_data_t;

FX_EXTERN_C void _fx_free_E22LexerUtils__LexerError(_fx_E22LexerUtils__LexerError_data_t* dst)
{
   _fx_free_T2Ta2iS(&dst->data);
   fx_free(dst);
}

FX_EXTERN_C int _fx_M10LexerUtilsFM15make_LexerErrorE2Ta2iS(struct _fx_Ta2i* arg0, fx_str_t* arg1, fx_exn_t* fx_result)
{
   FX_MAKE_EXN_IMPL_START(_FX_EXN_E22LexerUtils__LexerError, _fx_E22LexerUtils__LexerError_data_t,
      _fx_E22LexerUtils__LexerError_info);
   exn_data->data.t0 = *arg0;
   fx_copy_str(arg1, &exn_data->data.t1);
   return 0;
}

FX_EXTERN_C int _fx_M10LexerUtilsFM8stream_tN20LexerUtils__stream_t4SiiS(
   fx_str_t* arg0,
   int_ arg1,
   int_ arg2,
   fx_str_t* arg3,
   struct _fx_N20LexerUtils__stream_t_data_t** fx_result)
{
   FX_MAKE_RECURSIVE_VARIANT_IMPL_START(_fx_N20LexerUtils__stream_t);
   fx_copy_str(arg0, &v->u.stream_t.t0);
   v->u.stream_t.t1 = arg1;
   v->u.stream_t.t2 = arg2;
   fx_copy_str(arg3, &v->u.stream_t.t3);
   return 0;
}

FX_EXTERN_C int _fx_M10LexerUtilsFM11make_streamN20LexerUtils__stream_t1S(
   fx_str_t* fname_0,
   struct _fx_N20LexerUtils__stream_t_data_t** fx_result,
   void* fx_fv)
{
   fx_str_t buf_0 = {0};
   int fx_status = 0;
   FX_CALL(_fx_M4FileFM9read_utf8S1S(fname_0, &buf_0, 0), _fx_cleanup);
   FX_CALL(_fx_M10LexerUtilsFM8stream_tN20LexerUtils__stream_t4SiiS(fname_0, 1, 0, &buf_0, fx_result), _fx_cleanup);

_fx_cleanup: ;
   FX_FREE_STR(&buf_0);
   return fx_status;
}

FX_EXTERN_C int _fx_M10LexerUtilsFM11skip_spacesT3CiB3N20LexerUtils__stream_tiB(
   struct _fx_N20LexerUtils__stream_t_data_t* s_0,
   int_ pos_0,
   bool allow_nested_0,
   struct _fx_T3CiB* fx_result,
   void* fx_fv)
{
   fx_str_t buf_0 = {0};
   fx_exn_t v_0 = {0};
   int fx_status = 0;
   int_ lineno0_0 = s_0->u.stream_t.t1;
   int_ lineno_0 = lineno0_0;
   int_ bol_0 = s_0->u.stream_t.t2;
   fx_copy_str(&s_0->u.stream_t.t3, &buf_0);
   int_ len_0 = FX_STR_LENGTH(buf_0);
   int_ inside_comment_0 = 0;
   bool inside_eol_comment_0 = false;
   char_ c_res_0 = (char_)0;
   int_ pos_1 = pos_0;
   while (pos_1 < len_0) {
      FX_STR_CHKIDX(buf_0, pos_1, _fx_catch_0);
      char_ c_0 = FX_STR_ELEM(buf_0, pos_1);
      pos_1 = pos_1 + 1;
      char_ c1_0 = FX_STR_ELEM_ZERO(buf_0, pos_1);
      bool t_0;
      if (c_0 == (char_)10) {
         t_0 = true;
      }
      else if (c_0 == (char_)13) {
         t_0 = c1_0 != (char_)10;
      }
      else {
         t_0 = false;
      }
      if (t_0) {
         lineno_0 = lineno_0 + 1; bol_0 = pos_1; inside_eol_comment_0 = false;
      }
      else {
         bool t_1;
         if (c_0 == (char_)32) {
            t_1 = true;
         }
         else {
            t_1 = c_0 == (char_)9;
         }
         bool t_2;
         if (t_1) {
            t_2 = true;
         }
         else {
            t_2 = c_0 == (char_)13;
         }
         bool t_3;
         if (t_2) {
            t_3 = true;
         }
         else {
            t_3 = inside_eol_comment_0;
         }
         if (!t_3) {
            if (inside_comment_0 > 0) {
               bool t_4;
               if (c_0 == (char_)42) {
                  t_4 = c1_0 == (char_)47;
               }
               else {
                  t_4 = false;
               }
               if (t_4) {
                  inside_comment_0 = inside_comment_0 - 1; pos_1 = pos_1 + 1;
               }
               else {
                  bool t_5;
                  if (c_0 == (char_)47) {
                     t_5 = c1_0 == (char_)42;
                  }
                  else {
                     t_5 = false;
                  }
                  bool t_6;
                  if (t_5) {
                     t_6 = allow_nested_0;
                  }
                  else {
                     t_6 = false;
                  }
                  if (t_6) {
                     inside_comment_0 = inside_comment_0 + 1; pos_1 = pos_1 + 1;
                  }
               }
            }
            else {
               bool t_7;
               if (c_0 == (char_)47) {
                  t_7 = c1_0 == (char_)42;
               }
               else {
                  t_7 = false;
               }
               if (t_7) {
                  inside_comment_0 = 1;
               }
               else {
                  bool t_8;
                  if (c_0 == (char_)47) {
                     t_8 = c1_0 == (char_)47;
                  }
                  else {
                     t_8 = false;
                  }
                  if (t_8) {
                     inside_eol_comment_0 = true;
                  }
                  else {
                     c_res_0 = c_0; pos_1 = pos_1 - 1; FX_BREAK(_fx_catch_0);
                  }
               }
            }
         }
      }

   _fx_catch_0: ;
      FX_CHECK_BREAK();
      FX_CHECK_EXN(_fx_cleanup);
   }
   s_0->u.stream_t.t1 = lineno_0;
   s_0->u.stream_t.t2 = bol_0;
   if (inside_comment_0 > 0) {
      _fx_Ta2i v_1 = { lineno_0, pos_1 - bol_0 };
      fx_str_t slit_0 = FX_MAKE_STR("unterminated comment");
      FX_CALL(_fx_M10LexerUtilsFM15make_LexerErrorE2Ta2iS(&v_1, &slit_0, &v_0), _fx_cleanup);
      FX_THROW(&v_0, true, _fx_cleanup);
   }
   _fx_T3CiB tup_0 = { c_res_0, pos_1, lineno_0 > lineno0_0 };
   *fx_result = tup_0;

_fx_cleanup: ;
   FX_FREE_STR(&buf_0);
   fx_free_exn(&v_0);
   return fx_status;
}

FX_EXTERN_C int _fx_M10LexerUtilsFM9getnumberT5ildiC4SiBB(
   fx_str_t* s,
   int_ pos,
   bool just_int,
   bool get_suffix,
   struct _fx_T5ildiC* fx_result,
   void* fx_fv)
{
   
const int MAX_ATOF = 128;
    char buf[128 + 16];
    int_ i = 0, len = s->length - pos;
    const char_ *ptr = s->data + pos;
    bool ok = true;
    uint64_t r = 0, r1;
    int base = 10;
    bool flt = false, have_dot = false, have_e = false;
    char_ c = '\0';

    if(len <= 0)
        return FX_SET_EXN_FAST(FX_EXN_BadArgError);

    if( ptr[0] == '0' ) {
        if(len > 2 && (ptr[1] == 'x' || ptr[1] == 'X')) {
            base = 16;
            ptr += 2;
            len -= 2;
        } else if(len > 2 && (ptr[1] == 'b' || ptr[1] == 'B')) {
            base = 2;
            ptr += 2;
            len -= 2;
        } else if(len > 2 && (ptr[1] == 'o' || ptr[1] == 'O')) {
            base = 8;
            ptr += 2;
            len -= 2;
        } else if(!just_int && len >= 2 && (ptr[1] == '.' || ptr[1] == 'e' || ptr[1] == 'E')) {
            flt = true;
        }
        else base = 8;
    }

    if( !flt ) {
        if( base == 10 ) {
            for( i = 0; i < len; i++ ) {
                c = ptr[i];
                if(c < '0' || c > '9')
                    break;
                r1 = r*10 + (c - '0');
                if (r1 < r)
                    ok = false; // do not exit the loop, because it can be
                                // a floating-point literal
                buf[i] = (char)c;
                if( i >= MAX_ATOF )
                    return FX_SET_EXN_FAST(FX_EXN_OverflowError);
                r = r1;
            }
            if( !just_int && (c == '.' || c == 'e' || c == 'E') )
                flt = true;
        } else {
            for( i = 0; i < len; i++ ) {
                c = ptr[i];
                int digit = 0;
                if('0' <= c && c <= '9')
                    digit = (int)(c - '0');
                else if('a' <= c && c <= 'f')
                    digit = (int)(c - 'a' + 10);
                else if('A' <= c && c <= 'F')
                    digit = (int)(c - 'A' + 10);
                else
                    break;
                if(digit >= base)
                    break;
                r1 = r*base + digit;
                if (r1 < r) {
                    ok = false;
                    break;
                }
                r = r1;
            }
        }
    }

    if(!flt) {
        int bits=0;
        bool unsigned_ = false;
        if (get_suffix) {
            uint64_t maxval = (uint64_t)1 << (sizeof(size_t)*8-1);
            if( c == 'L' ) {
                bits = 128;
                i++;
            } else if( c == 'i' || c == 'I' || c == 'u' || c == 'U' ) {
                unsigned_ = c == 'u' || c == 'U';
                char_ c1 = i+1 < len ? ptr[i+1] : (char_)'\0';
                char_ c2 = i+2 < len ? ptr[i+2] : (char_)'\0';
                char_ c3 = i+3 < len ? ptr[i+3] : (char_)'\0';

                if(c1 == '8' && (c2 < '0' || '9' < c2)) {
                    bits = 8;
                    maxval = unsigned_ ? 255 : 128;
                    i += 2;
                } else if(c1 == '1' && c2 == '6' && (c3 < '0' || '9' < c3)) {
                    bits = 16;
                    maxval = unsigned_ ? 65535 : 32768;
                    i += 3;
                } else if(c1 == '3' && c2 == '2' && (c3 < '0' || '9' < c3)) {
                    bits = 32;
                    maxval = unsigned_ ? 0xFFFFFFFFULL : 0x80000000ULL;
                    i += 3;
                } else if(c1 == '6' && c2 == '4' && (c3 < '0' || '9' < c3)) {
                    bits = 64;
                    maxval = unsigned_ ? 0xFFFFFFFFFFFFFFFFULL : 0x8000000000000000ULL;
                    i += 3;
                } else
                    return FX_SET_EXN_FAST(FX_EXN_BadArgError);
            }
            if(bits <= 64 && (!ok || r > maxval))
                return FX_SET_EXN_FAST(FX_EXN_OutOfRangeError);
        }
        fx_result->t0 = (ptr - s->data) + i;
        fx_result->t1 = (int64_t)r;
        fx_result->t2 = 0.;
        fx_result->t3 = bits;
        fx_result->t4 = unsigned_ ? 'u' : 'i';
        return FX_OK;
    }

    for(; i < len; i++) {
        c = ptr[i];
        if('0' <= c && c <= '9') {
        } else if(c == '.') {
            if(have_e || have_dot)
                break;
            have_dot = true;
        } else if(c == 'e' || c == 'E') {
            if(have_e)
                break;
            have_e = true;
        } else if(c == '+' || c == '-') {
            if(i == 0 || (ptr[i-1] != 'e' && ptr[i-1] != 'E'))
                break;
        } else
            break;
        buf[i] = (char)c;
        if(i >= MAX_ATOF) {
            ok = false;
            break;
        }
    }

    if (ok) {
        int bits = 64;
        char* endptr = 0;
        buf[i] = '\0';
        fx_result->t2 = strtod(buf, &endptr);
        ok = endptr == buf + i;
        if (c == 'f' || c == 'F') {
            bits = 32;
            endptr++;
        } else if (c == 'h' || c == 'H') {
            bits = 16;
            endptr++;
        }
        fx_result->t0 = (ptr - s->data) + (endptr - buf);
        fx_result->t1 = 0;
        fx_result->t3 = bits;
        fx_result->t4 = 'f';
    }
    return ok ? FX_OK : FX_SET_EXN_FAST(FX_EXN_OverflowError);

}

FX_EXTERN_C int _fx_M10LexerUtilsFM10getstring_T4iSiB5SiCBB(
   fx_str_t* s,
   int_ pos,
   char_ term,
   bool raw,
   bool fmt,
   struct _fx_T4iSiB* fx_result,
   void* fx_fv)
{
   
int delta_lines = 0;
    int_ sz = 256, n = 0;
    char_ buf0[256 + 32];
    char_* buf = buf0;
    int_ i = 0, j, len = s->length - pos;
    const char_ *ptr = s->data + pos;
    char_ c;
    bool inline_exp = false;

    if(len <= 0)
        return FX_SET_EXN_FAST(FX_EXN_BadArgError);

    for( i = 0; i < len; i++ ) {
        c = ptr[i];
        if (c == term) {
            i++;
            break;
        }
        if (c == 92) { // backslash
            if ((i+1 < len && ptr[i+1] == 10) || (i+2 < len && ptr[i+1] == 13 && ptr[i+2] == 10)) {
                for (++i; i < len; i++) {
                    c = ptr[i];
                    if (c == 10) delta_lines++;
                    if (c != 32 && c != 9 && c != 10 && c != 13)
                        break;
                }
                i--;
                continue;
            }
            if(raw) {
                if (i+1 < len && (ptr[i+1] == 34 || ptr[i+1] == 39)) { // quote
                    buf[n++] = 92;
                    buf[n++] = ptr[i+1];
                    i++;
                } else
                    buf[n++] = (char_)92; // backslash
            }
            else {
                if(++i >= len)
                    return FX_SET_EXN_FAST(FX_EXN_OverflowError);
                c = ptr[i];
                if(c == 'n')
                    c = '\n';
                else if(c == 'r')
                    c = '\r';
                else if(c == 'e')
                    c = 27;
                else if(c == 't')
                    c = '\t';
                else if(c == 'b') // backspace
                    c = 8;
                else if(c == ' ')
                    c = ' ';
                else if(c == 39) // single quote
                    c = (char_)39;
                else if(c == 34) // double quote
                    c = (char_)34;
                else if(c == 92) // backslash
                    c = (char_)92;
                else if(c == 'x') {
                    int x0=0, x1=0;
                    if( i+2 >= len || (x0 = decodehex(ptr[i+1])) < 0 ||
                        (x1 = decodehex(ptr[i+2])) < 0 )
                        return FX_SET_EXN_FAST(FX_EXN_BadArgError);
                    c = x0*16+x1;
                    i++;
                } else if('0' <= c && c <= '7') {
                    c = 0;
                    for(j = 0; j < 4 && i < len; j++, i++) {
                        int d = decodeoct(ptr[i]);
                        if(d < 0)
                            break;
                        c = (char_)(c*8 + d);
                    }
                    if(i >= len)
                        return FX_SET_EXN_FAST(FX_EXN_BadArgError);
                    i--;
                } else if(c == 'u' || c == 'U') {
                    int K = c == 'u' ? 4 : 8;
                    c = 0;
                    i++;
                    for(j = 0; j < K && i < len; j++, i++) {
                        int x = decodehex(ptr[i]);
                        if(x < 0)
                            return FX_SET_EXN_FAST(FX_EXN_BadArgError);
                        c = (char_)(c*16 + x);
                    }
                    if(i >= len || c > 1114111)
                        return FX_SET_EXN_FAST(FX_EXN_BadArgError);
                    i--;
                } else
                    return FX_SET_EXN_FAST(FX_EXN_BadArgError);
                buf[n++] = c;
            }
        } else if(fmt && c == 123 && i+1 < len && ptr[i+1] != 34) { // { or {{
            if (ptr[i+1] == 123) { i++; buf[n++] = 123; }
            else {
                inline_exp = true;
                i++;
                break;
            }
        } else if(fmt && c == 125 && i+1 < len && ptr[i+1] == 125) { // }}
            i++; buf[n++] = 125;
        } else if(c == 10 || (c == 13 && i+1 < len && ptr[i+1] == 10)) {
            delta_lines += 1;
            i += c == 13;
            buf[n++] = 10;
        } else {
            buf[n++] = c;
        }
        if( n >= sz ) {
            sz = sz*3/2;
            char_* buf1 = (char_*)fx_malloc(sz*sizeof(buf[0]));
            if(buf1) memcpy(buf1, buf, n*sizeof(buf[0]));
            if(buf != buf0) fx_free(buf);
            buf = buf1;
            if(!buf1)
                return FX_SET_EXN_FAST(FX_EXN_OutOfMemError);
        }
    }
    if (i == len)
        return FX_SET_EXN_FAST(FX_EXN_OverflowError);
    int fx_status = fx_make_str(buf, n, &fx_result->t1);
    if(buf != buf0) fx_free(buf);
    fx_result->t0 = (ptr - s->data) + i;
    fx_result->t2 = delta_lines;
    fx_result->t3 = inline_exp;
    return fx_status;

}

FX_EXTERN_C int _fx_M10LexerUtilsFM9getstringT4iSiB6SiTa2iCBB(
   fx_str_t* s_0,
   int_ pos_0,
   struct _fx_Ta2i* loc_0,
   char_ term_0,
   bool raw_0,
   bool fmt_0,
   struct _fx_T4iSiB* fx_result,
   void* fx_fv)
{
   fx_exn_t exn_0 = {0};
   int fx_status = 0;
   FX_CALL(_fx_M10LexerUtilsFM10getstring_T4iSiB5SiCBB(s_0, pos_0, term_0, raw_0, fmt_0, fx_result, 0), _fx_catch_0);

_fx_catch_0: ;
   if (fx_status < 0) {
      fx_exn_get_and_reset(fx_status, &exn_0);
      fx_status = 0;
      _fx_free_T4iSiB(fx_result);
      int tag_0 = exn_0.tag;
      if (tag_0 == FX_EXN_OverflowError) {
         fx_exn_t v_0 = {0};
         fx_str_t slit_0 = FX_MAKE_STR("unterminated string");
         FX_CALL(_fx_M10LexerUtilsFM15make_LexerErrorE2Ta2iS(loc_0, &slit_0, &v_0), _fx_catch_1);
         FX_THROW(&v_0, true, _fx_catch_1);

      _fx_catch_1: ;
         fx_free_exn(&v_0);
      }
      else if (tag_0 == FX_EXN_BadArgError) {
         fx_exn_t v_1 = {0};
         fx_str_t slit_1 = FX_MAKE_STR("unvalid escape sequence");
         FX_CALL(_fx_M10LexerUtilsFM15make_LexerErrorE2Ta2iS(loc_0, &slit_1, &v_1), _fx_catch_2);
         FX_THROW(&v_1, true, _fx_catch_2);

      _fx_catch_2: ;
         fx_free_exn(&v_1);
      }
      else {
         fx_str_t v_2 = {0};
         fx_str_t v_3 = {0};
         fx_exn_t v_4 = {0};
         FX_CALL(_fx_F6stringS1E(&exn_0, &v_2, 0), _fx_catch_3);
         fx_str_t slit_2 = FX_MAKE_STR("exception ");
         fx_str_t slit_3 = FX_MAKE_STR(" occured when parsing string literal");
         {
            const fx_str_t strs_0[] = { slit_2, v_2, slit_3 };
            FX_CALL(fx_strjoin(0, 0, 0, strs_0, 3, &v_3), _fx_catch_3);
         }
         FX_CALL(_fx_M10LexerUtilsFM15make_LexerErrorE2Ta2iS(loc_0, &v_3, &v_4), _fx_catch_3);
         FX_THROW(&v_4, true, _fx_catch_3);

      _fx_catch_3: ;
         fx_free_exn(&v_4);
         FX_FREE_STR(&v_3);
         FX_FREE_STR(&v_2);
      }
      FX_CHECK_EXN(_fx_cleanup);
   }

_fx_cleanup: ;
   fx_free_exn(&exn_0);
   return fx_status;
}

FX_EXTERN_C int fx_init_LexerUtils(void)
{
   FX_REG_EXN("LexerUtils.LexerError", _FX_EXN_E22LexerUtils__LexerError, _fx_E22LexerUtils__LexerError_info,
      _fx_free_E22LexerUtils__LexerError);
   int fx_status = 0;
   return fx_status;
}

FX_EXTERN_C void fx_deinit_LexerUtils(void)
{

}

