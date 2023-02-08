# FROM openjdk:17 as jre-build
FROM amazoncorretto:17.0.6-alpine3.17 as jre-build

# required for strip-debug to work
RUN apk add --no-cache binutils curl
RUN curl -o /checkstyle.jar -L https://github.com/checkstyle/checkstyle/releases/download/checkstyle-10.7.0/checkstyle-10.7.0-all.jar

# Build small JRE image
RUN $JAVA_HOME/bin/jlink \
         --verbose \
         --add-modules java.base,java.logging \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /javaruntime

# FROM debian:buster-slim
FROM alpine:latest
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
RUN mkdir /opt/app

COPY --from=jre-build /javaruntime $JAVA_HOME
COPY --from=jre-build /checkstyle.jar /opt/app


CMD ["java", "-jar", "/opt/app/checkstyle.jar"]
