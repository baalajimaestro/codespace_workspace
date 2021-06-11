FROM alpine:edge

RUN sed -e 's;^#http\(.*\)/edge/community;http\1/edge/community;g' -i /etc/apk/repositories

RUN apk update

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
                       openjdk11-jdk \
                       bash \
                       openssh-server \
                       openssh-client \
                       sudo \
                       ca-certificates \
                       nano \
                       docker \
                       docker-compose

ADD docker-init.sh /usr/bin/docker-init.sh
RUN chmod +x /usr/bin/docker-init.sh

RUN curl https://storage.googleapis.com/sem-cli-releases/get.sh | bash

RUN adduser --disabled-password \
            --gecos "" \
            --home "/workspaces" \
            --shell "/bin/bash" \
            baalajimaestro

RUN addgroup baalajimaestro docker

RUN echo "baalajimaestro ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir /usr/local/rustup /usr/local/cargo

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=nightly

RUN wget "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-musl/rustup-init"; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile default --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME;

ENV ANDROID_SDK_ROOT "/opt/android-sdk"
ENV ANDROID_HOME ${ANDROID_SDK_ROOT}
ENV PATH $PATH:${ANDROID_SDK_ROOT}/cmdline-tools/${CMDLINE_VERSION}/bin:${ANDROID_SDK_ROOT}/platform-tools
ENV CMDLINE_VERSION "4.0"
ENV SDK_TOOLS "7302050"

RUN curl -sLo commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-${SDK_TOOLS}_latest.zip && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    unzip -qq commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/${CMDLINE_VERSION} && \
    rm -v commandlinetools.zip && \
    mkdir -p ~/.android/ && touch ~/.android/repositories.cfg && \
    yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses && \
    sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install "build-tools;30.0.2" "ndk;21.4.7075529"


RUN ssh-keygen -A
RUN sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config 
RUN echo 'baalajimaestro:1234' | chpasswd

WORKDIR /workspaces
USER baalajimaestro

RUN echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
RUN echo 'export PS1="[\u@\h \W]\\$ "' >> ~/.bashrc

ENV LANG C.UTF-8

ENTRYPOINT [ "/usr/bin/docker-init.sh" ]
CMD ["/bin/bash"]