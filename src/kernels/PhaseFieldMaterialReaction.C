//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PhaseFieldMaterialReaction.h"

registerMooseObject("macawApp", PhaseFieldMaterialReaction);

template <>
InputParameters
validParams<PhaseFieldMaterialReaction>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription(
      "Transforms a material property into a kernel value (including off-diagonal terms). The material property can take any args, including the variable that this kernel applies to (u).");
  params.addRequiredParam<MaterialPropertyName>("mat_function","The material property name");
  params.addCoupledVar("args", "Vector of arguments that the material property depends on.");
  return params;
}

PhaseFieldMaterialReaction::PhaseFieldMaterialReaction(const InputParameters & parameters)
  : DerivativeMaterialInterface<JvarMapKernelInterface<Kernel>>(parameters),
    _K(getMaterialProperty<Real>("mat_function")),
    _dKdu(getMaterialPropertyDerivative<Real>("mat_function", _var.name())),
    _nvar(_coupled_moose_vars.size()),
    _dKdarg(_nvar)
{
  // Get reaction rate derivatives wrt args
  for (unsigned int i = 0; i < _nvar; ++i)
    _dKdarg[i] = &getMaterialPropertyDerivative<Real>("mat_function", _coupled_moose_vars[i]->name());
}

void
PhaseFieldMaterialReaction::initialSetup()
{
  validateNonlinearCoupling<Real>("mat_function");
}

Real
PhaseFieldMaterialReaction::computeQpResidual()
{
  return - _K[_qp] * _test[_i][_qp];
}

Real
PhaseFieldMaterialReaction::computeQpJacobian()
{
    return - _dKdu[_qp]  * _test[_i][_qp] * _phi[_j][_qp];
}

Real
PhaseFieldMaterialReaction::computeQpOffDiagJacobian(unsigned int jvar)
{
  // For all other vars get the coupled variable jvar is referring to
  const unsigned int cvar = mapJvarToCvar(jvar);
  return - (*_dKdarg[cvar])[_qp] * _test[_i][_qp] * _phi[_j][_qp];
}
