function set2dict(s)
  d = Dict()
  i = 1

  for ss in s
    d[ss] = i
    i = i + 1
    if (mod(i, 100000) == 0) println(i) end
  end

  d
end
