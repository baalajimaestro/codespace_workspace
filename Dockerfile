FROM alpine:edge

RUN apk add --no-cache coreutils \
                       alpine-sdk \
                       make \
                       xz \
                       tar \
                       zip \
                       unzip \
                       unrar \
                       rustup \
                       python3 \
                       python3-dev \
                       py3-pip \
                       openjdk16-jdk \
                       bash \
                       zsh \
                       openssh-server \
                       openssh-client \
                       sudo
                       
RUN curl https://storage.googleapis.com/sem-cli-releases/get.sh | bash