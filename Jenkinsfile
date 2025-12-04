pipeline {
    agent any

    environment {
        JAVA_HOME = tool name: 'jdk17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        TOMCAT_DIR = "/opt/tomcat10"
        TOMCAT_VERSION = "10.1.49"
    }

    stages {

        stage('Check Java & Maven') {
            steps {
                sh """
                echo "=== Check Java Version ==="
                java -version

                echo "=== Check Maven Version ==="
                if ! command -v mvn > /dev/null; then
                    echo "Maven not installed on Jenkins node!"
                    exit 1
                fi
                mvn -version
                """
            }
        }

        stage('Install Tomcat 10 (if not exists)') {
            steps {
                sh """
                echo "=== Checking Tomcat 10 installation ==="

                if [ -d "$TOMCAT_DIR" ]; then
                    echo "Tomcat 10 already installed at $TOMCAT_DIR"
                else
                    echo "Installing Tomcat 10"

                    cd /opt
                    sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
                    sudo tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz
                    sudo mv apache-tomcat-${TOMCAT_VERSION} tomcat10
                    sudo chmod +x $TOMCAT_DIR/bin/*.sh

                    echo "Tomcat 10 installation completed."
                fi
                """
            }
        }

        stage('Build WAR') {
            steps {
                sh "mvn clean package -DskipTests"
            }
        }

        stage('Deploy WAR to Tomcat 10') {
            steps {
                sh """
                echo "=== Verifying Tomcat webapps directory ==="
                if [ -d "$TOMCAT_DIR/webapps" ]; then
                    echo "webapps directory exists"
                else
                    echo "webapps directory missing!"
                    exit 1
                fi

                echo "=== Stopping Tomcat 10 ==="
                sudo $TOMCAT_DIR/bin/shutdown.sh || true

                echo "=== Cleaning old deployment ==="
                sudo rm -rf $TOMCAT_DIR/webapps/bus_booking*
                sudo rm -f $TOMCAT_DIR/webapps/bus_booking.war

                echo "=== Deploying New WAR ==="
                sudo cp target/*.war $TOMCAT_DIR/webapps/bus_booking.war

                echo "=== Starting Tomcat 10 ==="
                sudo $TOMCAT_DIR/bin/startup.sh

                echo "Deployment Completed!"
                """
            }
        }
    }
}
