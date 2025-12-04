pipeline {
    agent any
    environment {
        JAVA_HOME = tool name: 'jdk17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        TOMCAT_DIR = "/opt/tomcat10"
        TOMCAT_VERSION = "10.1.30"
    }
    stages {
        stage('Check Java & Maven') {
            steps {
                sh '''
                echo "=== Check Java ==="
                java -version
                echo "=== Check Maven ==="

                if ! command -v mvn > /dev/null; then
                    echo "Maven not found. Please install Maven on Jenkins node."
                    exit 1
                fi
                mvn -version
                '''
            }
        }
        stage('Install Tomcat (if not exists)') {
            steps {
                sh '''
                echo "=== Checking Tomcat ==="
                    if [ -d "/opt/tomcat10" ]; then
                        echo "Tomcat already installed in /opt/tomcat10"
                    else
                        echo "Installing Tomcat 10..."
                        cd /opt
                        sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.49/bin/apache-tomcat-10.1.49.tar.gz
			 https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.30/bin/apache-tomcat-10.1.30.tar.gz
                        sudo tar -xzf apache-tomcat-10.1.49.tar.gz
                        sudo mv apache-tomcat-10.1.49 tomcat10
                        sudo chmod +x /opt/tomcat10/bin/*.sh
                    fi
            }
        }
        stage('Build WAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('Deploy WAR to Tomcat') {
            steps {
                sh '''
                if [ -d "${TOMCAT_DIR}/webapps" ]; then
               echo "Directory exists"
                else
    echo "Directory does not exist"
                    exit 1
                fi
                echo "Stopping Tomcat (if running)..."
                sudo ${TOMCAT_DIR}/bin/shutdown.sh || true
                echo "Removing old deployment..."
                sudo rm -rf ${TOMCAT_DIR}/webapps/bus-booking-app*
                echo "Deploying new WAR..."
                sudo cp target/bus-booking-app-1.0-SNAPSHOT.war ${TOMCAT_DIR}/webapps/
                echo "Starting Tomcat..."
                sudo ${TOMCAT_DIR}/bin/startup.sh
                '''
            }
        }
        
    }
}
