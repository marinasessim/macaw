//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "MobilityRotationVector.h"
#include "RankTwoTensor.h"
#include "EulerAngles.h"
#include "RotationTensor.h"

registerMooseObject("macawApp", MobilityRotationVector);

InputParameters
MobilityRotationVector::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Compute a global anisotropic mobility/thermal conductivity tensor in a two phase model.");
  params.addRequiredParam<MaterialPropertyName>("M_A",
      "Name of the ConstantAnisotropicMobility Material for Phase A mobility (RealTensorValue type) to be transformed.");
  params.addRequiredParam<MaterialPropertyName>("M_name",
      "Name of the mobility tensor property to generate (RealTensorValue type).");
  params.addRequiredParam<MaterialPropertyName>("direction_vector",
      "Direction vector (as a Material Property of type RealVectorValue) to perform rotation of coordinate system.");
  return params;
}

MobilityRotationVector::MobilityRotationVector(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _M_a(getMaterialProperty<RealTensorValue>("M_A")),
    _M_name(getParam<MaterialPropertyName>("M_name")),
    _M(declareProperty<RealTensorValue>(_M_name)),
    _dir_vector(getMaterialProperty<RealVectorValue>("direction_vector"))
{
}

void
MobilityRotationVector::initQpStatefulProperties()
{
  _M[_qp].zero();
}

void
MobilityRotationVector::computeQpProperties()
{
  // Coordinate system axis that is rotated to match the direction vector
  const RealVectorValue xax(1,0,0);

  // Get the unit direction vector (normalize)
  RealVectorValue dir = _dir_vector[_qp].unit();
  const Real magnitude = _dir_vector[_qp].norm();

  // Make sure dir vector has a positive magnitude
  if (magnitude <= 0.0)
    dir = xax;

  // Check if direction is already horizontal (necessary bc cross product of itself is zero)
  if (dir == xax)
  {
      _M[_qp] = _M_a[_qp];
  }
  else
  {
    // Find normal vector - axis of rotation
    RealVectorValue w;
    w = xax.cross(dir);
    w = w.unit();

    //Find the angle of rotation
    Real angle;
    angle = std::acos(xax * dir);

    // Calculate the correspondent quaternion
    Eigen::Quaternion<Real> q;
    q = axisAngleToQuaternion(w,angle);

    // Calculate transformation matrix
    RealTensorValue T;
    T = quaternionToRotationMatrix(q);

    // Perform tensor transformation
    _M[_qp] = T * _M_a[_qp] * T.transpose();
  }

}

Eigen::Quaternion<Real>
MobilityRotationVector::axisAngleToQuaternion(RealVectorValue w, Real angle)
{
  Eigen::Quaternion<Real> q;

  // Get the unit vector of on the direction of w (normalize)
  w = w.unit();

  // Fill the quaternion components
  // Negative angle to ensure counter-clockwise rotation of coordinate system instead of a clockwise rotation of a vector
  // Divided by two because of quaternion rotation
  q.w() = std::cos(-angle/2);
  q.x() = std::sin(-angle/2) * w(0);
  q.y() = std::sin(-angle/2) * w(1);
  q.z() = std::sin(-angle/2) * w(2);

  return q;
}

RealTensorValue
MobilityRotationVector::quaternionToRotationMatrix(Eigen::Quaternion<Real> & q)
{
  RealTensorValue T;

  // Since there is no built-in quaternion operators
  // Fill the respective rotation matrix components
  T(0,0) = std::pow(q.w(),2) + std::pow(q.x(),2) - 0.5;
  T(0,1) = q.x() * q.y() - q.w() * q.z();
  T(0,2) = q.w() * q.y() + q.x() * q.z();
  T(1,0) = q.w() * q.z() + q.x() * q.y();
  T(1,1) = std::pow(q.w(),2) + std::pow(q.y(),2) - 0.5;
  T(1,2) = q.y() * q.z() - q.w() * q.x();
  T(2,0) = q.x() * q.z() - q.w() * q.y();
  T(2,1) = q.w() * q.x() + q.y() * q.z();
  T(2,2) = std::pow(q.w(),2) + std::pow(q.z(),2) - 0.5;
  T = 2 * T;

  return T;
}
