# Go2 NAV2 AMCL 导航项目

基于 [rbgyhjn/go2-nav2-amcl](https://github.com/rbgyhjn/go2-nav2-amcl)，感谢原作者 **@rbgyhjn**。

## 改动

- **减少侧走**：`max_vel_y` 从 1.3 降至 0.3，DWB 不再规划大幅侧向运动
- **增强避障**：`BaseObstacle.scale` 从 0.02 提至 3.0，障碍物评分权重大幅提升
- **膨胀半径**：`inflation_radius` 0.50 → 0.65，安全距离更大
- **代价衰减**：`cost_scaling_factor` 3.0 → 2.0，障碍影响范围更广
- **AMCL 定位**：`alpha1/2` 0.4 → 0.3，`update_min_a/d` 降低，旋转时定位更新更频繁

## 环境

- **机器人**：Unitree Go2
- **ROS 2**：Humble (Docker 容器内运行)
- **依赖**：Nav2、slam-toolbox、unitree_ros2

宿主机需要安装 Docker 和 NVIDIA Container Toolkit。

## 快速开始

### 1. 构建 Docker 镜像

```bash
cd go2-nav2-amcl
docker compose build   # 首次约 15 分钟
```

### 2. 启动容器

```bash
docker compose up -d
```

### 3. 编译工作空间（首次）

```bash
docker exec -it go2-nav2-amcl bash /ws/build_workspace.sh
```

## SLAM 建图

**终端 1** — 启动驱动 + SLAM：

```bash
docker exec -it go2-nav2-amcl bash
ros2 launch go2_core go2_start.launch.py
```

**终端 2** — 键盘遥控：

```bash
docker exec -it go2-nav2-amcl bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

**保存地图**：

```bash
docker exec go2-nav2-amcl bash -c '
source /opt/ros/humble/setup.bash
source /opt/unitree_ros2/cyclonedds_ws/install/setup.bash
source /ws/install/setup.bash
ros2 run nav2_map_server map_saver_cli -f /ws/maps/my_map'
```

## 导航

```bash
docker exec -it go2-nav2-amcl bash
ros2 launch go2_navigation2 go2_nav2.launch.py map:=/ws/maps/my_map.yaml
```

RViz 中：
1. **2D Pose Estimate** — 标定初始位姿
2. **Nav2 Goal** — 指定目标点

## 注意事项

- Go2 通过有线网口连接（192.168.123.x），Docker 使用 `network_mode: host`
- 容器内 `.bashrc` 已自动 source ROS + unitree + workspace 环境
- 地图默认保存在 `/ws/maps/`
- RViz 需 X11 授权：`xhost +local:`
