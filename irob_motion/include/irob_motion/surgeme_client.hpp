/*
 * 	gesture_client.hpp
 *
 *	Author(s): Tamas D. Nagy
 *	Created on: 2017-07-20
 *
 *	Single arm, ROS actions interface to the surgeme server. This objects are
 *  planned to be used as members of subtask-level logic.
 *
 */

#ifndef SURGEME_CLIENT_HPP_
#define SURGEME_CLIENT_HPP_

#include <iostream>
#include <sstream>
#include <vector>
#include <cmath>
#include <ros/ros.h>
#include <ros/package.h>
#include <std_msgs/String.h>
#include <geometry_msgs/PoseStamped.h>
#include <std_msgs/Float32.h>
#include <Eigen/Dense>
#include <Eigen/Geometry> 
#include <irob_utils/pose.hpp>
#include <irob_utils/trajectory.hpp>
#include <irob_utils/utils.hpp>
#include <irob_utils/irob_action_client.hpp>

#include <actionlib/server/simple_action_server.h>
#include <actionlib/client/simple_action_client.h>
#include <actionlib/client/terminal_state.h>

#include <irob_msgs/ToolPoseStamped.h>

#include <irob_msgs/SurgemeAction.h>
#include <irob_msgs/InstrumentInfo.h>
#include <irob_msgs/InstrumentJawPart.h>

namespace saf {

class SurgemeClient {

public:

protected:
  const std::string arm_name;
  ros::NodeHandle nh;

  // Action clients
  IrobActionClient<irob_msgs::SurgemeAction> ac;


  // States
  irob_msgs::ToolPoseStamped position_cartesian_current;
  irob_msgs::InstrumentInfo instrument_info;

  // Subscribers
  ros::Subscriber position_cartesian_current_sub;
  ros::Subscriber instrument_info_sub;

  // Publishers
  ros::Publisher position_cartesian_current_pub;
  ros::Publisher instrument_info_pub;


  void subscribeTopics();
  void advertiseTopics();
  void startActionClients();
  void waitForActionServer();

public:
  SurgemeClient(ros::NodeHandle, std::string);
  ~SurgemeClient();

  // Callbacks

  void positionCartesianCurrentCB(
      const irob_msgs::ToolPoseStampedConstPtr&);

  void instrumentInfoCB(
      const irob_msgs::InstrumentInfoConstPtr&);

  Pose getPoseCurrent();
  irob_msgs::InstrumentInfo getInstrumentInfo();
  std::string getName();

  // Robot motions
  void stop();
  void nav_to_pos(Pose,
                  double,
                  std::vector<Pose> = std::vector<Pose>(),
                  InterpolationMethod = InterpolationMethod::LINEAR);
  void grasp(Pose, Pose, double,	double,
             double,
             double,
             std::vector<Pose> = std::vector<Pose>(),
             InterpolationMethod = InterpolationMethod::LINEAR);
  void cut(Pose, Pose,double,
           double,
           double,
           std::vector<Pose> = std::vector<Pose>(),
           InterpolationMethod = InterpolationMethod::LINEAR);
  void release(Pose,	double,
               double,
               double);
  void place(Pose, Pose,
             double,
             std::vector<Pose> = std::vector<Pose>(),
             InterpolationMethod = InterpolationMethod::LINEAR);
  void push(Pose, Pose,
            Eigen::Vector3d,
            double,
            double,
            std::vector<Pose> = std::vector<Pose>(),
            InterpolationMethod = InterpolationMethod::LINEAR);
  void dissect(Pose, Pose,
               Eigen::Vector3d,
               double,
               double,
               double,
               std::vector<Pose> = std::vector<Pose>(),
               InterpolationMethod = InterpolationMethod::LINEAR);

  void manipulate(Eigen::Vector3d,
                  double);

  bool isSurgemeDone(bool = true);
  actionlib::SimpleClientGoalState getState();

  irob_msgs::SurgemeFeedback getFeedback(bool = true);
  irob_msgs::SurgemeResult getResult(bool = true);


};

}
#endif /* SURGEME_SERVER_HPP_ */
