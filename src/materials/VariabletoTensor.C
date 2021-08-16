//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "VariabletoTensor.h"
#include "RankTwoTensor.h"

registerMooseObject("macawApp", VariabletoTensor);

InputParameters
VariabletoTensor::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Transform 9 aux variables into a RealTensorValue. Used for tensor transfer between files.");
  params.addRequiredCoupledVar("var_xx", "Aux variable representing xx component");
  params.addRequiredCoupledVar("var_xy", "Aux variable representing xy component");
  params.addRequiredCoupledVar("var_xz", "Aux variable representing xz component");
  params.addRequiredCoupledVar("var_yx", "Aux variable representing yx component");
  params.addRequiredCoupledVar("var_yy", "Aux variable representing yy component");
  params.addRequiredCoupledVar("var_yz", "Aux variable representing yz component");
  params.addRequiredCoupledVar("var_zx", "Aux variable representing zx component");
  params.addRequiredCoupledVar("var_zy", "Aux variable representing zy component");
  params.addRequiredCoupledVar("var_zz", "Aux variable representing zz component");
  params.addParam<Real>("scale_factor", 1.0,
      "A constant that multiplies each component of the tensor.");
  params.addRequiredParam<MaterialPropertyName>("M_name",
      "Name of the mobility tensor property to generate (RealTensorValue type).");
  return params;
}

VariabletoTensor::VariabletoTensor(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _var_xx(coupledValue("var_xx")),
    _var_xy(coupledValue("var_xy")),
    _var_xz(coupledValue("var_xz")),
    _var_yx(coupledValue("var_yx")),
    _var_yy(coupledValue("var_yy")),
    _var_yz(coupledValue("var_yz")),
    _var_zx(coupledValue("var_zx")),
    _var_zy(coupledValue("var_zy")),
    _var_zz(coupledValue("var_zz")),
    _scale(getParam<Real>("scale_factor")),
    _M_name(getParam<MaterialPropertyName>("M_name")),
    _M(declareProperty<RealTensorValue>(_M_name))
{
}

void
VariabletoTensor::initQpStatefulProperties()
{
  _M[_qp].zero();
}

void
VariabletoTensor::computeQpProperties()
{
  RealTensorValue T;

  // Fill the tensor
  T(0,0) = _var_xx[_qp];
  T(0,1) = _var_xy[_qp];
  T(0,2) = _var_xz[_qp];
  T(1,0) = _var_yx[_qp];
  T(1,1) = _var_yy[_qp];
  T(1,2) = _var_yz[_qp];
  T(2,0) = _var_zx[_qp];
  T(2,1) = _var_zy[_qp];
  T(2,2) = _var_zz[_qp];
  T = _scale * T;

  _M[_qp] = T;
}
