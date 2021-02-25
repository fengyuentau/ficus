
/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

//////// ficus abstract syntax definition + helper structures and functions ////////

import Map, Set

/*
   we represent all the symbols in the code using Id.t variant, essentially, by a pair of integers <a, b>.
   Initially, b=0 (i.e. id ~ Id.Name(a)) and it represents the textual name as it occurs in the code, e.g. "i".
   "a" is the index in the array of strings that contains identifiers occured in the program.
   Later on, the type checker resolves the names and replaces b with
   some unique integer representing the particular object ("i") referenced in the particular
   context. For example:

   val i = 5
   val i = i + 1

   =>

   val i@100 : int = 5
   val i@101 : int = i@100 : int + 1

   (here i@100 means Id.Val(i, 100) and foo@101 means Id.Val(foo, 357), where i & foo are indices in the global
    table of symbolic names that corresponds to the abstract names "i", "foo", whereas 100 and 357
    are indices in the same table corresponding to the actually defined values.
    Internally the compiler uses unique names i@100 etc. to distinguish between values
    with the same name, but it uses the original names in error messages; it also uses the original name (i)
    to search for the symbol, i.e. Id.Name(f) can be matched with Id.Val(f, 12345) or Id.Val(f, 9876) or
    some other Id.Val(f, ...), depending on the current environment).

   There is a big global table of all symbols, so for each symbol we can retrieve its properties:
   the original name, inferred type, when and how it's defined.

   Sometimes we need a temporary value or a temporary function, i.e. when we do not have a user-specified
   name. In this case we use some common prefix, e.g. "t" for intermediate results in complex expressions,
   "lambda" for anonymous functions etc. but we represent the id as Id.Temp(prefix, N). Such id is
   always displayed as prefix@@N, e.g. "t@@1000" or "lambda@@777", and it can only be matched with
   itself (prefix@@N). That is, it's really unique.
*/

type id_t = IdName: int | IdVal: (int, int) | IdTemp: (int, int)

operator <=>(a: id_t, b: id_t) {
    | (IdName(a1), IdName(b1)) => a1 <=> b1
    | (IdVal(a1, a2), IdVal(b1, b2)) =>
        val d1 = a1 <=> b1
        if d1 != 0 {d1} else {a2 <=> b2}
    | (IdTemp(a1, a2), IdTemp(b1, b2)) =>
        val d1 = a1 <=> b1
        if d1 != 0 {d1} else {a2 <=> b2}
    | _ => a.__tag__ <=> b.__tag__
}

val noid = IdName(0)
val dummyid = IdName(1)

type scope_t =
    | ScBlock: int
    | ScLoop: (bool, int)
    | ScFold: int
    | ScArrMap: int
    | ScMap: int
    | ScTry: int
    | ScFun: id_t
    | ScClass: id_t
    | ScInterface: id_t
    | ScModule: id_t
    | ScGlobal

type loc_t =
{
    fname: id_t;
    line0: int;
    pos0: int;
    line1: int;
    pos1: int
}

val noloc = loc_t {fname=noid, line0=0, pos0=0, line1=0, pos1=0}
fun loclist2loc(llist: loc_t list, default_loc: loc_t) =
    fold loc = default_loc for loci <- llist {
        val {fname, line0, pos0, line1, pos1} = loc
        val {fname=loci_fname,
            line0=loci_line0, pos0=loci_pos0,
            line1=loci_line1, pos1=loci_pos1} = loci
        if fname != loci_fname {
            if fname == noid { loci } else { loc }
        } else {
            loc_t
            {
                fname=fname,
                line0=min(line0, loci_line0),
                pos0=min(pos0, loci_pos0),
                line1=max(line1, loci_line1),
                pos1=max(pos1, loci_pos1)
            }
        }
    }

fun get_start_loc(loc) {
    val {fname, line0, pos0, line1, pos1} = loc
    {fname=fname, line0=line0, pos0=pos0, line1=line0, pos1=pos0}
}

fun get_end_loc(loc: loc_t) {
    val {fname, line0, pos0, line1, pos1} = loc
    {fname=fname, line0=line1, pos0=pos1, line1=line1, pos1=pos1}
}

type lit_t =
    | LitInt: int64
    | LitSInt: (int, int64)
    | LitUInt: (int, int64)
    | LitFloat: (int, double)
    | LitString: string
    | LitChar: string
    | LitBool: bool
    | LitNil

type typ_t =
    | TypVar: typ_t? ref
    | TypVarTuple: typ_t?
    | TypVarArray: typ_t
    | TypVarRecord
    | TypInt
    | TypSInt: int
    | TypUInt: int
    | TypFloat: int
    | TypString
    | TypChar
    | TypBool
    | TypVoid
    | TypFun: (typ_t list, typ_t)
    | TypList: typ_t
    | TypTuple: typ_t list
    | TypRef: typ_t
    | TypArray: (int, typ_t)
    | TypRecord: ((id_t, typ_t, lit_t?) list, bool) ref
    | TypExn
    | TypErr
    | TypCPointer
    | TypApp: (typ_t list, id_t)
    | TypDecl
    | TypModule

fun make_new_typ() = TypVar(ref (None: typ_t?))

type binop_t = OpAdd | OpSub | OpMul | OpDiv | OpMod | OpPow
    | OpShiftLeft | OpShiftRight | OpDotMul | OpDotDiv | OpDotMod | OpDotPow
    | OpBitwiseAnd | OpLogicAnd | OpBitwiseOr | OpLogicOr | OpBitwiseXor
    | OpCompareEQ | OpCompareNE | OpCompareLT | OpCompareLE | OpCompareGT | OpCompareGE
    | OpDotCompareEQ | OpDotCompareNE | OpDotCompareLT | OpDotCompareLE
    | OpDotCompareGT | OpDotCompareGE | OpSpaceship | OpDotSpaceship | OpCons

type unop_t = OpPlus | OpNegate | OpDotMinus | OpBitwiseNot | OpLogicNot
    | OpMkRef | OpDeref | OpExpand | OpApos

type val_flags_t =
{
    val_flag_arg: bool = false;
    val_flag_mutable: bool = false;
    val_flag_temp: bool = false;
    val_flag_tempref: bool = false;
    val_flag_private: bool = false;
    val_flag_subarray: bool = false;
    val_flag_ctor: id_t;
    val_flag_global: scope_t list = []
}

fun default_val_flags() = val_flags_t {val_flag_ctor=noid}
fun default_arg_flags() = default_val_flags().{val_flag_arg=true}
fun default_var_flags() = default_val_flags().{val_flag_mutable=true}
fun default_tempval_flags() = default_val_flags().{val_flag_temp=true}
fun default_tempref_flags() = default_val_flags().{val_flag_tempref=true}
fun default_tempvaR_flags() = default_tempval_flags().{val_flag_mutable=true}

type fun_constr_t =
    | CtorNone
    | CtorStruct
    | CtorVariant: id_t
    | CtorFP: id_t
    | CtorExn: id_t

type fun_flags_t =
{
    fun_flag_pure: int=-1;
    fun_flag_ccode: bool=false;
    fun_flag_has_keywords: bool=false;
    fun_flag_inline: bool=false;
    fun_flag_nothrow: bool=false;
    fun_flag_really_nothrow: bool=false;
    fun_flag_private: bool=false;
    fun_flag_ctor: fun_constr_t;
    fun_flag_uses_fv: bool=false;
    fun_flag_recursive: bool=false
}

