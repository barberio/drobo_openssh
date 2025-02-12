### ZLIB ###
_build_zlib() {
local VERSION="1.2.12"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --prefix="${DEPS}" --libdir="${DEST}/lib" --shared
make
make install
popd
}

### OPENSSL ###
_build_openssl() {
local VERSION="1.1.1o"
local FOLDER="openssl-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://www.openssl.org/source/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./Configure --prefix="${DEPS}" --openssldir="${DEST}/etc/ssl" \
  zlib-dynamic --with-zlib-include="${DEPS}/include" --with-zlib-lib="${DEPS}/lib" \
  shared threads linux-armv4 -DL_ENDIAN ${CFLAGS} ${LDFLAGS} \
  -Wa,--noexecstack -Wl,-z,noexecstack
sed -i -e "s/-O3//g" Makefile
make
make install_sw
cp -vfa "${DEPS}/lib/libssl.so"* "${DEST}/lib/"
cp -vfa "${DEPS}/lib/libcrypto.so"* "${DEST}/lib/"
cp -vfaR "${DEPS}/lib/engines"* "${DEST}/lib/"
cp -vfaR "${DEPS}/lib/pkgconfig" "${DEST}/lib/"
rm -vf "${DEPS}/lib/libcrypto.a" "${DEPS}/lib/libssl.a"
popd
}

### OPENSSH ###
_build_openssh() {
local VERSION="9.0p1"
local FOLDER="openssh-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
sed -i -e "s/sshd\.pid/pid.txt/" pathnames.h
./configure --host="${HOST}" --prefix="${DEST}" --disable-strip \
  --with-zlib="${DEPS}" --with-ssl-dir="${DEPS}" \
  --with-pid-dir=/tmp/DroboApps/openssh --with-privsep-path="${DEST}/var/empty" \
  --with-privsep-user=sshd \
  --with-sandbox=no
make
make install-nokeys
mv "${DEST}/etc"/ssh_config{,.default}
mv "${DEST}/etc"/sshd_config{,.default}
popd
}

_build() {
  _build_zlib
  _build_openssl
  _build_openssh
  _package
}
