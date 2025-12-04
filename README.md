# Bus Booking Application

This repository contains the source code for the Bus Booking Application built with Spring Boot. It includes the necessary steps to build, deploy, and test the application, as well as CI/CD pipelines using both GitHub Actions and Jenkins.

## Prerequisites

- Java 17 or above
- Maven 3.6 or above
- GitHub repository for CI/CD (optional)
- Jenkins for Jenkins pipeline (optional)

## Project Setup

### Clone the Repository

```bash
git clone https://github.com/yourusername/bus-booking-app.git
cd bus-booking-app
Setting up Maven and Java
Ensure that Java 17 (or above) and Maven are installed on your machine. You can verify the installation by running:

bash
Copy code
java -version
mvn -version
If Java or Maven are not installed, follow the installation instructions for your operating system:

Install Java
Install Maven
Build and Run the Application Locally
Use the build_deploy.sh script to build, run, and stop the application.

build_deploy.sh
bash
Copy code
================================================================================================================================================
#!/bin/bash

# Step 1: Set up Maven environment
export MAVEN_HOME=/usr/local/maven
export PATH=$MAVEN_HOME/bin:$PATH

# Step 2: Clean and install the project
echo "Building the project..."
mvn clean install

# Step 3: Run the Spring Boot application
echo "Running the Spring Boot application..."
mvn spring-boot:run &  # Run the application in the background

# Wait for the application to start up
echo "Waiting for the application to start..."
sleep 15  # Adjust the time as per the application startup time

# Step 4: Validate that the application is running
echo "Validating if the application is running..."
RESPONSE=$(curl --write-out "%{http_code}" --silent --output /dev/null http://localhost:8080)
if [ "$RESPONSE" -eq 200 ]; then
    echo "The app is running successfully!"
else
    echo "The app failed to start. HTTP response code: $RESPONSE"
    exit 1
fi

# Step 5: Wait for 5 minutes (300 seconds)
echo "App has been running for 5 minutes. Waiting..."
sleep 300  # Wait for 5 minutes

# Step 6: Gracefully stop the Spring Boot application
echo "Stopping the app gracefully..."
mvn spring-boot:stop
Instructions to Run Locally
Make the script executable:

bash
Copy code
chmod +x build_deploy.sh
Execute the script to build, deploy, and stop the application:

bash
Copy code
./build_deploy.sh
The script will:

Build the project using Maven.
Start the Spring Boot application.
Validate if the application is running by checking the HTTP status.
Run the application for 5 minutes.
Gracefully stop the Spring Boot application after 5 minutes.
GitHub Actions CI/CD Pipeline
This project includes a GitHub Actions CI pipeline that automatically builds, tests, and deploys the Spring Boot application whenever you push changes to the repository.

==========================================================================================================================================================================

.github/workflows/java-ci.yml
yaml
Copy code
name: Build, Deploy, and Upload Artifacts

on:
  push:
    branches:
      - '**'
  pull_request:
    branches:
      - master
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      # Checkout the repository
      - name: Checkout Code
        uses: actions/checkout@v3

      # Set up Java
        - name: Set up Java
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      # Cache Maven dependencies
      - name: Cache Maven dependencies
        uses: actions/cache@v3
        with:
          path: ~/.m2
          key: ${{ runner.os }}-maven-${{ hashFiles('**/pom.xml') }}
          restore-keys: |
            ${{ runner.os }}-maven-

      # Build the project with Maven
      - name: Build with Maven
        run: mvn clean install

      # Upload the JAR as an artifact
      - name: Upload JAR as artifact
        uses: actions/upload-artifact@v4
        with:
          name: bus-booking-app
          path: target/bus-booking-app-1.0-SNAPSHOT.jar

      # Run the Spring Boot application
      - name: Run Spring Boot App
        run: mvn spring-boot:run &  # Run the application in the background
        env:
          SPRING_PROFILES_ACTIVE: "test"

      # Validate that the application is running by sending a request to the app
      - name: Validate App is Running
        run: |
          echo "Waiting for the app to start..."
          sleep 15  # Allow some time for the Spring Boot app to fully start
          echo "Checking if the app is running..."
          RESPONSE=$(curl --write-out "%{http_code}" --silent --output /dev/null http://localhost:8080)
          if [ "$RESPONSE" -eq 200 ]; then
            echo "The app is running successfully!"
          else
            echo "The app failed to start. HTTP response code: $RESPONSE"
            exit 1
          fi

      # Wait for 5 minutes
      - name: Wait for 5 minutes
        run: |
          echo "App has been running for 5 minutes. Waiting..."
          sleep 300  # Wait for 5 minutes (300 seconds)

      # Stop the Spring Boot app gracefully using spring-boot:stop
      - name: Gracefully Stop Spring Boot App
        run: |
          echo "Stopping the app gracefully..."
          mvn spring-boot:stop
=============================================================================================================================================================================
How the CI/CD Pipeline Works
Checkout the repository: This step checks out the code from the repository.
Set up Java: Sets up Java 17 using the actions/setup-java action.
Cache Maven dependencies: Caches the Maven dependencies to speed up subsequent builds.
Build with Maven: Runs mvn clean install to build the project.
Upload the JAR as an artifact: Uploads the generated JAR file as a build artifact.
Run the Spring Boot application: Starts the Spring Boot application in the background.
Validate that the app is running: Sends an HTTP request to http://localhost:8080 and checks if the app is running.
Wait for 5 minutes: Waits for 5 minutes to simulate the running app.
Gracefully stop the Spring Boot application: Stops the Spring Boot app using the spring-boot:stop command.
Jenkins Pipeline
The following Jenkins pipeline (Jenkinsfile) can be used for CI/CD with Jenkins.
===========================================================================================================================================================================
Jenkinsfile
groovy
Copy code
pipeline {
    agent any

    environment {
        MAVEN_HOME = '/usr/local/maven'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the repository
                checkout scm
            }
        }

        stage('Build') {
            steps {
                // Clean and install the project using Maven
                sh 'mvn clean install'
            }
        }

        stage('Run Application') {
            steps {
                // Run the Spring Boot application in the background
                sh 'mvn spring-boot:run &'
            }
        }

        stage('Validate Application') {
            steps {
                script {
                    // Validate if the application is running
                    def response = sh(script: 'curl --write-out "%{http_code}" --silent --output /dev/null http://localhost:8080', returnStdout: true).trim()
                    if (response != "200") {
                        error "The app failed to start. HTTP response code: ${response}"
                    } else {
                        echo "The app is running successfully!"
                    }
                }
            }
        }

        stage('Wait for 5 minutes') {
            steps {
                // Wait for 5 minutes (simulating app running)
                echo "App has been running for 5 minutes. Waiting..."
                sleep(time: 5, unit: 'MINUTES')
            }
        }

        stage('Stop Application') {
            steps {
                // Stop the Spring Boot application gracefully
                sh 'mvn spring-boot:stop'
            }
        }
    }

    post {
        always {
            // Clean up actions, if needed
            echo "Cleaning up after build"
        }
    }
}
How the Jenkins Pipeline Works
Checkout: Checks out the code from the repository.
Build: Uses Maven to build the project with mvn clean install.
Run Application: Starts the Spring Boot application in the background.
Validate Application: Sends an HTTP request to http://localhost:8080 to check if the application is running.
Wait for 5 minutes: Simulates the app running for 5 minutes.
Stop Application: Gracefully stops the Spring Boot application using mvn spring-boot:stop.
How to Trigger the Jenkins Pipeline
To trigger this pipeline in Jenkins:

Ensure Jenkins is set up with the necessary plugins (Maven, Git, etc.).
Create a new Jenkins job (Pipeline type).
Link the repository to the Jenkins job and point it to the Jenkinsfile.
Trigger the pipeline manually or based on webhooks from GitHub.
Conclusion
This repository contains everything you need to build, run, and deploy the Bus Booking Application. The CI/CD pipeline ensures that your application is automatically built, tested, and deployed whenever changes are made to the code using both GitHub Actions and Jenkins.
