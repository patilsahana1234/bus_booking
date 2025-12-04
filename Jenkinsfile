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
                        sudo wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.30/bin/apache-tomcat-10.1.30.tar.gz
                        sudo tar -xzf apache-tomcat-10.1.30.tar.gz
                        sudo mv apache-tomcat-10.1.30 tomcat10
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
                if [ ! -d /opt/tomcat10/webapps" ]; then
                    echo "Error: Tomcat webapps directory does not exist!"
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

        stage('Verify Deployment') {
            steps {
                sh '''
                echo "Waiting 10 seconds for Tomcat to start..."
                sleep 10

                if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/bus-booking-app/ | grep -q "200"; then
                    echo "Deployment successful!"
                else
                    echo "Deployment failed!"
                    exit 1
                fi
                '''
            }
        }
    }
}
