# Tutorial 4: Multiscale Coupling of NekRS and SAM for Primary Loop Modeling

This tutorial describes how to couple NekRS to a System Thernal Hydraulics (STH) code
with mass, momentum, and scalar coupling by exchanging boundary conditions
for velocity, pressure, and passive scalar. In particular, this tutorial
couples a NekRS RANS model to an STH code for improved modeling of
scalar mixing and transport within a system with recirculaiton of scalar.

For a real-world application of the coupling, we will utilize the double T-junction
scalar mixing experiment from Bertolotto et al.
(TODO: add reference to Bertolotto's original double T paper).

For a complete description of the experiment, the authors
direct readers to Bertolotto et al. (2009) and Bertolotto
(2011), but a brief description is given here. The double
T-junction’s setup is shown in [doublet], and it contains two
loops joined by a double T-junction where one loop serves
as the main line and one the recirculation line. The main
line enforces a set flow rate into the double T-junction, and
the recirculation line has a pump forcing flow back into the
double T-junction. The system is operated at atmospheric
conditions with tap water as the working fluid. A tracer
(deionized water) is injected within the side loop, and its
concentration is measured at three different locations using
wire mesh sensors (WM). The flow rate is controlled in each
loop to maintain the same Reynolds number of 23,750.

!media double_tjunction.png
  id=doublet
  caption=Schematic of the experiment for the coupling tutorial (adapted from TODO Bertolotto reference).
  style=width:80%;margin-left:auto;margin-right:auto;halign:center

# NekRS Model Details

NekRS is used to model the double T-junction where
3D mixing effects are most present, and the NekRS model
employs a unsteady-RANS simulation with its 𝑘-𝜏 model
along with an additional passive scalar for modeling the
tracer’s transport. An all-hex mesh is generated using Gmsh
(Geuzaine and Remacle (2009)) while ensuring the wall
y+ is below 1, and [doublet_nek_mesh] shows the NekRS mesh used.
The NekRS predicted flow field is shown in [doublet_nek_flow] with
boundaries labeled.

!media double_tjunction_nek_mesh.png
  id=doublet_nek_mesh
  caption=NekRS computational mesh used.
  style=width:40%;margin-left:auto;margin-right:auto;halign:center

!media double_tjunction_nek_flow.png
  id=doublet_nek_flow
  caption=NekRS’s predicted velocity field along the domain’s centerline, with boundaries labeled.
  style=width:40%;margin-left:auto;margin-right:auto;halign:center

TODO: images side by side

Boundary conditions set in the NekRS model are listed in [table-nek-bcs].
The NekRS model’s domain was extended at both outlets to ensure there’s no reversed
flow at these boundaries. The term “Developed” in [table-nek-bcs]
refers to a fully-developed profile coming from a periodic
simulation for the same operational Reynolds number as the
experiment.


!table id=table-nek-bcs caption=NekRS Model's boundary conditions.
| Boundary | Pressure (Pa) | Velocity | RANS $k$ and $\tau$ | Tracer ($S$) |
|---|---|---|---|---|
| Main inlet | - | Developed | Developed | 0 |
| Side inlet | - | Developed w/ $U_{STH}$ | Developed | Flat w/ $S_{STH}$ |
| Main outlet | 0 | $\nabla U =0$ | $\nabla k = \nabla \tau =0$ | $\nabla S=0$ |
| Side outlet | -365 | $\nabla U =0$ | $\nabla k = \nabla \tau =0$ | $\nabla S=0$ |
| Wall | - | 0 | 0 | $\nabla S=0$ |

TODO: add references of work
- Nureth 2022 conference paper
- Submitted Annals of Nuclear Energy paper
- Nureth 2023 conference paper
