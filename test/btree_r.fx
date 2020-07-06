import Args

type tree = Empty | Node: {left: tree, right: tree}

fun make (d: int) =
    if d == 0 { Node {left=Empty, right=Empty} }
    else { Node{right=make(d-1), left=make(d-1)} }

fun check (t: tree): int {
    | Node{left=l, right=r} => 1 + check(l) + check(r)
    | _ => 0
}

val min_depth = 4
val max_depth = match Args.arguments() {
    | n_str :: [] => getOpt(atoi(n_str), 10)
    | _ => 20
    }
val max_depth = max(min_depth + 2, max_depth)
val stretch_depth = max_depth + 1

val c = check (make(stretch_depth))
println("stretch tree of depth \(stretch_depth)\t check: \(c)")

val long_lived_tree = make(max_depth)

for i <- 0 : (max_depth - min_depth) / 2 + 1
{
    val d = min_depth + i * 2
    val niter = 1 << (max_depth - d + min_depth)
    val fold c = 0 for i <- 0:niter {
        c + check(make(d))
    }
    println("\(niter)\t trees of depth \(d)\t check: \(c)")
}

println("long lived tree of depth \(max_depth)\t check: \(check(long_lived_tree))")
