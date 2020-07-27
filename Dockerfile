FROM nnurphy/jpl-rs

### Haskell
ENV STACK_ROOT=/opt/stack

RUN set -ex \
  ; mkdir -p ${STACK_ROOT} && mkdir -p ${HOME}/.cabal \
  ; mkdir -p ${STACK_ROOT}/global-project \
  ; touch ${STACK_ROOT}/global-project/stack.yaml \
  ; curl -sSL https://get.haskellstack.org/ | sh \
  ; stack config set system-ghc --global false && stack config set install-ghc --global true  \
  ; git clone https://github.com/gibiansky/IHaskell \
  ; cd IHaskell \
  #; stack update && stack setup \
  # pip: 去掉版本号,尽量使用已安装版本
  ; sed -i 's/==.*$//g' requirements.txt \
  ; pip --no-cache-dir install -r requirements.txt \
  #; sed -i "s/^\(resolver:\).*$/\1 ${STACKAGE_VERSION}/g" stack.yaml \
  # Disabled for now because gtk2hs-buildtools doesn't work with lts-13 yet
  #; stack install gtk2hs-buildtools \
  ; stack install -j1 --fast \
  ; yq w -i ${STACK_ROOT}/global-project/stack.yaml 'resolver' \
        $(yq r ${HOME}/IHaskell/stack.yaml resolver) \
  ; ${HOME}/.local/bin/ihaskell install --stack \
  # 设置全局 stack resolver, 避免运行时重新安装 lts
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
  ; rm -rf ${HOME}/IHaskell/ \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY .ghci ${HOME}/.ghci

# RUN set -ex \
#   ; stack install flow lens recursion-schemes \
#   ; jupyter labextension install jupyterlab-ihaskell \
#   ; rm -rf /usr/local/share/.cache/yarn

COPY config.tuna.yaml /opt/stack/config.yaml