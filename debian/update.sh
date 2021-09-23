#!/bin/bash

# Packages and Packages.gz
dpkg-scanpackages --multiversion . > Packages
gzip -k -f Packages

# Release, Release.gpg & InRelease
apt-ftparchive release . > Release
gpg --default-key "PPA_EMAIL" -abs -o - Release > Release.gpg
gpg --default-key "PPA_EMAIL" --clearsign -o - Release > InRelease