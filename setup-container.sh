#! /bin/bash

echo "Setting up necessary files!"

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

cd ..
rm -rf /tmp/keys

sudo /usr/sbin/sshd
echo "SSH Daemon started, login with ssh -p 2222 localhost"

echo "Starting Docker..."
sudo nohup /usr/local/bin/docker-init.sh &
echo "Docker daemon started..."
