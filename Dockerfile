FROM fedora:34

# Env Vars for Rust and Android Build Tools
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    RUST_VERSION=nightly \
    ANDROID_SDK_ROOT="/opt/android-sdk" \
    ANDROID_HOME="/opt/android-sdk" \
    CMDLINE_VERSION="4.0" \
    SDK_TOOLS_VERSION="7302050" \
    BUILD_TOOLS_VERSION="30.0.2" \
    ANDROID_PLATFORM_VERSION="android-30" \
    LANG="C.UTF-8"

# Set PATH
ENV PATH=$PATH:/usr/local/cargo/bin:${ANDROID_SDK_ROOT}/cmdline-tools/${CMDLINE_VERSION}/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/build-tools/${BUILD_TOOLS_VERSION}:/opt/gradle/bin

RUN dnf -y update \
    && dnf -y install dnf-plugins-core \
    && sudo dnf config-manager \
                --add-repo \
                https://download.docker.com/linux/fedora/docker-ce.repo \
    && dnf -y update \
    && dnf -y install autogen \
                      automake \
                      bc \
                      binutils \
                      ccache \
                      clang \
                      containerd.io \
                      cpio \
                      curl \
                      diffutils \
                      docker-ce \
                      docker-ce-cli \
                      file \
                      gawk \
                      gcc \
                      gcc-c++ \
                      git \
                      gmp-devel \
                      gnupg \
                      hostname \
                      java-openjdk-headless \
                      lftp \
                      libtool \
                      m4 \
                      make \
                      megatools \
                      moreutils \
                      nano \
                      ncurses-compat-libs \
                      ncurses-devel \
                      ncurses-libs \
                      openssh-clients \
                      openssh-server \
                      openssl \
                      openssl-devel \
                      pigz \
                      pinentry \
                      procps \
                      python3 \
                      python3-pip \
                      rclone \
                      shtool \
                      supervisor \
                      tar \
                      wget \
                      which \
                      xz \
                      zip \
    && dnf clean all \
    && curl https://storage.googleapis.com/sem-cli-releases/get.sh | bash \
    && curl -sLo gdrive.tar.gz https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_amd64.tar.gz \
    && tar -xf gdrive.tar.gz \
    && mv gdrive /usr/bin \
    && rm -rf gdrive.tar.gz \
    && curl -sLo ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip \
    && unzip ngrok.zip \
    && mv ngrok /usr/bin \
    && rm -rf ngrok.zip \
    && curl -sLo gradle.zip https://services.gradle.org/distributions/gradle-6.9-bin.zip \
    && unzip gradle.zip \
    && mv gradle-6.9 /opt/gradle \
    && rm -rf gradle.zip \
    && curl https://cli-assets.heroku.com/install.sh | sh

# Install Rust Nightly Toolchain
RUN mkdir /usr/local/rustup /usr/local/cargo && \
    wget "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init"; \
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
    sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install "build-tools;${BUILD_TOOLS_VERSION}" && \
    sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install "platforms;${ANDROID_PLATFORM_VERSION}"

# Setup User
RUN mkdir /workspaces && \
    useradd baalajimaestro -m -d /workspaces && \
    usermod -a -G docker baalajimaestro && \
    chown -R baalajimaestro:baalajimaestro /workspaces && \
    echo "baalajimaestro ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    ssh-keygen -A && \
    sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config && \
    echo 'baalajimaestro:1234' | chpasswd

WORKDIR /workspaces
USER baalajimaestro

# Redo the ENV
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    RUST_VERSION=nightly \
    ANDROID_SDK_ROOT="/opt/android-sdk" \
    ANDROID_HOME="/opt/android-sdk" \
    CMDLINE_VERSION="4.0" \
    SDK_TOOLS_VERSION="7302050" \
    BUILD_TOOLS_VERSION="30.0.2" \
    ANDROID_PLATFORM_VERSION="android-30" \
    LANG="C.UTF-8"

ENV PATH=$PATH:/usr/local/cargo/bin:${ANDROID_SDK_ROOT}/cmdline-tools/${CMDLINE_VERSION}/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/build-tools/${BUILD_TOOLS_VERSION}:/opt/gradle/bin

CMD ["/bin/bash"]