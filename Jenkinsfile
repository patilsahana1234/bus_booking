pipeline {
    agent any

    environment {
        JAVA_HOME = tool name: 'JDK17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        TOMCAT_DIR = "/opt/tomcat10"
        WAR_NAME = "bus_booking.war"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git(
                    url: 'https://github.com/your-repo/bus_booking.git',
                    branch: 'main',
                    credentialsId: 'github-bus_booking-token' // Use your Jenkins credentials ID here
                )
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Stop Tomcat') {
            steps {
                echo 'Stopping Tomcat...'
                sh "sudo ${TOMCAT_DIR}/bin/shutdown.sh || true"
            }
        }

        stage('Clean Old Deployment') {
            steps {
                echo 'Cleaning old deployment...'
                sh "sudo rm -rf ${TOMCAT_DIR}/webapps/bus_booking"
                sh "sudo rm -f ${TOMCAT_DIR}/webapps/${WAR_NAME}"
            }
        }

        stage('Deploy WAR to Tomcat') {
            steps {
                echo 'Deploying new WAR...'
                sh "sudo cp target/${WAR_NAME} ${TOMCAT_DIR}/webapps/"
            }
        }

        stage('Start Tomcat') {
            steps {
                echo 'Starting Tomcat...'
                sh "sudo ${TOMCAT_DIR}/bin/startup.sh"
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                sh """
                    for i in {1..10}; do
                        curl -I http://localhost:8080/bus_booking && break
                        sleep 3
                    done
                """
            }
        }
    }
}
