#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Reproducir entorno en otra Fedora (tras git clone)
# -----------------------------------------------------------------------------
# 1) Dependencias base para compilar Ruby y extensiones nativas:
# 1) Dependencias base para compilar Ruby, OpenSSL 1.1 y extensiones nativas:
#    sudo dnf install -y gcc gcc-c++ make patch autoconf bison openssl-devel \
#      libyaml-devel readline-devel zlib-devel libffi-devel gdbm-devel \
#      ncurses-devel rust cargo git
#      libyaml-devel readline-devel zlib-ng-compat-devel libffi-devel gdbm-devel \
#      ncurses-devel perl-FindBin perl-IPC-Cmd perl-File-Compare perl-File-Copy \
#      perl-lib rust cargo git
#
# 2) Instalar rbenv + ruby-build (si no los tienes):
#    mkdir -p "$HOME/.rbenv"
#    git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
#    mkdir -p "$HOME/.rbenv/plugins"
#    git clone https://github.com/rbenv/ruby-build.git \
#      "$HOME/.rbenv/plugins/ruby-build"
#
# 3) Inicializar rbenv en tu shell (Command/bash):
#    echo 'export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"' >> ~/.bashrc
#    echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
#    source ~/.bashrc
#
# 4) Instalar la versión del proyecto y bundler lockeado por GitHub Pages:
#    export CFLAGS="-std=gnu17 -O2 -Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration -Wno-error=int-conversion"
#    rbenv install -s 2.4.10
#    rbenv local 2.4.10
#    gem install bundler -v 1.17.3 --no-document
#
# 5) Ejecutar este script:
#    ./run-local.sh
#    ./run-local.sh   (o: sh run-local.sh)
#
# Nota: este repo usa stack legacy de GitHub Pages (jekyll 3.8.x + bundler 1.17.3).
# No actualices Gemfile.lock para mantener compatibilidad con Pages.

export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
unset GEM_HOME GEM_PATH BUNDLE_BIN_PATH

# Flags de compatibilidad con GCC 15/16 (Fedora 42+) para Ruby 2.4 y gemas C legacy
export CFLAGS="${CFLAGS:--std=gnu17 -O2 -Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration -Wno-error=int-conversion}"

if ! rbenv versions --bare | grep -qx "2.4.10"; then
  echo "==> Ruby 2.4.10 no detectado en rbenv; instalando..."
  if ! perl -MFindBin -e 1 2>/dev/null; then
    echo "==> Descargando módulos Perl necesarios para compilar OpenSSL 1.1.1w sin sudo..."
    mkdir -p /tmp/perl-deps
    dnf download --destdir=/tmp/perl-deps perl-FindBin perl-IPC-Cmd perl-File-Compare perl-File-Copy perl-lib
    for rpm in /tmp/perl-deps/*.rpm; do
      rpm2cpio "$rpm" | cpio -idmv -D /tmp/perl-deps/root 2>/dev/null
    done
    export PERL5LIB="/tmp/perl-deps/root/usr/lib64/perl5:/tmp/perl-deps/root/usr/share/perl5:/tmp/perl-deps/root/usr/share/perl5/vendor_perl${PERL5LIB:+:$PERL5LIB}"
  fi
  rbenv install -s 2.4.10
fi

rbenv local 2.4.10

if ! gem list -i bundler -v 1.17.3 >/dev/null 2>&1; then
  gem install bundler -v 1.17.3 --no-document
fi

bundle _1.17.3_ install --path vendor/bundle
bundle _1.17.3_ exec jekyll serve

