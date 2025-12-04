pipeline {
    agent any


   environment {
        TOMCAT_HOST = '3.110.194.254'
        TOMCAT_USER = 'root'
        TOMCAT_DIR = '/opt/apache-tomcat-10.1.49/webapps'
        JAR_FILE = 'bus-booking-app-1.0-SNAPSHOT.war'  // Replace with the actual name of your JAR file
    }

    stages {
        stage('checkout') {
            steps {
                sh 'rm -rf bus_booking'
                sh 'git clone 'https://github.com/patilsahana1234/bus_booking.git''
            }
        }

        stage('build') {
            steps {
                script {
                    def mvnHome = tool 'Maven'
                    def mvnCMD = "${mvnHome}/bin/mvn"
                    sh "${mvnCMD} clean install"
                }
            }
        }

        stage('Show Contents of target') {
            steps {
                script {
                    // Print the contents of the target directory
                    sh 'ls -l target'
                }
            }
        }

        stage('Run JAR Locally') {
            steps {
                script {
                    // Run the JAR file using java -jar
                    sh "java -jar target/${JAR_FILE}"
                }
            }
        }

        stage('Deploy JAR to Tomcat') {
            steps {
                script {
                    // Copy JAR to Tomcat server
                    sh "scp target/${JAR_FILE} ${TOMCAT_USER}@${TOMCAT_HOST}:${TOMCAT_DIR}/"

                    // SSH into Tomcat server and restart Tomcat
                    sh "ssh ${TOMCAT_USER}@${TOMCAT_HOST} 'bash -s' < restart-tomcat.sh"

                    echo "Application deployed and Tomcat restarted"
                }
            }
        }
    }

    post {
        success {
            echo "Build, Run, and Deployment to Tomcat successful!"
        }
        failure {
            echo "Build, Run, and Deployment to Tomcat failed!"
        }
    }
}
