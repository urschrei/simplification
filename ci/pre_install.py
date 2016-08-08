#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import io
import requests
import zipfile
import tarfile

# We need to build the module using a Rust binary
# This logic tries to grab it from GitHub, based on the platform
platform = sys.platform
print(platform)

# If we sign our requests, GH doesn't aggressively rate-limit us
if not 'win32' in platform:
    # get GH access token from Travis
    with open('key.txt', 'r') as f:
        ghkey = f.read().strip()
        path = os.path.join(os.environ['HOME'], "build/urschrei/simplification/simplification")
elif 'win32' in platform:
    ghkey = os.environ['TARBALL_KEY']
    path = "C:\projects\simplification\simplification"

# Get the latest release details for the binary
project = 'rdp'
latest_release = requests.get(
    "https://api.github.com/repos/urschrei/%s/releases/latest" % project,
    headers={'Authorization':'token %s' % ghkey}).json()
print(latest_release)
tagname = latest_release['tag_name']
# What platform are we on?
if 'darwin' in platform:
    lib = "librdp.dylib"
    url = 'https://github.com/urschrei/{project}/releases/download/{tagname}/{project}-{tagname}-x86_64-apple-darwin.tar.gz'
elif 'win32' in platform:
    lib = "rdp.dll"
    # distinguish between 64-bit and 32-bit Windows Pythons
    if sys.maxsize > 2**32:
        url = 'https://github.com/urschrei/{project}/releases/download/{tagname}/{project}-{tagname}-x86_64-pc-windows-gnu.zip'
    else:
        url = 'https://github.com/urschrei/{project}/releases/download/{tagname}/{project}-{tagname}-i686-pc-windows-gnu.zip'
elif 'linux' in platform:
    lib = "librdp.so"
    url = 'https://github.com/urschrei/{project}/releases/download/{tagname}/{project}-{tagname}-x86_64-unknown-linux-gnu.tar.gz'

# Construct download URL
fdict = {'project': project, 'tagname': tagname}
built = url.format(**fdict)
print(("URL:", built))
# Get compressed archive and extract binary (and lib, on Windows)
release = requests.get(built, headers={'Authorization':'access_token %s' % ghkey}, stream=True)     
fname = os.path.splitext(built)
content = release.content
so = io.BytesIO(content)
if fname[1] == '.zip':
    raw_zip = zipfile.ZipFile(so)
    raw_zip.extractall(path)
else:
    tar = tarfile.open(mode="r:gz", fileobj=so)
    tar.extractall(path)
