#!/bin/bash
set -xe
echo "Patching for implausible wheel ticks"

FILE="/opt/open_mower_ros/src/lib/xbot_positioning/src/xbot_positioning.cpp"
LINE="vx = d_ticks / dt;"

NEW_CODE='    // Ignore implausible wheel tick calculation
    if(abs(vx) > 0.6) {
        ROS_WARN_STREAM("got vx > 0.6 (" << vx << ") - dropping measurement");
        vx = 0.0;
        return;
    }'

if ! grep -q 'got vx > 0.6 (' "$FILE"; then
    awk -v new_code="$NEW_CODE" -v line="$LINE" '
    $0 ~ line {
        print $0
        print new_code
        next
    }
    { print }
    ' "$FILE" > /tmp/xbot_positioning.cpp && mv /tmp/xbot_positioning.cpp "$FILE"
else
    echo "Wheel tick patch already present, skipping."
fi
