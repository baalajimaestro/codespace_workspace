#! /bin/bash

echo "Initial Codespace Setup Running!"

git clone -q https://baalajimaestro:${GH_PERSONAL_TOKEN}@github.com/baalajimaestro/keys /tmp/keys
cd /tmp/keys
mkdir ~/.ssh
mv id_ed25519 ~/.ssh/id_ed25519
mv authorized_keys ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_ed25519
chmod 600 ~/.ssh/authorized_keys
mv baalajimaestro.gpg /tmp

echo "Import GPG keys yourself, placed in /tmp"
git config --global user.name baalajimaestro
git config --global user.email "me@baalajimaestro.me"
git config --global commit.gpgsign true
git config --global user.signingkey 35EA585CF08135747CE5DDB4F93C394FE9BBAFD5
git config --global core.editor nano
git config --global push.gpgSign if-asked
git config --global init.defaultBranch master

# TTY Specific Customisation
echo 'export GPG_TTY=$(tty)' >> /workspaces/.bashrc
echo 'export PS1="[\u@\h \W]\\$ "' >> /workspaces/.bashrc

# Codespaces happens to reset the PATH, so set it back
echo 'export RUSTUP_HOME=/usr/local/rustup' >> /workspaces/.bashrc
echo 'export CARGO_HOME=/usr/local/cargo' >> /workspaces/.bashrc
echo 'export RUST_VERSION=nightly' >> /workspaces/.bashrc
echo 'export ANDROID_SDK_ROOT="/opt/android-sdk"' >> /workspaces/.bashrc
echo 'export ANDROID_HOME="/opt/android-sdk"' >> /workspaces/.bashrc
echo 'export CMDLINE_VERSION="4.0"' >> /workspaces/.bashrc
echo 'export SDK_TOOLS_VERSION="7302050"' >> /workspaces/.bashrc
echo 'export BUILD_TOOLS_VERSION="30.0.2"' >> /workspaces/.bashrc
echo 'export LANG="C.UTF-8"' >> /workspaces/.bashrc
echo 'export PATH="$PATH:/usr/local/cargo/bin:${ANDROID_SDK_ROOT}/cmdline-tools/${CMDLINE_VERSION}/bin:${ANDROID_SDK_ROOT}/platform-tools"' >> /workspaces/.bashrc

rm -rf /tmp/keys
