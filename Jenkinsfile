pipeline {
    agent any

    environment {
        BASE_DIR = "/opt/bus_booking"
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
                sudo mkdir -p $BASE_DIR
                sudo chown -R $USER:$USER $BASE_DIR

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
                cd $BASE_DIR

                echo "=== Removing old project folders ==="
                rm -rf bus_booking
                rm -rf bus-booking-app

                echo "=== Cloning latest code ==="
                git clone https://github.com/patilsahana1234/bus_booking.git

                echo "=== Moving actual application folder ==="
                mv bus_booking/bus-booking-app $BASE_DIR/

                echo "=== Cleaning leftover ==="
                rm -rf bus_booking
                '''
            }
        }

        stage('Create build_deploy.sh') {
            steps {
                sh '''
                cd $APP_DIR

                echo "=== Creating fresh build_deploy.sh ==="

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

echo "=== Stopping existing app if running ==="
PID=$(pgrep -f "$DEPLOY_DIR/$WAR_NAME" || true)
if [ -n "$PID" ]; then
    pkill -f "$DEPLOY_DIR/$WAR_NAME"
    sleep 5
fi

echo "=== Building Project ==="
mvn clean package -DskipTests

echo "=== Copying WAR ==="
WAR_FILE=$(find $TARGET_DIR -name "*.war" | head -n 1)
cp "$WAR_FILE" "$DEPLOY_DIR/$WAR_NAME"

echo "=== Starting Application on Port $PORT ==="
nohup java -jar "$DEPLOY_DIR/$WAR_NAME" --server.port=$PORT > "$LOG_FILE" 2>&1 &

sleep 30

echo "=== Checking Health ==="
if curl -s http://localhost:$PORT/actuator/health | grep -q "UP"; then
    echo "Application running on port $PORT"
else
    echo "Startup failed. Check logs at $LOG_FILE"
fi
EOF

                chmod +x build_deploy.sh
                '''
            }
        }

        stage('Build and Deploy') {
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
