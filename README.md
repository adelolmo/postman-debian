# postman-debian

Debian package for Postman API Platform (https://www.postman.com/)

## Build debian package

    make
    make debian

The package is created in the parent directory:
e.g. `../postman_9.31.0_amd64.deb`

You can also build a different version of postman with the parameter `VERSION` and a version number:

    make VERSION=9.30.0
    make debian

## Install locally

    make
    sudo make install

You can also install a different version of postman with the parameter `VERSION` and a version number:

    make VERSION=9.30.0
    sudo make install
