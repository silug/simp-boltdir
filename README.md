# simp-boltdir
Boltdir with tasks/plans for syncing simp repos locally

To use:
* Install [bolt](https://puppet.com/docs/bolt/latest/bolt.html) **version 2.8.0 or later**.
* In the directory you want all the SIMP modules, run `git clone https://github.com/silug/simp-boltdir.git Boltdir`
* If you want to avoid issues with GitHub's API limits, set the environment variable `TOKEN` to a GitHub API token with read access.
* `bolt plan run simp_update -t all`
