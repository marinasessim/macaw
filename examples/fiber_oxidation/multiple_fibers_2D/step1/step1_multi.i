#------------------------------------------------------------------------------#
# Fiber direction calculation
# This step1 pseudo-simulation is used to compute the direction vectors of the
# carbon fibers, which is later used as the reference direction to perform a
# rotation of the coordinate system of the thermal conductivity tensor. We align
# the x-direction of the original tensor with the local direction vector of the
# fibers. The diffuse interface is simulataneously generated from the sharp
# binary image used as the initial condition for the fibers.
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2

    xmin = 0
    xmax = 557280 # 120 microns
    nx = 120

    ymin = 0
    ymax = 557280 # 120 microns
    ny = 120

    elem_type = QUAD4
  []

  uniform_refine = 2
[]

#------------------------------------------------------------------------------#
[GlobalParams]
  # Interface thickness from Grand Potential material
  # Total interface thickness
  width = 4644 # int_width 1 micron, half of the total width

  # [Materials] stuff during initialization
  derivative_order = 2
  evalerror_behavior = error
  enable_ad_cache = false
  enable_jit = false
[]

#------------------------------------------------------------------------------#
[Functions]
  # IMAGE READER
  [ic_func_eta_f]
    type = ImageFunction
    file = multiple_fibers.tif
    threshold = 170
    upper_value = 0.0 # white is zero
    lower_value = 1.0 # black is one
  []
  [ic_func_eta_g]
    type = ImageFunction
    file = multiple_fibers.tif
    threshold = 170
    upper_value = 1.0 # white is one
    lower_value = 0.0 # black is zero
  []

  # Temperature IC
  [ic_func_Tx]
    type = ParsedFunction
    value = '(1000-2000)/464400 * x + 2000'
  []
  [ic_func_Ty]
    type = ParsedFunction
    value = '(1000-2000)/464400 * y + 2000'
  []
[]


#------------------------------------------------------------------------------#
[ICs]
  # IMAGE READER
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

  [IC_Tx]
    type = FunctionIC
    variable = T_x
    function = ic_func_Tx
  []
  [IC_Ty]
    type = FunctionIC
    variable = T_y
    function = ic_func_Ty
  []
[]

#------------------------------------------------------------------------------#
[Variables]
  #Phase eta_f: carbon fiber
  [eta_f]
  []
  #Phase eta_g: gas
  [eta_g]
  []

  # Temperatures
  [T_x]
  []
  [T_y]
  []
[]

#------------------------------------------------------------------------------#
# Bnds stuff
[AuxVariables]
  [var_00]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_01]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_02]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []

  [var_10]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_11]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_12]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []

  [var_20]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_21]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_22]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
[]

