include("proc_incremental_ints.jl")

#csv_file = "data/test.csv"
csv_file = "data/2014_08_repourl_actor_createdat.csv"
s = readcsv(csv_file, String; header=true)

items = s[1]

N = size(items, 1)

ri = create_empty_rec_index()
tic()
for i = 1:N

  if (mod(i, 100000) == 0)
    @printf("%d / %d, %.2f%%\r", i, N, i * 100 / N)
  end

  push_item(ri, items[i, 1], items[i, 2])
end
toc()

tic()
index_dir = "Data/Index/"
save(index_dir, ri)
toc()
