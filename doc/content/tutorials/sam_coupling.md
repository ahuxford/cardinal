# Tutorial 4: Multiscale Coupling of NekRS and SAM for Primary Loop Modeling

In this tutorial, you will learn how to:

- Couple NekRS with a System Thermal Hydraulics (STH) code for tracking scalar transport in a double T-junction loop with flow recirculation
- Demonstrate NekRS's superior 3D scalar mixing prediction compared to an STH code
- Solve NekRS in dimensional form
- Utilize NekRS's RANS $k-\tau$ model with passive scalar transport

!alert! note title=Computing Needs
The coupled simulation requires about 8 hours to run on an 80-core node on ANL's eddy computing cluster.
!alert-end!


This tutorial describes how to couple NekRS to a System Thernal Hydraulics (STH) code
utilizing Cardinal's [NekRSSeparateDomainProblem](/problems/NekRSSeparateDomainProblem.md) class.
This class is used in this tutorial to couple mass, momentum, and scalar conservation
between NekRS and an STH code by exchanging boundary condition information
for velocity, pressure, and a passive scalar.

## Geometry and computational model

For a real-world application of the coupling, we will utilize the double T-junction
scalar mixing experiment from [!cite](bertolotto). We will use and show
the use of NekRS for improved prediction of 3D mixing of a passive scalar compared
to a 1D STH code. A schematic of the double T-junction experiment is shown in [doublet] and contains two
loops joined by a double T-junction where one loop serves
as the main line and one as the recirculation line. The main
line enforces a set flow rate into the double T-junction, and
the recirculation line has a pump that enforces flow back into the
double T-junction. The system is operated at atmospheric
conditions with tap water as the working fluid. A tracer
(deionized water) is injected within the side loop, and its
concentration is measured at three different locations using
wire mesh sensors (WM). The flow rates are controlled in each
loop to maintain an identical turbulent Reynolds number of 23,750.

!media double_tjunction.png
  id=doublet
  caption=Schematic of the experiment for the coupling tutorial (adapted from [!cite](bertolotto)).
  style=width:80%;margin-left:auto;margin-right:auto;halign:center

# NekRS Model Details

NekRS is used to model the double T-junction where
3D mixing effects are most present, and the NekRS model
employs a unsteady-RANS simulation with its $k-\tau$ model
and an additional passive scalar for modeling the
injected tracer. An all-hex mesh is generated using Gmsh
[!cite](gmsh) while ensuring the wall y+ is below 1, and the NekRS
`gmsh2nek` tool is used to convert to nek's mesh format.

!gallery! large=6
!card media/double_tjunction_nek_mesh.png title=NekRS computational mesh

!card media/double_tjunction_nek_flow.png title=NekRS predicted velocity field, with boundaries labeled
!gallery-end!


TODO: images side by side

Boundary conditions set in the NekRS model are listed in [table-nek-bcs].
The NekRS model’s domain was extended at both outlets to ensure there’s no reversed
flow at these boundaries. The term “Developed” in [table-nek-bcs]
refers to a fully-developed profile coming from a periodic
simulation for the same operational Reynolds number as in the
experiment.

!table id=table-nek-bcs caption=NekRS Model's boundary conditions.
| Boundary | Pressure (Pa) | Velocity | RANS $k$ and $\tau$ | Tracer ($S$) |
|---|---|---|---|---|
| Main inlet | - | Developed | Developed | 0 |
| Side inlet | - | Developed w/ $U_{STH}$ | Developed | Flat w/ $S_{STH}$ |
| Main outlet | 0 | $\nabla U =0$ | $\nabla k = \nabla \tau =0$ | $\nabla S=0$ |
| Side outlet | -365 | $\nabla U =0$ | $\nabla k = \nabla \tau =0$ | $\nabla S=0$ |
| Wall | - | 0 | 0 | $\nabla S=0$ |

In [table-nek-bcs]'s NekRS boundary conditions, the relative
pressure at the Side outlet is set to -365 Pa such that NekRS
reproduces the 1:1 flow ratio used in the experiment. In
Bertolotto et al. (2009)’s CFX simulation, the authors utilized
a split-flow boundary condition. For the present NekRS
model, setting the relative Side outlet pressure achieves the
same desired result.