fun default_fun_flags() = fun_flags_t {fun_flag_ctor=CtorNone}

type for_make_t = ForMakeArray | ForMakeList | ForMakeTuple

type for_flags_t =
{
    for_flag_parallel: bool = false;
    for_flag_make: for_make_t;
    for_flag_unzip: bool = false;
    for_flag_fold: bool = false;
    for_flag_nested: bool = false
}

fun default_for_flags() =
{
    for_flag_parallel=false,
    for_flag_make=ForMakeArray,
    for_flag_unzip=false,
    for_flag_fold=false,
    for_flag_nested=false
}

type border_t =
    | BorderNone
    | BorderClip
    | BorderZero

type interpolate_t =
    | InterpNone
    | InterpLinear

type var_flags_t =
{
    var_flag_module: id_t;
    var_flag_record: bool = false;
    var_flag_recursive: bool = false;
    var_flag_have_tag: bool = false;
    var_flag_opt: bool = false
}

fun default_variant_flags() = var_flags_t {var_flag_module=noid}

type ctx_t = (typ_t, loc_t)

type exp_t =
    | ExpNop: loc_t
    | ExpBreak: (bool, loc_t)
    | ExpContinue: loc_t
    | ExpRange: (exp_t?, exp_t?, exp_t?, ctx_t)
    | ExpLit: (lit_t, ctx_t)
    | ExpIdent: (id_t, ctx_t)
    | ExpBinOp: (binop_t, exp_t, exp_t, ctx_t)
    | ExpUnOp: (unop_t, exp_t, ctx_t)
    | ExpSeq: (exp_t list, ctx_t)
    | ExpMkTuple: (exp_t list, ctx_t)
    | ExpMkArray: (exp_t list list, ctx_t)
    | ExpMkRecord: (exp_t, (id_t, exp_t) list, ctx_t)
    | ExpUpdateRecord: (exp_t, (id_t, exp_t) list, ctx_t)
    | ExpCall: (exp_t, exp_t list, ctx_t)
    | ExpAt: (exp_t, border_t, interpolate_t, exp_t list, ctx_t)
    | ExpAssign: (exp_t, exp_t, loc_t)
    | ExpMem: (exp_t, exp_t, ctx_t)
    | ExpThrow: (exp_t, loc_t)
    | ExpIf: (exp_t, exp_t, exp_t, ctx_t)
    | ExpWhile: (exp_t, exp_t, loc_t)
    | ExpDoWhile: (exp_t, exp_t, loc_t)
    | ExpFor: ((pat_t, exp_t) list, pat_t, exp_t, for_flags_t, loc_t)
    | ExpMap: (((pat_t, exp_t) list, pat_t) list, exp_t, for_flags_t, ctx_t)
    | ExpTryCatch: (exp_t, (pat_t list, exp_t) list, ctx_t)
    | ExpMatch: (exp_t, (pat_t list, exp_t) list, ctx_t)
    | ExpCast: (exp_t, typ_t, ctx_t)
    | ExpTyped: (exp_t, typ_t, ctx_t)
    | ExpCCode: (string, ctx_t)
    | DefVal: (pat_t, exp_t, val_flags_t, loc_t)
    | DefFun: deffun_t ref
    | DefExn: defexn_t ref
    | DefTyp: deftyp_t ref
    | DefVariant: defvariant_t ref
    | DefClass: defclass_t ref
    | DefInterface: definterface_t ref
    | DirImport: ((id_t, id_t) list, loc_t)
    | DirImportFrom: (id_t, id_t list, loc_t)
    | DirPragma: (string list, loc_t)

type pat_t =
    | PatAny: loc_t
    | PatLit: (lit_t, loc_t)
    | PatIdent: (id_t, loc_t)
    | PatTuple: (pat_t list, loc_t)
    | PatVariant: (id_t, pat_t list, loc_t)
    | PatRecord: (id_t?, (id_t, pat_t) list, loc_t)
    | PatCons: (pat_t, pat_t, loc_t)
    | PatAs: (pat_t, id_t, loc_t)
    | PatTyped: (pat_t, typ_t, loc_t)
    | PatWhen: (pat_t, exp_t, loc_t)
    | PatRef: (pat_t, loc_t)

type env_entry_t =
    | EnvId: id_t
    | EnvTyp: typ_t

/*
  Environment (env_t) is the mapping from id_t to env_entry_t list.
  It's the key data structure used by the type checker.

  That is, for each id Id.Name(i) (which corresponds to some abstract symbol <i>)
  we store a list of possible matches Id.Val(i, j) - the really defined symbols.
  When the key is Id.Temp(prefix, k), we can only have a single match Id.Temp(prefix, k).

  Why have a list of possible matches? Because:
   * in the nested scopes we can redefine a symbol from the outer scope
   * a defined value can be redefined later in the same block: val a = 5; val a = a + 1
   * we can have overloaded functions, e.g. sin:float->float and sin:double->double
   * types and functions/values with the same name can co-exist without conflicts, e.g.
     string type and string:'t->string functions.

  Note that we use purely-functional data structure (Map) to store the environment.
  Such immutable data structure let us forget about the neccesity to "undo" environment changes
  when we get back from the nested expression analysis, at the expense of slight loss in efficiency
  (however, the type checker is very inexpensive compiler stage, even in "-O0" compile mode)
*/
type env_t = (id_t, env_entry_t list) Map.map_t
type idset_t = id_t Set.set_t

type defval_t =
{
    dv_name: id_t; dv_typ: typ_t;
    dv_flags: val_flags_t;
    dv_scope: scope_t list;
    dv_loc: loc_t
}

type deffun_t =
{
    df_name: id_t; df_templ_args: id_t list;
    df_args: pat_t list; df_typ: typ_t; df_body: exp_t;
    df_flags: fun_flags_t; df_scope: scope_t list;
    df_loc: loc_t; df_templ_inst: id_t list ref; df_env: env_t
}

type defexn_t =
{
    dexn_name: id_t; dexn_typ: typ_t;
    dexn_scope: scope_t list; dexn_loc: loc_t
}

type deftyp_t =
{
    dt_name: id_t; dt_templ_args: id_t list;
    dt_typ: typ_t; dt_finalized: bool;
    dt_scope: scope_t list; dt_loc: loc_t
}

/* variants are represented in a seemingly complex but logical way;
   the structure contains the list of variant cases (dvar_cases, a list of (id_t, typ_t) pairs),
   as well as the variant constructors (dvar_ctors). Think of the id_t's in dvar_cases
   as of enumeration elements that represent different "tag" values.
   Whereas the constructors will eventually (in the final compiled code)
   become real functions that take the case arguments on input and return the variant instance.

   If the variant is generic, then it may have some instances,
   which are listed in dvar_templ_inst.
   In this case each constructor is also a generic function,
   which contains the corresponding list of instances as well.
   When variant type is instantiated, its instance is added to dvar_templ_list.
   Also, instances of all its constructors are created as well and added
   to the corresponding df_templ_inst' lists of the generic constructors.
*/
type defvariant_t =
{
    dvar_name: id_t; dvar_templ_args: id_t list;
    dvar_alias: typ_t; dvar_flags: var_flags_t;
    dvar_cases: (id_t, typ_t) list;
    dvar_ctors: id_t list; dvar_templ_inst: id_t list ref;
    dvar_scope: scope_t list; dvar_loc: loc_t
}

