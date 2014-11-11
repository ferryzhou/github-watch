#csv_file = "data/test.csv"
csv_file = "data/2014_08_repourl_actor_createdat.csv"
s = readcsv(csv_file; header=true)

items = s[1]

include("set2dict.jl")

repo_dict = set2dict(Set(items[:, 1]))
actor_dict = set2dict(Set(items[:, 2]))

println("dicts are ready ")

N = size(items, 1)
I = zeros(N)
J = zeros(N)
for i = 1:N
  I[i] = repo_dict[items[i, 1]]
  J[i] = actor_dict[items[i, 2]]
  if (mod(i, 100000) == 0) println(i) end
end

#println(I)
#println(J)
