#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Reproducir entorno en otra Fedora (tras git clone)
# -----------------------------------------------------------------------------
# 1) Dependencias base para compilar Ruby y extensiones nativas:
#    sudo dnf install -y gcc gcc-c++ make patch autoconf bison openssl-devel \
#      libyaml-devel readline-devel zlib-devel libffi-devel gdbm-devel \
#      ncurses-devel rust cargo git
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
#    rbenv install -s 2.4.10
#    rbenv local 2.4.10
#    gem install bundler -v 1.17.3 --no-document
#
# 5) Ejecutar este script:
#    ./run-local.sh
#
# Nota: este repo usa stack legacy de GitHub Pages (jekyll 3.8.x + bundler 1.17.3).
# No actualices Gemfile.lock para mantener compatibilidad con Pages.

export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
unset GEM_HOME GEM_PATH BUNDLE_BIN_PATH

bundle _1.17.3_ install --path vendor/bundle
bundle _1.17.3_ exec jekyll serve
