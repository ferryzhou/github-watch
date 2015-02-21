# a web server in julia to serve recommendation requests
# /r?name=username/reponame" get repo detailed information
# /n?name=username/reponame" get recommended repo information
# / is %2F

include("proc_incremental_ints.jl")

import JSON

using Morsel

app = Morsel.app()

tic(); ri = load_rec_index("Data/Index/"); toc()

route(app, GET, "/n") do req, res
  params = req.state[:url_params]
  url = string("https://github.com/", params["name"])
  JSON.json(get_rec_repos(ri, url))
end

get(app, "/about") do req, res
    "This app is running on Morsel"
end

start(app, 8000)