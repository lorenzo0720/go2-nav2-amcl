#!/bin/bash
# build_workspace.sh — Run ONCE inside container to compile go2-nav2-amcl
set -e

# Source ROS 2 Humble + unitree_ros2
source /opt/ros/humble/setup.bash
source /opt/unitree_ros2/cyclonedds_ws/install/setup.bash

cd /ws

echo "=== Building go2-nav2-amcl workspace ==="
echo "Packages:"
ls -d src/*/package.xml src/*/*/package.xml 2>/dev/null | sed 's|/package.xml||' || true

colcon build --symlink-install

echo ""
echo "=== Build complete ==="
source install/setup.bash
echo ""
echo "Installed packages:"
ros2 pkg list | grep go2
