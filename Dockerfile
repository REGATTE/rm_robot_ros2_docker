# Use Ubuntu 22.04 ARM64 as base image
# FROM --platform=linux/arm64 ubuntu:22.04
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    git \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install -U \
    colcon-common-extensions \
    rosdep \
    vcstool \
    empy==3.3.4

# Add ROS2 apt repository
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS2 Humble and dependencies
RUN apt-get update && apt-get install -y \
    ros-humble-desktop \
    ros-humble-moveit \
    ros-humble-moveit-ros-visualization \
    ros-humble-moveit-ros-planning-interface \
    ros-humble-moveit-ros-planning \
    ros-humble-moveit-ros-occupancy-map-monitor \
    ros-humble-moveit-ros-move-group \
    ros-humble-moveit-ros-control-interface \
    ros-humble-moveit-ros-benchmarks \
    ros-humble-moveit-ros \
    ros-humble-moveit-planners \
    ros-humble-moveit-core \
    ros-humble-moveit-chomp-optimizer-adapter \
    ros-humble-moveit-common \
    ros-humble-moveit-configs-utils \
    ros-humble-moveit-msgs \
    ros-humble-moveit-planners-chomp \
    ros-humble-moveit-planners-ompl \
    ros-humble-moveit-runtime \
    ros-humble-moveit-servo \
    ros-humble-moveit-setup-assistant \
    ros-humble-moveit-simple-controller-manager \
    ros-humble-moveit-visual-tools \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-ros \
    ros-humble-gazebo-plugins \
    ros-humble-gazebo-msgs \
    ros-humble-gazebo-dev \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /ros2_ws

# Clone the repository
RUN git clone https://github.com/RealManRobot/ros2_rm_robot.git src/ros2_rm_robot

# Install dependencies
RUN cd src/ros2_rm_robot && \
    rosdep init && \
    rosdep update && \
    rosdep install --from-paths . --ignore-src -r -y

# Build the workspace
RUN . /opt/ros/humble/setup.sh && \
    colcon build --packages-select rm_ros_interfaces

RUN . /opt/ros/humble/setup.sh && \
    colcon build

# Source the setup file
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source /ros2_ws/install/setup.bash" >> ~/.bashrc

# Set the entrypoint
ENTRYPOINT ["/bin/bash", "-c", "source /opt/ros/humble/setup.bash && source /ros2_ws/install/setup.bash && bash"] 