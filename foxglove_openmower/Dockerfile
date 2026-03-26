# Base officielle OpenMower
FROM ghcr.io/clemenselflein/open_mower_ros:latest

USER root
SHELL ["/bin/bash", "-c"]

# Timezone
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Dépendances utiles + build
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3-rosdep \
    python3-catkin-tools \
    ros-noetic-ros-babel-fish \
    nlohmann-json3-dev \
    ccache \
 && rm -rf /var/lib/apt/lists/*

# ccache
ENV PATH="/usr/lib/ccache:${PATH}"
ENV CCACHE_DIR=/root/.ccache
ENV CCACHE_MAXSIZE=2G

ARG TARGETARCH
ARG AMD64_MAX_JOBS=8
ARG ARM64_MAX_JOBS=4

# PATCH OpenMower (désactive comms si OM_NO_COMMS=true)
RUN sed -i 's/output="screen"/unless="\$\(optenv OM_NO_COMMS True\)" output="screen"/g' \
    /opt/open_mower_ros/src/open_mower/launch/include/_comms.launch

# Ajout Foxglove bridge dans le workspace ROS existant
WORKDIR /opt/open_mower_ros/src
RUN git clone --branch v2 https://github.com/Mowglifrenchtouch/ros-foxglove-bridge.git foxglove_bridge && \
    git clone https://github.com/ClemensElflein/slic3r_coverage_planner.git slic3r_coverage_planner && \
    git clone https://github.com/Mowglifrenchtouch/Mowgli_ROS_Package.git && \
    mv Mowgli_ROS_Package/mowgli . && \
    rm -rf Mowgli_ROS_Package && \
    source /opt/ros/noetic/setup.bash

# Build du workspace complet
WORKDIR /opt/open_mower_ros
RUN source /opt/ros/noetic/setup.bash && \
    ccache -z && \
    rosdep update || true && \
    rosdep install -y --from-paths src --ignore-src \
      --skip-keys="slic3r_coverage_planner paho-mqtt-cpp" || true && \
    CORES=$(nproc) && \
    if [ "$TARGETARCH" = "amd64" ]; then \
      JOBS=$(( CORES < AMD64_MAX_JOBS ? CORES : AMD64_MAX_JOBS )); \
      LOAD=$JOBS; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      JOBS=$(( CORES < ARM64_MAX_JOBS ? CORES : ARM64_MAX_JOBS )); \
      LOAD=$JOBS; \
    else \
      JOBS=2; LOAD=2; \
    fi && \
    echo "Building for $TARGETARCH with $CORES cores visible, using -j${JOBS} -l${LOAD}" && \
    catkin_make -j${JOBS} -l${LOAD} || \
    (echo "===== CMakeError.log =====" && cat /opt/open_mower_ros/build/CMakeFiles/CMakeError.log && \
     echo "===== CMakeOutput.log =====" && cat /opt/open_mower_ros/build/CMakeFiles/CMakeOutput.log && false)

# Script de démarrage
COPY foxglove_openmower/scripts/start-foxglove.sh /usr/local/bin/start-foxglove.sh
RUN chmod +x /usr/local/bin/start-foxglove.sh

CMD ["/usr/local/bin/start-foxglove.sh"]
