pipeline {
    agent any
    environment {
        JAVA_HOME = tool name: 'jdk17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        TOMCAT_DIR = "/opt/tomcat9"
        TOMCAT_VERSION = "9.0.112"
    }
    stages {
        stage('Check Java & Maven') {
            steps {
                sh """
                echo "=== Check Java ==="
                java -version
                echo "=== Check Maven ==="
                if ! command -v mvn > /dev/null; then
                    echo "Maven not found. Please install Maven on Jenkins node."
                    exit 1
                fi
                mvn -version
                """
            }
        }

        stage('Install Tomcat (if not exists)') {
            steps {
                sh """
                echo "=== Checking Tomcat ==="
                if [ -d "\$TOMCAT_DIR" ]; then
                    echo "Tomcat already installed in \$TOMCAT_DIR"
                else
                    echo "Installing Tomcat 9..."
                    cd /opt
                    sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.112/bin/apache-tomcat-9.0.112.tar.gz
                    sudo tar -xzf apache-tomcat-9.0.112.tar.gz
                    sudo mv apache-tomcat-9.0.112 tomcat9
                    sudo chmod +x \$TOMCAT_DIR/bin/*.sh
                fi
                """
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Deploy WAR to Tomcat') {
            steps {
                sh """
                if [ -d "\$TOMCAT_DIR/webapps" ]; then
                    echo "Directory exists"
                else
                    echo "Directory does not exist"
                    exit 1
                fi

                echo "Stopping Tomcat (if running)..."
                sudo \$TOMCAT_DIR/bin/shutdown.sh || true

                echo "Removing old deployment..."
                sudo rm -rf \$TOMCAT_DIR/webapps/bus-booking-app*

                echo "Deploying new WAR..."
                sudo cp target/bus-booking-app-1.0-SNAPSHOT.war $TOMCAT_DIR/webapps/bus_booking.war


                echo "Starting Tomcat..."
                sudo \$TOMCAT_DIR/bin/startup.sh
                """
            }
        }
    }
}
