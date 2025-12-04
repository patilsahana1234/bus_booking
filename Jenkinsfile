pipeline {
    agent any

    environment {
        JAVA_HOME = tool name: 'JDK17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        TOMCAT_DIR = "/opt/tomcat10"
        TOMCAT_VERSION = "10.1.49"
        WAR_NAME = "bus-booking-app.war"
        CONTEXT_NAME = "bus_booking"
        TOMCAT_PORT = "8081" // Use a different port to avoid Jenkins conflict
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'feature-1',
                    url: 'https://github.com/patilsahana1234/bus_booking.git'
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Install Tomcat If Missing') {
            steps {
                sh '''
                if [ -d "$TOMCAT_DIR" ]; then
                    echo "Tomcat already exists"
                else
                    echo "Installing Tomcat 10..."
                    cd /opt
                    sudo wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.49/bin/apache-tomcat-10.1.49.tar.gz
                    sudo tar -xzf apache-tomcat-10.1.49.tar.gz
                    sudo mv apache-tomcat-10.1.49 tomcat10
                    sudo chmod +x $TOMCAT_DIR/bin/*.sh

                    # Change Tomcat port to avoid conflict with Jenkins
                    sudo sed -i "s/port=\"8080\"/port=\"$TOMCAT_PORT\"/" $TOMCAT_DIR/conf/server.xml
                fi
                '''
            }
        }

        stage('Deploy WAR to Tomcat') {
            steps {
                sh '''
                echo "Stopping Tomcat..."
                sudo $TOMCAT_DIR/bin/shutdown.sh || true

                echo "Cleaning old deployment..."
                sudo rm -rf $TOMCAT_DIR/webapps/$CONTEXT_NAME*

                echo "Deploying WAR to context: $CONTEXT_NAME..."
                sudo cp target/$WAR_NAME $TOMCAT_DIR/webapps/$CONTEXT_NAME.war

                echo "Starting Tomcat..."
                sudo $TOMCAT_DIR/bin/startup.sh

                # Wait 10 seconds for Tomcat to start
                sleep 10
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    def url = "http://localhost:${env.TOMCAT_PORT}/${env.CONTEXT_NAME}/"
                    def status = sh(script: "curl -o /dev/null -s -w '%{http_code}' $url", returnStdout: true).trim()

                    if (status != '200') {
                        error "Deployment failed! App not reachable at $url (HTTP $status)"
                    } else {
                        echo "Deployment successful! App running at $url"
                    }
                }
            }
        }
    }
}
