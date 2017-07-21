/*
 *  trajectory_factory.hpp
 *	
 *  Author(s): Tamas D. Nagy
 *	Created on: 2016-10-25
 *  
 */

#ifndef DVRK_TRAJECTORY_FACTORY_HPP_
#define DVRK_TRAJECTORY_FACTORY_HPP_

#include <iostream>
#include <vector>
#include <ros/ros.h>
#include <cmath>
#include <Eigen/Dense>
#include <Eigen/Geometry> 
#include "irob_utils/trajectory.hpp"
#include "irob_utils/pose.hpp"
#include "irob_utils/utils.hpp"

namespace ias {

class TrajectoryFactory
{

	private:
		TrajectoryFactory() {}
	public:
		

		
		/*
		 *	Uniform ramp between x1 and x2
		 */
		static Trajectory<double> uniformRamp(int N, 
								double x1=0.0, double x2=1.0)
		{
			Trajectory<double> v;
			if (N <= 1)
			{
				// Generating NaN
				v.addPoint(interpolate(0.5, x1, x2));
				return v;
			}
			for (int i = 0; i < N; i++)
			{
				v.addPoint(interpolate(((double)i)/(N-1), x1, x2));
			}
			return v;
		}
		
		/*
		 *	Accelerating ramp between x1 and x2
		 *	For decceleration: acceleratingRamp(N, x2, x1).reverse()
		 */
		static Trajectory<double> acceleratingRamp(int N, 
								double x1=0.0, double x2=1.0)
		{
			Trajectory<double> v, steps;
			double maxStep = (2.0*(x2-x1))/N;
			steps = uniformRamp(N, 0.0, maxStep);
			
			double a = x1;
			for (int i = 0; i < N; i++)
			{
				a += steps[i];
				v.addPoint(interpolate(a, x1, x2));
			}
			return v;
		}
		
		/*
		 *	Smooth ramp between x1 and x2
		 */
		static Trajectory<double> smoothenedRamp(int Nfull, int Nacc,
								double x1=0.0, double x2=1.0)
		{
			Trajectory<double> v, steps;
		
			double accRatio = ((double)Nacc) / Nfull;
			double maxStep = (x2-x1)/(Nfull-Nacc);
			steps = uniformRamp(Nacc, 0.0, maxStep);
			
			double a = x1;
			for (int i = 0; i < Nacc; i++)
			{
				a += steps[i];
				v.addPoint(interpolate(a, x1, x2));
			}
			
			for (int i = 0; i < Nfull-(2*Nacc); i++)
			{
				a += maxStep;
				v.addPoint(interpolate(a, x1, x2));
			}
			
			steps.reverse();
			
			for (int i = 0; i < Nacc; i++)
			{
				a += steps[i];
				v.addPoint(interpolate(a, x1, x2));
			}
			//ROS_INFO_STREAM(v);
			return v;
		}
	
		template <class P>
		static Trajectory<P> linearTrajectoryForTime(P start,P end, 
											double T, double dt)
		{
			Trajectory<P> tr(dt);
			int N = (int)round(T / dt)+1;
			Trajectory<double> ramp = uniformRamp(N);
			for (int i = 0; i < ramp.size(); i++)
			{
				tr.addPoint(interpolate(ramp[i], start, end));
			}
			return tr;
		}
		
