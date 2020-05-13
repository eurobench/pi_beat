# PI BEAT

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Copyright BEAT 2020

## Purposes

This toolbox allows computing Performance Indicator (PI) within the BEAT project protocol.
In particular, kinematic parameters both in stepping and perturbed conditions, muscle synergies in stepping condition, posturographic parameters both in stepping and perturbed conditions and parameters to understand the behaviour under step and sinusoidal parameters can be computed.
The toolbox contains seven PI's algorithms.

## Installation

To enable the code under octave, additional packages are needed.
Follow this [link](https://octave.org/doc/v4.2.1/Installing-and-Removing-Packages.html) to make the installation of the additional packages needed.

Once octave is configured:

```console
pkg load statistics
pkg load io
pkg load linear-algebra
pkg load signal
```

## Usage

### Protocol oriented launch

The current enables to score 7 different protocols

* Protocol 1.
  * run_kinematic_walking
  * run_emg
* Protocol 2.
  * run_kinematic_walking
  * run_emg
  * run_posturography_unperturbed
* Protocol 3.
  * run_posturography_unperturbed
* Protocol 4.
  * run_posturography_unperturbed
* Protocol 5.
  * run_kinematic_perturbation
  * run_posturography_perturbation

```shell
./run_protocol5 tests/data/protocol5/input/jointAngles.csv tests/data/protocol5/input/platformData.csv out_tests
```

* Protocol 6.
  * run_kinematic_perturbation
  * run_posturography_perturbation
  * run_stepperturbation

```shell
./run_protocol6 tests/data/protocol6/input/jointAngles.csv tests/data/protocol6/input/platformData.csv out_tests
```

* Protocol 7.
  * run_posturography_perturbation
  * run_sinusoidalperturbation

### Performance Indicator launch

_kinematic_routine_walking_

This routine computes the mean range of motion and the Coefficient of Variation when stepping on place protocols have been performed.
The script _run_kinematic_walking_ launches this PI from the shell of a machine with octave installed.
To be run, it is mandatory to provide files `jointAngles.csv` and `PlatformData.csv`.
PlatformData must be related to the protocol1 or protocol2.
Assuming folder `./tests/data/input` contains the needed input data and `./tests/data/output` exists and will contain the results, the shell command is:

```console
./run_kinematic_walking ./tests/data/input/subject_01_run_01_jointAngles.csv ./tests/data/input/subject_01_run_01_PlatformData_protocolnumber.csv ./tests/data/output ./
```

_kinematic_routine_perturbation_

This routine computes the range of motion in different directions of the space when perturbation protocols have been performed.
The script _run_kinematic_perturbation_ launches this PI from the shell of a machine with octave installed.
To be run, it is mandatory to provide files `jointAngles.csv` and `PlatformData.csv`.
PlatformData must be related to the protocol5 or protocol6.
Assuming folder `./test_data/input` contains the needed input data and `./tests/data/output` exists and will contain the results, the shell command is:

```console
./run_kinematic_perturbation ./tests/data/input/subject_01_run_01_jointAngles.csv ./tests/data/input/subject_01_run_01_PlatformData_protocolnumber.csv ./tests/data/output ./
```

_EMG_routine_

This routine computes the muscle synergy number for the right and left side of the lower limbs when stepping protocols have been performed.
The script _run_EMG_ launches this PI from the shell of a machine with octave installed.
To be run, it is mandatory to provide files `emg.csv` and `PlatformData.csv`.
PlatformData must be related to the protocol1 or protocol2.
Assuming folder `./test_data/input` contains the needed input data and `./tests/data/output` exists and will contain the results, the shell command is:

```console
./run_EMG ./tests/data/input/subject_01_run_01_emg.csv ./tests/data/input/subject_01_run_01_PlatformData_protocolnumber.csv ./tests/data/output ./
```

_posturographic_routine_unperturbed_

This routine computes the posturographic parameters: path length of the Centre of Pressure (CoP), path length of the CoP in antero-posterior direction, path length of the CoP in medio-lateral direction and the area at 95% of the confidence ellipse when protocols without perturbations have been performed.
The script _run_posturography_unperturbed_ launches this PI from the shell of a machine with octave installed. To be run, it is mandatory to provide file `PlatformData.csv` file.
PlatformData must be related to the protocol2, protocol3 or protocol4.
Assuming folder `./test_data/input` contains the needed input data and `./tests/data/output` exists and will contain the results, the shell command is:

```console
./run_posturography_unperturbed ./tests/data/input/subject_01_run_01_PlatformData_protocolnumber.csv ./tests/data/output ./
```

_posturographic_routine_perturbation_

This routine computes the posturographic parameters: path length of the Centre of Pressure (CoP) and the area at 95% of the confidence ellipse in different space directions when protocols with perturbations have been performed.
The script _run_posturography_perturbation_ launches this PI from the shell of a machine with octave installed.
To be run, it is mandatory to provide file `PlatformData.csv` file.
PlatformData must be related to the protocol5, protocol6 or protocol7.
Assuming folder `./test_data/input` contains the needed input data and `./tests/data/output` exists and will contain the results, the shell command is:

```console
./run_posturography_perturbation ./tests/data/input/subject_01_run_01_PlatformData_protocolnumber.csv ./tests/data/output ./
```

_step_perturbation_

This routine computes the parameters to quantify the reaction of the subject to step perturbation: overshoot of the platform angle, the final angular position of the platform and the range of the excursion of the platform during the last 1.5 s of the task in each space direction when step perturbation protocol with uneven surface has been performed.
The script _run_stepperturbation_ launches this PI from the shell of a machine with octave installed.
To be run, it is mandatory to provide file `PlatformData.csv`.
PlatformData must be related to the protocol6.
Assuming folder `./test_data/input` contains the needed input data and `./tests/data/output` exists and will contain the results, the shell command is:

```console
./run_stepperturbation ./tests/data/input/subject_01_run_01_PlatformData_protocolnumber.csv ./tests/data/output ./
```

_sinusoidal_perturbation_

This routine computes the kinematic parameters to quantify the reaction of the subject to sinusoidal perturbation: gain ratio and shift phase with respect to the imposed sinusoidal wave when sinusoidal perturbation protocol has been performed.
The script _run_sinusoidalperturbation_ launches this PI from the shell of a machine with octave installed.
To be run, it is mandatory to provide files `jointAngles.csv` and `PlatformData.csv` file.
PlatformData must be related to the protocol7.
Assuming folder `./test_data/input` contains the needed input data and `./tests/data/output` exists and will contain the results, the shell command is:

```console
./run_sinusoidalperturbation ./tests/data/input/subject_01_run_01_jointAngles.csv ./tests/data/input/subject_01_run_01_PlatformData_protocolnumber.csv ./tests/data/output ./
```

## Build docker image

_to be done (later)_

## Launch the docker image

_to be done (later)_

## Acknowledgements

<a href="http://eurobench2020.eu">
  <img src="http://eurobench2020.eu/wp-content/uploads/2018/06/cropped-logoweb.png"
       alt="rosin_logo" height="60" >
</a>

Supported by Eurobench - the European robotic platform for bipedal locomotion benchmarking.
More information: [Eurobench website][eurobench_website]

<img src="http://eurobench2020.eu/wp-content/uploads/2018/02/euflag.png"
     alt="eu_flag" width="100" align="left" >

This project has received funding from the European Union’s Horizon 2020
research and innovation programme under grant agreement no. 779963.

The opinions and arguments expressed reflect only the author‘s view and
reflect in no way the European Commission‘s opinions.
The European Commission is not responsible for any use that may be made
of the information it contains.

[eurobench_logo]: http://eurobench2020.eu/wp-content/uploads/2018/06/cropped-logoweb.png
[eurobench_website]: http://eurobench2020.eu "Go to website"
