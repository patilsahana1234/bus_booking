pipeline {
    agent any

    environment {
        JAVA_HOME = tool(name: 'JDK17', type: 'jdk')
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        BASE_DIR = "/opt/bus_booking"     // Base folder for cloning repo
        TOMCAT_DIR = "/opt/tomcat10"
        WAR_NAME = "bus-booking-app.war"
        APP_PORT = "8081"
    }

    stages {

        stage('Prepare Environment') {
            steps {
                sh '''
                #!/bin/bash
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
                echo "=== Checking out Correct Repo & Branch ==="

                rm -rf /opt/bus_booking
               mkdir -p /opt/bus_booking
                cd /opt/bus_booking

                git clone -b feature-1 https://github.com/patilsahana1234/bus_booking.git
                echo "=== Code Pulled ==="
                '''
            }
        }

        stage('Detect Maven Project') {
    steps {
        sh '''
        set -e  # Exit on any error
        cd "$BASE_DIR/bus_booking"

        # Find the first pom.xml
        POM_PATH=$(find . -name "pom.xml" | head -n 1)
        if [ -z "$POM_PATH" ]; then
            echo "Error: pom.xml not found in repo!"
            exit 1
        fi

        APP_DIR=$(dirname "$POM_PATH")
        echo "Detected Maven project at: $APP_DIR"

        # Save detected directory to file for next stage
        echo "$APP_DIR" > detected_app_dir.txt
        '''
    }
}

stage('Build WAR') {
    steps {
        sh '''
        set -e
        APP_DIR=$(cat "$BASE_DIR/bus_booking/detected_app_dir.txt")
        cd "$BASE_DIR/bus_booking/$APP_DIR"

        echo "Building WAR..."
        mvn clean package -DskipTests

        # Find the WAR file
        WAR_FILE=$(find target -name "*.war" | head -n 1)
        if [ -z "$WAR_FILE" ]; then
            echo "Error: WAR file not generated!"
            exit 1
        fi

        # Copy WAR to consistent location
        cp "$WAR_FILE" "$BASE_DIR/$WAR_NAME"
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

                echo "Deploying new WAR..."
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
                echo "Waiting for application to start..."
                for i in $(seq 1 12); do
                    curl -I http://localhost:$APP_PORT && break
                    echo "Waiting for app... ($i/12)"
                    sleep 10
                done
                '''
            }
        }
    }

    post {
        always {
            sh '''
            echo "Pipeline completed. WAR is at $BASE_DIR/$WAR_NAME"
            echo "Check Tomcat logs for more details: $TOMCAT_DIR/logs"
            '''
        }
    }
}