type defclass_t =
{
    dcl_name: id_t; dcl_templ_args: id_t list;
    dcl_typ: typ_t; dcl_ifaces: id_t list;
    dcl_args: pat_t list; dcl_members: exp_t list;
    dcl_templ_inst: id_t list ref;
    dcl_scope: scope_t list; dcl_loc: loc_t
}

type definterface_t =
{
    di_name: id_t; di_base: id_t; di_members: exp_t list;
    di_scope: scope_t list; di_loc: loc_t
}

type defmodule_t =
{
    dm_name: id_t; dm_filename: string;
    dm_defs: exp_t list ref; dm_idx: int;
    dm_deps: id_t list; dm_env: env_t;
    dm_parsed: bool
}

type pragmas_t =
{
    pragma_cpp: bool;
    pragma_clibs: (string, loc_t) list
}

type id_info_t =
    | IdNone
    | IdVal: defval_t
    | IdFun: deffun_t ref
    | IdExn: defexn_t ref
    | IdTyp: deftyp_t ref
    | IdVariant: defvariant_t ref
    | IdClass: defclass_t ref
    | IdInterface: definterface_t ref
    | IdModule: defmodule_t ref

type 't dynvec_t =
{
    count: int ref;
    data: 't [] ref;
    val0: 't
}

fun dynvec_create(v0: 't) = dynvec_t {
    count=0,
    data=ref (array(): 't []),
    val0=v0
}

fun dynvec_clear(v: 't dynvec_t) {
    v.count = 0
    *v.data = (array() : 't [])
}

fun dynvec_isempty(v: 't dynvec_t) = v.count == 0

fun dynvec_init(v: 't dynvec_t, n: int) {
    *v.count = n
    *v.data = array(n, v.val0)
}

fun dynvec_push(v: 't dynvec_t) {
    val sz = size(v.data)
    val n0 = *v.count
    if sz <= n0 {
        val n1 = max(n0, 128)*3/2
        val old_data = *v.data
        val new_data = [for i <- 0:n1 { if i < n0 {old_data[i]} else {v.val0}]
        v.data = new_data
    }
    val i = n0
    *v.count = n0 + 1
    i
}

fun dynvec_get(v: 't dynvec_t, i: int) = (*v.data)[i]
fun dynvec_set(v: 't dynvec_t, i: int, newv: 't) = (*v.data)[i] = newv

var all_ids = dynvec_create(IdNone)
var all_strhash = (Hashtbl.create(1000): (string, int) Hashtbl.t)
var all_strings = dynvec_create("")
val all_modules = (Hashtbl.create(100): (string, id_t) Hashtbl.t)
val sorted_modules = (ref []: id_t list ref)
val ids_frozen = ref true
fun freeze_ids(f) = *ids_frozen = f

fun new_id_idx() {
    if !*ids_frozen {}
    else {
        raise Fail("internal error: attempt to add new AST id during K-phase or C code generation phase")
    }
    dynvec_push(all_ids)
}

fun dump_id(i: id_t) {
    | IdName(i) => f"IdName(%d)", i)
    | IdVal(i, j) => f"IdVal(%d, %d)", i, j)
    | IdTemp(i, j) => f"IdTemp(%d, %d)", i, j)
}

fun id2str__(i: id_t, pp: bool, val_decor: string, temp_decor: string) =
    if i == noid { "<noid>" }
    else {
        val (infix, prefix, suffix) =
        match i {
        | IdName(i) => ("", i, -1)
        | IdVal(i, j) => (val_decor, i, j)
        | IdTemp(i, j) => (temp_decor, i, j)
        }
        val prefix = dynvec_get(all_strings, prefix)
        if pp || suffix < 0 { prefix }
        else { f"{prefix}{infix}{suffix}" }
    }

fun id2str_(i: id_t, pp: bool) = id2str__(i, pp, "@", "@@")

fun id2str(i) = id2str_(i, false)

fun pp_id2str(i) = id2str_(i, true)

exception SyntaxError: (string, Lexing.position, Lexing.position)
exception SyntaxErrorLoc: (string, loc_t)
fun loc2str(loc) = f"%s: %d", pp_id2str(loc.fname), loc.line0)

exception CompileError: (loc_t, string)
exception PropagateCompileError

var compile_errs = []: exn list
var compile_err_ctx = []: string list

fun raise_compile_err(loc: loc_t, msg: string) {
    val whole_msg = f"{loc2str(loc): error: {msg}"
    val whole_msg = match compile_err_ctx {
        | [] => whole_msg
        | ctx => "\n\t".concat(whole_msg :: ctx)
        }
    throw CompileError(loc, whole_msg)
}

fun push_compile_err(err: exn) {
    compile_errs = err :: compile_errs
}

fun check_compile_errs() =
    match compile_errs {
        | err :: _ => throw PropagateCompileError
        | _ => {}
    }

fun print_compile_err(err: exn) {
    | CompileError(loc, msg) => println(msg)
    | Failure(msg) => println(f"Failure: {msg}")
    | _ => println("\n\nException {err} occured")
}

fun pr_verbose(str: string) =
    if Options.verbose() {
        val eol = Utils.endswith(str, "\n") {""} else {"\n"}
        print(f"{str}{eol}")
    }
    File.flush_all()

fun id2prefix(i) {
    val prefix = match i {
                 | IdName(i) => i
                 | IdVal(i, _) => i
                 | IdTemp(i, _) => i
                 }
    dynvec_get(all_strings, prefix)
}

fun id2idx_(i, loc) =
    match i {
    | IdName(_) => raise_compile_err(loc, f"attempt to query information about unresolved '%s'", id2str(i)))
    | IdVal(_, i_real) => i_real
    | IdTemp(_, i_real) => i_real
    }

fun id2idx(i) = id2idx_(i, noloc)

fun id_info(i) = dynvec_get(all_ids, id2idx(i))

fun is_unique_id(i) = match i {
                      | IdName(_) => false
                      | _ => true
                      }

fun get_id_prefix(s) =
    match Hashtbl.find_all(all_strhash, s) {
    | idx :: _ => idx
    | _ => val idx = dynvec_push(all_strings)
           Hashtbl.add(all_strhash, s, idx)
           dynvec_set(all_strings, idx, s)
           idx
    }

fun get_id(s) {
    val i = get_id_prefix(s)
    IdName(i)
}

fun gen_temp_id(s) {
    val i_name = get_id_prefix(s)
    val i_real = new_id_idx()
    IdTemp((i_name, i_real))
}

fun dup_id(old_id) {
    val k = new_id_idx()
    match old_id {
    | IdName(i) => IdVal((i, k))
    | IdVal(i, _) => IdVal((i, k))
    | IdTemp(i, _) => IdTemp((i, k))
    }
}

fun get_orig_id(i: id_t) {
    | IdName(_) => i
    | IdVal(i, _) => IdName(i)
    | IdTemp(_, _) => i
}

fun set_id_entry(i, n) {
    val idx = id2idx(i)
    dynvec_set(all_ids, idx, n)
}

