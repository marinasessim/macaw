#------------------------------------------------------------------------------#
# Surface Reaction
# Nondimensional parameters with convertion factors:
# lo = 2.1524e-04 micron
# to = 4.3299e-04 s
# eo = 3.9 eV
# This file replicates the comparison with the analytical model, where the left
# half of the domain is a carbon fiber, and the right is a gas. We assume an infinite
# amount of carbon, and the interface remains static while the gas change composition.
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
[Mesh]
  type = GeneratedMesh
  dim = 1

  xmin = 0
  xmax = 46440 # 10 microns
  nx = 10

  uniform_refine = 3 # refine
[]

#------------------------------------------------------------------------------#
[GlobalParams]
  # Interface thickness for Grand Potential material
  width = 4644 # int_width 1 micron, half of the total width

  # [Materials] stuff during initialization
  derivative_order = 2
  evalerror_behavior = error
  enable_ad_cache = false
  enable_jit = false
[]

#------------------------------------------------------------------------------#
[Variables]
  [w_c]
  []
  [w_o]
  []
  [w_co]
  []

  #Phase eta_f: carbon fiber
  [eta_f]
  []
  #Phase eta_g: gas
  [eta_g]
  []
[]

#------------------------------------------------------------------------------#
[Functions]
  [ic_func_eta_f]
    type = ParsedFunction
    value = '0.5^2*(1.0-tanh(2*(x-x_val)/(int_width)))*(1.0-tanh(2*(y-y_val)/(int_width)))'
    vars = 'int_width  x_val    y_val'
    vals = '4644       23220    232200' # int_width = 1 micron (half total)
  []
  [ic_func_eta_g]
    type = ParsedFunction
    value = '1 - 0.5^2*(1.0-tanh(2*(x-x_val)/(int_width)))*(1.0-tanh(2*(y-y_val)/(int_width)))'
    vars = 'int_width  x_val    y_val'
    vals = '4644       23220    232200' # int_width = 1 micron (half total)
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

  [IC_w_c]
    type = ConstantIC
    variable = w_c
    value = 0
  []
  [IC_w_o]
    type = ConstantIC
    variable = w_o
    value = 0
  []
  [IC_w_co]
    type = ConstantIC
    variable = w_co
    value = 0
  []

  [IC_T]
    type = ConstantIC
    variable = T
    value = 3000
  []
[]

#------------------------------------------------------------------------------#
[AuxVariables]
  [T]
  []
[]
# End of AuxVariables

