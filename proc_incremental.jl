include("io_utils.jl")

#csv_file = "data/test.csv"
csv_file = "data/2014_08_repourl_actor_createdat.csv"
s = readcsv(csv_file, String; header=true)

items = s[1]

# keep track of a user's repos
user_repos = Dict{String, Set{String}}()

# keep track related repo's count
repo_repos = Dict{String, Dict{String, Int}}()

# track count of each repos
repos = Dict{String, Int}()

N = size(items, 1)

tic()
for i = 1:N

  if (mod(i, 100000) == 0)
    @printf("%d / %d, %.2f%%\r", i, N, i * 100 / N)
  end

  user = items[i, 2]
  repo = items[i, 1]

  # increase self similarity
  if (haskey(repos, repo)) repos[repo] = repos[repo] + 1
  else repos[repo] = 1
  end

  # add repo to repo count
  if !haskey(user_repos, user)
    user_repos[user] = Set{String}()
  else
    other_repos = user_repos[user]
    if (!in(other_repos, repo))  # otherwise duplicate and do nothing

      # add repos to repo's counts
      if !haskey(repo_repos, repo)
        repo_repos[repo] = Dict{String, Int}()
      end
      repo_counts = repo_repos[repo]
      for orepo in other_repos
        if haskey(repo_counts, orepo) repo_counts[orepo] = repo_counts[orepo] + 1
        else repo_counts[orepo] = 1
        end
      end

      # add repo to repos' counts
      for orepo in other_repos
        if !haskey(repo_repos, orepo)
          repo_repos[orepo] = Dict{String, Int}()
        end
        orepo_counts = repo_repos[orepo]
        if haskey(orepo_counts, repo) orepo_counts[repo] = orepo_counts[repo] + 1
        else orepo_counts[repo] = 1
        end
      end
    end
  end
  push!(user_repos[user], repo)
end

toc()

#println(user_repos)
#println(repo_repos)
#println(repos)

save("Data/user_repos.j", user_repos)
save("Data/repo_repos.j", repo_repos)
save("Data/repos.j", repos)
