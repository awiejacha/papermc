# Build
FROM openjdk:11 AS build
MAINTAINER SZERESCIOCH <karol.wiejacha@gmail.com>
ARG SERVER_VER
ENV SERVER_VER="$SERVER_VER"
WORKDIR /opt/minecraft
ADD https://papermc.io/api/v1/paper/${SERVER_VER}/latest/download paperclip.jar
RUN useradd -ms /bin/bash minecraft && chown minecraft /opt/minecraft -R
USER minecraft
RUN /usr/local/openjdk-11/bin/java -jar /opt/minecraft/paperclip.jar; exit 0
RUN mv /opt/minecraft/cache/patched*.jar paperspigot.jar

# Runtime
FROM anapsix/alpine-java as runtime
MAINTAINER SZERESCIOCH <karol.wiejacha@gmail.com>
ARG SERVER_WORK_DIR
ENV SERVER_WORK_DIR="$SERVER_WORK_DIR"
COPY docker /
COPY --from=build /opt/minecraft/paperspigot.jar /opt/minecraft/paperspigot.jar
WORKDIR ${SERVER_WORK_DIR}
RUN apk add --no-cache --update bash s6
CMD [ "s6-svscan", "-s", "/etc/s6" ]