#------------------------------------------------------------------------------#
[AuxKernels]
  [aux_T]
    type = ConstantAux
    variable = T
    value = 3000
  []
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
  [reaction_kernel_O]
    type = PhaseFieldMaterialReaction
    variable = w_o
    mat_function = reaction_CO
    args = 'w_c w_o eta_f eta_g T'
  []

  [reaction_kernel_CO]
    type = PhaseFieldMaterialReaction
    variable = w_co
    mat_function = production_CO
    args = 'w_c w_o eta_f eta_g T'
  []

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
    args = 'w_c w_o w_co eta_g T'
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
    args = 'w_c w_o w_co eta_f T'
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
  # Chemical potential kernels
  #----------------------------------------------------------------------------#
  # Carbon
  [w_c_dot]
    type = SusceptibilityTimeDerivative
    variable = w_c
    f_name = chi_c
    args = 'w_c eta_f eta_g T'
  []

  [diffusion_c]
    type = MatDiffusion
    variable = w_c
    diffusivity = Dchi_c
    args = 'w_c eta_f eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Oxygen
  [w_o_dot]
    type = SusceptibilityTimeDerivative
    variable = w_o
    f_name = chi_o
    args = 'w_o eta_f eta_g T'
  []

  [diffusion_o]
    type = MatDiffusion
    variable = w_o
    diffusivity = Dchi_o
    args = 'w_o eta_f eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Carbon Monoxide
  [w_co_dot]
    type = SusceptibilityTimeDerivative
    variable = w_co
    f_name = chi_co
    args = 'w_co eta_f eta_g T'
  []

  [diffusion_co]
    type = MatDiffusion
    variable = w_co
    diffusivity = Dchi_co
    args = 'w_co eta_f eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Coupled kernels
  #----------------------------------------------------------------------------#
  # Carbon
  [coupled_eta_f_dot_c]
    type = CoupledSwitchingTimeDerivative
    variable = w_c
    v = eta_f
    Fj_names = 'rho_c_f  rho_c_g'
    hj_names = 'h_f      h_g'
    args = 'eta_f eta_g w_o w_co T'
  []

  [coupled_eta_g_dot_c]
    type = CoupledSwitchingTimeDerivative
    variable = w_c
    v = eta_g
    Fj_names = 'rho_c_f  rho_c_g'
    hj_names = 'h_f      h_g'
    args = 'eta_f eta_g w_o w_co T'
  []

  #----------------------------------------------------------------------------#
  # Oxygen
  [coupled_eta_f_dot_o]
    type = CoupledSwitchingTimeDerivative
    variable = w_o
    v = eta_f
    Fj_names = 'rho_o_f  rho_o_g'
    hj_names = 'h_f      h_g'
    args = 'eta_f eta_g w_c w_co T'
  []

  [coupled_eta_g_dot_o]
    type = CoupledSwitchingTimeDerivative
    variable = w_o
    v = eta_g
    Fj_names = 'rho_o_f  rho_o_g'
    hj_names = 'h_f      h_g'
    args = 'eta_f eta_g w_c w_co T'
  []

  #----------------------------------------------------------------------------#
  # Carbon Monoxide
  [coupled_eta_f_dot_co]
    type = CoupledSwitchingTimeDerivative
    variable = w_co
    v = eta_f
    Fj_names = 'rho_co_f rho_co_g'
    hj_names = 'h_f      h_g'
    args = 'eta_f eta_g w_c w_o T'
  []

  [coupled_eta_g_dot_co]
    type = CoupledSwitchingTimeDerivative
    variable = w_co
    v = eta_g
    Fj_names = 'rho_co_f rho_co_g'
    hj_names = 'h_f      h_g'
    args = 'eta_f eta_g w_c w_o T'
  []
[] # End of Kernels

