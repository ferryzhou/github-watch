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

include("io_utils.jl")

type RecIndex
  repo_url2id::Dict{String, Int}
  repo_id2url::Dict{Int, String}
  user_name2id::Dict{String, Int}
  user_id2name::Dict{Int, String}
  user_repos::Dict{Int, Set{Int}}
  repo_repos::Dict{Int, Dict{Int, Int}}
  repo_counts::Dict{Int, Int}
end

function create_empty_rec_index()
  RecIndex(Dict(), Dict(), Dict(), Dict(), Dict(), Dict(), Dict())
end

function save(index_dir, ri::RecIndex)
  p(x) = string(index_dir, x)
  save(p("repo_url2id.j"), ri.repo_url2id)
  save(p("repo_id2url.j"), ri.repo_id2url)
  save(p("user_name2id.j"), ri.user_name2id)
  save(p("user_id2name.j"), ri.user_id2name)
  save(p("user_repos.j"), ri.user_repos)
  save(p("repo_repos.j"), ri.repo_repos)
  save(p("repo_counts.j"), ri.repo_counts)
end

function load_rec_index(index_dir)
  ri = create_empty_rec_index()
  p(x) = string(index_dir, x)
  ri.repo_url2id = load(p("repo_url2id.j"))
  ri.repo_id2url = load(p("repo_id2url.j"))
  ri.user_name2id = load(p("user_name2id.j"))
  ri.user_id2name = load(p("user_id2name.j"))
  ri.user_repos = load(p("user_repos.j"))
  ri.repo_repos = load(p("repo_repos.j"))
  ri.repo_counts = load(p("repo_counts.j"))
  ri
end

function push_item(ri::RecIndex, repo_url, user_name)
  repo_id = get_repo_id(ri, repo_url)
  user_id = get_user_id(ri, user_name)

  #increase self similarity
  if haskey(ri.repo_counts, repo_id) ri.repo_counts[repo_id] = ri.repo_counts[repo_id] + 1
  else ri.repo_counts[repo_id] = 1 end

  if !haskey(ri.user_repos, user_id)
    ri.user_repos[user_id] = Set{Int}(repo_id)
    return # first repo of the user, no need to change counts
  end

  other_repos = ri.user_repos[user_id]

  if in(other_repos, repo_id) return end # already checked in

  # add other repos to repo's counts
  if !haskey(ri.repo_repos, repo_id)
    ri.repo_repos[repo_id] = Dict{Int, Int}()
  end
  rcounts = ri.repo_repos[repo_id]
  for orepo in other_repos
    if haskey(rcounts, orepo) rcounts[orepo] = rcounts[orepo] + 1
    else rcounts[orepo] = 1
    end
  end

  # add repo to other repos' counts
  for orepo in other_repos
    if !haskey(ri.repo_repos, orepo)
      ri.repo_repos[orepo] = Dict{Int, Int}()
    end
    orepo_counts = ri.repo_repos[orepo]
    if haskey(orepo_counts, repo_id) orepo_counts[repo_id] = orepo_counts[repo_id] + 1
    else orepo_counts[repo_id] = 1
    end
  end

  push!(ri.user_repos[user_id], repo_id)
end

function get_repo_id(ri::RecIndex, repo_url)
  get_id(repo_url, ri.repo_url2id, ri.repo_id2url)
end

function get_user_id(ri::RecIndex, user_name)
  get_id(user_name, ri.user_name2id, ri.user_id2name)
end

# given a repo url, return recommended repos (urls with similarity scores)
# return empty if it's new
function get_rec_repos(ri::RecIndex, repo_url, topN = 100)
  id = get_repo_id(ri, repo_url)
  rr = ri.repo_repos[id]
  ids = collect(keys(rr))
  if isempty(ids); return []; end
  counts = map(x -> rr[x], ids)
  nn = map(x->sqrt(ri.repo_counts[x]), ids)
  nscore = counts ./nn
  sinds = sortperm(nscore, rev=true)
  sids = ids[sinds]
  N = min(length(sids), topN)
  map(i -> ri.repo_id2url[i], sids[1:N])
end

# get id of s, index is not exist
function get_id(s, s2i, i2s)
  if haskey(s2i, s) return s2i[s] end
  i = length(i2s) + 1
  i2s[i] = s
  s2i[s] = i
  i
end

#######
# (TODO) generate top N repo top M rec json products for embedding in html
# need cutted repo_id2url, repo_url2id, repo_repos

function gen_topNM_jsons(ri::RecIndex, N, M, dst_dir)

end
