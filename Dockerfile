FROM openjdk:8u302-slim
COPY ./target/demo.jar /app/demo.jar
CMD ["java", "-jar", "/app/demo.jar"]
