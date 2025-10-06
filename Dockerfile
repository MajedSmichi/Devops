# Étape 1 : builder
FROM maven:3.9.0-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Étape 2 : exécuter
FROM eclipse-temurin:17-jre
WORKDIR /app

COPY wait-for-it.sh /wait-for-it.sh
COPY target/student-management-0.0.1-SNAPSHOT.jar app.jar
RUN chmod +x /wait-for-it.sh

EXPOSE 8089

# Attendre MySQL avant de démarrer Spring Boot
ENTRYPOINT ["/wait-for-it.sh", "mysql:3306", "--timeout=30", "--strict", "--", "java", "-jar", "app.jar"]

