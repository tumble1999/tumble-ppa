#!/bin/bash

# Packages and Packages.gz
dpkg-scanpackages --multiversion . > Packages
gzip -k -f Packages

# Release, Release.gpg & InRelease
apt-ftparchive release . > Release
gpg --default-key "tumble@users.noreply.github.com" -abs -o - Release > Release.gpg
gpg --default-key "tumble@users.noreply.github.com" --clearsign -o - Release > InRelease