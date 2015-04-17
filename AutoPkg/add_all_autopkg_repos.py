#!/usr/bin/env python
import json
import urllib2
import subprocess

ORG_REPOS_URL = "https://api.github.com/orgs/autopkg/repos"

org_repos = urllib2.urlopen(ORG_REPOS_URL)
org_repos_data = json.load(org_repos)
for repo in org_repos_data:
    print repo['html_url']
    subprocess.call(['autopkg', 'repo-add', repo['html_url']])

