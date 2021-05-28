#! /bin/bash

echo "Setting up necessary files!"

git clone https://baalajimaestro:${GH_PERSONAL_TOKEN}@github.com/baalajimaestro/keys /tmp/keys
cd /tmp/keys
mkdir ~/.ssh
mv id_ed25519 ~/.ssh/id_ed25519
cat authorized_keys >> ~/.ssh/authorized_keys
mv baalajimaestro.gpg /tmp

echo "Import GPG keys yourself, placed in /tmp"
git config --global user.name baalajimaestro
git config --global user.email "me@baalajimaestro.me"
git config --global commit.gpgsign true
git config --global user.signingkey 35EA585CF08135747CE5DDB4F93C394FE9BBAFD5
git config --global core.editor nano
git config --global push.gpgSign if-asked
git config --global init,defaultBranch master

cd ..
rm -rf /tmp/keys

/usr/sbin/sshd -p 2222
echo "SSH Daemon started!"

echo 'export GPG_TTY=$(tty)' >> ~/.bashrc

sudo mount -t tmpfs -o size=8G /dev/null /dev/shm
sleep 2

echo "Starting Docker..."
sudo nohup dockerd > /dev/null 2>&1 &
echo "Docker daemon started..."
