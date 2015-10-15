See [wiki](http://gitlab.wmt.dk/solshark/prezentor-2-0/wikis/home)

Debug modules:

```
export DEBUG=api,tests,jobs,jobs.reports,api.helper
```

Pre-install `sharp` deps (screendumps generation)

As **root**:

```
curl -s https://raw.githubusercontent.com/lovell/sharp/master/preinstall.sh | bash -
```

Using **sudo**:

```
curl -s https://raw.githubusercontent.com/lovell/sharp/master/preinstall.sh | sudo bash -
```