For the velocity field’s boundary conditions in Table 4, a
developed profile from a periodic simulation is used for both
inlets. However, the Side inlet’s velocity profile is scaled
such that its average velocity matches the velocity $U_{STH}$
coming from SAM. For the tracer’s Side inlet boundary
condition, Bertolotto et al. (2009) found that the distribution injected into the CFD domain has little influence on
tracer concentrations extracted at wire mesh sensor locations.
Therefore, a flat inlet distribution is used, corresponding to the value $S_{STH}$ from SAM, where S denotes that the
tracer being modeled a passive scalar.

The initial tracer injection is simulated as a prescribed,
time-dependent profile at NekRS’s Side inlet boundary, and
the injection follows experimental wire mesh sensor 1 data.
The tracer is modeled as a passive scalar with zero molecular
diffusivity but includes turbulent diffusion using a turbulent
Schmidt of 0.9, the same methodology used in Bertolotto
et al. (2009)

# STH Model Details

While NekRS models the double T-junction, STH is
used to model the entire recirculation loop, including the
portion of the double T-junction that closes the recirculation
loop. To enforce the 1:1 flow ratio between the main and
recirculation loop, Bertolotto et al. (2009) implemented a
TRACE component to set the flow rate in the recirculation
loop. To do the same in SAM, the “desired mass flow rate”
parameter is set for SAM’s pump component, such that a
1:1 flow ratio is maintained. The SAM model employs a
passive scalar to model the tracer’s transport with a diffusion
coefficient of 7.6e-3 m2/s, which acts to model 3D mixing
effects in the recirculation loop. Bertolotto (2011) used a
similar value for their TRACE model of the same system.


# Setting initial conditions for coupled STH-NekRS simulation

NekRS and the STH code's initial conditions are set from restart files
following the [Restarting coupled NekRS and MOOSE simulations](tutorials/restart_nek_moose.md)
tutorial.

# NekRS Input Files

TODO
- nekrs mesh, put on anl box
- cardinal input file
- multiApp transfers
- .usr file for taking averages at WM locations

# STH Input Files

TODO
- STH input
- Tracer concentration profile

# Run the tutorial

- write

# Postprocessing Results

In order to validate the coupling against [!cite](bertolotto)'s experiment,
the area-averaged tracer concentration if obtained from the NekRS solution, and
the coupled STH-NekRS coupled results are compared to experimental data
as well as STH standalone results.

## Video of coupled SAM-NekRS simulation

The video in [doublet_vid] shows the coupled tracer concentration being
injected and recirculated through the 3D NekRS domain and the 1D STH domain.
Concentration profiles are shown with comparisons between experiment data,
STH standalone and SAM-NekRS coupled results.

!media double_tjunction_video.mp4
  id=doublet_vid
  caption=Video of coupled NekRS-STH simulation of tracer transport utilizing Paraview.
  style=width:95%;margin-left:auto;margin-right:auto;halign:center

During the initial tracer injection, WM1’s concentration profile in all simulations
exactly match the experiment because this is the initial tracer injection
used for all simulations. SAM standalone simulation underpredicts tracer
recirculation through WM2 and overpredicts tracer leaving through WM3. Coupled
SAM-NekRS simulation produces improved results due to NekRS's improved prediction
of 3D scalar mixing within the double T-junction. Such 3D mixing effects are not
modeled within SAM's 1D components.

After the first flow through, the tracer is recirculated
through the side recirculation loop and re-enters the double
T-Junction at WM1. The SAM standalone simulation continues to underpredict tracer
recirculation through WM2 and overpredict tracer leaving
the system through WM3. SAM-NekRS coupled results again
match more closely with the experiment.

## Concentration integral plots

Next, concentration integrals are used to compare the
total concentration of tracer passing through each wire mesh
sensor over time. The concentration integrals are shown
in [doublet_concint], where each integral increases three times, one
time for each flow through of tracer. In [doublet_concint] it is even more
apparent that the SAM standalone simulation underpredicts
tracer recirculation through WM2 and overpredicts tracer
leaving the system through WM3. Furthermore, SAM-
NekRS coupled results match experiment more closely, showing
improved scalar transport modeling using the coupled SAM-NekRS model.

!media double_tjunction_concint.png
  id=doublet_concint
  caption=Figure 13: Concentration integrals through each wire mesh sensor.
  style=width:50%;margin-left:auto;margin-right:auto;halign:center


TODO: add references of work
- Nureth 2022 conference paper
- Submitted Annals of Nuclear Energy paper
- Nureth 2023 conference paper

!bibtex bibliography
