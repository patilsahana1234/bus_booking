pipeline {
    agent { label 'java' }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Run Application') {
            steps {
                sh '''
                    echo "Starting Spring Boot with nohup..."
                    nohup mvn spring-boot:run > app.log 2>&1 &
                    echo $! > app.pid
                    sleep 10
                '''
            }
        }

        stage('Validate Application') {
            steps {
                sh '''
                    echo "Waiting for app on 8080..."

                    for i in {1..20}; do
                        if curl -s http://localhost:8080 >/dev/null; then
