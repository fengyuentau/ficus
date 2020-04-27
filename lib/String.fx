/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

// String operations
import List

ccode "#include <string.h>"

inline fun length(s: string) = Builtins.length(s)

nothrow pure fun empty(s: string): bool = ccode "return s->length == 0;"

pure nothrow fun startsWith(s: string, prefix: string): bool = ccode
    "
    int_ sz1 = s->length;
    int_ sz2 = prefix->length;
    return sz2 <= sz1 && memcmp(s->data, prefix->data,
                                (size_t)(sz2*sizeof(s->data[0]))) == 0;
    "

pure nothrow fun endsWith(s: string, suffix: string): bool = ccode
    "
    int_ sz1 = s->length;
    int_ sz2 = suffix->length;
    return sz2 <= sz1 && memcmp(s->data + (sz1 - sz2), suffix->data,
                                (size_t)(sz2*sizeof(s->data[0]))) == 0;
    "

pure nothrow fun find(s: string, part: string): int = ccode
    "
    int_ i, sz1 = s->length, sz2 = part->length, l = sz1 - sz2 + 1;
    if (sz2 == 0 || l <= 0)
        return 0;
    for( i = 0; i < l; i++ )
    {
        if( s->data[i] == part->data[0] &&
            memcmp(s->data + i, part->data, sz2*sizeof(part->data[0])) == 0)
            return i;
    }
    return -1;
    "

pure nothrow fun rfind(s: string, part: string): int = ccode
    "
    int_ sz1 = s->length, sz2 = part->length, pos = sz1 - sz2;
    for ( ; pos >= 0; pos--) {
        if( memcmp(s->data + pos, part->data, sz2*sizeof(part->data[0])) == 0)
            break;
    }
    return pos;
    "

pure fun tolower(s: string): string = ccode
    "
    int_ sz = s->length;
    int fx_status = fx_make_str(0, sz, fx_result);
    if( fx_status >= 0 )
    {
        char_* ptr = (char_*)fx_result->data;
        for (size_t i = 0; i < sz; i++)
            ptr[i] = fx_tolower(ptr[i]);
    }
    return fx_status;
    "

pure fun toupper(s: string): string = ccode
    "
    int_ sz = s->length;
    int fx_status = fx_make_str(0, sz, fx_result);
    if( fx_status >= 0 )
    {
        char_* ptr = (char_*)fx_result->data;
        for (size_t i = 0; i < sz; i++)
            ptr[i] = fx_toupper(ptr[i]);
    }
    return fx_status;
    "

pure fun lstrip(s: string): string = ccode
    "
    const char_* ptr = s->data;
    size_t sz = s->length;
    size_t i = 0;
    for (; i < sz && fx_isspace(ptr[i]); i++)
        ;
    return fx_substr(s, i, sz, fx_result);
    "

pure fun rstrip(s: string): string = ccode
    "
    const char_* ptr = s->data;
    size_t sz = s->length;
    for (; sz > 0 && fx_isspace(ptr[sz - 1]); sz--)
        ;
    return fx_substr(s, 0, sz, fx_result);
    "

pure fun strip(s: string): string = ccode
    "
    const char_* ptr = s->data;
    int_ i = 0, sz = s->length;
    for (; i < sz && fx_isspace(ptr[i]); i++)
        ;
    for (; sz > i && fx_isspace(ptr[sz - 1]); sz--)
        ;
    return fx_substr(s, i, sz, fx_result);
    "

fun join(sep: string, sl:string list)
{
    pure fun join_(sep: string, strs: string []): string = ccode
    "
    return fx_strjoin(sep, (fx_str_t*)strs->data, strs->dim[0].size, fx_result);
    "
    join_(sep, [for (s in sl) s])
}

pure nothrow fun isalpha(c: char): bool = ccode "return fx_isalpha(c);"
pure nothrow fun isalnum(c: char): bool = ccode "return fx_isalnum(c);"
pure nothrow fun isdigit(c: char): bool = ccode "return fx_isdigit(c);"
pure nothrow fun isdecimal(c: char): bool = ccode "return fx_isdecimal(c);"
pure nothrow fun isspace(c: char): bool = ccode "return fx_isspace(c);"
pure nothrow fun tolower(c: char): char = ccode "return fx_tolower(c);"
pure nothrow fun toupper(c: char): char = ccode "return fx_toupper(c);"