fun get_exp_ctx(e: exp_t) {
    | ExpNop(l) => (TypVoid, l)
    | ExpBreak(_, l) => (TypVoid, l)
    | ExpContinue(l) => (TypVoid, l)
    | ExpRange(_, _, _, c) => c
    | ExpLit(_, c) => c
    | ExpIdent(_, c) => c
    | ExpBinOp(_, _, _, c) => c
    | ExpUnOp(_, _, c) => c
    | ExpSeq(_, c) => c
    | ExpMkTuple(_, c) => c
    | ExpMkRecord(_, _, c) => c
    | ExpMkArray(_, c) => c
    | ExpUpdateRecord(_, _, c) => c
    | ExpCall(_, _, c) => c
    | ExpAt(_, _, _, _, c) => c
    | ExpAssign(_, _, l) => (TypVoid, l)
    | ExpMem(_, _, c) => c
    | ExpThrow(_, l) => (TypErr, l)
    | ExpIf(_, _, _, c) => c
    | ExpWhile(_, _, l) => (TypVoid, l)
    | ExpDoWhile(_, _, l) => (TypVoid, l)
    | ExpFor(_, _, _, _, l) => (TypVoid, l)
    | ExpMap(_, _, _, c) => c
    | ExpTryCatch(_, _, c) => c
    | ExpMatch(_, _, c) => c
    | ExpCast(_, _, c) => c
    | ExpTyped(_, _, c) => c
    | ExpCCode(_, c) => c
    | DefVal(_, _, _, dv_loc) => (TypDecl, dv_loc)
    | DefFun {ref {df_loc}} => (TypDecl, df_loc)
    | DefExn {ref {dexn_loc}} => (TypDecl, dexn_loc)
    | DefTyp {ref {dt_loc}} => (TypDecl, dt_loc)
    | DefVariant {ref {dvar_loc}} => (TypDecl, dvar_loc)
    | DefClass {ref {dcl_loc}} => (TypDecl, dcl_loc)
    | DefInterface {ref {di_loc}} => (TypDecl, di_loc)
    | DirImport(_, l) => (TypDecl, l)
    | DirImportFrom(_, _, l) => (TypDecl, l)
    | DirPragma(_, l) => (TypDecl, l)
}

fun get_exp_typ(e: exp_t) = get_exp_ctx(e).0
fun get_exp_loc(e: exp_t) = get_exp_ctx(e).1

fun get_pat_loc(p: pat_t) {
    | PatAny(l) => l
    | PatLit(_, l) => l
    | PatIdent(_, l) => l
    | PatTuple(_, l) => l
    | PatVariant(_, _, l) => l
    | PatRecord(_, _, l) => l
    | PatCons(_, _, l) => l
    | PatAs(_, _, l) => l
    | PatTyped(_, _, l) => l
    | PatRef(_, l) => l
    | PatWhen(_, _, l) => l
}

fun pat_skip_typed(p) = match p {
                        | PatTyped(p, _, _) => pat_skip_typed(p)
                        | _ => p
                        }

fun get_module(m) =
    match id_info(m) {
    | IdModule(minfo) => minfo
    | _ => failwith(f"internal error in process_all: %s is not a module", pp_id2str(m)))
    }

fun get_module_env(m) = *get_module(m).dm_env

fun find_module(mname_id, mfname) =
    try {
        get_module(Hashtbl.find(all_modules, mfname))
    } catch {
    | Not_found =>
        val m_fresh_id = dup_id(mname_id)
        val newmodule = ref {dm_name=m_fresh_id, dm_filename=mfname, dm_idx=-1, dm_defs=[], dm_deps=[], dm_env=Env.empty, dm_parsed=false}
        set_id_entry(m_fresh_id, IdModule(newmodule))
        Hashtbl.add(all_modules, mfname, m_fresh_id)
        newmodule
    }

val block_scope_idx = ref (-1)
fun new_block_scope() {
    *block_scope_idx = *block_scope_idx + 1
    ScBlock(*block_scope_idx)
}

fun new_loop_scope(nested) {
    *block_scope_idx = *block_scope_idx + 1
    ScLoop((nested, *block_scope_idx))
}

fun new_map_scope() {
    *block_scope_idx = *block_scope_idx + 1
    ScMap(*block_scope_idx)
}

fun new_arr_map_scope() {
    *block_scope_idx = *block_scope_idx + 1
    ScArrMap(*block_scope_idx)
}

fun new_fold_scope() {
    *block_scope_idx = *block_scope_idx + 1
    ScFold(*block_scope_idx)
}

fun new_try_scope() {
    *block_scope_idx = *block_scope_idx + 1
    ScTry(*block_scope_idx)
}

fun scope2str(sc: scope_t list) {
    | scj :: rest =>
        val prefix = match scj {
            | ScBlock(b) => f"block({b})" + scope2str(r)
            | ScLoop(f, b) =>
                val nested = if f {"nested_"} else {""}
                f"{nested}loop_block({b})"
            | ScArrMap(b) => f"arr_map_block({b})"
            | ScMap(b) :: r => f"map_block({b})"
            | ScFold(b) :: r => f"fold_block({b})"
            | ScTry(b) :: r => f"try_block({b})"
            | ScFun(f) :: r => f"fun({id2str(f)})"
            | ScClass(c) :: r => f"class({id2str(c)})"
            | ScInterface(i) :: r => f"interface({id2str(i)})"
            | ScModule(m) :: r => f"mod({id2str(m)})"
            | ScGlobal :: r => "global"
            }
        match rest {
        | _ :: _ => prefix + "." + scope2str(rest)
        | _ => prefix
        }
    | _ => ""
}

fun get_module_scope(sc: scope_t list) {
    | ScModule(_) :: _ => sc
    | ScGlobal :: _ | [] => sc
    | sc_top :: r => get_module_scope(r)
}

fun get_qualified_name(name: id_t, sc: scope_t list) =
    match sc {
    | (ScModule(m) :: _) when pp_id2str(m) == "Builtins" => name
    | ScModule(m) :: r => get_qualified_name(pp_id2str(m) + "." + name, r)
    | ScGlobal :: _ | [] => name
    | sc_top :: r => get_qualified_name(name, r)
    }

fun get_scope(id_info) =
    match id_info {
    | IdNone => ScGlobal :: []
    | IdVal {dv_scope} => dv_scope
    | IdFun {ref {df_scope}} => df_scope
    | IdExn {ref {dexn_scope}} => dexn_scope
    | IdTyp {ref {dt_scope}} => dt_scope
    | IdVariant {ref {dvar_scope}} => dvar_scope
    | IdClass {ref {dcl_scope}} => dcl_scope
    | IdInterface {ref {di_scope}} => di_scope
    | IdModule(_) => ScGlobal :: []
    }

fun get_idinfo_loc(id_info) =
    match id_info {
    | IdNone | IdModule(_) => noloc
    | IdVal {dv_loc} => dv_loc
    | IdFun {ref {df_loc}} => df_loc
    | IdExn {ref {dexn_loc}} => dexn_loc
    | IdTyp {ref {dt_loc}} => dt_loc
    | IdVariant {ref {dvar_loc}} => dvar_loc
    | IdClass {ref {dcl_loc}} => dcl_loc
    | IdInterface {ref {di_loc}} => di_loc
    }

fun get_idinfo_typ(id_info, loc) =
    match id_info {
    | IdNone => raise_compile_err(loc, "ast: attempt to request type of non-existing symbol")
    | IdModule(_) => TypModule
    | IdVal {dv_typ} => dv_typ
    | IdFun {ref {df_typ}} => df_typ
    | IdExn {ref {dexn_typ}} => dexn_typ
    | IdTyp {ref {dt_typ}} => dt_typ
    | IdVariant {ref {dvar_alias}} => dvar_alias
    | IdClass {ref {dcl_typ}} => dcl_typ
    | IdInterface {ref {di_name}} => TypApp(([], di_name))
    }

