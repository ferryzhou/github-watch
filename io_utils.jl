function save(filename, v)
  f = open(filename, "w")
  serialize(f, v)
  close(f)
end

function load(filename)
  f = open(filename, "r")
  return deserialize(f)
  close(f)
end
