#csv_file = "data/test.csv"
csv_file = "data/2014_08_repourl_actor_createdat.csv"
s = readcsv(csv_file, String; header=true)

items = s[1]

include("set2dict.jl")
include("io_utils.jl")

repo_set = Set(items[:, 1])
repo_dict, repos = set2dictarr(repo_set)
actor_set = Set(items[:, 2])
actor_dict, actors = set2dictarr(actor_set)

println("dicts are ready ")

N = size(items, 1)
#I = Array(Int, N)
#J = Array(Int, N)
#for i = 1:N
#  I[i] = repo_dict[items[i, 1]]
#  J[i] = actor_dict[items[i, 2]]
#  if (mod(i, 100000) == 0) println(i) end
#end

I = map((x) -> repo_dict[x], items[:, 1]) #produce Array of Any, cannot be used in sparse
J = map((x) -> actor_dict[x], items[:, 2])

println(typeof(repo_dict[items[1,1]]))
println(typeof(I)) # Array{Any,1}
I = convert(Array{Int}, I)
J = convert(Array{Int}, J)
println(typeof(I)) # Array{Int64,1}
A = sparse(I, J, ones(Int, N))

#println(A)

println("A is ready")

cinds = sortperm(vec(sum(A, 1)), rev=true)
rinds = sortperm(vec(sum(A, 2)), rev=true)

D = A[rinds, cinds]
nrepos = repos[rinds]
nactors = actors[cinds]

println("D is ready ")

#println(D)
save("Data/A.j", A)
save("Data/D.j", D)
writecsv("Data/nrepos.csv", nrepos)
writecsv("Data/nactors.csv", nactors)
