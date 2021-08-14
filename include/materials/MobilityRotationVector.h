//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"

// Forward Declarations
template <typename>
class RankTwoTensorTempl;
typedef RankTwoTensorTempl<Real> RankTwoTensor;

/**
 * This material takes in a direction vector and rotates the coordinate system of a tensor
 * to align the original x-axis direction with the given vector.
 */
class MobilityRotationVector : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  MobilityRotationVector(const InputParameters & parameters);

protected:
  virtual void initQpStatefulProperties();

  virtual void computeQpProperties();

  Eigen::Quaternion<Real> axisAngleToQuaternion(RealVectorValue w, Real angle);

  RealTensorValue quaternionToRotationMatrix(Eigen::Quaternion<Real> & q);


  // Phase A material properties
  const MaterialProperty<RealTensorValue> & _M_a;

  // Global material properties
  MaterialPropertyName _M_name;
  MaterialProperty<RealTensorValue> & _M;

  // Direction vector
  const MaterialProperty<RealVectorValue> & _dir_vector;

};
