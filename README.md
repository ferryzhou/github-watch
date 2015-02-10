github-watch
============

analyze and visualize github data

a unique repo is defined by name and created time, create a unique repo name by <name>-<timestamp>

repo page

1. name, created-at, url, language, details, stars, starred by 

2. star histogram (1w, 1m, 1y, 2y, 3y, 4y, 5y)

3. related repos, different language in different colors

user page

1. name, url

2. starred repos, 


## implementation

use elastic search to provide restful api

## algorithm for similarity measurement

S(r_i, r_j) = (r_i .* r_j) / norm(r_i) / norm(r_j)

## incremental update

assuming K(i, j) = r_i .* r_j

K(i, j) is sparse

for each i, keep a set of K(i, j) indexed by j

i and j can be repo url

keep a set of M(i) = K(i, i)

for each user u, keep a set of starred repo urls

for each start event (u_k, r_i)

  add r_i to user's repo list

  for each other repo j in the list

    K(i, j)++

    K(j, i)++

  then M(i)++

## stack

redis

nodejs



