pipeline {
    agent any

    environment {
        JAVA_HOME = tool(name: 'JDK17', type: 'jdk')
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        TOMCAT_DIR = "/opt/tomcat10"
        WAR_NAME = "bus_booking.war"   // Renamed WAR for browser access
        APP_PORT = "8081"
    }

    stages {

        stage('Prepare Environment') {
            steps {
                sh '''
                set -e
                if ! java -version &>/dev/null; then
                    sudo apt-get update
                    sudo apt-get install -y openjdk-17-jdk
                fi
                if ! mvn -v &>/dev/null; then
                    sudo apt-get install -y maven
                fi
                '''
            }
        }

        stage('Checkout Code') {
            steps {
                sh '''
                set -e
                if [ -d "$WORKSPACE/bus_booking/.git" ]; then
                    cd "$WORKSPACE/bus_booking"
                    git fetch --all
                    git reset --hard origin/feature-1
                else
                    git clone -b feature-1 https://github.com/patilsahana1234/bus_booking.git "$WORKSPACE/bus_booking"
                fi
                '''
            }
        }

        stage('Detect Maven Project') {
            steps {
                sh '''
                set -e
                cd "$WORKSPACE/bus_booking"
                POM_PATH=$(find . -name "pom.xml" | head -n 1)
                if [ -z "$POM_PATH" ]; then
                    echo "Error: pom.xml not found!"
                    exit 1
                fi
                APP_DIR=$(dirname "$POM_PATH")
                echo "Detected Maven project at: $APP_DIR"
                echo "$APP_DIR" > "$WORKSPACE/detected_app_dir.txt"
                '''
            }
        }

        stage('Build WAR') {
            steps {
                sh '''
                set -e
                APP_DIR=$(cat "$WORKSPACE/detected_app_dir.txt")
                cd "$WORKSPACE/bus_booking/$APP_DIR"
                echo "Building WAR..."
                mvn clean package -DskipTests

                WAR_FILE=$(find target -name "*.war" | head -n 1)
                if [ -z "$WAR_FILE" ]; then
                    echo "Error: WAR file not generated!"
                    exit 1
                fi
                cp "$WAR_FILE" "$WORKSPACE/$WAR_NAME"
                echo "WAR built at $WORKSPACE/$WAR_NAME"
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
                sudo rm -rf $TOMCAT_DIR/webapps/bus_booking
                sudo rm -f $TOMCAT_DIR/webapps/$WAR_NAME

                echo "Deploying new WAR..."
                sudo cp "$WORKSPACE/$WAR_NAME" $TOMCAT_DIR/webapps/
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
                    curl -I http://localhost:$APP_PORT/bus_booking && break
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
            echo "Pipeline completed. WAR is at $WORKSPACE/$WAR_NAME"
            echo "Access the app in browser: http://<server-ip>:$APP_PORT/bus_booking/"
            echo "Check Tomcat logs for more details: $TOMCAT_DIR/logs"
            '''
        }
    }
}
