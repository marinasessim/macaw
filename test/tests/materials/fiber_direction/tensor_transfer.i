#------------------------------------------------------------------------------#
# Anisotropic Thermal Conductivity Tensor Calculation
# Nondimensional parameters with convertion factors:
# lo = 2.1524e-04 micron
# to = 4.3299e-04 s
# eo = 3.9 eV
# This file calculates the direction of a fiber that is initialized using a
# bounding box IC. The direction calculation is based on the artificial heat
# flux approach from Schneider et al 2016. Then, it uses the calculated direction
# to rotate the coordinate system of the fiber thermal conductivity tensor.
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2

    xmin = 0
    xmax = 557280 # 120 microns
    nx = 12

    ymin = 0
    ymax = 557280 # 120 microns
    ny = 12
  []
[]

#------------------------------------------------------------------------------#
[UserObjects]
  [solution_uo]
    type = SolutionUserObject
    mesh = th_cond_tensor_rotation_exodus.e
    system_variables = 'eta_f eta_g
                        var_00 var_01 var_02
                        var_10 var_11 var_12
                        var_20 var_21 var_22'
    timestep = 'LATEST'
  []
[]

#------------------------------------------------------------------------------#
[Variables]
  [T]
    initial_condition = 3000
  []
[]

#------------------------------------------------------------------------------#
[Functions]
  [ic_func_eta_f]
    type = SolutionFunction
    from_variable = eta_f
    solution = solution_uo
  []
  [ic_func_eta_g]
    type = SolutionFunction
    from_variable = eta_g
    solution = solution_uo
  []

  [ic_func_00]
    type = SolutionFunction
    from_variable = var_00
    solution = solution_uo
  []
  [ic_func_01]
    type = SolutionFunction
    from_variable = var_01
    solution = solution_uo
  []
  [ic_func_02]
    type = SolutionFunction
    from_variable = var_02
    solution = solution_uo
  []

  [ic_func_10]
    type = SolutionFunction
    from_variable = var_10
    solution = solution_uo
  []
  [ic_func_11]
    type = SolutionFunction
    from_variable = var_11
    solution = solution_uo
  []
  [ic_func_12]
    type = SolutionFunction
    from_variable = var_12
    solution = solution_uo
  []

  [ic_func_20]
    type = SolutionFunction
    from_variable = var_20
    solution = solution_uo
  []
  [ic_func_21]
    type = SolutionFunction
    from_variable = var_21
    solution = solution_uo
  []
  [ic_func_22]
    type = SolutionFunction
    from_variable = var_22
    solution = solution_uo
  []
[]

#------------------------------------------------------------------------------#
[ICs]
  [IC_eta_f]
    type = FunctionIC
    variable = eta_f
    function = ic_func_eta_f
  []
  [IC_eta_g]
    type = FunctionIC
    variable = eta_g
    function = ic_func_eta_g
  []
  [IC_00]
    type = FunctionIC
    variable = var_00
    function = ic_func_00
  []
  [IC_01]
    type = FunctionIC
    variable = var_01
    function = ic_func_01
  []
  [IC_02]
    type = FunctionIC
    variable = var_02
    function = ic_func_02
  []

  [IC_10]
    type = FunctionIC
    variable = var_10
    function = ic_func_10
  []
  [IC_11]
    type = FunctionIC
    variable = var_11
    function = ic_func_11
  []
  [IC_12]
    type = FunctionIC
    variable = var_12
    function = ic_func_12
  []

  [IC_20]
    type = FunctionIC
    variable = var_20
    function = ic_func_20
  []
  [IC_21]
    type = FunctionIC
    variable = var_21
    function = ic_func_21
  []
  [IC_22]
    type = FunctionIC
    variable = var_22
    function = ic_func_22
  []
[]

#------------------------------------------------------------------------------#
[AuxVariables]
  #Phase eta_f: carbon fiber
  [eta_f]
  []
  #Phase eta_g: gas
  [eta_g]
  []

  [var_00]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_01]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_02]
    order = CONSTANT
    family = MONOMIAL
  []

  [var_10]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_11]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_12]
    order = CONSTANT
    family = MONOMIAL
  []

  [var_20]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_21]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_22]
    order = CONSTANT
    family = MONOMIAL
  []
[]

#------------------------------------------------------------------------------#
[AuxKernels]
[] # End of AuxKernels

