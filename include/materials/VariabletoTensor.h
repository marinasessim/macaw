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
 * This material assembles a RealTensor material property
 * by reading 9 variables. It is useful to transfer a tensor from
 * another simulation.
 */
class VariabletoTensor : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  VariabletoTensor(const InputParameters & parameters);

protected:
  virtual void initQpStatefulProperties();

  virtual void computeQpProperties();

  // Variables
  const VariableValue & _var_xx;
  const VariableValue & _var_xy;
  const VariableValue & _var_xz;
  const VariableValue & _var_yx;
  const VariableValue & _var_yy;
  const VariableValue & _var_yz;
  const VariableValue & _var_zx;
  const VariableValue & _var_zy;
  const VariableValue & _var_zz;

  // Scale factor
  const Real _scale;

  // Global material properties
  MaterialPropertyName _M_name;
  MaterialProperty<RealTensorValue> & _M;

};