#------------------------------------------------------------------------------#
[AuxKernels]
  [var_00_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_00
    row = 0
    column = 0
    execute_on = 'TIMESTEP_END'
  []
  [var_01_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_01
    row = 0
    column = 1
    execute_on = 'TIMESTEP_END'
  []
  [var_02_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_02
    row = 0
    column = 2
    execute_on = 'TIMESTEP_END'
  []

  [var_10_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_10
    row = 1
    column = 0
    execute_on = 'TIMESTEP_END'
  []
  [var_11_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_11
    row = 1
    column = 1
    execute_on = 'TIMESTEP_END'
  []
  [var_12_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_12
    row = 1
    column = 2
    execute_on = 'TIMESTEP_END'
  []

  [var_20_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_20
    row = 2
    column = 0
    execute_on = 'TIMESTEP_END'
  []
  [var_21_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_21
    row = 2
    column = 1
    execute_on = 'TIMESTEP_END'
  []
  [var_22_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_22
    row = 2
    column = 2
    execute_on = 'TIMESTEP_END'
  []
[]

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
  # eta_f kernels
  [AC_f_bulk]
    type = ACGrGrMulti
    variable = eta_f
    v = 'eta_g'
    gamma_names = 'gamma_fg'
    mob_name = L
  []

  [AC_f_sw]
    type = ACSwitching
    variable = eta_f
    Fj_names = 'omega_f omega_g'
    hj_names = 'h_f     h_g'
    mob_name = L
    args = 'eta_g'
  []

  [AC_f_int]
    type = ACInterface
    variable = eta_f
    kappa_name = kappa
    mob_name = L
    args = 'eta_g'
  []

  [eta_f_dot]
    type = TimeDerivative
    variable = eta_f
  []

  #----------------------------------------------------------------------------#
  # eta_g kernels
  [AC_g_bulk]
    type = ACGrGrMulti
    variable = eta_g
    v = 'eta_f'
    gamma_names = 'gamma_fg'
    mob_name = L
  []

  [AC_g_sw]
    type = ACSwitching
    variable = eta_g
    Fj_names = 'omega_f omega_g'
    hj_names = 'h_f     h_g'
    mob_name = L
    args = 'eta_f'
  []

  [AC_g_int]
    type = ACInterface
    variable = eta_g
    kappa_name = kappa
    mob_name = L
    args = 'eta_f'
  []

  [eta_g_dot]
    type = TimeDerivative
    variable = eta_g
  []

  #----------------------------------------------------------------------------#
  # Heat Conduction kernels
  [Heat_Conduction_Tx]
    type = HeatConduction
    variable = T_x
    diffusion_coefficient = thermal_conductivity
  []

  [Heat_Conduction_Ty]
    type = HeatConduction
    variable = T_y
    diffusion_coefficient = thermal_conductivity
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

    outputs = exodus
    output_properties = h_f
  []

  [switch_g]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h_g
    all_etas = 'eta_f eta_g'
    phase_etas = 'eta_g'

    outputs = exodus
    output_properties = h_g
  []

  #----------------------------------------------------------------------------#
  # Grand potential densities
  [omega_f]
    type = DerivativeParsedMaterial
    f_name = omega_f
    function = '1e-5'
  []

  [omega_g]
    type = DerivativeParsedMaterial
    f_name = omega_g
    function = '1e-5'
  []

  #----------------------------------------------------------------------------#
  [phase_mobility]
    type = GenericConstantMaterial

    prop_names = 'L'
    prop_values = '1e3'
  []

  #----------------------------------------------------------------------------#
  # Grand Potential Interface Parameters
  [iface]
    type = GrandPotentialInterface
    gamma_names = 'gamma_fg'
    sigma = '0.01'
    kappa_name = kappa
    mu_name = mu
  []

  #------------------------------------------------------------------------------#
  # Conservation check
  [sum_eta]
    type = ParsedMaterial
    f_name = sum_eta
    args = 'eta_f eta_g'

    function = 'eta_f + eta_g'
  []

  [sum_h]
    type = DerivativeParsedMaterial
    f_name = sum_h
    args = 'eta_f eta_g'

    function = 'h_f + h_g'

    material_property_names = 'h_f h_g'
  []

  #------------------------------------------------------------------------------#
  [thermal_conductivity]
    type = DerivativeParsedMaterial
    f_name = thermal_conductivity
    args = 'eta_f eta_g'

    function = 'h_f*100.0 + h_g*1.0'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'

  []

  [th_cond_AF]
    type = DerivativeParsedMaterial
    f_name = th_cond_AF
    args = 'eta_f eta_g'

    function = 'h_f*100.0 + h_g*0.0'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
  []

  #------------------------------------------------------------------------------#
  # Tensor Transformation #
  #------------------------------------------------------------------------------#
  # FiberDirection transforms the temperature gradient into the normalized fiber direction
  [direction_AF]
    type = FiberDirectionAF
    temp_x = T_x
    temp_y = T_y

    thermal_conductivity = th_cond_AF
    vector_name = fiber_direction_AF

    correct_negative_directions = false
    angle_tol = 60
    norm_tol = 1
  []

  # MobilityRotationVector calculates the transformed tensor given the fiber direction
  [transformation]
    type = MobilityRotationVector
    M_A = thcond_f
    direction_vector = fiber_direction_AF
    M_name = rot_thcond_f
  []
  #----------------------------------------------------------------------------#
  # Thermal conductivity
  # In step 1, the value with the longitudinal thermal conductivity is ii
  [thcond_f]
    type = ConstantAnisotropicMobility
    tensor = '7.4576e+06      0             0
              0               7.4576e+04    0
              0               0             7.4576e+04'

    M_name = thcond_f
  []

  # In step 1, thcond_g should be all zeros
  [thcond_g]
    type = ConstantAnisotropicMobility
    tensor = '0      0    0
              0      0    0
              0      0    0'

    M_name = thcond_g
  []

  # Creates a compound tensor for the entire domain
  [thcond_composite]
    type = CompositeMobilityTensor
    args = 'eta_f eta_g'

    weights = 'h_f            h_g'
    tensors = 'rot_thcond_f   thcond_g'

    M_name = thcond_aniso
  []

[] # End of Materials

#------------------------------------------------------------------------------#
[BCs]
  [Tx_left]
    type = DirichletBC
    variable = T_x
    boundary = 'left'
    value = 2000
  []
  [Tx_right]
    type = DirichletBC
    variable = T_x
    boundary = 'right'
    value = 1000
  []

  [Ty_bottom]
    type = DirichletBC
    variable = T_y
    boundary = 'bottom'
    value = 2000
  []
  [Ty_top]
    type = DirichletBC
    variable = T_y
    boundary = 'top'
    value = 1000
  []
[]

#------------------------------------------------------------------------------#
[Preconditioning]
  active = 'hypre'

  [hypre]
    type = SMP
    full = true
    solve_type = NEWTON
    petsc_options_iname = '-pc_type  -pc_hypre_type  -ksp_gmres_restart  -pc_hypre_boomeramg_strong_threshold'
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
#---------------------------------------------------------------------------------------------#
[Executioner]
  type = Transient

  nl_max_its = 12
  nl_rel_tol = 1.0e-8

  l_max_its = 30
  l_tol = 1.0e-8

  start_time = 0.0
  end_time = 200

  dtmin = 1e-6

  verbose = true

  automatic_scaling = true
  compute_scaling_once = false

  line_search = basic
  line_search_package = petsc

  scheme = bdf2

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1

    growth_factor = 1.2
    cutback_factor = 0.83333

    optimal_iterations = 4 # Number of nonlinear
    linear_iteration_ratio = 10 # Ratio of linear to nonlinear

    iteration_window = 0
  []
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
  # Species output
  [int_h_f]
    type = ElementIntegralMaterialProperty
    mat_prop = h_f
    execute_on = 'TIMESTEP_END FINAL'

    allow_duplicate_execution_on_initial = true

    outputs = 'exodus console'
  []

  #----------------------------------------------------------------------------#
  # Stats
  [dt]
    type = TimestepSize
  []
  [alive_time]
    type = PerfGraphData
    data_type = TOTAL
    section_name = 'Root'
  []
  [mem_total_physical_mb]
    type = MemoryUsage
    mem_type = physical_memory
    mem_units = megabytes
    value_type = total
  []
  [mem_max_physical_mb]
    type = MemoryUsage
    mem_type = physical_memory
    mem_units = megabytes
    value_type = max_process
  []
[]

#------------------------------------------------------------------------------#
[Outputs]
  [console]
    type = Console
    fit_mode = 160
    max_rows = 10
  []

  [exodus]
    type = Exodus
  []

  [pgraph]
    type = PerfGraphOutput
    execute_on = 'final'
    level = 2
    heaviest_branch = true
    heaviest_sections = 2
  []
[]

#------------------------------------------------------------------------------#
[Debug]
  show_var_residual_norms = true
[]
