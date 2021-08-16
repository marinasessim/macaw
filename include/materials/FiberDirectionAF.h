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
#include "RankTwoTensor.h"

class FiberDirectionAF;

template <>
InputParameters validParams<FiberDirectionAF>();

/**
 * Calculates the direction vector of carbon fibers based on the artificial
 * heat flux approach from M. Schneider et al., Thermal fiber orientation
 * tensors for digital paper physics, Int. J. Solids Struct. 100 (2016) 234–244.
 */
class FiberDirectionAF : public DerivativeMaterialInterface<Material>
{
public:
  FiberDirectionAF(const InputParameters & parameters);

protected:
  virtual void initQpStatefulProperties();

  virtual void computeQpProperties();

  /// Gradient of T
  const VariableGradient & _grad_temp_x;
  const VariableGradient & _grad_temp_y;
  const VariableGradient & _grad_temp_z;

  /// Thermal conductivity
  const MaterialProperty<Real> & _thcond;

  /// Tolerance
  const Real _atol;
  const Real _ntol;
  bool _correct;

  /// Material property to save the direction vector
  MaterialProperty<RealVectorValue> & _dir;
};
