FROM ubuntu:20.04
LABEL org.opencontainers.image.description Prebuild container setup for building react-native apk or aab
LABEL org.opencontainers.image.authors skull.saders18@gmail.com
# set ARG to bypass dialog error \
# "debconf: unable to initialize frontend: Dialog debconf: (TERM is not set, so the dialog frontend is not usable.) debconf: falling back to frontend: Readline Configuring tzdata" \
# when installing git
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Asia/Jakarta
ARG NODE_VERSION=16.x
ARG SDK_VERSION=7583922
ARG NDK_VERSION=21.4.7075529
ARG CMAKE_VERSION=3.10.2.4988404
ARG ANDROID_VERSION=android-31
ARG ANDROID_BUILD_TOOLS_VERSION=30.0.2

RUN apt update && apt install -y curl && \
curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
apt -y install gcc g++ make && \
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt update && apt -y install yarn && \
apt install -y nodejs openjdk-11-jre-headless python3
RUN apt install -y expect git openjdk-8-jdk-headless wget unzip vim && \
wget https://dl.google.com/android/repository/commandlinetools-linux-${SDK_VERSION}_latest.zip
RUN mkdir -p Android/Sdk && unzip commandlinetools-linux-${SDK_VERSION}_latest.zip -d Android/Sdk/cmdline-tools && \
mv Android/Sdk/cmdline-tools/cmdline-tools Android/Sdk/cmdline-tools/latest

ENV ANDROID_HOME="$HOME/Android/Sdk"
ENV PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest"
ENV PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
ENV PATH="$PATH:$ANDROID_HOME/platform-tools"

RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} "tools"
RUN sdkmanager "platform-tools" "platforms;${ANDROID_VERSION}" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"
# If you use react-native-reanimated or react-native-mmkv-storage then install ndk & cmake
RUN sdkmanager --install "ndk;${NDK_VERSION}"
RUN sdkmanager --install "cmake;${CMAKE_VERSION}"
RUN sdkmanager --licenses

CMD ["/bin/sh"]
