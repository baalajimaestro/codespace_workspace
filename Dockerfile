FROM alpine:edge

# Env Vars for Rust and Android Build Tools
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    RUST_VERSION=nightly \
    ANDROID_SDK_ROOT="/opt/android-sdk" \
    ANDROID_HOME="/opt/android-sdk" \
    CMDLINE_VERSION="4.0" \
    SDK_TOOLS_VERSION="7302050" \
    BUILD_TOOLS_VERSION="30.0.2" \
    LANG="C.UTF-8"

# Set PATH
ENV PATH=$PATH:/usr/local/cargo/bin:${ANDROID_SDK_ROOT}/cmdline-tools/${CMDLINE_VERSION}/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/build-tools/${BUILD_TOOLS_VERSION}

# Enable Community Repo
RUN sed -e 's;^#http\(.*\)/edge/community;http\1/edge/community;g' -i /etc/apk/repositories

RUN apk add --update --no-cache coreutils \
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
                                docker-compose \
                                fuse \
                                fuse-overlayfs && \
    rm -rf /var/cache/apk/* && \
    curl https://storage.googleapis.com/sem-cli-releases/get.sh | bash

# Install Rust Nightly Toolchain
RUN mkdir /usr/local/rustup /usr/local/cargo && \
    wget "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-musl/rustup-init"; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile default --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME;

# Install SDK Manager and Android Build Tools
RUN curl -sLo commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-${SDK_TOOLS_VERSION}_latest.zip && \
    sudo mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    sudo unzip -qq commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    sudo mv ${ANDROID_SDK_ROOT}/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/${CMDLINE_VERSION} && \
    rm -v commandlinetools.zip && \
    mkdir -p ~/.android/ && touch ~/.android/repositories.cfg && \
    yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses > /dev/null && \
    echo "Accepted all available licenses for Android SDK" && \
    sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install "build-tools;${BUILD_TOOLS_VERSION}"

# Setup User
RUN adduser --disabled-password \
            --gecos "" \
            --home "/workspaces" \
            --shell "/bin/bash" \
            baalajimaestro && \
    addgroup baalajimaestro docker && \
    echo "baalajimaestro ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    ssh-keygen -A && \
    sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config && \
    echo 'baalajimaestro:1234' | chpasswd

WORKDIR /workspaces
USER baalajimaestro

CMD ["/bin/bash"]