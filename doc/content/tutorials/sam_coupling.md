# Tutorial 4: Multiscale Coupling of NekRS and SAM for Primary Loop Modeling

In this tutorial, you will learn how to:

- Couple NekRS with a System Thermal Hydraulics (STH) code for tracking scalar transport in a double T-junction with flow recirculation
- Solve NekRS and an STH code in dimensional form
- Utilize NekRS's RANS $k-\tau$ model with an additional passive scalar for tracer modeling

This tutorial describes how to couple NekRS to a System Thernal Hydraulics (STH) code
utilizing Cardinal's [NekRSSeparateDomainProblem](/problems/NekRSSeparateDomainProblem.md) class.
This class is used to couple mass, momentum, and scalar conservation
between NekRS and an STH code by exchanging boundary conditions
for velocity, pressure, and a passive scalar.

## Geometry and computational model

For a real-world application of the coupling, we will utilize the double T-junction
scalar mixing experiment from [!cite](bertolotto), which provides a complete
description of the experiment. We will use and show
the use of NekRS for improved 3D mixing of a passive scalar compared
to a 1D STH code. The double T-junction’s setup is shown in [doublet], and it contains two
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
  caption=Schematic of the experiment for the coupling tutorial (adapted from [!cite](bertolotto)).
  style=width:80%;margin-left:auto;margin-right:auto;halign:center

# NekRS Model Details

NekRS is used to model the double T-junction where
3D mixing effects are most present, and the NekRS model
employs a unsteady-RANS simulation with its 𝑘-𝜏 model
along with an additional passive scalar for modeling the
tracer’s transport. An all-hex mesh is generated using Gmsh
[!cite](gmsh) while ensuring the wall
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
such that its average velocity matches the velocity 𝑈𝑆𝑇 𝐻
coming from SAM. For the tracer’s Side inlet boundary
condition, Bertolotto et al. (2009) found that the distribution injected into the CFD domain has little influence on
tracer concentrations extracted at wire mesh sensor locations.
Therefore, a flat inlet distribution is used, corresponding to the value 𝑆𝑆𝑇 𝐻 from SAM, where 𝑆 denotes that the
tracer is a passive scalar.

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


# Initial conditions

NekRS and STH's initial conditions are set using restart files,
using the procedure outlined in nek-moose restart tutorial.
TODO: link to nek+moose restart tutorial

# NekRS Input Files

TODO

# STH Input Files

TODO
- STH input
- Tracer concentration profile

# Run the tutorial

Alert, need space for NekRS computation
- full 35 second simulation runs on 80 cores on ANL's Eddy cluster in ~ 8 hours.

# Postprocessing Results

In order to validate the coupling against [!cite](bertolotto)'s experiment,
the area-averaged tracer concentration if obtained from the NekRS solution, and
the coupled STH-NekRS coupled results are compared to experimental data
as well as STH standalone results.

## Video of coupled simulation

The video in [doublet_vid] shows the coupled tracer concentration being
injected and recirculated through the 3D NekRS domain and the 1D STH domain.

!media double_tjunction_video.mp4
  id=doublet_vid
  caption=Video of coupled NekRS-STH simulation of tracer transport utilizing Paraview.
  style=width:95%;margin-left:auto;margin-right:auto;halign:center

Coupled STH-NekRS concentration profiles
For all present simulations, a time step size of 2.5e4 seconds is used. The simulations were repeated using a
NekRS polynomial order of 3, 4, and 5. Results using a
polynomial order of 4 and 5 did not differ significantly,
so to limit computational expenses an order of 4 is used.
For all comparisons, experiment data
are compared to STH standalone and STH-NekRS coupled simulation results.

The cross-section averaged concentration over time for
the first flow through of tracer is shown in Fig. 11. WM1’s
concentration profile in all simulations matches the experiment exactly because this is the initial tracer injection
used for all simulations. SAM-NekRS coupled results for
WM2 and WM3 match the experiment better than the SAM
standalone simulation while producing similar results to
previous TRACE-CFX coupling. The SAM standalone simulation under predicts tracer recirculating in the recirculation
loop through WM2 and over predicts tracer leaving the
system through WM3. This is due to the 3D mixing effects
present within the double T-junction, which SAM doesn’t
take into account when using its 1D components.

After the first flow through, the tracer is recirculated
through the side recirculation loop and re-enters the double
T-Junction at WM1. The concentration over time for the
second and third flow throughs are shown in Fig. 12. The
SAM standalone simulation continues to under predict tracer
recirculation through WM2 and over predict tracer leaving
the system through WM3. SAM-NekRS coupled results are
similar to previous TRACE-CFX results, but for WM2 and
WM3, the present SAM-NekRS results match more closely
with the experiment. This is likely due to a combination of
effects stemming from differences in the codes and models
used between the SAM-NekRS and TRACE-CFX coupling.
SAM utilizes higher-order numerical methods than TRACE,
resulting in a low amount of numerical diffusion that would
greatly affect passive scalar transport, both spatially and
temporally. As for the CFD models, NekRS uses the RANS
𝑘-𝜏 model whereas CFX used the RANS SST (Shear Stress
Transport) model. Different RANS models are expected to
predict different flow fields, so for the double T-junction the
NekRS RANS 𝑘-𝜏 model likely predicts a flow field more
similar to the experiment compared to the CFX RANS SST
model.

## Concentration Integral plots

Next, concentration integrals are used to compare the
total concentration of tracer passing through each wire mesh
sensor over time. The concentration integrals are shown
in Fig. 13, where each integral increases three times, one
for each flow through of tracer. In Fig. 13 it is even more
apparent that the SAM standalone simulation under predicts
tracer recirculation (through WM2) and over predicts tracer
leaving the system (through WM3). Furthermore, SAM-
NekRS coupled results match experiment more closely than
the previous TRACE-CFX coupling, with the largest dif-
ference being in the WM3 concentration integral plot. This
is likely due to differences in the predicted velocity field
between NekRS’s RANS 𝑘-𝜏 model and CFX’s RANS SST
model used by Bertolotto et al. (2009).

!media double_tjunction_concint.png
  id=doublet_concint
  caption=Figure 13: Concentration integrals through each wire mesh sensor.
  style=width:50%;margin-left:auto;margin-right:auto;halign:center


TODO: add references of work
- Nureth 2022 conference paper
- Submitted Annals of Nuclear Energy paper
- Nureth 2023 conference paper

!bibtex bibliography
