# Procedures

## 2026-02 - Touch all CVEs while CVE REST Services is also updating

1. `git pull`
2. run `./build_cve_fullpath_listing.sh ../../cves` to generate a full listing of all the current CVEs (be sure there is no ending '/')
    - note we don't need to worry about new/updated CVEs from CVE REST Services because (presumably) they will have the correct date formats already and do not need to be updated
