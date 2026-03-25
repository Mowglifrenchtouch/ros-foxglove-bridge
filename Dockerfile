ARG IMAGE=ghcr.io/cedbossneo/mowgli-docker:upstream
FROM ${IMAGE}

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3-rosdep \
    python3-catkin-tools \
    ros-noetic-ros-babel-fish \
    nlohmann-json3-dev \
    ccache \
 && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/lib/ccache:${PATH}"
ENV CCACHE_DIR=/root/.ccache
ENV CCACHE_MAXSIZE=2G

WORKDIR /opt/open_mower_ros/src
RUN rm -rf foxglove_bridge_src
COPY . /opt/open_mower_ros/src/foxglove_bridge_src

WORKDIR /opt/open_mower_ros
RUN source /opt/ros/noetic/setup.bash && \
    ccache -z && \
    rosdep install -y --from-paths src --ignore-src || true && \
    catkin_make -j2 -l2 && \
    ccache -s

COPY start_foxglove.sh /usr/local/bin/start-foxglove.sh
RUN chmod +x /usr/local/bin/start-foxglove.sh

CMD ["/usr/local/bin/start-foxglove.sh"]
