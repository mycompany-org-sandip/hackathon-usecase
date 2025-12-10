# Build stage
FROM maven:3.9.2-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre
# Alternative fully supported image: FROM adoptium/temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/order-service-0.0.1-SNAPSHOT.jar ./order-service.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","order-service.jar"]
