FROM px4io/px4-dev-base-jammy:latest

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

WORKDIR /root

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    curl \
    git \
    locales \
    nano \
    python-is-python3 \
    python3-pip \
    software-properties-common \
    sudo \
    wget \
    lsb-release \
    ca-certificates \
    clang-format \
    clang-tidy \
    libegl1 \
    libgl1 \
    libglvnd0 \
    libglx0 \
    libvulkan1 \
    mesa-utils \
    vulkan-tools \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && add-apt-repository universe \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir vcstool

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" > /etc/apt/sources.list.d/ros2.list \
    && wget -qO /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg https://packages.osrfoundation.org/gazebo.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" > /etc/apt/sources.list.d/gazebo-stable.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop \
    ros-dev-tools \
    gz-garden \
    ros-humble-ros-gzgarden \
    ros-humble-behaviortree-cpp \
    ros-humble-joint-state-publisher \
    ros-humble-mavros \
    ros-humble-mavros-extras \
    ros-humble-mavros-msgs \
    ros-humble-moveit \
    ros-humble-moveit-hybrid-planning \
    ros-humble-moveit-ros-occupancy-map-monitor \
    ros-humble-moveit-ros-perception \
    ros-humble-moveit-ros-visualization \
    ros-humble-moveit-visual-tools \
    ros-humble-octomap \
    ros-humble-octomap-msgs \
    ros-humble-octomap-rviz-plugins \
    ros-humble-octomap-server \
    ros-humble-pcl-conversions \
    ros-humble-pcl-ros \
    ros-humble-rtabmap-ros \
    ros-humble-rmw-cyclonedds-cpp \
    ros-humble-tf-transformations \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    libfcl-dev \
    libgz-msgs10-dev \
    libasio-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    empy==3.3.4 \
    pyros-genmsg \
    black \
    isort \
    ruff \
    cmakelang

RUN wget -q https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh \
    && bash ./install_geographiclib_datasets.sh \
    && rm -f ./install_geographiclib_datasets.sh

RUN git clone --depth 1 https://github.com/eProsima/Micro-XRCE-DDS-Agent.git \
    && cd Micro-XRCE-DDS-Agent \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j"$(nproc)" \
    && make install \
    && ldconfig \
    && cd /root \
    && rm -rf /root/Micro-XRCE-DDS-Agent

RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc \
    && echo "if [ -f /root/ros2_ws/install/setup.bash ]; then source /root/ros2_ws/install/setup.bash; fi" >> /root/.bashrc

RUN git config --global --add safe.directory '*'

COPY scripts/check_gpu.sh /usr/local/bin/check-gpu
RUN chmod 0755 /usr/local/bin/check-gpu

CMD ["bash"]
