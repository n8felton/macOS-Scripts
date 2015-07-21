#!/usr/bin/env python
import json
import urllib2
import subprocess
from operator import itemgetter

ORG_REPOS_URL = "https://api.github.com/orgs/autopkg/repos?per_page=100"

org_repos = urllib2.urlopen(ORG_REPOS_URL)
org_repos_data = json.load(org_repos)
for repo in sorted(org_repos_data, key=itemgetter('stargazers_count'),
                   reverse=True):
    print repo['clone_url']
    subprocess.call(['autopkg', 'repo-add', repo['clone_url']])
