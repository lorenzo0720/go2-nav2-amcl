FROM osrf/ros:humble-desktop-full

# Install Nav2 + dependencies
RUN apt update && apt install -y --no-install-recommends \
    ros-humble-navigation2 \
    ros-humble-nav2-bringup \
    ros-humble-nav2-map-server \
    ros-humble-slam-toolbox \
    ros-humble-robot-localization \
    ros-humble-xacro \
    ros-humble-teleop-twist-keyboard \
    ros-humble-rmw-cyclonedds-cpp \
    ros-humble-rosidl-generator-dds-idl \
    python3-empy \
    python3-pip \
    cmake \
    build-essential \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Copy and build unitree_ros2 (for unitree_go, unitree_api messages)
# 如果构建失败，先克隆: git clone https://github.com/unitreerobotics/unitree_ros2.git unitree_ros2
COPY unitree_ros2 /opt/unitree_ros2
RUN cd /opt/unitree_ros2/cyclonedds_ws \
    && rm -rf build install log \
    && . /opt/ros/humble/setup.sh \
    && colcon build --packages-select unitree_go unitree_api \
    && rm -rf build log

# Cyclone DDS config (placeholder NIC name, replace for real hardware)
RUN mkdir -p /opt/cyclonedds_cfg \
    && echo '<?xml version="1.0" encoding="UTF-8" ?>' > /opt/cyclonedds_cfg/cyclonedds.xml \
    && echo '<CycloneDDS xmlns="https://cdds.io/config">' >> /opt/cyclonedds_cfg/cyclonedds.xml \
    && echo '    <Domain Id="any">' >> /opt/cyclonedds_cfg/cyclonedds.xml \
    && echo '        <General>' >> /opt/cyclonedds_cfg/cyclonedds.xml \
    && echo '            <Interfaces>' >> /opt/cyclonedds_cfg/cyclonedds.xml \
    && echo '                <NetworkInterface name="REPLACE_WITH_GO2_NIC" priority="default" multicast="default" />' >> /opt/cyclonedds_cfg/cyclonedds.xml \
    && echo '            </Interfaces>' >> /opt/cyclonedds_cfg/cyclonedds.xml \
    && echo '        </General>' >> /opt/cyclonedds_cfg/cyclonedds.xml \
    && echo '    </Domain>' >> /opt/cyclonedds_cfg/cyclonedds.xml \
    && echo '</CycloneDDS>' >> /opt/cyclonedds_cfg/cyclonedds.xml

# Workspace directory
RUN mkdir -p /ws/src /ws/maps

# Environment in .bashrc
RUN echo 'source /opt/ros/humble/setup.bash' >> /root/.bashrc \
    && echo 'source /opt/unitree_ros2/cyclonedds_ws/install/setup.bash' >> /root/.bashrc \
    && echo 'export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp' >> /root/.bashrc \
    && echo 'export CYCLONEDDS_URI=file:///opt/cyclonedds_cfg/cyclonedds.xml' >> /root/.bashrc \
    && echo 'export RCUTILS_COLORIZED_OUTPUT=1' >> /root/.bashrc \
    && echo '' >> /root/.bashrc \
    && echo '# Source workspace if built' >> /root/.bashrc \
    && echo 'if [ -f /ws/install/setup.bash ]; then source /ws/install/setup.bash; fi' >> /root/.bashrc

WORKDIR /ws