fun get_id_typ(i: id_t, loc: loc_t) =
    match i {
    | IdName(_) => make_new_typ()
    | _ => get_idinfo_typ(id_info(i), loc)
    }

fun get_lit_typ(l: lit_t) {
    | LitInt(_) => TypInt
    | LitSInt(b, _) => TypSInt(b)
    | LitUInt(b, _) => TypUInt(b)
    | LitFloat(b, _) => TypFloat(b)
    | LitString(_) => TypString
    | LitChar(_) => TypChar
    | LitBool(_) => TypBool
    | LitNil => TypList(make_new_typ())
}

/* shorten type specification by redirecting the references in TypVar
   to the "root" of each connected component tree - a cluster of equivalent/unified types.
   In other words, if we had
   t -> t2 -> t3 ... -> root
   before the call, after the call we will have
   t -> root, t2 -> root, t3 -> root, ...
   Returns the root. */
fun deref_typ(t: typ_t) {
    | TypVar(_) =>
        fun find_root(t: typ_t) {
            | TypVar (ref (Some(TypVarArray(_))) => t
            | TypVar (ref (Some(TypVarTuple(_))) => t
            | TypVar (ref (Some(TypVarRecord)) => t
            | TypVar (ref (Some(t2)) => find_root(t2)
            | _ => t
        }

        val root = find_root(t)
        fun update_refs(t: typ_t) {
            | TypVar(ref(Some(TypVar(ref Some(_)) as t1)) as r) =>
                *r = Some(root); update_refs(t1)
            | _ => root
        }
        update_refs(t)
    | _ => t
}

fun is_typ_scalar(t: typ_t) {
    | TypInt | TypSInt(_, _) | TypUInt(_, _) | TypFloat(_, _) | TypBool | TypChar => true
    | _ => false
}

fun is_typ_numeric(t: typ_t, allow_vec_tuples: bool) =
    match deref_typ(t) {
    | TypInt | TypSInt(_) | TypUInt(_) | TypFloat(_) => true
    | TypTuple(t0 :: trest) =>
        if allow_vec_tuples && is_typ_numeric(t0, true) {
            val t0 = deref_typ(t0)
            fold all=true for t in trest {if deref_typ(t) != t0 {break with false}; true}
        }
    | _ => false
    }

fun string(bop: binop_t) {
    | OpAdd => "+"
    | OpSub => "-"
    | OpMul => "*"
    | OpDiv => "/"
    | OpMod => "%"
    | OpPow => "**"
    | OpDotMul => ".*"
    | OpDotDiv => "./"
    | OpDotMod => ".%"
    | OpDotPow => ".**"
    | OpShiftLeft => "<<"
    | OpShiftRight => ">>"
    | OpBitwiseAnd => "&"
    | OpLogicAnd => "&&"
    | OpBitwiseOr => "|"
    | OpLogicOr => "||"
    | OpBitwiseXor => "^"
    | OpSpaceship => "<=>"
    | OpCompareEQ => "=="
    | OpCompareNE => "!="
    | OpCompareLE => "<="
    | OpCompareGE => ">="
    | OpCompareLT => "<"
    | OpCompareGT => ">"
    | OpDotSpaceship => ".<=>"
    | OpDotCompareEQ => ".=="
    | OpDotCompareNE => ".!="
    | OpDotCompareLE => ".<="
    | OpDotCompareGE => ".>="
    | OpDotCompareLT => ".<"
    | OpDotCompareGT => ".>"
    | OpCons => "::"
}

fun unop_to_string(uop: unop_t) {
    | OpPlus => "+"
    | OpNegate => "-"
    | OpDotMinus => ".-"
    | OpBitwiseNot => "~"
    | OpLogicNot => "!"
    | OpExpand => "\\"
    | OpMkRef => "REF"
    | OpDeref => "*"
    | OpApos => "'"
}

fun border2str(border: border_t, f: bool) {
    val pt = if f {"."} else {""}
    match (border, f) {
    | (BorderNone, _) => ""
    | (BorderClip, _) => pt + ".clip"
    | (BorderZero, _) => pt + ".zero"
    }
}

fun interp2str(interp: interpolate_t, f: bool) {
    match (interp, f) {
    | (InterpNone, true) => ""
    | (InterpNone, _) => "NONE"
    | (InterpLinear, _) => pt + "LINEAR"
    }
}

fun fname_op_apos() = get_id("__apos__")
fun fname_op_add() = get_id("__add__")
fun fname_op_sub() = get_id("__sub__")
fun fname_op_mul() = get_id("__mul__")
fun fname_op_div() = get_id("__div__")
fun fname_op_mod() = get_id("__mod__")
fun fname_op_pow() = get_id("__pow__")
fun fname_op_dot_mul() = get_id("__dot_mul__")
fun fname_op_dot_div() = get_id("__dot_div__")
fun fname_op_dot_mod() = get_id("__dot_mod__")
fun fname_op_dot_pow() = get_id("__dot_pow__")
fun fname_op_shl() = get_id("__shl__")
fun fname_op_shr() = get_id("__shr__")
fun fname_op_bit_and() = get_id("__bit_and__")
fun fname_op_bit_or() = get_id("__bit_or__")
fun fname_op_bit_xor() = get_id("__bit_xor__")
fun fname_op_cmp() = get_id("__cmp__")
fun fname_op_eq() = get_id("__eq__")
fun fname_op_ne() = get_id("__ne__")
fun fname_op_lt() = get_id("__lt__")
fun fname_op_gt() = get_id("__gt__")
fun fname_op_le() = get_id("__le__")
fun fname_op_ge() = get_id("__ge__")
fun fname_op_dot_cmp() = get_id("__dot_cmp__")
fun fname_op_dot_eq() = get_id("__dot_eq__")
fun fname_op_dot_ne() = get_id("__dot_ne__")
fun fname_op_dot_lt() = get_id("__dot_lt__")
fun fname_op_dot_gt() = get_id("__dot_gt__")
fun fname_op_dot_le() = get_id("__dot_le__")
fun fname_op_dot_ge() = get_id("__dot_ge__")
fun fname_op_plus() = get_id("__plus__")
fun fname_op_negate() = get_id("__negate__")
fun fname_op_dot_minus() = get_id("__dot_minus__")
fun fname_op_bit_not() = get_id("__bit_not__")
fun fname_to_int() = get_id("int")
fun fname_to_uint8() = get_id("uint8")
fun fname_to_int8() = get_id("int8")
fun fname_to_uint16() = get_id("uint16")
fun fname_to_int16() = get_id("int16")
fun fname_to_uint32() = get_id("uint32")
fun fname_to_int32() = get_id("int32")
fun fname_to_uint64() = get_id("uint64")
fun fname_to_int64() = get_id("int64")
fun fname_to_float() = get_id("float")
fun fname_to_double() = get_id("double")
fun fname_to_bool() = get_id("bool")
fun fname_string() = get_id("string")
fun fname_repr() = get_id("repr")

fun binop_try_remove_dot(bop: binop_t) =
    match bop {
    | OpDotMul => OpMul
    | OpDotDiv => OpDiv
    | OpDotMod => OpMod
    | OpDotPow => OpPow
    | OpDotSpaceship => OpSpaceship
    | OpDotCompareEQ => OpCompareEQ
    | OpDotCompareNE => OpCompareNE
    | OpDotCompareLE => OpCompareLE
    | OpDotCompareGE => OpCompareGE
    | OpDotCompareLT => OpCompareLT
    | OpDotCompareGT => OpCompareGT
    | _ => bop
    }

fun get_binop_fname(bop: binop_t, loc: loc_t) =
    match bop {
    | OpAdd => fname_op_add()
    | OpSub => fname_op_sub()
    | OpMul => fname_op_mul()
    | OpDiv => fname_op_div()
    | OpMod => fname_op_mod()
    | OpPow => fname_op_pow()
    | OpDotMul => fname_op_dot_mul()
    | OpDotDiv => fname_op_dot_div()
    | OpDotMod => fname_op_dot_mod()
    | OpDotPow => fname_op_dot_pow()
    | OpShiftLeft => fname_op_shl()
    | OpShiftRight => fname_op_shr()
    | OpBitwiseAnd => fname_op_bit_and()
    | OpBitwiseOr => fname_op_bit_or()
    | OpBitwiseXor => fname_op_bit_xor()
    | OpSpaceship => fname_op_cmp()
    | OpCompareEQ => fname_op_eq()
    | OpCompareNE => fname_op_ne()
    | OpCompareLE => fname_op_le()
    | OpCompareGE => fname_op_ge()
    | OpCompareLT => fname_op_lt()
    | OpCompareGT => fname_op_gt()
    | OpDotSpaceship => fname_op_dot_cmp()
    | OpDotCompareEQ => fname_op_dot_eq()
    | OpDotCompareNE => fname_op_dot_ne()
    | OpDotCompareLE => fname_op_dot_le()
    | OpDotCompareGE => fname_op_dot_ge()
    | OpDotCompareLT => fname_op_dot_lt()
    | OpDotCompareGT => fname_op_dot_gt()
    | OpLogicAnd | OpLogicOr | OpCons =>
        raise_compile_err(loc, f"for binary operation \"%s\" there is no corresponding function", binop_to_string(bop)))
    }

fun get_unop_fname(uop, loc) =
    match uop {
    | OpApos => fname_op_apos()
    | OpPlus => fname_op_plus()
    | OpNegate => fname_op_negate()
    | OpDotMinus => fname_op_dot_minus()
    | OpBitwiseNot => fname_op_bit_not()
    | OpLogicNot | OpExpand | OpMkRef | OpDeref =>
        raise_compile_err(loc, f"for unary operation \"%s\" there is no corresponding function", unop_to_string(uop)))
    }

fun fname_always_import() = [:
    fname_op_add(), fname_op_sub(), fname_op_mul(), fname_op_div(),
    fname_op_mod(), fname_op_pow(), fname_op_dot_mul(), fname_op_dot_div(),
    fname_op_dot_mod(), fname_op_dot_pow(), fname_op_shl(), fname_op_shr(),
    fname_op_bit_and(), fname_op_bit_or(), fname_op_bit_xor(), fname_op_cmp(),
    fname_op_dot_cmp(), fname_op_eq(), fname_op_ne(), fname_op_le(),
    fname_op_ge(), fname_op_lt(), fname_op_gt(),
    fname_op_dot_eq(), fname_op_dot_ne(), fname_op_dot_le(),
    fname_op_dot_ge(), fname_op_dot_lt(), fname_op_dot_gt(),
    fname_op_plus(), fname_op_negate(), fname_op_dot_minus(),
    fname_op_bit_not(), fname_op_apos(),
    fname_to_int(), fname_to_uint8(), fname_to_int8(), fname_to_uint16(),
    fname_to_int16(), fname_to_uint32(), fname_to_int32(), fname_to_uint64(),
    fname_to_int64(), fname_to_float(), fname_to_double(), fname_to_bool(),
    fname_string(), fname_repr()
:]

fun init_all_ids() {
    freeze_ids(false)
    dynvec_clear(all_ids)
    Hashtbl.reset(all_strhash)
    get_id_prefix("")
    get_id_prefix("_")
    fname_always_import()
}

val reserved_keywords = Hashtbl.create(1001)
for kwd <- [: "fx_result", "fx_status", "fx_fv" :] {
    Hashtbl.add(reserved_keywords, kwd, 1)
}

val builtin_exceptions = (id_t, id_t) Map.map_t (Hashtbl.create(101): (id_t, id_t) Hashtbl.t)
fun get_builtin_exception(n0: id_t, loc: loc_t) =
    match Hashtbl.find_all(builtin_exceptions, n0) {
    | n :: _ => n
    | _ => raise_compile_err(loc, f"cannot find built-in exception '%s'", id2str(n0)))
    }

fun is_fun_ctor(flags) = flags.fun_flag_ctor != CtorNone

fun ctor2str(f) =
    if f == CtorNone {
        "not_a_constructor"
    } else {
        val s = match f {
            | CtorNone => ""
            | CtorStruct => "record_or_tuple"
            | CtorVariant(i) => f"variant(%s)", id2str(i))
            | CtorFP(i) => f"fp(%s)", id2str(i))
            | CtorExn(i) => f"exn(%s)", id2str(i))
        }
        "Constructor(" + s + ")"
    }

