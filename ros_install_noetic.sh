#!/bin/bash -eu

# The BSD License
# Copyright (c) 2020 Qbotics Labs Pvt Ltd
# Copyright (c) 2014 OROCA and ROS Korea Users Group

#set -x

COLOR_REST="$(tput sgr0)"
COLOR_RED="$(tput setaf 1)"
COLOR_GREEN="$(tput setaf 2)"

name_ros_distro=noetic 
user_name=$(whoami)
echo "#################################################################"
echo "$COLOR_GREEN >>>  {Starting ROS Noetic Installation} $COLOR_REST"
echo "$COLOR_GREEN >>> {Checking your Ubuntu version}  $COLOR_REST"
#Getting version and release number of Ubuntu
version=`lsb_release -sc`
relesenum=`grep DISTRIB_DESCRIPTION /etc/*-release | awk -F 'Ubuntu ' '{print $2}' | awk -F ' LTS' '{print $1}'`
echo "$COLOR_GREEN >>> {Your Ubuntu version is: [Ubuntu $version $relesenum]} $COLOR_REST"
#Checking version is focal, if yes proceed othervice quit
case $version in
  "focal" )
  ;;
  *)
    echo "$COLOR_GREEN >>> {ERROR: This script will only work on Ubuntu Focal (20.04).} $COLOR_REST"
    exit 0
esac

echo "$COLOR_GREEN >>> {Ubuntu Focal 20.04 is fully compatible with Ubuntu Focal 20.04} $COLOR_REST"
echo "#################################################################"
echo "$COLOR_GREEN >>> {Step 1: Configure your Ubuntu repositories} $COLOR_REST"
#Configure your Ubuntu repositories to allow "restricted," "universe," and "multiverse." You can follow the Ubuntu guide for instructions on doing this. 
#https://help.ubuntu.com/community/Repositories/Ubuntu

sudo add-apt-repository universe
sudo add-apt-repository restricted
sudo add-apt-repository multiverse

echo "$COLOR_GREEN >>> {Done: Added Ubuntu repositories} $COLOR_REST"
echo "#################################################################"
echo "$COLOR_GREEN >>> {Step 2: Setup your sources.list} $COLOR_REST"

#This will add the ROS Noetic package list to sources.list 
sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu ${version} main\" > /etc/apt/sources.list.d/ros-latest.list"

#Checking file added or not
if [ ! -e /etc/apt/sources.list.d/ros-latest.list ]; then
  echo "$COLOR_GREEN >>> {Error: Unable to add sources.list, exiting} $COLOR_REST"
  exit 0
fi

echo "$COLOR_GREEN >>> {Done: Added sources.list} $COLOR_REST"
echo "#################################################################"
echo "$COLOR_GREEN >>> {Step 3: Set up your keys} $COLOR_REST"
echo "$COLOR_GREEN >>> {Installing curl for adding keys} $COLOR_REST"
#Installing curl: Curl instead of the apt-key command, which can be helpful if you are behind a proxy server: 
#TODO:Checking package is not working sometimes, so disabling it
#Checking curl is installed or not
#name=curl
#which $name > /dev/null 2>&1

#if [ $? == 0 ]; then
#    echo "Curl is already installed!"
#else
#    echo "Curl is not installed,Installing Curl"

sudo apt install curl
#fi

echo "#################################################################"
#Adding keys
echo "$COLOR_GREEN >>> {Waiting for adding keys, it will take few seconds} $COLOR_REST"
ret=$(curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add -)

#Checking return value is OK
case $ret in
  "OK" )
  ;;
  *)
    echo "$COLOR_GREEN >>> {ERROR: Unable to add ROS keys} $COLOR_REST"
    exit 0
esac

echo "$COLOR_GREEN >>> {Done: Added Keys} $COLOR_REST"
echo "#################################################################"
echo "$COLOR_GREEN >>> {Step 4: Updating Ubuntu package index, this will take few minutes depend on your network connection} $COLOR_REST"
sudo apt update
echo "#################################################################"
echo "$COLOR_GREEN >>> {Step 5: Install ROS, you pick how much of ROS you would like to install.} $COLOR_REST"
echo "$COLOR_GREEN [1. Desktop-Full Install: (Recommended) : Everything in Desktop plus 2D/3D simulators and 2D/3D perception packages ] $COLOR_REST"
echo "$COLOR_GREEN [2. Desktop Install: Everything in ROS-Base plus tools like rqt and rviz] $COLOR_REST"
echo "$COLOR_GREEN [3. ROS-Base: (Bare Bones) ROS packaging, build, and communication libraries. No GUI tools.] $COLOR_REST"
#Assigning default value as 1: Desktop full install
read -p "Enter your install (Default is 1):" answer 

case "$answer" in
  1)
    package_type="desktop-full"
    ;;
  2)
    package_type="desktop"
    ;;
  3)
    package_type="ros-base"
    ;;
  * )
    package_type="desktop-full"
    ;;
esac
echo "#################################################################"
echo "$COLOR_GREEN >>>  {Starting ROS installation, this will take about 20 min. It will depends on your internet  connection} $COLOR_REST"
sudo apt-get install -y ros-${name_ros_distro}-${package_type} 
echo "#################################################################"
echo "$COLOR_GREEN >>> {Step 6: Setting ROS Environment, This will add ROS environment to .bashrc.}" $COLOR_REST 
echo "$COLOR_GREEN >>> { After adding this, you can able to access ROS commands in terminal} $COLOR_REST"
echo "source /opt/ros/noetic/setup.bash" >> /home/$user_name/.bashrc
source /home/$user_name/.bashrc
echo
"#################################################################"
echo "$COLOR_GREEN >>> {Step 7: Install Dependencies for building packages.} $COLOR_REST"
echo "$COLOR_GREEN >>> { After installing this, Initialize rosdep} $COLOR_REST"
sudo apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
sudo apt install python3-rosdep
sudo rosdep init
rosdep update
echo  "#################################################################"
echo "$COLOR_GREEN >>> {Step 8: Testing ROS installation, checking ROS version.} $COLOR_REST"
echo "$COLOR_GREEN >>> {Type [ rosversion -d ] to get the current ROS installed version} $COLOR_REST"
echo "#################################################################"