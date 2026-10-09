$services = @{
    "companyms" = 8081
    "jobms" = 8082
    "reviewms" = 8083
    "service-reg" = 8761
    "configserver" = 8080
    "gateway" = 8084
}

foreach ($service in $services.Keys) {
    $port = $services[$service]
    $dir = "F:\Java\JobLens\backend\$service"
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir
    }
    
    $dockerfile = @"
# Stage 1: Build the application
FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
# Download dependencies first to cache them
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE $port
ENTRYPOINT ["java", "-jar", "app.jar"]
"@
    
    Set-Content -Path "$dir\Dockerfile" -Value $dockerfile
    Write-Host "Updated $dir\Dockerfile"
}
