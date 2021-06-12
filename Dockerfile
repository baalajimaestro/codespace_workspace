FROM fedora:34

# Env Vars for Android Build Tools
ENV ANDROID_SDK_ROOT="/opt/android-sdk" \
    ANDROID_HOME="/opt/android-sdk" \
    CMDLINE_VERSION="4.0" \
    SDK_TOOLS_VERSION="7302050" \
    BUILD_TOOLS_VERSION="30.0.2" \
    LANG="C.UTF-8"

# Set PATH
ENV PATH=$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/${CMDLINE_VERSION}/bin:${ANDROID_SDK_ROOT}/platform-tools

RUN dnf -y update \
    && dnf -y install dnf-plugins-core \
    && sudo dnf config-manager \
                --add-repo \
                https://download.docker.com/linux/fedora/docker-ce.repo \
    && dnf -y update \
    && dnf -y install   git \
                        libtool \
                        binutils \
                        shtool \
                        which \
                        hostname \
                        nano \
                        ccache \
                        bc \
                        gnupg \
                        zip \
                        curl \
                        make \
                        m4 \
                        diffutils \
                        openssh-clients \
                        openssh-server \
                        java-openjdk-headless \
                        automake \
                        autogen \
                        gcc \
                        gcc-c++ \
                        ncurses-compat-libs \
                        ncurses-devel \
                        ncurses-libs \
                        curl \
                        wget \
                        gawk \
                        pigz \
                        tar \
                        procps \
                        xz \
                        openssl \
                        openssl-devel \
                        gmp-devel \
                        file \
                        cpio \
                        python3 \
                        python3-pip \
                        lftp \
                        docker-ce \
                        docker-ce-cli \
                        containerd.io \
    && dnf clean all \
    && curl https://storage.googleapis.com/sem-cli-releases/get.sh | bash \
    && curl -sLo isl-0.22.1.tar.xz http://isl.gforge.inria.fr/isl-0.22.1.tar.xz \
    && tar -xf isl-0.22.1.tar.xz \
    && cd isl-0.22.1 \
    && ./configure > /dev/null \
    && sudo make install > /dev/null \
    && cd .. \
    && rm -rf isl-0.22.1 isl-0.22.1.tar.xz

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

CMD ["/bin/bash"]