function set2dictarr(s)
  d = Dict{String, Int}()
  a = Array(String, length(s))
  i = 1::Int

  for ss in s
    a[i] = ss
    d[ss] = i
    i = i + 1
    if (mod(i, 100000) == 0) println(i) end
  end

  d, a
end
