# run proc_data before this one

include("io_utils.jl")

D = load("Data/D.j")

println(size(D))
a = sum(D, 2)
println(a[[1, 10, 1000, 10000, 100000]])

N = 10000

nD = D[1:N, 1:end]

#nD = convert(Array{Int64, 2}, nD)

println("computing P")
P = nD * nD'

println("normalizing P")
V = sqrt(sum(nD, 2))
M = V * V'
P = P ./ M

#println(P[1:3, 1:3])

println("computing recommendations")
K = 20
recs = zeros(Int16, N, K)
for i = 1:N
    sims = P[:, i]
    inds = sortperm(sims, rev=true)
    recs[i, :] = inds[2:K+1]
end

println("saving recs")
writecsv("Data/recs.csv", recs)
save("Data/recs.j", recs)

nrepos = readcsv("Data/nrepos.csv", String)
writecsv("Data/rec_repos.csv", nrepos[1:N])

t = 100
println(nrepos[t])
for i = 1 : K
  println(nrepos[recs[t, i]])
end
