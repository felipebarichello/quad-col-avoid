function setros() {
    source /opt/ros/humble/setup.bash
}

function setup() {
    source install/setup.bash
}

function buildall() {
    colcon build && setup
}

function build() {
    colcon build --packages-select px4_offboard && setup
}

function remodel() {
    cp -r models/* ~/PX4-Autopilot/Tools/simulation/gz/models/
}

function sim() {
    ros2 launch px4_offboard offboard_velocity_control.launch.py
}

function kgz() {
    ps aux | grep gz | grep -v grep | awk '{print $2}' | xargs kill -9
}