#------------------------------------------------------------------------------#
#    #  ######  #####   #    #  ######  #        ####
#   #   #       #    #  ##   #  #       #       #
####    #####   #    #  # #  #  #####   #        ####
#  #    #       #####   #  # #  #       #            #
#   #   #       #   #   #   ##  #       #       #    #
#    #  ######  #    #  #    #  ######  ######   ####
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
[Kernels]
  #----------------------------------------------------------------------------#
  # Heat Conduction kernels
  [Heat_Conduction]
    type = MatAnisoDiffusion
    variable = T
    args = 'eta_f eta_g'

    diffusivity = thcond_aniso
  []
[]
#----------------------------------------------------------------------------#
# END OF KERNELS

#------------------------------------------------------------------------------#
#    #    ##    #####  ######  #####   #    ##    #        ####
##  ##   #  #     #    #       #    #  #   #  #   #       #
# ## #  #    #    #    #####   #    #  #  #    #  #        ####
#    #  ######    #    #       #####   #  ######  #            #
#    #  #    #    #    #       #   #   #  #    #  #       #    #
#    #  #    #    #    ######  #    #  #  #    #  ######   ####
#------------------------------------------------------------------------------#
[Materials]
  #----------------------------------------------------------------------------#
  # Switching functions
  [switch_f]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h_f
    all_etas = 'eta_f eta_g'
    phase_etas = 'eta_f'
  []

  [switch_g]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h_g
    all_etas = 'eta_f eta_g'
    phase_etas = 'eta_g'
  []

  #----------------------------------------------------------------------------#
  # Generates a th cond tensor (RealTensorValue) from the transfer aux variables
  [thcond_a]
    type = VariabletoTensor
    var_xx = var_00
    var_xy = var_01
    var_xz = var_02
    var_yx = var_10
    var_yy = var_11
    var_yz = var_12
    var_zx = var_20
    var_zy = var_21
    var_zz = var_22

    M_name = thcond_a
  []

  [thcond_b]
    type = ConstantAnisotropicMobility
    tensor = '2.6501e+04      0             0
              0               2.6501e+04    0
              0               0             2.6501e+04'

    M_name = thcond_b
  []

  # Creates a compound tensor for the entire domain
  [thcond_composite]
    type = CompositeMobilityTensor
    args = 'eta_f eta_g'

    weights = 'h_f       h_g'
    tensors = 'thcond_a  thcond_b'

    M_name = thcond_aniso

    outputs = exodus
    output_properties = thcond_aniso
  []

[]

#------------------------------------------------------------------------------#
[BCs]
  [fixed_T_top]
    type = DirichletBC
    variable = 'T'
    boundary = 'top'
    value = '3000'
  []
[]

#------------------------------------------------------------------------------#
[Preconditioning]
  active = 'hypre'

  [hypre]
    type = SMP
    full = true
    solve_type = NEWTON
    petsc_options_iname = '-pc_type  -pc_hypre_type  -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
    petsc_options_value = 'hypre     boomeramg       31                  0.7'
  []

[]

#---------------------------------------------------------------------------------------------#
#######  #     #  #######   #####   #     #  #######  ###  #######  #     #  #######  ######
#         #   #   #        #     #  #     #     #      #   #     #  ##    #  #        #     #
#          # #    #        #        #     #     #      #   #     #  # #   #  #        #     #
#####       #     #####    #        #     #     #      #   #     #  #  #  #  #####    ######
#          # #    #        #        #     #     #      #   #     #  #   # #  #        #   #
#         #   #   #        #     #  #     #     #      #   #     #  #    ##  #        #    #
#######  #     #  #######   #####    #####      #     ###  #######  #     #  #######  #     #
#---------------------------------------------------------------------------------------------#
[Executioner]
  type = Transient

  nl_max_its = 12
  nl_rel_tol = 1.0e-8

  nl_abs_tol = 1e-10

  l_max_its = 30
  l_tol = 1.0e-6

  start_time = 0.0
  dt = 1
  num_steps = 1

  verbose = true

  automatic_scaling = true
  compute_scaling_once = false

  line_search = default
  line_search_package = petsc

  scheme = bdf2
[]

#------------------------------------------------------------------------------#
#####    ####    ####   #####
#    #  #    #  #         #
#    #  #    #   ####     #
#####   #    #       #    #
#       #    #  #    #    #
#        ####    ####     #
#------------------------------------------------------------------------------#
[Postprocessors]
[]

#------------------------------------------------------------------------------#
[Outputs]
  [exodus]
    type = Exodus
  []

  [csv]
    type = CSV
  []

  [pgraph]
    type = PerfGraphOutput
    execute_on = 'final'
    level = 2
    heaviest_branch = true
    heaviest_sections = 2
  []
[]