fun lit2str(c: lit_t, cmode: bool, loc: loc_t) {
    fun add_dot(s, suffix) =
        if s.contains('.') || s.contains('e') { s+suffix }
        else { s + "." + suffix }

    match c {
    | LitInt(v) => f"%Li", v)
    | LitSInt(64, v) => if cmode {
                            f"%LiLL", v)
                        } else {
                            f"%Lii%d", v, 64)
                        }
    | LitUInt(64, v) => if cmode {
                            f"%LiULL", v)
                        } else {
                            f"%Lii%d", v, 64)
                        }
    | LitSInt(b, v) => if cmode {
                           f"%Li", v)
                       } else {
                           f"%Lii%d", v, b)
                       }
    | LitUInt(b, v) => if cmode {
                           f"%LuU", v)
                       } else {
                           f"%Luu%d", v, b)
                       }
    | LitFloat(16, v) => val s = f"%.4g", v)
                         add_dot(s, "h")
    | LitFloat(32, v) => val s = f"%.8g", v)
                         add_dot(s, "f")
    | LitFloat(64, v) => val s = f"%.16g", v)
                         add_dot(s, "")
    | LitFloat(b, v) => raise_compile_err(loc, f"invalid literal LitFloat(%d, %.16g)", b, v))
    | LitString(s) => "\"" + Utils.escaped_uni(s) + "\""
    | LitChar(c) => "\'" + Utils.escaped_uni(c) + "\'"
    | LitBool(true) => "true"
    | LitBool(false) => "false"
    | LitNil => "nullptr"
    }
}

fun print_idset(setname, s) {
    printf("%s:[", setname)
    IdSet.iter(fun (i) {
                   printf(" %s", id2str(i))
        }, s)
    printf(" ]\n")
}

val parser_ctx_module = ref noid
val parser_ctx_file = ref noid
val parser_ctx_deps = ref ([]: id_t list)
val parser_ctx_inc_dirs = ref ([]: string list)
val parser_ctx_module_idx = ref (-1)
fun add_to_imported_modules(mname_id, (pos0, pos1)) {
    val mname = pp_id2str(mname_id)
    match Utils.locate_module_file(mname, *parser_ctx_inc_dirs) {
    | Some(mfname) =>
        val dep_minfo = find_module(mname_id, mfname)
        val mname_unique_id = *dep_minfo.dm_name
        *parser_ctx_deps = mname_unique_id :: *parser_ctx_deps
        mname_unique_id
    | _ => throw SyntaxError(("module " + mname + " is not found", pos0, pos1))
    }
}

