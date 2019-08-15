FROM nnurphy/jpl-rs

### Haskell
ENV STACK_ROOT=/opt/stack \
    STACKAGE_VERSION=lts-14.1

RUN set -ex \
  ; mkdir -p ${STACK_ROOT} && mkdir -p ${HOME}/.cabal \
  ; curl -sSL https://get.haskellstack.org/ | sh \
  ; stack config set system-ghc --global false && stack config set install-ghc --global true  \
  ; stack update && stack setup \
  ; git clone https://github.com/gibiansky/IHaskell \
  ; cd IHaskell \
  # pip: 去掉版本号,尽量使用已安装版本
  ; sed -i 's/==.*$//g' requirements.txt \
  ; pip --no-cache-dir install -r requirements.txt \
  ; sed -i "s/^\(resolver:\).*$/\1 ${STACKAGE_VERSION}/g" stack.yaml \
   # parsers boomerang criterion weigh arithmoi syb multipart HTTP html xhtml
  ; stack install \
      optparse-applicative taggy \
      shelly aeson yaml \
      monad-journal \
      MonadRandom monad-logger \
      cryptonite pipes \
      conduit machines mustache \
      # wreq scotty wai websockets warp
      http-conduit servant \
      hspec extensible-exceptions deepseq \
      hmatrix linear ad integration statistics \
      filepath directory pretty process singletons \
      monad-par async stm classy-prelude reactive-banana uniplate syb dimensional \
      bound unbound-generics primitive memory array \
      free extensible-effects ghc-prim \
      bytestring containers fgl \
      template-haskell time transformers unix attoparsec megaparsec mtl \
      network QuickCheck parallel random call-stack regex-base regex-compat regex-posix \
      text hashable unordered-containers vector zlib fixed \
      flow lens \
  # Disabled for now because gtk2hs-buildtools doesn't work with lts-13 yet
  #; stack install gtk2hs-buildtools \
  ; stack install --fast \
  ; ${HOME}/.local/bin/ihaskell install --stack \
  ; mkdir -p ${STACK_ROOT}/global-project \
  # 设置全局 stack resolver, 避免运行时重新安装 lts
  ; sed -i "s/^\(resolver:\).*$/\1 ${STACKAGE_VERSION}/g" ${STACK_ROOT}/global-project/stack.yaml \
  ; rm -rf ${STACK_ROOT}/programs/x86_64-linux/*.tar.xz \
  ; rm -rf ${STACK_ROOT}/pantry/* \
  ; rm -rf ${HOME}/IHaskell/ \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY .ghci ${HOME}/.ghci

#RUN set -ex \
#  ; jupyter labextension install ihaskell_labextension \
#  #; jupyter labextension install jupyterlab-ihaskell \
#  ; rm -rf /usr/local/share/.cache/yarn
