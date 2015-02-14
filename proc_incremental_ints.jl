# map strings to integers
# repo_url2id, repo_id2url: repo_url <-> repo_id,
# user_name2id, user_id2name: user_name <-> user_id
# same as proc_incremental.jl
# keep maps of
#   user_repos: user_id -> set of repo_id
#   repo_repos: repo_id -> dict of <repo_id, count>
#   repo_counts: repo_id -> count

# keep existing maps
# for new arrays of <repo_url, user_name>
# map all repo_urls to repo_ids and user_names to user_ids, update string interger maps
# for each <repo_id, user_id> pair
#   push to system

repo_url2id = Dict{String, Int}()
repo_id2url = Dict{Int, String}()
user_name2id = Dict{String, Int}()
user_id2name = Dict{Int, String}()
user_repos = Dict{Int, Set{Int}}()
repo_repos = Dict{Int, Dict{Int, Int}}()
repo_counts = Dict{Int, Int}()

function push_item(repo_url, user_name)
  repo_id = get_repo_id(repo_url)
  user_id = get_user_id(user_name)

  #increase self similarity
  if haskey(repo_counts, repo_id) repo_counts[repo_id] = repo_counts[repo_id] + 1
  else repo_counts[repo_id] = 1 end

  if !haskey(user_repos, user_id)
    user_repos[user_id] = Set{Int}(repo_id)
    return # first repo of the user, no need to change counts
  end

  other_repos = user_repos[user_id]

  if in(other_repos, repo_id) return end # already checked in

  # add other repos to repo's counts
  if !haskey(repo_repos, repo_id)
    repo_repos[repo_id] = Dict{Int, Int}()
  end
  rcounts = repo_repos[repo_id]
  for orepo in other_repos
    if haskey(rcounts, orepo) rcounts[orepo] = rcounts[orepo] + 1
    else rcounts[orepo] = 1
    end
  end

  # add repo to other repos' counts
  for orepo in other_repos
    if !haskey(repo_repos, orepo)
      repo_repos[orepo] = Dict{Int, Int}()
    end
    orepo_counts = repo_repos[orepo]
    if haskey(orepo_counts, repo_id) orepo_counts[repo_id] = orepo_counts[repo_id] + 1
    else orepo_counts[repo_id] = 1
    end
  end

  push!(user_repos[user_id], repo_id)
end

function get_repo_id(repo_url)
  get_id(repo_url, repo_url2id, repo_id2url)
end

function get_user_id(user_name)
  get_id(user_name, user_name2id, user_id2name)
end

function get_id(s, s2i, i2s)
  if haskey(s2i, s) return s2i[s] end
  i = length(i2s) + 1
  i2s[i] = s
  s2i[s] = i
  i
end

#csv_file = "data/test.csv"
csv_file = "data/2014_08_repourl_actor_createdat.csv"
s = readcsv(csv_file, String; header=true)

items = s[1]

N = size(items, 1)

tic()
for i = 1:N

  if (mod(i, 100000) == 0)
    @printf("%d / %d, %.2f%%\r", i, N, i * 100 / N)
  end

  push_item(items[i, 1], items[i, 2])
end
toc()

include("io_utils.jl")

tic()
save("Data/Index/repo_url2id.j", repo_url2id)
save("Data/Index/repo_id2url.j", repo_id2url)
save("Data/Index/user_name2id.j", user_name2id)
save("Data/Index/user_id2name.j", user_id2name)
save("Data/Index/user_repos.j", user_repos)
save("Data/Index/repo_repos.j", repo_repos)
save("Data/Index/repo_counts.j", repo_counts)
toc()

#println(repo_url2id)
#println(repo_id2url)
#println(user_name2id)
#println(user_id2name)
#println(user_repos)
#println(repo_repos)
#println(repo_counts)
