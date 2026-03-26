#!/bin/bash
set -e
echo "Starting OpenMower environment..."
source /opt/ros/noetic/setup.bash
source /opt/open_mower_ros/devel/setup.bash
export OM_NO_COMMS=True
exec roslaunch --screen foxglove_bridge foxglove_bridge.launch
    port:=8765 \
    address:=0.0.0.0
