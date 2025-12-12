#!/bin/bash
# Ubuntu Tomcat 9 install script (tested on Ubuntu 20.04/22.04)
set -e
TOMCAT_USER=tomcat
TOMCAT_GROUP=tomcat
TOMCAT_VERSION=9.0.73
INSTALL_DIR=/opt/tomcat

echo "Installing OpenJDK and utilities..."
sudo apt-get update
sudo apt-get install -y default-jdk wget curl unzip

echo "Creating tomcat user and group..."
sudo groupadd --force $TOMCAT_GROUP
sudo useradd -s /bin/false -g $TOMCAT_GROUP -d $INSTALL_DIR $TOMCAT_USER || true

echo "Downloading Tomcat..."
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
sudo mkdir -p $INSTALL_DIR
sudo tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C $INSTALL_DIR --strip-components=1
sudo chown -R $TOMCAT_USER:$TOMCAT_GROUP $INSTALL_DIR
sudo chmod +x $INSTALL_DIR/bin/*.sh

echo "Create systemd service..."
sudo bash -c 'cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1-openjdk
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment="CATALINA_OPTS=-Xms256M -Xmx512M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

echo "Reload systemd and start tomcat..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

echo "Tomcat installed and started. Check status with: sudo systemctl status tomcat"
