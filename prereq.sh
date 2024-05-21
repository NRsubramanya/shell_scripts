apt update -y
apt install git -y
apt install ansible -y
apt install nano -y 
apt install net-tools
apt install wget -y
apt install curl -y

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce=5:24.0.5-1~ubuntu.20.04~focal docker-ce-cli=5:24.0.5-1~ubuntu.20.04~focal containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world

sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker --version
docker-compose --version

sudo apt-get update && sudo apt-get install -y openjdk-8-jdk

ssh-keygen -t rsa -C subramanya@platformatory.com



