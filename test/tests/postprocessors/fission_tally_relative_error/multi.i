[Mesh]
  [sphere]
    type = FileMeshGenerator
    file = ../../neutronics/meshes/sphere.e
  []
  [solid]
    type = CombinerGenerator
    inputs = sphere
    positions = '0 0 0
                 0 0 4
                 0 0 8'
  []
  [solid_ids]
    type = SubdomainIDGenerator
    input = solid
    subdomain_id = '100'
  []
[]

[Problem]
  type = OpenMCCellAverageProblem
  power = 100.0
  solid_blocks = '100'
  tally_blocks = '100'
  solid_cell_level = 0
  tally_type = cell
  check_tally_sum = false

  tally_score = 'heating kappa_fission'

  # this outputs the fission tally standard deviation in space
  output = 'unrelaxed_tally_std_dev'

  initial_properties = xml
[]

[Executioner]
  type = Transient
  num_steps = 1
[]

[Postprocessors]
  [max_rel_err_ht]
    type = TallyRelativeError
    value_type = max
    tally_score = 'heating'
  []
  [min_rel_err_ht]
    type = TallyRelativeError
    value_type = min
    tally_score = 'heating'
  []
  [max_rel_err_kf]
    type = TallyRelativeError
    value_type = max
    tally_score = 'kappa_fission'
  []
  [min_rel_err_kf]
    type = TallyRelativeError
    value_type = min
    tally_score = 'kappa_fission'
  []
[]

[Outputs]
  csv = true
[]
