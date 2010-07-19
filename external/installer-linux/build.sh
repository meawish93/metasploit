#!/bin/sh

VERSION="3.4.1-release"
BASE=`dirname $0`

ARCHIVE=$1
if [ -n "${ARCHIVE}" ]; then
    echo "Extracting archive"
    rm -rf msf3-*
    tar -xjf "${ARCHIVE}"
    if [ ! -d msf3-http ]; then
        echo "${ARCHIVE} must contain an svn checkout of msf as a single directory called msf3-http"
        exit 1
    fi
fi

if [ -z "$(which makeself)" ]; then
    echo "makeself needs to be installed and in the path"
    exit 2
fi

if [ ! -d msf3-http ]; then
    echo "Cannot continue without an svn checkout of msf as a directory called msf3-http"
    exit 2
fi

#
# Expects msf3.tar to exist and contain a single directory called msf3
#
build_makeself() {
    TITLE=$1
    INSTALLER_FILENAME=$2
    BIN_TARBALL_PATH=$3

    TMP=tmp_install_`date +%s1`
    mkdir ${TMP}/
    cp msf3.tar ${TMP}/
    cp ${BIN_TARBALL_PATH} ${TMP}/metasploit.tar.bz2
    bunzip2 ${TMP}/metasploit.tar.bz2
    cp -a ${BASE}/scripts/*.sh ${TMP}/
    cp -a ${BASE}/scripts/msfupdate ${TMP}/
    makeself "${TMP}" "${INSTALLER_FILENAME}" "${TITLE}" ./installer.sh
    rm -rf ${TMP}
}

# Remove any lingering symlinks from previous builds
rm msf3 2>/dev/null

ln -sf msf3-http msf3
tar hcf msf3.tar msf3

TITLE="Metasploit Framework v${VERSION} Installer (64-bit)"
INSTALLER_FILENAME="framework-${VERSION}-linux-x86_64.run"
BINPATH="${BASE}/bin/linux64.tar.bz2"
if [ -f ${BINPATH} ]; then
    echo "Making 64-bit"
    build_makeself "${TITLE}" "${INSTALLER_FILENAME}" "${BINPATH}"
fi

TITLE="Metasploit Framework v${VERSION} Installer (32-bit)"
INSTALLER_FILENAME="framework-${VERSION}-linux-i686.run"
BINPATH="${BASE}/bin/linux32.tar.bz2"
if [ -f ${BINPATH} ]; then
    echo "Making 32-bit"
    # Build the regular 32-bit installer
    # Uses the same msf3.tar as 64-bit, so we don't need to regenerate it.
    build_makeself "${TITLE}" "${INSTALLER_FILENAME}" "${BINPATH}"

    ./minify.sh msf3-http

    rm msf3 msf3.tar
    ln -sf msf3-mini msf3
    tar hcf msf3.tar msf3

    TITLE="Metasploit Framework v${VERSION} Miniature Installer (32-bit)"
    INSTALLER_FILENAME="framework-${VERSION}-mini-linux-i686.run"
    BINPATH="${BASE}/bin/linux32.tar.bz2"
    build_makeself "${TITLE}" "${INSTALLER_FILENAME}" "${BINPATH}"
fi

rm msf3 msf3.tar

