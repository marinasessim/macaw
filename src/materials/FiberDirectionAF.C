//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FiberDirectionAF.h"

registerMooseObject("macawApp", FiberDirectionAF);

template <>
InputParameters
validParams<FiberDirectionAF>()
{
  InputParameters params = validParams<Material>();
  params.addClassDescription(
      "Calculate fiber direction based on artifical heat flux approach.");
  params.addRequiredCoupledVar("temp_x",
      "Temperature variable for artificial gradient imposed in the direction of the x axis");
  params.addCoupledVar("temp_y",
      "Temperature variable for artificial gradient imposed in the direction of the y axis");
  params.addCoupledVar("temp_z",
      "Temperature variable for artificial gradient imposed in the direction of the z axis");
  params.addRequiredParam<MaterialPropertyName>("vector_name",
      "Name of the direction unit vector (material property) to be created");
  params.addRequiredParam<MaterialPropertyName>("thermal_conductivity",
      "The name of the isotropic thermal conductivity material property that will be used in the flux computation.");
  params.addParam<Real>("angle_tol", 60.0,
      "Tolerance in the angle (degrees) for the orientation correction. Value from 0 to 90 degrees.");
  params.addParam<Real>("norm_tol", 1.0,
      "Tolerance in the relative flux magnitude difference for the orientation correction. Value must greater than zero.");
  params.addParam<bool>("correct_negative_directions", true,
      "Correct negative directions of same orientation.");
  return params;
}

FiberDirectionAF::FiberDirectionAF(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _grad_temp_x(coupledGradient("temp_x")),
    _grad_temp_y(_subproblem.mesh().dimension() >= 2 ? coupledGradient("temp_y") : _grad_zero),
    _grad_temp_z(_subproblem.mesh().dimension() == 3 ? coupledGradient("temp_z") : _grad_zero),
    _thcond(getMaterialProperty<Real>("thermal_conductivity")),
    _atol(getParam<Real>("angle_tol")),
    _ntol(getParam<Real>("norm_tol")),
    _correct(getParam<bool>("correct_negative_directions")),
    _dir(declareProperty<RealVectorValue>(getParam<MaterialPropertyName>("vector_name")))
{
  if (_atol < 0.0  || _atol > 90.0)
    mooseError("Please specify an angle tolerance between 0 and 90 degrees in", name());

  if (_ntol < 0.0)
    mooseError("Please specify a positive relative magnitude tolerance in", name());
}

void
FiberDirectionAF::initQpStatefulProperties()
{
  _dir[_qp].zero();
}

void
FiberDirectionAF::computeQpProperties()
{
  RealVectorValue flux_x(0,0,0);
  RealVectorValue flux_y(0,0,0);
  RealVectorValue flux_z(0,0,0);
  RealVectorValue flux_sum(0,0,0);

  // Calculate heat flux for imposed directions
  flux_x = - _thcond[_qp] * _grad_temp_x[_qp];
  flux_y = - _thcond[_qp] * _grad_temp_y[_qp];
  flux_z = - _thcond[_qp] * _grad_temp_z[_qp];

  if (_correct == true)
  {
    // Check if all flux norms are greater than zero
    if (flux_x.norm() > 0.0 && flux_y.norm() > 0.0 && flux_z.norm() > 0.0)
    {
      RealVectorValue flux_x_dir(0,0,0);
      RealVectorValue flux_y_dir(0,0,0);
      RealVectorValue flux_z_dir(0,0,0);

      // Get direction vectors
      flux_x_dir = flux_x.unit();
      flux_y_dir = flux_y.unit();
      flux_z_dir = flux_z.unit();

      Real angle_xy;
      Real diff_xy;

      Real angle_xz;
      Real diff_xz;

      // Find the relative difference in the magnitude of the fluxes
      diff_xy = std::abs((flux_y.norm() - flux_x.norm())/flux_x.norm());
      diff_xz = std::abs((flux_z.norm() - flux_x.norm())/flux_x.norm());

      // Find the angle between flux x and y
      // Dot product always returns an angle between 0 and pi (180)
      angle_xy = std::acos(flux_x_dir * flux_y_dir) * 180/3.14159265358979323846;
      angle_xz = std::acos(flux_x_dir * flux_z_dir) * 180/3.14159265358979323846;

      // If the angle is larger than a threshold
      // and if the relative difference in the norm is smaller than a threshold
      if (angle_xy >= (180 - _atol) && diff_xy <= _ntol)
      {
        // Flip the orientation of the flux_y direction
        flux_y = - flux_y;
      } else if (angle_xz >= (180 - _atol) && diff_xz <= _ntol)
      {
        // Flip the orientation of the flux_z direction
        flux_z = - flux_z;
      }
    }
  }

  // Compute the sum of the artificial fluxes in 3 directions
  flux_sum = flux_x + flux_y + flux_z;

  const Real magnitude = flux_sum.norm();

  if (magnitude > 0.0)
  {
    _dir[_qp] = flux_sum.unit();
  }
}
