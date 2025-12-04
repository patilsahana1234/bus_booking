#!/bin/bash

# Step 1: Set up Maven environment
export MAVEN_HOME=/usr/local/maven
export PATH=$MAVEN_HOME/bin:$PATH

# Step 2: Clean and install the project
echo "Building the project..."
mvn clean install

# Step 3: Run the Spring Boot application
echo "Running the Spring Boot application..."
mvn spring-boot:run &  # Run the application in the background

# Wait for the application to start up
echo "Waiting for the application to start..."
sleep 15  # Adjust the time as per the application startup time

# Step 4: Validate that the application is running
echo "Validating if the application is running..."
RESPONSE=$(curl --write-out "%{http_code}" --silent --output /dev/null http://localhost:8080 (http://localhost:8080/))
if [ "$RESPONSE" -eq 200 ]; then
    echo "The app is running successfully!"
else
    echo "The app failed to start. HTTP response code: $RESPONSE"
    exit 1
fi

# Step 5: Wait for 5 minutes (300 seconds)
echo "App has been running for 5 minutes. Waiting..."
sleep 300  # Wait for 5 minutes

# Step 6: Gracefully stop the Spring Boot application
echo "Stopping the app gracefully..."
mvn spring-boot:stop
