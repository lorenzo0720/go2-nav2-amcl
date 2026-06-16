#!/bin/bash
# go2_env.sh — Source in every container shell before running ROS commands
source /opt/ros/humble/setup.bash
source /opt/unitree_ros2/cyclonedds_ws/install/setup.bash
source /ws/install/setup.bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI=file:///opt/cyclonedds_cfg/cyclonedds.xml
export RCUTILS_COLORIZED_OUTPUT=1

echo "Go2 ROS 2 Humble environment ready."
echo "  SLAM:      ros2 launch go2_core go2_start.launch.py"
echo "  Nav2:      ros2 launch go2_navigation2 go2_nav2.launch.py"
echo "  Save map:  ros2 run nav2_map_server map_saver_cli -f /ws/maps/my_map"
