FROM busybox AS mod-composer

ARG SPTQuestingBots=https://github.com/dwesterwick/SPTQuestingBots/releases/download/0.5.0/DanW-SPTQuestingBots.zip
ARG SPTFOVFix=https://github.com/space-commits/SPT-FOV-Fix/releases/download/v1.11.0/Fontaine-FOV-Fix-v1.11.0-SPT-v3.8.0.zip
ARG FikaServer=https://github.com/project-fika/Fika-Server/releases/download/v2.0/fika-server.zip
ARG LootingBots=https://github.com/Skwizzy/SPT-LootingBots/releases/download/v1.3.2-aki-3.8.0/Skwizzy-LootingBots-1.3.2.zip
ARG SAIN=https://github.com/Solarint/SAIN/releases/download/2.2.1/SAIN-2.2.1-Hotfix.zip
ARG SPTRealism=https://github.com/space-commits/SPT-Realism-Mod-Client/releases/download/v1.1.2/Realism-Mod-v1.1.2-SPT-v3.8.0.zip
ARG SWAGDonuts=https://github.com/p-kossa/nookys-swag-presets-spt/releases/download/v3.3.5/SWAG-Donuts-v3.3.5-SPT380.zip
ARG MoreCheckmarks=https://github.com/TommySoucy/MoreCheckmarks/releases/download/v1.5.13/MoreCheckmarks-1.5.13-for-3.8.0-29197.zip

WORKDIR /mods
RUN wget -O mod.zip ${SPTQuestingBots}
RUN unzip mod.zip
RUN rm mod.zip

RUN wget -O mod.zip ${SPTFOVFix}
RUN unzip mod.zip
RUN rm mod.zip

RUN wget -O mod.zip ${FikaServer}
RUN unzip mod.zip
RUN rm mod.zip

RUN wget -O mod.zip ${LootingBots}
RUN unzip mod.zip
RUN rm mod.zip

RUN wget -O mod.zip ${SAIN}
RUN unzip mod.zip
RUN rm mod.zip

RUN wget -O mod.zip ${SWAGDonuts}
RUN unzip mod.zip
RUN rm mod.zip

RUN wget -O mod.zip ${SPTRealism}
RUN unzip mod.zip
RUN sed -i 's/\\\\/\//g' user/mods/SPT-Realism/src/mod.ts
RUN rm mod.zip

RUN wget -O mod.zip ${MoreCheckmarks}
RUN unzip mod.zip
RUN rm mod.zip

##############################################

FROM node:20.11.1 AS spt-aki-server-builder

ARG SPTAkiServer=3.8.1


RUN apt update && apt install -yq git-lfs

RUN git clone -b ${SPTAkiServer} https://dev.sp-tarkov.com/SPT-AKI/Server.git server
WORKDIR /server
RUN git-lfs pull
WORKDIR /server/project
RUN npm install
RUN npm run build:release

##############################################

FROM bitnami/minideb

COPY --from=spt-aki-server-builder /server/project/build /Aki-server
COPY --from=mod-composer /mods/user /Aki-server/user
COPY ./Aki_Data /Aki-server/Aki_Data
COPY ./user /Aki-server/user

# RUN sed -i 's/127.0.0.1/0.0.0.0/g' /Aki-server/Aki_Data/Server/configs/http.json

EXPOSE 6969
WORKDIR /Aki-server
ENTRYPOINT ["./Aki.Server.exe"]
