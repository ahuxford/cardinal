num_layers = 1

channel_diameter = 0.016                 # diameter of the coolant channels (m)
height = 6.343                           # height of the full core (m)

[Mesh]
  [solid]
    type = FileMeshGenerator
    file = solid_mesh_in.e
  []

  allow_renumbering = false
[]

[Problem]
  type = OpenMCCellAverageProblem
  power = 1000.0
  scaling = 100.0
  solid_blocks = '1 2'
  tally_type = mesh
  mesh_template = solid_mesh_in.e
  solid_cell_level = 1

  symmetry_mapper = sym
[]

[UserObjects]
  [sym]
    type = NearestNodeNumberUO
    point = '0.0 0.0 0.0'
  []
[]

[Executioner]
  type = Steady
[]
