pipeline {
    agent any
    environment {
        JAVA_HOME = tool name: 'jdk-17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        TOMCAT_DIR = "/opt/tomcat10"
        TOMCAT_VERSION = "10.1.30"
        TOMCAT_URL = "https://downloads.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
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

        stage('Build WAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Install Tomcat (if not exists)') {
            steps {
                sh '''
                if [ ! -d "${TOMCAT_DIR}" ]; then
                    echo "==== Tomcat not found. Installing... ===="
                    sudo mkdir -p ${TOMCAT_DIR}
                    cd /tmp
                    curl -O ${TOMCAT_URL}
                    if file apache-tomcat-${TOMCAT_VERSION}.tar.gz | grep -q "gzip"; then
                        sudo tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C ${TOMCAT_DIR} --strip-components=1
                        sudo useradd -m -U -d ${TOMCAT_DIR} -s /bin/false tomcat || true
                        sudo chown -R tomcat:tomcat ${TOMCAT_DIR}
                        sudo chmod +x ${TOMCAT_DIR}/bin/*.sh
                        echo "Tomcat installed successfully."
                    else
                        echo "Error: Downloaded Tomcat file is invalid."
                        exit 1
                    fi
                else
                    echo "Tomcat already installed."
                fi
                '''
            }
        }

        stage('Deploy WAR to Tomcat') {
            steps {
                sh '''
                if [ ! -d "${TOMCAT_DIR}/webapps" ]; then
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