fun typ2str(t) =
    match t {
    | TypVarTuple(Some(t)) => f"(%s ...)", typ2str(t))
    | TypVarTuple(_) => "(...)"
    | TypVarArray(t) => f"%s [+]", typ2str(t))
    | TypVarRecord => "{...}"
    | TypVar {ref Some(t)} => typ2str(t)
    | TypVar(_) => "<unknown>"
    | TypApp([], i) => id2str(i)
    | TypApp(tl, i) => f"%s %s", tl2str(tl), id2str(i))
    | TypInt => "int"
    | TypSInt(n) => f"int%d", n)
    | TypUInt(n) => f"uint%d", n)
    | TypFloat(n) =>
        match n {
        | 16 => "half"
        | 32 => "float"
        | 64 => "double"
        | _ => raise_compile_err(noloc, f"bad floating-point type TypFloat(%d)", n))
        }
    | TypVoid => "void"
    | TypBool => "bool"
    | TypChar => "char"
    | TypString => "string"
    | TypCPointer => "cptr"
    | TypFun(argtyps, rt) => "(" + tl2str(argtyps) + " -> " + typ2str(rt) + ")"
    | TypTuple(tl) => val s = tl2str(tl)
                      match tl {
                      | x :: [] => "(" + s + ",)"
                      | _ => s
                      }
    | TypRecord {ref (relems, _)} => "{" + String.concat("; ", [: for (i, t, _) <- relems {
                                                                   id2str(i) + ": " + typ2str(t)
                                               } :]) + "}"
    | TypArray(d, t) => f"%s [%s]", typ2str(t), String.make(d - 1, ','))
    | TypList(t) => typ2str(t) + " list"
    | TypRef(t) => typ2str(t) + " ref"
    | TypExn => "exn"
    | TypErr => "<err>"
    | TypDecl => "<decl>"
    | TypModule => "<module>"
    }
fun tl2str(tl) {
    val s = String.concat(", ", [: for t <- tl {
                                    typ2str(t)
                } :])
    match tl {
    | x :: [] => s
    | _ => "(" + s + ")"
    }
}

fun parse_pragmas(prl) {
    val clib_regexp = Str.regexp("clib *: *\\([_A-Za-z0-9\\-\\.]+\\) *")
    fun parse(prl, result) =
        match prl {
        | (pr, loc) :: rest =>
            if pr == "c++" || pr == "C++" {
                parse(rest, result.{pragma_cpp=true})
            } else if Str.string_match(clib_regexp, pr, 0) {
                val libname = Str.matched_group(1, pr)
                parse(rest, result.{pragma_clibs=(libname, loc) :: result.pragma_clibs})
            } else {
                raise_compile_err(loc, f"unrecognized pragma '%s'", pr))
            }
        | [] => result
        }

    parse(prl, {pragma_cpp=false, pragma_clibs=[]})
}

type ast_callb_t =
    {acb_typ: (typ_t -> ast_callb_t -> typ_t) option; acb_exp: (exp_t -> ast_callb_t -> exp_t) option; acb_pat:
        (pat_t -> ast_callb_t -> pat_t) option}

fun check_n_walk_typ(t: typ_t, callb: ast_callb_t) =
    match callb.acb_typ {
    | Some(f) => f(t, callb)
    | _ => walk_typ(t, callb)
    }
fun check_n_walk_tlist(tlist: typ_t list, callb: ast_callb_t) =
    [: for t <- tlist {check_n_walk_typ(t, callb)} :]
fun check_n_walk_exp(e: exp_t, callb) = match callb.acb_exp {
                                 | Some(f) => f(e, callb)
                                 | _ => walk_exp(e, callb)
                                 }
fun check_n_walk_elist(elist, callb) =
    [: for e <- elist { check_n_walk_exp(e, callb) } :]
fun check_n_walk_pat(p: pat_t, callb) = match callb.acb_pat {
                                 | Some(f) => f(p, callb)
                                 | _ => walk_pat(p, callb)
                                 }
fun check_n_walk_plist(plist, callb) = [: for p <- plist {
                                           check_n_walk_pat(p, callb)
    } :]
