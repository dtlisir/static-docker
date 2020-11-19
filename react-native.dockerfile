#!/usr/bin/env -S docker build --compress -t pvtmert/react-native -f

FROM debian:sid

RUN apt update
RUN apt install -y \
	curl unzip procps openjdk-8-jdk-headless \
	libpulse0 qemu-kvm libgl1 libxcomposite1 \
	libxcursor1 libasound2 qt5dxcb-plugin

WORKDIR /home

ENV ANDROID_HOME /usr/lib/android-sdk
ENV NODE_VERSION v12.16.0
ENV PASSWORD hellorn
ENV FD_GEOM 720x800
ENV DEVICE "Nexus 5X"
ENV IMAGE "system-images;android-29;google_apis;x86_64"
ENV NAME "defaultdevice"
ENV TARGET host.docker.internal

#RUN apt update && apt install -y \
#	unzip procps tightvncserver matchbox-window-manager fluxbox dwm \
#	libpulse0 xz-utils x11vnc vnc4server nodejs nodejs-legacy chromium \
#	android-sdk android-sdk-platform-tools android-sdk-build-tools \
#	android-sdk-platform-23 android-tools-fastboot android-tools-adb \
#	&& apt clean

ADD "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" android-sdk.zip
RUN unzip -od "${ANDROID_HOME}" android-sdk.zip

ADD "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz" node.tar.gz
RUN tar --strip=1 -C "/usr/local" -xzvf node.tar.gz
RUN npm i -g npm yarn react-native-cli

RUN yes | /usr/lib/android-sdk/tools/bin/sdkmanager --update
RUN yes | /usr/lib/android-sdk/tools/bin/sdkmanager --install \
	'extras;android;gapid;3'                                                            \
	'extras;android;m2repository'                                                       \
	'extras;google;google_play_services'                                                \
	'extras;google;instantapps'                                                         \
	'extras;google;m2repository'                                                        \
	'extras;google;webdriver'                                                           \
	'extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2' \
	'extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2'        \
	'patcher;v4'                                                                        \
	'platform-tools'                                                                    \
	'build-tools;29.0.2'                                                                \
	'platforms;android-29'                                                              \
	'emulator' 'tools' "${IMAGE}"
RUN yes | /usr/lib/android-sdk/tools/bin/sdkmanager --update

RUN ( \
	echo "#!/bin/bash"         ; \
	echo "xhost +"             ; \
	echo "xset -dpms s off"    ; \
	echo "fluxbox &"           ; \
	echo "bash /root/emu.sh &" ; \
	echo "xterm || wait"       ; \
	) | tee /root/.xsession && chmod +x /root/.xsession

#RUN echo | /usr/lib/android-sdk/tools/bin/avdmanager create avd \
#	-k "${IMAGE}" -n "${NAME}" -d "${DEVICE}"
#RUN echo "/usr/lib/android-sdk/emulator/emulator -avd ${NAME} -noaudio -no-boot-anim -gpu off" \
#	| tee /root/emu.sh

#EXPOSE 5900 5555 5554 5037 8080 8081
#CMD x11vnc -q -bg -loop -forever -mdns -shared -find -create -xvnc -reopen -ncache_cr -noncache -threads -noxdamage -ping 1 -passwd "${PASSWORD}"
#CMD echo "${PASSWORD}" | vncpasswd -f | vncserver -verbose -fg -name $(hostname) \
#	-depth 32 -geometry ${FD_GEOM} -localhost no -passwd /dev/stdin \
#	-SecurityTypes VncAuth --I-KNOW-THIS-IS-INSECURE :0

EXPOSE 5037 5554 5555
ENV DISPLAY "${TARGET}:0"
ENV PATH "${PATH}:/usr/lib/android-sdk/platform-tools"
CMD /usr/lib/android-sdk/platform-tools/adb start-server        && \
	/usr/lib/android-sdk/platform-tools/adb connect "${TARGET}" && \
	/usr/lib/android-sdk/tools/bin/avdmanager create avd \
		-k "${IMAGE}" -n "${NAME}" -d "${DEVICE}"     && \
	/usr/lib/android-sdk/emulator/emulator \
		-avd "${NAME}" \
			-verbose \
			-no-audio \
			-delay-adb \
			-no-boot-anim \
			-no-accel \
			-gpu off

# -no-qt \
# -lowram \
# -no-accel \
