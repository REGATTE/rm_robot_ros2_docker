# ROS2 RM Robot Docker Container

This repository contains a Dockerfile to run the ROS2 RM Robot package in a containerized environment. The container supports both x86 and ARM architectures.

## Prerequisites

- Docker installed on your system
- Docker BuildKit enabled (recommended)

## Building the Container

To build the container, run:

```bash
# For x86 architecture
docker build -f Dockerfile.x86 -t ros2_rm_robot:x86 .
```

```bash
# For amr64 architecture
docker build --platform linux/arm64 --network=host -f Dockerfile.arm64 -t ros2_rm_robot:arm64 .
```

## Running the Container

To run the container with GUI support (for visualization tools like RViz and Gazebo):

```bash
# For x86 architecture
docker run -it --rm \
    --net=host \
    --privileged \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev:/dev \
    ros2_rm_robot:x86

# For ARM architecture
docker run -it --rm \
    --net=host \
    --platform linux/arm64 \
    --privileged \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev:/dev \
    ros2_rm_robot:arm64
```

## Running Examples

Once inside the container, you can run the examples:

```bash
# For virtual robot arm
ros2 launch rm_bringup rm_75_gazebo.launch.py

# For real robot arm
ros2 launch rm_bringup rm_75_bringup.launch.py
```

## Notes

1. The container includes:
   - Ubuntu 22.04
   - ROS2 Humble
   - MoveIt2
   - Gazebo
   - All required dependencies for the RM Robot package

2. For GUI applications to work, you need to:
   - Allow X11 forwarding on your host system
   - Have an X server running
   - Share the X11 socket with the container

3. For real robot control, you'll need to:
   - Connect the robot to your host system
   - Pass through the appropriate USB devices
   - Configure network settings if needed

## Troubleshooting

If you encounter permission issues with X11:
```bash
xhost +local:docker
```

If you need to access USB devices:
```bash
# List USB devices
lsusb

# Add specific device to docker run command
--device=/dev/ttyUSB0
``` 