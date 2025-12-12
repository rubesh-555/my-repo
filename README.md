# tomcat-deploy-pipeline

This repository contains:
- Jenkins pipeline (Declarative) with a simple Blue/Green deployment flow.
- `tomcat_install.sh` — a script to install Tomcat 9 on Ubuntu and create a systemd service.
- `maven-demo/` — a minimal Maven WAR demo app that builds `maven-demo.war`.
- `.gitignore`

## How it works
1. Jenkins builds the WAR from `maven-demo/` using Maven.
2. The pipeline uploads the WAR as `ROOT_blue.war` or `ROOT_green.war` to your Tomcat `webapps` directory.
3. The pipeline then copies the selected `ROOT_<color>.war` to `ROOT.war` on the server and restarts Tomcat — effectively switching traffic to the new version.

## Before you run
- Create an SSH credential in Jenkins (private key) and set the credentials ID in the Jenkinsfile (`SSH_CRED_ID`).
- Ensure Jenkins can reach your server (firewall/port 22).
- On the remote server, run `tomcat_install.sh` (as root or using sudo) to install Tomcat under `/opt/tomcat`.
- Update `TOMCAT_USER`, `TOMCAT_IP`, and `TOMCAT_WAR_PATH` in the Jenkinsfile if different.

Tomcat is expected to be accessible at: http://54.169.199.41:8080/

## Quick usage
- Push this repo to GitHub and update the `git` URL in the Jenkinsfile.
- Create a Jenkins pipeline job pointing to this repo and branch `main`.
- Run the job and choose parameter `DEPLOY_TO = blue` or `green`.

