pipeline {
    agent any

    environment {
        TOMCAT_IP = "47.130.3.103"
        TOMCAT_USER = "ubuntu"
        TOMCAT_WAR_PATH = "/opt/tomcat/webapps"
        SSH_CRED_ID = "ec2-key"
    }

    parameters {
        choice(name: 'DEPLOY_TO', choices: ['blue','green'], description: 'Which environment to deploy to')
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/rubesh-555/my-repo.git'
            }
        }

        stage('Build WAR') {
            steps {
                dir('maven-demo') {
                    sh "mvn clean package -DskipTests"
                }
            }
        }

        stage('Blue/Green Deploy') {
            steps {
                script {
                    def targetColor = params.DEPLOY_TO ?: 'blue'
                    def warFile = "maven-demo/target/maven-demo.war"

                    sshagent(credentials: [env.SSH_CRED_ID]) {

                        sh """
                            scp -o StrictHostKeyChecking=no ${warFile} ${TOMCAT_USER}@${TOMCAT_IP}:${TOMCAT_WAR_PATH}/ROOT_${targetColor}.war
                        """

                        sh """
                            ssh -o StrictHostKeyChecking=no ${TOMCAT_USER}@${TOMCAT_IP} \
                            "sudo cp ${TOMCAT_WAR_PATH}/ROOT_${targetColor}.war ${TOMCAT_WAR_PATH}/ROOT.war && sudo systemctl restart tomcat"
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful to ${env.TOMCAT_IP}"
        }
        failure {
            echo "Deployment failed."
        }
    }
}
