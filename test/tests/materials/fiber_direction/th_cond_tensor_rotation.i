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
  # DIRECTION VERIFICATION
  # Calculate average direction in the fiber
  [dir_x_func]
    type = ParsedFunction
    value = 'dir_x_pp / (int_h_f)'
    vars = 'dir_x_pp int_h_f'
    vals = 'dir_x_pp int_h_f'
  []
  [dir_y_func]
    type = ParsedFunction
    value = 'dir_y_pp / (int_h_f)'
    vars = 'dir_y_pp int_h_f'
    vals = 'dir_y_pp int_h_f'
  []

  [ave_angle_degree_func]
    type = ParsedFunction
    value = 'atan(ave_dir_y/ave_dir_x)*180/pi'
    vars = 'ave_dir_x ave_dir_y'
    vals = 'ave_dir_x ave_dir_y'
  []

  [ave_angle_rad_func]
    type = ParsedFunction
    value = 'atan(ave_dir_y/ave_dir_x)'
    vars = 'ave_dir_x ave_dir_y'
    vals = 'ave_dir_x ave_dir_y'
  []

  # TENSOR VERIFICATION
  # Calculate average tensor component in the fiber
  [comp_00_func]
    type = ParsedFunction
    value = 'comp_00_pp / (int_h_f)'
    vars = 'comp_00_pp int_h_f'
    vals = 'comp_00_pp int_h_f'
  []
  [comp_01_func]
    type = ParsedFunction
    value = 'comp_01_pp / (int_h_f)'
    vars = 'comp_01_pp int_h_f'
    vals = 'comp_01_pp int_h_f'
  []
  [comp_10_func]
    type = ParsedFunction
    value = 'comp_10_pp / (int_h_f)'
    vars = 'comp_10_pp int_h_f'
    vals = 'comp_10_pp int_h_f'
  []
  [comp_11_func]
    type = ParsedFunction
    value = 'comp_11_pp / (int_h_f)'
    vars = 'comp_11_pp int_h_f'
    vals = 'comp_11_pp int_h_f'
  []

  # Temperature IC
  [ic_func_Tx]
    type = ParsedFunction
    value = '(1000-2000)/557280 * x + 2000'
  []
  [ic_func_Ty]
    type = ParsedFunction
    value = '(1000-2000)/557280 * y + 2000'
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
[ICs]
  [IC_eta_f]
    type = BoundingBoxIC
    variable = eta_f

    x1 = 232200 # 50
    y1 = 46440 # 10

    x2 = 325080 # 70
    y2 = 510840 # 110

    inside = 1.0
    outside = 0.0

    int_width = 0
  []
  [IC_eta_g]
    type = BoundingBoxIC
    variable = eta_g

    x1 = 232200 # 50
    y1 = 46440 # 10

    x2 = 325080 # 70
    y2 = 510840 # 110

    inside = 0.0
    outside = 1.0

    int_width = 0
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
[AuxVariables]
  # DIRECTION VERIFICATION
  [dir_x]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [dir_y]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []

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
  # DIRECTION VERIFICATION
  [dir_x_aux]
    type = MaterialRealVectorValueAux
    variable = dir_x
    component = 0
    property = fiber_direction_AF
  []
  [dir_y_aux]
    type = MaterialRealVectorValueAux
    variable = dir_y
    component = 1
    property = fiber_direction_AF
  []

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

    outputs = exodus
    output_properties = L
  []

  #----------------------------------------------------------------------------#
  # Grand Potential Interface Parameters
  [iface]
    # reproduce the parameters from GrandPotentialMultiphase.i
    type = GrandPotentialInterface
    gamma_names = 'gamma_fg'
    sigma = '0.01'
    kappa_name = kappa
    mu_name = mu

    outputs = exodus
  []

  #------------------------------------------------------------------------------#
  # Conservation check
  [sum_eta]
    type = ParsedMaterial
    f_name = sum_eta
    args = 'eta_f eta_g'

    function = 'eta_f + eta_g'

    outputs = exodus
    output_properties = sum_eta
  []

  [sum_h]
    type = DerivativeParsedMaterial
    f_name = sum_h
    args = 'eta_f eta_g'

    function = 'h_f + h_g'

    material_property_names = 'h_f h_g'

    outputs = exodus
    output_properties = sum_h
  []

  #------------------------------------------------------------------------------#
  [thermal_conductivity]
    type = DerivativeParsedMaterial
    f_name = thermal_conductivity
    args = 'eta_f eta_g'

    function = 'h_f*100 + h_g*1'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'

    outputs = exodus
    output_properties = thermal_conductivity
  []

  [th_cond_AF]
    type = DerivativeParsedMaterial
    f_name = th_cond_AF
    args = 'eta_f eta_g'

    function = 'h_f*100 + h_g*0.0'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'

    outputs = exodus
    output_properties = th_cond_AF
  []

  #------------------------------------------------------------------------------#
  # Tensor Transformation #
  #------------------------------------------------------------------------------#
  # FiberDirection transforms the artificial heat flux into the normalized fiber direction
  [direction_AF]
    type = FiberDirectionAF
    temp_x = T_x
    temp_y = T_y

    thermal_conductivity = th_cond_AF
    vector_name = fiber_direction_AF

    outputs = exodus
  []

  # MobilityRotationVector calculates the transformed tensor given the fiber direction
  [transformation]
    type = MobilityRotationVector
    M_A = thcond_f
    direction_vector = fiber_direction_AF
    M_name = rot_thcond_f

    outputs = exodus
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

    outputs = exodus
    output_properties = thcond_aniso
  []

  #------------------------------------------------------------------------------#
  # DIRECTION VERIFICATION
  # Average fiber direction
  [dir_x_mat]
    type = ParsedMaterial
    f_name = dir_x_mat
    args = dir_x
    function = 'h_f * dir_x'
    material_property_names = 'h_f'
    outputs = exodus
  []
  [dir_y_mat]
    type = ParsedMaterial
    f_name = dir_y_mat
    args = dir_y
    function = 'h_f * dir_y'
    material_property_names = 'h_f'
    outputs = exodus
  []

  [angle_degree_mat]
    type = ParsedMaterial
    f_name = angle_mat
    args = 'dir_x dir_y'

    function = 'h_f * atan(dir_y/dir_x) * 180/ pi'

    constant_names = 'pi'
    constant_expressions = '3.14159265358979323846'

    material_property_names = 'h_f'
    outputs = exodus
  []

  #------------------------------------------------------------------------------#
  # TENSOR VERIFICATION
  # Average tensor component 00 in the fiber
  [comp_00_mat]
    type = ParsedMaterial
    f_name = comp_00_mat
    args = var_00
    function = 'h_f * var_00'
    material_property_names = 'h_f'
    outputs = exodus
  []

  [comp_01_mat]
    type = ParsedMaterial
    f_name = comp_01_mat
    args = var_01
    function = 'h_f * var_01'
    material_property_names = 'h_f'
    outputs = exodus
  []

  [comp_10_mat]
    type = ParsedMaterial
    f_name = comp_10_mat
    args = var_10
    function = 'h_f * var_10'
    material_property_names = 'h_f'
    outputs = exodus
  []

  [comp_11_mat]
    type = ParsedMaterial
    f_name = comp_11_mat
    args = var_11
    function = 'h_f * var_11'
    material_property_names = 'h_f'
    outputs = exodus
  []
