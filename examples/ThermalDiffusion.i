[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 14
  ny = 10
  nz = 0
  xmin = 10
  xmax = 40
  ymin = 15
  ymax = 35
  elem_type = QUAD4
[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = SmoothCircleIC
      x1 = 25.0
      y1 = 25.0
      radius = 6.0
      invalue = 0.9
      outvalue = 0.1
      int_width = 3.0
    [../]
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = SmoothCircleIC
      x1 = 30.0
      y1 = 25.0
      radius = 4.0
      invalue = 0.9
      outvalue = 0.1
      int_width = 2.0
    [../]
  [../]
[]

[Kernels]
  [./detadt]
    type = TimeDerivative
    variable = eta
  [../]
  [./ACBulk]
    type = ACParsed
    variable = eta
    args = c
    f_name = F
  [../]
  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = kappa_eta
  [../]

  [./c_res]
    type = SplitCHParsed
    variable = c
    f_name = F
    kappa_name = kappa_c
    w = w
    args = 'eta'
  [../]
  [./w_res]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
  [./time]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  
  # Terms for representing the Soret Diffusion and this needs to represent the interaction 
  # between two components Cu and Sn.
  [./w_res_soret]
    type = MultiSoretDiffusion
    variable = w
    #c = c
    #T = T
    diff_name_1 = D1
    diff_name_2 = D2
    #Q_name = Qstar
  [../]
  
  [./HtCond]
    type = MatDiffusion
    variable = T
    #D_name = thermal_conductivity
    #Either the effective thermal conductivity/ the composite thermal conductivity or something else
  [../]
[]

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]
#the gradient energy coefficient of Allen-Cahn Equation  (assumed constant)
  [./consts]
    type = GenericConstantMaterial
    block = 0
    prop_names  = 'kappa_eta'
    prop_values = '1        '
  [../]
 
 #the mobility of Allen-Cahn Equation - is a function of concentration variables of two species 
  [./mob_AC]
    type = DerivativeParsedMaterial
      block = 0
      f_name = 'L'
      args = 'c'
      function = (1-0.5 *c)
      outputs = exodus
      derivative_order = 1
  [../]
      
  # the gradient energy coefficient of Cahn-Hilliard Equation (assumed constant)    
  [./consts2]
    type = GenericConstantMaterial
    prop_names  = 'kappa_c'
    prop_values = '1 1'
    block = 0
  [../]
  
  # the mobility of Cahn-Hilliard Equation assumed to be a function of concentration of two species
  [./mob_CH]
    type = DerivativeParsedMaterial
      block = 0
      f_name = 'M'
      args = 'c'
      function = (1-0.5 *c)
      outputs = exodus
      derivative_order = 1
  [../]

  [./switching]
    type = SwitchingFunctionMaterial
    block = 0
    eta = eta
    h_order = SIMPLE
  [../]
  [./barrier]
    type = BarrierFunctionMaterial
    block = 0
    eta = eta
    g_order = SIMPLE
  [../]

  [./free_energy_A]
    type = DerivativeParsedMaterial
    block = 0
    f_name = Fa
    args = 'c'
    function = '(c-0.1)^2*(c-1)^2 + c*0.01'
    derivative_order = 2
    enable_jit = true
  [../]
  [./free_energy_B]
    type = DerivativeParsedMaterial
    block = 0
    f_name = Fb
    args = 'c'
    function = 'c^2*(c-0.9)^2 + (1-c)*0.01'
    derivative_order = 2
    enable_jit = true
  [../]

  [./free_energy]
    type = DerivativeTwoPhaseMaterial
    block = 0
    f_name = F
    fa_name = Fa
    fb_name = Fb
    args = 'c'
    eta = eta
    derivative_order = 2
    outputs = exodus
    output_properties = 'F dF/dc dF/deta d^2F/dc^2 d^2F/dcdeta d^2F/deta^2'
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'
  solve_type = 'NEWTON'

  l_max_its = 15
  l_tol = 1.0e-4

  nl_max_its = 10
  nl_rel_tol = 1.0e-11

  start_time = 0.0
  num_steps = 1
  dt = 0.1
[]

[Outputs]
  exodus = true
[]