#------------------------------------------------------------------------------#
#    #    ##    #####  ######  #####   #    ##    #        ####
##  ##   #  #     #    #       #    #  #   #  #   #       #
# ## #  #    #    #    #####   #    #  #  #    #  #        ####
#    #  ######    #    #       #####   #  ######  #            #
#    #  #    #    #    #       #   #   #  #    #  #       #    #
#    #  #    #    #    ######  #    #  #  #    #  ######   ####
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
[Materials]
  #----------------------------------------------------------------------------#
  # Reaction expressions
  [CO_reaction_production]
    type = DerivativeParsedMaterial
    f_name = production_CO
    args = 'w_c w_o eta_f eta_g T'

    function = 'if(rho_c>K_tol&rho_o>K_tol,K_CO*rho_c*rho_o,0)'

    material_property_names = 'K_CO(T) rho_c(w_c,eta_f,eta_g) rho_o(w_o,eta_f,eta_g) K_tol'
  []

  [CO_reaction_consumption]
    type = DerivativeParsedMaterial
    f_name = reaction_CO
    args = 'w_c w_o eta_f eta_g T'

    function = 'if(rho_c>K_tol&rho_o>K_tol,-K_CO*rho_c*rho_o,0)'

    material_property_names = 'K_CO(T) rho_c(w_c,eta_f,eta_g) rho_o(w_o,eta_f,eta_g) K_tol'
  []

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
  # Grand potential densities
  # Dilute solution model
  [omega_f]
    type = DerivativeParsedMaterial
    f_name = omega_f
    args = 'w_c w_o w_co'

    function = '-w_c/Va -k_b*To/Va * exp(-(w_c+Ef_v)/(k_b*To))
                -k_b*To/Va * exp((w_o-Ef_o_f)/(k_b*To))
                -k_b*To/Va * exp((w_co-Ef_co_f)/(k_b*To))'

    material_property_names = 'To Ref k_b Va Ef_o_f Ef_co_f Ef_v tol'
  []

  # Gas phase: Parabolic
  [omega_b]
    type = DerivativeParsedMaterial
    f_name = omega_b
    args = 'w_c w_o w_co'

    function = '-1/2*w_c^2/(Va^2*A_c_g) -w_c*xeq_c_g/Va
                -1/2*w_o^2/(Va^2*A_o_g) -w_o*xeq_o_g/Va
                -1/2*w_co^2/(Va^2*A_co_g) -w_co*xeq_co_g/Va'

    material_property_names = 'Ref Va A_o_g A_c_g A_co_g xeq_o_g xeq_c_g xeq_co_g'
  []

  [omega]
    type = DerivativeParsedMaterial
    f_name = omega
    args = 'w_c w_o w_co eta_f eta_g'

    function = 'h_f*omega_f + h_g*omega_g'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) omega_f(w_c,w_o,w_co)
                              omega_g(w_c,w_o,w_co)'
  []

  #----------------------------------------------------------------------------#
  # grand potential density interfacial part for visualization purposes
  [omega_inter]
    type = ParsedMaterial
    f_name = omega_inter
    args = 'eta_f eta_g'

    function = 'mu * ((eta_f^4)/4 - (eta_f^2)/2 + (eta_g^4)/4 - (eta_g^2)/2
                + gamma/2 * (eta_f^2)*(eta_g^2) + gamma/2 * (eta_f^2)*(eta_g^2) + 1/4)'

    constant_names = 'gamma'
    constant_expressions = '1.5'

    material_property_names = 'mu'
  []

  #----------------------------------------------------------------------------#
  # CARBON
  [rho_c_f]
    type = DerivativeParsedMaterial
    f_name = rho_c_f
    args = 'w_c'

    function = '1/Va*(1 - exp(-(w_c+Ef_v)/(k_b*To)))' # Dilute Sol

    material_property_names = 'To Va Ef_v k_b'
  []

  [rho_c_g]
    type = DerivativeParsedMaterial
    f_name = rho_c_g
    args = 'w_c'

    function = '1/Va*(w_c/(Va*A_c_g) + xeq_c_g)' # Parabolic

    material_property_names = 'Va A_c_g xeq_c_g'
  []

  [rho_c]
    type = DerivativeParsedMaterial
    f_name = rho_c
    args = 'w_c eta_f eta_g'

    function = 'h_f*rho_c_f + h_g*rho_c_g'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_c_f(w_c) rho_c_g(w_c)'
  []

  [x_c]
    type = DerivativeParsedMaterial
    f_name = x_c
    args = 'w_c eta_f eta_g'

    function = 'Va*(h_f*rho_c_f + h_g*rho_c_g)'

    material_property_names = 'Va h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_c_f(w_c) rho_c_g(w_c)'

    outputs = exodus
    output_properties = x_c
  []

  #----------------------------------------------------------------------------#
  # OXYGEN
  [rho_o_f]
    type = DerivativeParsedMaterial
    f_name = rho_o_f
    args = 'w_o'

    function = '1/Va * exp((w_o-Ef_o_f)/(k_b*To))' #Dilute Sol

    material_property_names = 'To Va Ef_o_f k_b'
  []

  [rho_o_g]
    type = DerivativeParsedMaterial
    f_name = rho_o_g
    args = 'w_o'

    function = '1/Va*(w_o/(Va*A_o_g) + xeq_o_g)' #Parabolic

    material_property_names = 'Va A_o_g xeq_o_g'
  []

  [rho_o]
    type = DerivativeParsedMaterial
    f_name = rho_o
    args = 'w_o eta_f eta_g'

    function = 'h_f*rho_o_f + h_g*rho_o_g'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_o_f(w_o) rho_o_g(w_o)'
  []

  [x_o]
    type = DerivativeParsedMaterial
    f_name = x_o
    args = 'w_o eta_f eta_g'

    function = 'Va*(h_f*rho_o_f + h_g*rho_o_g)'

    material_property_names = 'Va h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_o_f(w_o) rho_o_g(w_o)'

    outputs = exodus
    output_properties = x_o
  []

  #----------------------------------------------------------------------------#
  # CARBON MONOXIDE
  [rho_co_f]
    type = DerivativeParsedMaterial
    f_name = rho_co_f
    args = 'w_co'

    function = '1/Va * exp((w_co-Ef_co_f)/(k_b*To))' #Ideal Sol

    material_property_names = 'To Va Ef_co_f k_b'
  []

  [rho_co_g]
    type = DerivativeParsedMaterial
    f_name = rho_co_g
    args = 'w_co'

    function = '1/Va*(w_co/(Va*A_co_g) + xeq_co_g)' #Parabolic

    material_property_names = 'Va A_co_g xeq_co_g'
  []

  [rho_co]
    type = DerivativeParsedMaterial
    f_name = rho_co
    args = 'w_co eta_f eta_g'

    function = 'h_f*rho_co_f + h_g*rho_co_g'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_co_f(w_co) rho_co_g(w_co)'
  []

  [x_co]
    type = DerivativeParsedMaterial
    f_name = x_co
    args = 'w_co eta_f eta_g'

    function = 'Va*(h_f*rho_co_f + h_g*rho_co_g)'

    material_property_names = 'Va h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_co_f(w_co) rho_co_g(w_co)'

    outputs = exodus
    output_properties = x_co
  []

  #----------------------------------------------------------------------------#
  # Susceptibilities
  [chi_c]
    type = DerivativeParsedMaterial
    f_name = chi_c
    args = 'w_c eta_f eta_g'

    function = 'h_f*(1/(Va*k_b*To) * exp(-(w_c+Ef_v)/(k_b*To)))
                +h_g*(1/(Va^2*A_c_g))'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) k_b Ef_v Va A_c_g To'
  []

  [chi_o]
    type = DerivativeParsedMaterial
    f_name = chi_o
    args = 'w_o eta_f eta_g'

    function = 'h_f*(1/(Va*k_b*To) * exp((w_o-Ef_o_f)/(k_b*To)))
                +h_g*(1/(Va^2*A_o_g))'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) k_b Ef_o_f Va A_o_g To'
  []

  [chi_co]
    type = DerivativeParsedMaterial
    f_name = chi_co
    args = 'w_co eta_f eta_g'

    function = 'h_f*(1/(Va*k_b*To) * exp((w_co-Ef_co_f)/(k_b*To)))
                +h_g*(1/(Va^2*A_co_g))'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) k_b Ef_co_f Va A_co_g To'
  []

  #----------------------------------------------------------------------------#
  #####     ##    #####     ##    #    #   ####
  #    #   #  #   #    #   #  #   ##  ##  #
  #    #  #    #  #    #  #    #  # ## #   ####
  #####   ######  #####   ######  #    #       #
  #       #    #  #   #   #    #  #    #  #    #
  #       #    #  #    #  #    #  #    #   ####
  #----------------------------------------------------------------------------#
  #----------------------------------------------------------------------------#
  # CONSTANT Reaction rate
  [reactivity_CO]
    type = DerivativeParsedMaterial
    f_name = K_CO
    args = 'eta_f eta_g T'

    function = 'K_pre/(int_width/2) * exp(-Q/(k_B*T))'

    constant_names        = 'K_pre        Q             k_B'
    constant_expressions  = '6.8191e-01   5.3772e-01    8.6173e-5'

    material_property_names = 'int_width'
  []

  #----------------------------------------------------------------------------#
  # Interface Width
  [K_tol]
    type = GenericConstantMaterial

    prop_names = 'K_tol'
    prop_values = '-1'
  []

  #----------------------------------------------------------------------------#
  # Phase mobility
  [phase_mobility]
    type = GenericConstantMaterial

    prop_names = 'L'
    prop_values = '1e-2'
  []

  [int_width]
    type = GenericConstantMaterial

    prop_names = 'int_width'
    prop_values = '4644' # eta's width
  []

  #----------------------------------------------------------------------------#
  # Grand Potential Interface Parameters
  [iface]
    type = GrandPotentialInterface
    gamma_names = 'gamma_fg'

    sigma = '1.4829e-02' # = 0.2 J/m2

    kappa_name = kappa
    mu_name = mu

    sigma_index = 0
  []

  #----------------------------------------------------------------------------#
  # Constant parameters
  [params]
    type = GenericConstantMaterial
    prop_names = 'To      k_b          tol    Va'
    prop_values = '3000   2.2096e-05   1e-8   1.0'
  []

  [formation_energies]
    type = GenericConstantMaterial
    prop_names = 'Ef_v    Ef_o_f            Ef_co_f'
    prop_values = '1.0     1.5641e+00        1.6179e+00'
  []

  [params_carbon]
    type = GenericConstantMaterial
    prop_names = 'A_c_g        xeq_c_g'
    prop_values = '2e-1           0.0'
  []

  [params_oxygen]
    type = GenericConstantMaterial
    prop_names = 'A_o_g        xeq_o_g'
    prop_values = '1e-6          0.999'
  []

  [params_mono]
    type = GenericConstantMaterial
    prop_names = 'A_co_g       xeq_co_g'
    prop_values = '1e-6           0.0'
  []

  #----------------------------------------------------------------------------#
  # Diffusivities
  [diff_c]
    type = DerivativeParsedMaterial
    f_name = D_c
    args = 'eta_f eta_g'

    function = 'h_f*1 + h_g*9.3458e+11'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
  []

  [diff_o]
    type = DerivativeParsedMaterial
    f_name = D_o
    args = 'eta_f eta_g'

    function = 'h_f*2.8037e+09+ h_g*9.3458e+11'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
  []

  [diff_co]
    type = DerivativeParsedMaterial
    f_name = D_co
    args = 'eta_f eta_g'

    function = 'h_f*2.8037e+09+ h_g*9.3458e+11'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
  []

  #----------------------------------------------------------------------------#
  # Mobilities
  [mob_c]
    type = DerivativeParsedMaterial
    f_name = Dchi_c
    args = 'w_c eta_f eta_g'

    function = 'D_c*chi_c'

    material_property_names = 'D_c(eta_f,eta_g) chi_c(w_c,eta_f,eta_g)'
  []

  [mob_o]
    type = DerivativeParsedMaterial
    f_name = Dchi_o
    args = 'w_o eta_f eta_g'

    function = 'D_o*chi_o'

    material_property_names = 'D_o(eta_f,eta_g) chi_o(w_o,eta_f,eta_g)'
  []

  [mob_co]
    type = DerivativeParsedMaterial
    f_name = Dchi_co
    args = 'w_co eta_f eta_g'

    function = 'D_co*chi_co'

    material_property_names = 'D_co(eta_f,eta_g) chi_co(w_co,eta_f,eta_g)'
  []
[]

#------------------------------------------------------------------------------#
[BCs]
  [carbon]
    type = DirichletBC
    variable = 'w_c'
    boundary = 'left'
    value = '0'
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
  nl_rel_tol = 1.0e-6

  l_max_its = 30
  l_tol = 1.0e-6

  start_time = 0.0
  dt = 1
  num_steps = 10

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
[Postprocessors]
  # Species output
  [total_carbon]
    type = ElementIntegralMaterialProperty
    mat_prop = x_c

    outputs = 'csv exodus'
  []

  [total_oxygen]
    type = ElementIntegralMaterialProperty
    mat_prop = x_o

    outputs = 'csv exodus'
  []

  [total_mono]
    type = ElementIntegralMaterialProperty
    mat_prop = x_co

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
