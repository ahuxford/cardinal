[Mesh]
  [sphere]
    type = FileMeshGenerator
    file = ../../meshes/sphere.e
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
  [fluid]
    type = FileMeshGenerator
    file = ../../heat_source/stoplight.exo
  []
  [fluid_ids]
    type = SubdomainIDGenerator
    input = fluid
    subdomain_id = '200'
  []
  [combine]
    type = CombinerGenerator
    inputs = 'solid_ids fluid_ids'
  []
[]

[Problem]
  type = OpenMCCellAverageProblem
  source_strength = 1e6
  verbose = true

  solid_blocks = '100'
  fluid_blocks = '200'
  tally_blocks = '100 200'
  solid_cell_level = 0
  fluid_cell_level = 0
  tally_type = cell
  tally_score = 'H3_production'

  initial_properties = xml
[]

[Executioner]
  type = Steady
[]

[Postprocessors]
  [total_H3]
    type = ElementIntegralVariablePostprocessor
    variable = H3_production
  []
  [fluid_H3]
    type = PointValue
    variable = H3_production
    point = '0.0 0.0 2.0'
  []
  [pebble1_H3]
    type = PointValue
    variable = H3_production
    point = '0.0 0.0 0.0'
  []
  [pebble2_H3]
    type = PointValue
    variable = H3_production
    point = '0.0 0.0 4.0'
  []
  [pebble3_H3]
    type = PointValue
    variable = H3_production
    point = '0.0 0.0 8.0'
  []
  [vol_fluid]
    type = VolumePostprocessor
    block = '200'
  []
  [vol_solid]
    type = VolumePostprocessor
    block = '100'
  []
[]

[Outputs]
  execute_on = final
  csv = true
  exodus = true
[]
