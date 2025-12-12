pipeline {
    agent any

    environment {
        TOMCAT_IP = "47.130.3.103"               // change if needed
        TOMCAT_USER = "ubuntu"                    // change to your server user
        TOMCAT_WAR_PATH = "/opt/tomcat/webapps"   // Tomcat webapps path
        SSH_CRED_ID = "ec2-key"               // Jenkins credential ID (SSH private key)
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/YOUR-USERNAME/tomcat-deploy-pipeline.git'
            }
        }

        stage('Build WAR') {
            steps {
                dir('maven-demo') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Blue/Green Deploy') {
            steps {
                script {
                    def targetColor = params.DEPLOY_TO ?: 'blue' // default param fallback
                    def warFile = "maven-demo/target/maven-demo.war"
                    sshagent (credentials: [env.SSH_CRED_ID]) {
                        // upload as ROOT_blue.war or ROOT_green.war
                        sh '''scp -o StrictHostKeyChecking=no ${warFile} ${TOMCAT_USER}@${TOMCAT_IP}:${TOMCAT_WAR_PATH}/ROOT_${targetColor}.war
                            ssh -o StrictHostKeyChecking=no ${TOMCAT_USER}@${TOMCAT_IP} \
                            'sudo cp ${TOMCAT_WAR_PATH}/ROOT_${targetColor}.war ${TOMCAT_WAR_PATH}/ROOT.war && sudo systemctl restart tomcat'
                        '''
                    }
                }
            }
        }
    }

    parameters {
        choice(name: 'DEPLOY_TO', choices: ['blue','green'], description: 'Which environment to deploy to (blue or green)')
    }

    post {
        success {
            echo "Deployed to Tomcat (${env.TOMCAT_IP}) successfully."
        }
        failure {
            echo "Deployment failed."
        }
    }
}
