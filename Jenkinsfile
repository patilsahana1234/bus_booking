pipeline {
    agent any

    environment {
        JAVA_HOME = tool(name: 'JDK17', type: 'jdk')
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        APP_DIR = "/opt/bus_booking/bus_booking"
        TOMCAT_DIR = "/opt/tomcat10"
        WAR_NAME = "bus-booking-app-1.0-SNAPSHOT.war"
        APP_PORT = "8081"
    }

    stages {

        stage('Prepare Environment') {
            steps {
                sh '''
                #!/bin/bash
                # Ensure app folder exists
                sudo mkdir -p /opt/bus_booking
                sudo chown -R $USER:$USER /opt/bus_booking

                # Install Java if missing
                if ! java -version &>/dev/null; then
                    sudo apt-get update
                    sudo apt-get install -y openjdk-17-jdk
                fi

                # Install Maven if missing
                if ! mvn -v &>/dev/null; then
                    sudo apt-get install -y maven
                fi
                '''
            }
        }

        stage('Checkout Code') {
            steps {
                sh '''
                cd /opt/bus_booking
                if [ -d "bus_booking/.git" ]; then
                    cd bus_booking
                    git fetch --all
                    git reset --hard origin/main
                else
                    git clone https://github.com/patilsahana1234/bus_booking.git
                fi
                '''
            }
        }

        stage('Build WAR') {
            steps {
                sh '''
                cd $APP_DIR
                mvn clean package -DskipTests
                '''
            }
        }

        stage('Stop Tomcat') {
            steps {
                sh '''
                echo "Stopping Tomcat..."
                sudo $TOMCAT_DIR/bin/shutdown.sh || true
                sleep 5
                '''
            }
        }

        stage('Deploy WAR') {
            steps {
                sh '''
                echo "Cleaning old deployment..."
                sudo rm -rf $TOMCAT_DIR/webapps/bus-booking-app
                sudo rm -f $TOMCAT_DIR/webapps/$WAR_NAME

                echo "Copying new WAR..."
                sudo cp $APP_DIR/target/$WAR_NAME $TOMCAT_DIR/webapps/
                '''
            }
        }

        stage('Start Tomcat') {
            steps {
                sh '''
                echo "Starting Tomcat..."
                sudo $TOMCAT_DIR/bin/startup.sh
                sleep 10
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                echo "Checking application on port $APP_PORT..."
                curl -I http://localhost:$APP_PORT || echo "Application may not have started yet."
                '''
            }
        }
    }

    post {
        always {
            sh '''
            echo "Pipeline completed. Logs are in $APP_DIR/target"
            '''
        }
    }
}
