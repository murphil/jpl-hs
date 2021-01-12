FROM nnurphy/jpl-rs

### Haskell
ENV STACK_ROOT=/opt/stack

RUN set -ex \
  ; mkdir -p ${STACK_ROOT}/global-project && mkdir -p ${HOME}/.cabal \
  ; curl -sSL https://get.haskellstack.org/ | sh \
  ; stack config set system-ghc --global false && stack config set install-ghc --global true  \
  ; stack update && stack setup \
  ; git clone https://github.com/gibiansky/IHaskell \
  ; cd IHaskell \
  # pip: 去掉版本号,使用已安装版本
  ; sed -i 's/==.*$//g' requirements.txt \
  ; pip --no-cache-dir install -r requirements.txt \
  ; stack install -j1 --fast \
  ; ${HOME}/.local/bin/ihaskell install --stack \
   # parsers boomerang criterion weigh arithmoi syb multipart HTTP html xhtml
  ; stack install -j1 --no-interleaved-output \
      # optparse-applicative taggy \
      shelly aeson yaml \
      monad-journal monad-logger \
      MonadRandom unix \
      # pipes \
      conduit machines mustache \
      # wreq scotty wai websockets warp
      http-conduit \
      # extensible-exceptions deepseq \
  #    hmatrix linear integration statistics \
      filepath directory pretty process singletons \
  #    monad-par async stm classy-prelude \
      # bound unbound-generics memory array \
      free extensible-effects  \
      # bytestring containers fgl \
      template-haskell time transformers attoparsec \
      # megaparsec mtl \
      QuickCheck \
      # parallel random call-stack \
      # text hashable unordered-containers vector zlib fixed \
      flow lens recursion-schemes \
  ; rm -rf ${STACK_ROOT}/programs/x86_64-linux/*.tar.xz \
  ; rm -rf ${STACK_ROOT}/pantry/* \
  #; rm -rf ${HOME}/IHaskell/ \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -ex \
  ; mkdir -p /opt/language-server/haskell \
  ; hls_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json"  https://api.github.com/repos/haskell/haskell-language-server/releases | yq e '.[0].tag_name' -) \
  ; ghc_version=$(stack ghc -- --version | grep -oP 'version \K([0-9\.]+)') \
  ; curl -sSL https://github.com/haskell/haskell-language-server/releases/download/${hls_version}/haskell-language-server-wrapper-Linux.gz | gzip -d > /opt/language-server/haskell/haskell-language-server-wrapper \
  ; curl -sSL https://github.com/haskell/haskell-language-server/releases/download/${hls_version}/haskell-language-server-Linux-${ghc_version}.gz | gzip -d > /opt/language-server/haskell/haskell-language-server-${ghc_version} \
  ; chmod +x /opt/language-server/haskell/* \
  ; for l in /opt/language-server/haskell/*; do ln -fs $l /usr/local/bin; done

COPY .ghci ${HOME}/.ghci

#RUN set -ex \
#  #; stack install flow lens recursion-schemes \
#  ; jupyter labextension install jupyterlab-ihaskell \
#  ; rm -rf /usr/local/share/.cache/yarn

COPY config.tuna.yaml /opt/stack/config.yaml
