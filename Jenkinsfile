pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        TOMCAT_HOME   = "/opt/tomcat10"
        TOMCAT_VERSION = "10.1.30"
        TOMCAT_USER    = "tomcat"
        WAR_NAME       = "bus-booking-app-1.0-SNAPSHOT.war"
    }

    stages {

        stage('Ensure Java & Maven') {
            steps {
                sh '''
                    echo "=== Check Java ==="
                    if command -v java >/dev/null 2>&1; then
                        echo "Java already installed: $(java -version 2>&1 | head -n 1)"
                    else
                        echo "Java not found. Installing OpenJDK 17..."
                        sudo apt update -y
                        sudo apt install -y openjdk-17-jdk
                    fi

                    echo "=== Check Maven ==="
                    if command -v mvn >/dev/null 2>&1; then
                        echo "Maven already installed: $(mvn -v | head -n 1)"
                    else
                        echo "Maven not found. Installing Maven..."
                        sudo apt install -y maven
                    fi
                '''
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/vivek-co/bus_booking.git'
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Install Tomcat (if Not Exists)') {
            steps {
                sh '''
                    if [ ! -d "${TOMCAT_HOME}" ]; then
                        echo "==== Tomcat not found. Installing... ===="

                        # Install Java if missing
                        if ! type java >/dev/null 2>&1; then
                            sudo apt update -y
                            sudo apt install -y openjdk-17-jdk
                        fi

                        # Create Tomcat user
                        sudo useradd -m -U -d /opt/tomcat -s /bin/false ${TOMCAT_USER} || true

                        # Download Tomcat
                        cd /tmp
                        curl -O https://dlcdn.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

                        # Extract
                        sudo mkdir -p ${TOMCAT_HOME}
                        sudo tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C ${TOMCAT_HOME} --strip-components=1

                        # Permissions
                        sudo chown -R ${TOMCAT_USER}:${TOMCAT_USER} ${TOMCAT_HOME}
                        sudo chmod +x ${TOMCAT_HOME}/bin/*.sh

                        # Systemd service
                        sudo bash -c "cat > /etc/systemd/system/tomcat10.service" <<EOF
[Unit]
Description=Apache Tomcat 10
After=network.target

[Service]
Type=forking
User=${TOMCAT_USER}
Group=${TOMCAT_USER}
Environment=JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
Environment=CATALINA_BASE=${TOMCAT_HOME}
Environment=CATALINA_HOME=${TOMCAT_HOME}
Environment=CATALINA_PID=${TOMCAT_HOME}/temp/tomcat.pid
ExecStart=${TOMCAT_HOME}/bin/startup.sh
ExecStop=${TOMCAT_HOME}/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

                        sudo systemctl daemon-reload
                        sudo systemctl enable tomcat10
                        sudo systemctl start tomcat10
                    else
                        echo "==== Tomcat already installed at ${TOMCAT_HOME} ===="
                    fi
                '''
            }
        }

        stage('Deploy WAR to Tomcat') {
            steps {
                sh '''
                    echo "Stopping Tomcat..."
                    sudo systemctl stop tomcat10 || true

                    echo "Removing old deployment..."
                    sudo rm -rf ${TOMCAT_HOME}/webapps/bus-booking-app*

                    echo "Deploying new WAR..."
                    sudo cp target/${WAR_NAME} ${TOMCAT_HOME}/webapps/

                    echo "Starting Tomcat..."
                    sudo systemctl start tomcat10
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    echo "Waiting for 15 seconds..."
                    sleep 15

                    echo "Checking Application Status..."
                    curl -I http://localhost:8080/bus-booking-app || true
                '''
            }
        }
    }
}
