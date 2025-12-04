pipeline {
    agent any

    environment {
        JAVA_HOME = tool name: 'JDK17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        TOMCAT_DIR = "/opt/tomcat10"
        TOMCAT_VERSION = "10.1.49"
        WAR_NAME = "bus-booking-app.war"
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

        stage('Install Tomcat 10 If Missing') {
            steps {
                sh '''
                if [ -d "$TOMCAT_DIR" ]; then
                    echo "Tomcat already exists"
                else
                    echo "Installing Tomcat 10..."
                    cd /opt
                    sudo wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.30/bin/apache-tomcat-10.1.49.tar.gz
                    sudo tar -xzf apache-tomcat-10.1.49.tar.gz
                    sudo mv apache-tomcat-10.1.49 tomcat10
                    sudo chmod +x $TOMCAT_DIR/bin/*.sh
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
                sudo rm -rf $TOMCAT_DIR/webapps/bus-booking-app*
                sudo rm -f $TOMCAT_DIR/webapps/ROOT.war

                echo "Deploying WAR..."
                sudo cp target/*.war $TOMCAT_DIR/webapps/ROOT.war

                echo "Starting Tomcat..."
                sudo $TOMCAT_DIR/bin/startup.sh
                '''
            }
        }
    }
}
