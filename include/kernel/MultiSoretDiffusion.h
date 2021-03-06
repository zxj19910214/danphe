/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef MULTISORETDIFFUSION_H
#define MULTISORETDIFFUSION_H

#include "Kernel.h"

//Forward Declaration
class MultiSoretDiffusion;

template<>
InputParameters validParams<MultiSoretDiffusion>();
/**
 * SoretDiffusion adds the soret effect in the split form of the Cahn-Hilliard
 * equation.
 */
class MultiSoretDiffusion : public Kernel
{
public:
  MultiSoretDiffusion(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);
  virtual Real computeQpCJacobian();

  /// int label for temperature variable
  unsigned int _T_var;

  /// Coupled variable for the temperature
  const VariableValue & _T;

  /// Variable gradient for temperature
  const VariableGradient & _grad_T;

  /// int label for the Concentration
  unsigned int _c_var;

  /// Variable value for the concentration
  const VariableValue & _c;

  /// Diffusivity material property
  ///const MaterialProperty<Real> & _D;

  /// Heat of transport material property
  ///const MaterialProperty<Real> & _Q;
  
  /// Net thermotransport factor symbolized as Mq
  const MaterialProperty<Real> & _Mq;

  /// Boltzmann constant
  const Real _kb;

  ///Universal Gas Constant
  const Real _R;
};

#endif //MULTISORETDIFFUSION_H
