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
                            echo "App is running!"
                            exit 0
                        fi
                        echo "Not responding yet... retry $i"
                        sleep 3
                    done

                    echo "App FAILED to start!"
                    tail -n 200 app.log || true
                    exit 1
                '''
            }
        }

        stage('Wait for 2 minutes') {
            steps {
                sleep(time: 2, unit: 'MINUTES')
            }
        }

        stage('Stop Application') {
            steps {
                sh '''
                    if [ -f app.pid ]; then
                        PID=$(cat app.pid)
                        echo "Stopping app with PID $PID"
                        kill $PID || true
                    fi
                '''
            }
        }
    }

    post {
        always {
            echo "Cleaning up..."
        }
    }
}
