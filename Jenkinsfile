pipeline {
    agent any

    environment {
        APP_DIR = "/opt/bus_booking/bus-booking-app"
        JAVA_HOME = "/usr/lib/jvm/java-17-openjdk-amd64"
        PATH = "${JAVA_HOME}/bin:${env.PATH}:/usr/share/maven/bin"
        APP_PORT = "8081"
        WAR_NAME = "bus-booking-app.war"
    }

    stages {

        stage('Prepare Environment') {
            steps {
                sh '''
                #!/bin/bash
                # Install Java if missing
                if ! java -version &>/dev/null; then
                    echo "Installing Java 17..."
                    sudo apt-get update
                    sudo apt-get install -y openjdk-17-jdk
                else
                    echo "Java is already installed"
                fi

                # Install Maven if missing
                if ! mvn -v &>/dev/null; then
                    echo "Installing Maven..."
                    sudo apt-get install -y maven
                else
                    echo "Maven is already installed"
                fi

                # Create app directory
                sudo mkdir -p $APP_DIR
                sudo chown -R $USER:$USER $APP_DIR
                '''
            }
        }

        stage('Checkout Code') {
            steps {
                sh '''
                cd $APP_DIR
                if [ -d ".git" ]; then
                    git fetch --all
                    git reset --hard origin/main
                else
                    git clone https://github.com/patilsahana1234/bus_booking.git $APP_DIR
                fi
                '''
            }
        }

        stage('Create build_deploy.sh if Missing') {
            steps {
                sh '''
                cd $APP_DIR
                if [ ! -f build_deploy.sh ]; then
                    echo "Creating build_deploy.sh..."
                    cat << 'EOF' > build_deploy.sh
#!/bin/bash
set -e
APP_DIR="$(pwd)"
TARGET_DIR="$APP_DIR/target"
WAR_NAME="bus-booking-app.war"
DEPLOY_DIR="$APP_DIR/deploy"
LOG_FILE="$DEPLOY_DIR/app.log"
PORT=8081

mkdir -p "$DEPLOY_DIR"
PKILL_CMD=$(pgrep -f "$DEPLOY_DIR/$WAR_NAME" || true)
if [ -n "$PKILL_CMD" ]; then
    pkill -f "$DEPLOY_DIR/$WAR_NAME"
    sleep 5
fi
mvn clean package -DskipTests
WAR_FILE=$(find $TARGET_DIR -name "*.war" | head -n 1)
cp "$WAR_FILE" "$DEPLOY_DIR/$WAR_NAME"
nohup java -jar "$DEPLOY_DIR/$WAR_NAME" --server.port=$PORT > "$LOG_FILE" 2>&1 &
sleep 30
if curl -s http://localhost:$PORT/actuator/health | grep -q "UP"; then
    echo "Application running on port $PORT"
else
    echo "Check logs at $LOG_FILE"
fi
EOF
                    chmod +x build_deploy.sh
                else
                    echo "build_deploy.sh already exists"
                fi
                '''
            }
        }

        stage('Build and Deploy Application') {
            steps {
                sh '''
                cd $APP_DIR
                ./build_deploy.sh
                '''
            }
        }
    }

    post {
        always {
            sh '''
            echo "Pipeline completed. Application running on port $APP_PORT"
            echo "Logs: $APP_DIR/deploy/app.log"
            '''
        }
    }
}
