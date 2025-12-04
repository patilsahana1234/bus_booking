pipeline {
    agent any

    environment {
        JAVA_HOME = tool(name: 'JDK17', type: 'jdk')
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        BASE_DIR = "/opt/bus_booking"           // Base folder for cloning
        TOMCAT_DIR = "/opt/tomcat10"
        WAR_NAME = "bus-booking-app.war"
        APP_PORT = "8081"
    }

    stages {

        stage('Prepare Environment') {
            steps {
                sh '''
                #!/bin/bash
                # Create base directory
                sudo mkdir -p $BASE_DIR
                sudo chown -R $USER:$USER $BASE_DIR

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
                cd $BASE_DIR
                if [ -d "bus_booking/.git" ]; then
                    cd bus_booking
                    git fetch --all
                    git reset --hard origin/main
                else
                    git clone https://github.com/patilsahana1234/bus_booking.git bus_booking
                fi
                '''
            }
        }

        stage('Detect Maven Project') {
            steps {
                sh '''
                cd $BASE_DIR/bus_booking
                # Look for pom.xml recursively
                POM_PATH=$(find . -name "pom.xml" | head -n 1)
                if [ -z "$POM_PATH" ]; then
                    echo "Error: pom.xml not found!"
                    exit 1
                fi

                # Set the directory containing pom.xml
                APP_DIR=$(dirname $POM_PATH)
                echo "Detected Maven project in: $APP_DIR"
                echo $APP_DIR > detected_app_dir.txt
                '''
            }
        }

        stage('Build WAR') {
            steps {
                sh '''
                APP_DIR=$(cat $BASE_DIR/bus_booking/detected_app_dir.txt)
                cd $BASE_DIR/bus_booking/$APP_DIR
                mvn clean package -DskipTests

                # Get the WAR file
                WAR_FILE=$(find target -name "*.war" | head -n 1)
                if [ -z "$WAR_FILE" ]; then
                    echo "Error: WAR file not generated!"
                    exit 1
                fi
                cp $WAR_FILE $BASE_DIR/$WAR_NAME
                echo "WAR built at $BASE_DIR/$WAR_NAME"
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
                sudo cp $BASE_DIR/$WAR_NAME $TOMCAT_DIR/webapps/
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
            echo "Pipeline completed. Logs may be in $TOMCAT_DIR/logs or $BASE_DIR/$WAR_NAME"
            '''
        }
    }
}