		template <class P>
		static Trajectory<P> linearTrajectoryForSpeed(P start,P end, 
											double speed, double dt)
		{
			Trajectory<P> tr(dt);
			double stepSize = speed * dt;
			int N = (int)round(distanceEuler(start, end) / stepSize)+1;
			Trajectory<double> ramp = uniformRamp(N);
			for (int i = 0; i < ramp.size(); i++)
			{
				tr.addPoint(interpolate(ramp[i], start, end));
			}
			return tr;
		}
		
		
		template <class P>
		static Trajectory<P> linearTrajectoryWithSmoothAcceleration(
						P start,
						P end, 
						double Tfull,
						double Tacc, 
						double dt)
		{
			Trajectory<P> tr(dt);
			int Nfull = (int)round(Tfull / dt)+1;
			int Nacc = (int)round(Tacc / dt)+1;
				
			Trajectory<double> ramp = smoothenedRamp(Nfull, Nacc);
			for (int i = 0; i < ramp.size(); i++)
			{
				tr.addPoint(interpolate(ramp[i], start, end));
			}
			return tr;
		}
		
		
		static Trajectory<Eigen::Vector3d> circleTrajectoryHorizontal(
			Eigen::Vector3d start, 
			double toAngle, Eigen::Vector3d center,
			double T, double dt)
		{
			Trajectory<Eigen::Vector3d> tr(dt);
			int N = (int)round(T / dt)+1;
			Trajectory<double> ramp = uniformRamp(N, 0.0, toAngle);
			for (int i = 0; i < ramp.size(); i++)
			{
				Eigen::Vector3d p = start-center;
				Eigen::Vector3d p1(p.x()*cos(ramp[i])-p.y()*sin(ramp[i]), 
					p.y()*cos(ramp[i])+p.x()*sin(ramp[i]), p.z());
				Eigen::Vector3d p2 = p1+center;
				tr.addPoint(p2);
			}
			return tr;
		}
		
		static Trajectory<Pose> circleTrajectoryHorizontal(
			Pose start, 
			double toAngle, Eigen::Vector3d center,
			double T, double dt)
		{
			Trajectory<Pose> tr(dt);
			int N = (int)round(T / dt)+1;
			Trajectory<double> ramp = uniformRamp(N, 0.0, toAngle);
			for (int i = 0; i < ramp.size(); i++)
			{
				Eigen::Vector3d p = start.position-center;
				Eigen::Vector3d p1(p.x()*cos(ramp[i])-p.y()*sin(ramp[i]), 
					p.y()*cos(ramp[i])+p.x()*sin(ramp[i]), p.z());
				Eigen::Vector3d p2 = p1+center;
				Pose po2(p2, start.orientation, start.jaw);
				tr.addPoint(po2);
			}
			return tr;
		}
		
		static Trajectory<Eigen::Vector3d> circleTrajectoryVerticalY(
			Eigen::Vector3d start, 
			double toAngle, Eigen::Vector3d center,
			double T, double dt)
		{
			Trajectory<Eigen::Vector3d> tr(dt);
			int N = (int)round(T / dt)+1;
			Trajectory<double> ramp = uniformRamp(N, 0.0, toAngle);
			for (int i = 0; i < ramp.size(); i++)
			{
				Eigen::Vector3d p = start-center;
				Eigen::Vector3d p1(p.x(), 
					p.y()*cos(ramp[i])+p.z()*sin(ramp[i]), p.z()*cos(ramp[i])-p.y()*sin(ramp[i]));
				Eigen::Vector3d p2 = p1+center;
				tr.addPoint(p2);
			}
			return tr;
		}
		
		static Trajectory<Eigen::Vector3d> circleTrajectoryVerticalX(
			Eigen::Vector3d start, 
			double toAngle, Eigen::Vector3d center,
			double T, double dt)
		{
			Trajectory<Eigen::Vector3d> tr(dt);
			int N = (int)round(T / dt)+1;
			Trajectory<double> ramp = uniformRamp(N, 0.0, toAngle);
			for (int i = 0; i < ramp.size(); i++)
			{
				Eigen::Vector3d p = start-center;
				Eigen::Vector3d p1(p.x()*cos(ramp[i])+p.z()*sin(ramp[i]), 
					p.y(), p.z()*cos(ramp[i])-p.x()*sin(ramp[i]));
				Eigen::Vector3d p2 = p1+center;
				tr.addPoint(p2);
			}
			return tr;
		}

};

}

#endif