fun walk_typ(t, callb) {
    fun walk_typ_(t) = check_n_walk_typ(t, callb)

    fun walk_tl_(tl) = check_n_walk_tlist(tl, callb)

    match t {
    | TypVar(r) => match *r {
                   | Some(t) => val t1 = walk_typ_(t)
                                *r = Some(t1)
                   | _ => {}
                   }
                   t
    | TypInt => t
    | TypSInt(_) => t
    | TypUInt(_) => t
    | TypFloat(_) => t
    | TypString => t
    | TypChar => t
    | TypBool => t
    | TypVoid => t
    | TypFun(args, rt) => TypFun((walk_tl_(args), walk_typ_(rt)))
    | TypList(t) => TypList(walk_typ_(t))
    | TypTuple(tl) => TypTuple(walk_tl_(tl))
    | TypVarTuple(t_opt) => TypVarTuple(match t_opt {
                                        | Some(t) => Some(walk_typ_(t))
                                        | _ => None
                                        })
    | TypRef(t) => TypRef(walk_typ_(t))
    | TypArray(d, et) => TypArray((d, walk_typ_(et)))
    | TypVarArray(et) => TypVarArray(walk_typ_(et))
    | TypVarRecord => t
    | TypRecord({ref (relems, ordered)} as r) => val new_relems = [: for (n, t, v) <- relems {
                                                                    (n, walk_typ_(t), v)
                                                 } :]
                                                 *r = (new_relems, ordered)
                                                 t
    | TypExn => t
    | TypErr => t
    | TypCPointer => t
    | TypApp(ty_args, n) => TypApp((walk_tl_(ty_args), n))
    | TypDecl => t
    | TypModule => t
    }
}
fun walk_exp(e, callb) {
    fun walk_typ_(t) = check_n_walk_typ(t, callb)
    fun walk_exp_(e) = check_n_walk_exp(e, callb)
    fun walk_elist_(el) = check_n_walk_elist(el, callb)
    fun walk_pat_(p) = check_n_walk_pat(p, callb)
    fun walk_plist_(pl) = check_n_walk_plist(pl, callb)
    fun walk_pe_l_(pe_l) = [: for (p, e) <- pe_l { (walk_pat_(p), walk_exp_(e)) } :]
    fun walk_ne_l_(ne_l) = [: for (n, e) <- ne_l { (n, walk_exp_(e)) } :]
    fun walk_cases_(ple_l) = [: for (pl, e) <- ple_l { (walk_plist_(pl), walk_exp_(e)) } :]

    fun walk_exp_opt_(e_opt: exp_t?) {
        | Some(e) => Some(walk_exp_(e))
        | _ => None
    }

    fun walk_ctx_((t, loc): ctx_t) = (walk_typ_(t), loc)

    match e {
    | ExpNop(_) => e
    | ExpBreak(_) => e
    | ExpContinue(_) => e
    | ExpRange(e1_opt, e2_opt, e3_opt, ctx) => ExpRange((walk_exp_opt_(e1_opt), walk_exp_opt_(e2_opt), walk_exp_opt_(e3_opt), walk_ctx_(ctx)))
    | ExpLit(l, ctx) => ExpLit((l, walk_ctx_(ctx)))
    | ExpIdent(n, ctx) => ExpIdent((n, walk_ctx_(ctx)))
    | ExpBinOp(bop, e1, e2, ctx) => ExpBinOp((bop, walk_exp_(e1), walk_exp_(e2), walk_ctx_(ctx)))
    | ExpUnOp(uop, e, ctx) => ExpUnOp((uop, walk_exp_(e), walk_ctx_(ctx)))
    | ExpSeq(elist, ctx) => ExpSeq((walk_elist_(elist), walk_ctx_(ctx)))
    | ExpMkTuple(elist, ctx) => ExpMkTuple((walk_elist_(elist), walk_ctx_(ctx)))
    | ExpMkArray(ell, ctx) => ExpMkArray((ell.map(walk_elist_), walk_ctx_(ctx)))
    | ExpMkRecord(e, ne_l, ctx) => ExpMkRecord((walk_exp_(e), walk_ne_l_(ne_l), walk_ctx_(ctx)))
    | ExpUpdateRecord(e, ne_l, ctx) => ExpUpdateRecord((walk_exp_(e), walk_ne_l_(ne_l), walk_ctx_(ctx)))
    | ExpCall(f, args, ctx) => ExpCall((walk_exp_(f), walk_elist_(args), walk_ctx_(ctx)))
    | ExpAt(arr, border, interp, idx, ctx) => ExpAt((walk_exp_(arr), border, interp, walk_elist_(idx), walk_ctx_(ctx)))
    | ExpAssign(lv, rv, loc) => ExpAssign((walk_exp_(lv), walk_exp_(rv), loc))
    | ExpMem(a, member, ctx) => ExpMem((walk_exp_(a), walk_exp_(member), walk_ctx_(ctx)))
    | ExpThrow(a, loc) => ExpThrow((walk_exp_(a), loc))
    | ExpIf(c, then_e, else_e, ctx) => ExpIf((walk_exp_(c), walk_exp_(then_e), walk_exp_(else_e), walk_ctx_(ctx)))
    | ExpWhile(c, e, loc) => ExpWhile((walk_exp_(c), walk_exp_(e), loc))
    | ExpDoWhile(e, c, loc) => ExpDoWhile((walk_exp_(e), walk_exp_(c), loc))
    | ExpFor(pe_l, idx_pat, body, flags, loc) => ExpFor((walk_pe_l_(pe_l), walk_pat_(idx_pat), walk_exp_(body), flags, loc))
    | ExpMap(pew_ll, body, flags, ctx) =>
        ExpMap((pew_ll.map((fun ((pe_l, idx_pat)) {
                                walk_pe_l_(pe_l)
                               }, walk_pat_(idx_pat))), walk_exp_(body), flags, walk_ctx_(ctx)))
    | ExpTryCatch(e, cases, ctx) => ExpTryCatch((walk_exp_(e), walk_cases_(cases), walk_ctx_(ctx)))
    | ExpMatch(e, cases, ctx) => ExpMatch((walk_exp_(e), walk_cases_(cases), walk_ctx_(ctx)))
    | ExpCast(e, t, ctx) => ExpCast((walk_exp_(e), walk_typ_(t), walk_ctx_(ctx)))
    | ExpTyped(e, t, ctx) => ExpTyped((walk_exp_(e), walk_typ_(t), walk_ctx_(ctx)))
    | ExpCCode(str, ctx) => ExpCCode((str, walk_ctx_(ctx)))
    | DefVal(p, v, flags, loc) => DefVal((walk_pat_(p), walk_exp_(v), flags, loc))
    | DefFun(df) =>
        if *df.df_templ_args != [] {
            e
        } else {
            val {df_args, df_typ, df_body} = *df
            *df = df->{df_args=walk_plist_(df_args), df_typ=walk_typ_(df_typ), df_body=walk_exp_(df_body)}
            e
        }
    | DefExn(de) => val {dexn_typ} = *de
                    *de = de->{dexn_typ=walk_typ_(dexn_typ)}
                    e
    | DefTyp(dt) => val {dt_typ} = *dt
                    *dt = dt->{dt_typ=walk_typ_(dt_typ)}
                    e
    | DefVariant(dvar) =>
        val {dvar_alias, dvar_cases} = *dvar
        *dvar = dvar->{dvar_alias=walk_typ_(dvar_alias), dvar_cases=[: for (n, t) <- dvar_cases {
                                                                    (n, walk_typ_(t))
                                                         } :]}
        e
    | DefClass(dc) => e
    | DefInterface(di) => e
    | DirImport(_, _) => e
    | DirImportFrom(_, _, _) => e
    | DirPragma(_, _) => e
    }
}
fun walk_pat(p, callb) {
    fun walk_typ_(t) = check_n_walk_typ(t, callb)

    fun walk_pat_(p) = check_n_walk_pat(p, callb)

    fun walk_pl_(p) = check_n_walk_plist(p, callb)

    match p {
    | PatAny(_) => p
    | PatLit(_) => p
    | PatIdent(_) => p
    | PatTuple(pl, loc) => PatTuple((walk_pl_(pl), loc))
    | PatVariant(n, args, loc) => PatVariant((n, walk_pl_(args), loc))
    | PatRecord(n_opt, np_l, loc) => PatRecord((n_opt, [: for (n, p) <- np_l {
                                                           (n, walk_pat_(p))
                                                   } :], loc))
    | PatCons(p1, p2, loc) => PatCons((walk_pat_(p1), walk_pat_(p2), loc))
    | PatAs(p, n, loc) => PatAs((walk_pat_(p), n, loc))
    | PatTyped(p, t, loc) => PatTyped((walk_pat_(p), walk_typ_(t), loc))
    | PatWhen(p, e, loc) => PatWhen((walk_pat_(p), check_n_walk_exp(e, callb), loc))
    | PatRef(p, loc) => PatRef((walk_pat_(p), loc))
    }
}

fun dup_typ_(t, callb) =
    match t {
    | TypVar {ref Some(t1)} => TypVar(ref Some(dup_typ_(t1, callb)))
    | TypVar(_) => TypVar(ref None)
    | TypRecord(r) =>
        val (relems, ordered) = *r
        val new_relems = [: for (n, t, v) <- relems {
                             (n, dup_typ_(t, callb), v)
        } :]
        TypRecord(ref (new_relems, ordered))
    | _ => walk_typ(t, callb)
    }

fun dup_exp_(e, callb) =
    match e {
    | DefFun(r) => walk_exp(DefFun(ref (*r)), callb)
    | DefExn(r) => walk_exp(DefExn(ref (*r)), callb)
    | DefTyp(r) => walk_exp(DefTyp(ref (*r)), callb)
    | DefVariant(r) => walk_exp(DefVariant(ref (*r)), callb)
    | DefClass(r) => walk_exp(DefClass(ref (*r)), callb)
    | DefInterface(r) => walk_exp(DefInterface(ref (*r)), callb)
    | _ => walk_exp(e, callb)
    }

val dup_callb = {acb_typ=Some(dup_typ_), acb_exp=Some(dup_exp_), acb_pat=None}
fun dup_typ(t) = dup_typ_(t, dup_callb)

fun dup_exp(e) = dup_exp_(e, dup_callb)

fun dup_pat(p) = walk_pat(p, dup_callb)

fun deref_typ_rec(t) {
    fun deref_typ_rec_(t, callb) {
        val t = deref_typ(t)
        walk_typ(t, callb)
    }

    val deref_callb = {acb_typ=Some(deref_typ_rec_), acb_exp=None, acb_pat=None}
    deref_typ_rec_(t, deref_callb)
}
