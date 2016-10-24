/*
 * point_3d.cpp
 *
 *  Created on: 2016. okt. 10.
 *      Author: tamas
 */

#include <iostream>
#include <math.h>
#include "point_3d.hpp"

 	Point3D::Point3D(): x(0.0), y(0.0), z(0.0) {}
   	Point3D::Point3D(double x, double y, double z): x(x), y(y), z(z) {}
   	Point3D::Point3D(const Point3D& other): x(other.x), y(other.y), z(other.z) {}
   	
   	void Point3D::swap(Point3D& other) 
   	{
   		Point3D tmp(*this);
   		x = other.x;
   		y = other.y;
   		z = other.z;
   		
   		other.x = tmp.x;
   		other.y = tmp.y;
   		other.z = tmp.z;
   	}
   	
   	Point3D Point3D::operator=(const Point3D& other)
   	{
   		Point3D tmp(other);
   		this->swap(tmp);
   		return *this;
   	}
   	
   	Point3D Point3D::operator+=(const Point3D& other) 
   	{
   		x += other.x;
   		y += other.y;
   		z += other.z;
   		
   		return *this;
   	}
   	
   	Point3D Point3D::operator-=(const Point3D& other) 
   	{
   		x -= other.x;
   		y -= other.y;
   		z -= other.z;
   		
   		return *this;
   	}
   	
   	Point3D Point3D::operator/=(const double& d) 
   	{
   		x /= d;
   		y /= d;
   		z /= d;
   		
   		return *this;
   	}
   	
   	Point3D Point3D::operator*=(const double& d) 
   	{
   		x *= d;
   		y *= d;
   		z *= d;
   		
   		return *this;
   	}
   	
   	Point3D Point3D::operator+(const Point3D& other) const
   	{
   		Point3D tmp(*this);
   		tmp += other;
   		return tmp;
   	}
   	
   	Point3D Point3D::operator-(const Point3D& other) const
   	{
   		Point3D tmp(*this);
   		tmp -= other;
   		return tmp;
   	}
   	
   	Point3D Point3D::operator*(const double& d) const
   	{
   		Point3D tmp(*this);
   		tmp *= d;
   		return tmp;
   	}
   	
   	Point3D Point3D::operator/(const double& d) const
   	{
   		Point3D tmp(*this);
   		tmp /= d;
   		return tmp;
   	}
   	
   	double Point3D::distance(const Point3D& other) const
   	{
   		Point3D d = *this - other;
   		return sqrt((d.x*d.x)+(d.y*d.y)+(d.z*d.z));
   	}
   	
   	std::ostream& operator<<(std::ostream& os, const Point3D& p)
   	{
   		return os << "(" << p.x <<", " << p.y << ", " << p.z << ")";
   	}


