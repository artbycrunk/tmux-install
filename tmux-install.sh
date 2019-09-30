#! /usr/bin/env bash

[ "${TMUX_INSTALL_DIR}" ] || TMUX_INSTALL_DIR=${HOME}/tmux-static

[ "${TMUX_VERSION}" ] || TMUX_VERSION=2.9a
[ "${NCURSES_VERSION}" ] || NCURSES_VERSION=6.1
[ "${LIBEVENT_VERSION}" ] || LIBEVENT_VERSION=2.1.8 
[ "${TMUX_STATIC}" ] || TMUX_STATIC=--enable-static

TMPDIR=${TMUX_INSTALL_DIR}/tmux-tmp-${TMUX_VERSION}
BASEDIR=${TMUX_INSTALL_DIR}
TMUXTARGET=${BASEDIR}/tmux-${TMUX_VERSION}

mkdir -p $TMUXTARGET

export PKG_CONFIG_PATH="${TMUXTARGET}/lib/pkgconfig"

#function for colored console output
output_info () {
    echo -e "\x1B[93m$1\x1B[0m"
}

output_info "tmux-${TMUX_VERSION} will be installed in : ${TMUXTARGET}"

#remove rc from tmux versions like 3.0-rc5
IFS='-'
read -ra ADDR <<< "$TMUX_VERSION"
TMUX_MAJOR_VERSION=${ADDR[0]}
IFS=' '

## Fetch dependencies
mkdir -p $TMPDIR
cd $TMPDIR
if [ ! -f libevent-${LIBEVENT_VERSION}-stable.tar.gz ]; then
        output_info "Fetching : libevent-${LIBEVENT_VERSION}"
        wget -q -O libevent-${LIBEVENT_VERSION}-stable.tar.gz https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable/libevent-${LIBEVENT_VERSION}-stable.tar.gz
fi
if [ ! -f ncurses-${NCURSES_VERSION}.tar.gz ]; then
        output_info "Fetching : ncurses-${NCURSES_VERSION}"
        wget -q -O ncurses-${NCURSES_VERSION}.tar.gz http://ftp.gnu.org/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz
fi
if [ ! -f tmux-${TMUX_VERSION}.tar.gz ]; then
        output_info "Fetching : tmux-${TMUX_VERSION}"
        wget -q -O tmux-${TMUX_VERSION}.tar.gz https://github.com/tmux/tmux/releases/download/${TMUX_MAJOR_VERSION}/tmux-${TMUX_VERSION}.tar.gz
fi

## Configure and make dependencies
if [ ! -d libevent-${LIBEVENT_VERSION}-stable ]; then
        cd ${TMPDIR}
        output_info "Extracting : libevent-${LIBEVENT_VERSION}-stable.tar.gz"
        tar -xzf libevent-${LIBEVENT_VERSION}-stable.tar.gz
        cd ${TMPDIR}/libevent-${LIBEVENT_VERSION}-stable
        ./configure --prefix=$TMUXTARGET --disable-shared
        output_info "Installing : libevent-${LIBEVENT_VERSION}"
        make && make install
fi

if [ ! -d ncurses-${NCURSES_VERSION} ]; then
        cd ${TMPDIR}
        output_info "Extracting : ncurses-${NCURSES_VERSION}.tar.gz"
        tar -xzf ncurses-${NCURSES_VERSION}.tar.gz
        cd ${TMPDIR}/ncurses-${NCURSES_VERSION}
        ./configure --prefix=$TMUXTARGET --with-shared
        output_info "Installing : ncurses-${NCURSES_VERSION}"
        make && make install
fi

## Install tmux
if [ ! -d tmux-${TMUX_VERSION} ]; then
        cd ${TMPDIR}
        output_info "Extracting : tmux-${TMUX_VERSION}.tar.gz"
        tar -xzf tmux-${TMUX_VERSION}.tar.gz
        cd tmux-${TMUX_VERSION}
        ./configure --prefix=$TMUXTARGET $TMUX_STATIC CPPFLAGS="-I${TMUXTARGET}/include" LIBS="-lresolv" CFLAGS="-I${TMUXTARGET}/include -I${TMUXTARGET}/include/ncurses" LDFLAGS="-L${TMUXTARGET}/lib -L${TMUXTARGET}/include -L${TMUXTARGET}/include/ncurses -L/usr/lib64" LIBEVENT_CFLAGS="-I${TMUXTARGET}/include" LIBEVENT_LIBS="-L${TMUXTARGET}/lib -levent" LIBTINFO_CFLAGS="-I${TMUXTARGET}/include" LIBTINFO_LIBS="-L${TMUXTARGET}/lib -lncurses"

        output_info "Installing : tmux-${TMUX_VERSION} ${TMUX_STATIC}"
        make && make install
fi

## Verify the installed version.
if [ -f $TMUXTARGET/bin/tmux ]; then
        $TMUXTARGET/bin/tmux -V
        output_info "You can optionally add ${TMUXTARGET}/bin/ to your PATH."
fi