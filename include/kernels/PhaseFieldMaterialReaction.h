//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef PHASEFIELDMATERIALREACTION_H
#define PHASEFIELDMATERIALREACTION_H

#include "Kernel.h"
#include "JvarMapInterface.h"
#include "Material.h"
#include "DerivativeMaterialInterface.h"

// Forward Declaration
class PhaseFieldMaterialReaction;

template <>
InputParameters validParams<PhaseFieldMaterialReaction>();

/**
 * This kernel adds to the residual of the variable u a contribution of
 * \f$ -K \f$ where \f$ K \f$ is a material property expression that can take any arguments.
 */
class PhaseFieldMaterialReaction : public DerivativeMaterialInterface<JvarMapKernelInterface<Kernel>>
{
public:
  PhaseFieldMaterialReaction(const InputParameters & parameters);
  virtual void initialSetup();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  /// Material property expression
  const MaterialProperty<Real> & _K;

  ///  Material property derivative w.r.t. u
  const MaterialProperty<Real> & _dKdu;

  /// Number of other coupled variables (args)
  const unsigned int _nvar;

  ///  Material property derivative w.r.t. other coupled variables in args
  std::vector<const MaterialProperty<Real> *> _dKdarg;
};

#endif // PHASEFIELDMATERIALREACTION