[]

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
  l_tol = 1.0e-6

  start_time = 0.0
  dt = 1
  num_steps = 1

  automatic_scaling = true
  compute_scaling_once = false

  line_search = basic
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

#------------------------------------------------------------------------------#
[Postprocessors]
  # Species output
  [int_h_f]
    type = ElementIntegralMaterialProperty
    mat_prop = h_f
    execute_on = 'TIMESTEP_END FINAL'

    allow_duplicate_execution_on_initial = true

    outputs = 'csv'
  []

  # DIRECTION VERIFICATION
  # Integral direction component inside the fiber = h_f * component
  [dir_x_pp]
    type = ElementIntegralMaterialProperty
    mat_prop = 'dir_x_mat'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []
  [dir_y_pp]
    type = ElementIntegralMaterialProperty
    mat_prop = 'dir_y_mat'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  # Average tensor components
  [ave_dir_x]
    type = FunctionValuePostprocessor
    function = 'dir_x_func'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv exodus'
  []
  [ave_dir_y]
    type = FunctionValuePostprocessor
    function = 'dir_y_func'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv exodus'
  []

  [ave_angle_degree_pp]
    type = FunctionValuePostprocessor
    function = 'ave_angle_degree_func'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv console exodus'
  []

  [ave_angle_rad_pp]
    type = FunctionValuePostprocessor
    function = 'ave_angle_rad_func'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv exodus'
  []

  # TENSOR VERIFICATION
  # Integral tensor component inside the fiber = h_f * component
  [comp_00_pp]
    type = ElementIntegralMaterialProperty
    mat_prop = 'comp_00_mat'
    execute_on = 'INITIAL TIMESTEP_END FINAL'

    outputs = 'csv'
  []
  [comp_01_pp]
    type = ElementIntegralMaterialProperty
    mat_prop = 'comp_01_mat'
    execute_on = 'INITIAL TIMESTEP_END FINAL'

    outputs = 'csv'
  []
  [comp_10_pp]
    type = ElementIntegralMaterialProperty
    mat_prop = 'comp_10_mat'
    execute_on = 'INITIAL TIMESTEP_END FINAL'

    outputs = 'csv'
  []
  [comp_11_pp]
    type = ElementIntegralMaterialProperty
    mat_prop = 'comp_11_mat'
    execute_on = 'INITIAL TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  # Average tensor components
  [ave_comp_00]
    type = FunctionValuePostprocessor
    function = 'comp_00_func'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv exodus'
  []
  [ave_comp_01]
    type = FunctionValuePostprocessor
    function = 'comp_01_func'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv exodus'
  []
  [ave_comp_10]
    type = FunctionValuePostprocessor
    function = 'comp_10_func'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv exodus'
  []
  [ave_comp_11]
    type = FunctionValuePostprocessor
    function = 'comp_11_func'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv exodus'
  []
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
