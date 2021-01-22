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

### Protocol benchmark

The code enables scoring 7 different protocols

* Protocol 1.
  * run_kinematic_walking
  * run_emg

```shell
./run_protocol1 tests/data/protocol1/input/jointAngles.csv tests/data/protocol1/input/platformData.csv tests/data/protocol1/input/emg.csv out_tests
```

* Protocol 2.
  * run_kinematic_walking
  * run_emg
  * run_posturography_unperturbed

```shell
./run_protocol2 tests/data/protocol2/input/jointAngles.csv tests/data/protocol2/input/platformData.csv tests/data/protocol2/input/emg.csv out_tests
```

* Protocol 3.
  * run_posturography_unperturbed

```shell
./run_protocol3 tests/data/protocol3/input/platformData.csv out_tests
```

* Protocol 4.
  * run_posturography_unperturbed

```shell
./run_protocol4 tests/data/protocol4/input/platformData.csv out_tests
```

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

```shell
./run_protocol7 tests/data/protocol7/input/jointAngles.csv tests/data/protocol7/input/platformData.csv out_tests
```

### Performance Indicator launch

_kinematic_routine_walking_

This routine computes the mean range of motion and the Coefficient of Variation when stepping on place protocols have been performed.
Assuming folder `out_tests` exists:

```console
./run_kinematic_walking ./tests/data/protocol1/input/jointAngles.csv ./tests/data/protocol1/input/PlatformData.csv ./out_tests
```

The script can be launched for the protocol1 or protocol2.

_kinematic_routine_perturbation_

This routine computes the range of motion in different directions of the space when perturbation protocols have been performed.
Assuming folder `out_tests` exists:

```console
./run_kinematic_perturbation ./tests/data/protocol5/input/jointAngles.csv ./tests/data/protocol5/input/platformData.csv ./out_tests
```

`PlatformData` file must be related to the protocol5 or protocol6.

_EMG_routine_

This routine computes the muscle synergy number for the right and left side of the lower limbs when stepping protocols have been performed.
Assuming folder `out_tests` exists:

```console
./run_EMG ./tests/data/protocol1/input/emg.csv ./tests/data/protocol1/input/platformData.csv ./out_tests
```

`PlatformData` must be related to the protocol1 or protocol2.

_posturographic_routine_unperturbed_

This routine computes the posturographic parameters: path length of the Centre of Pressure (CoP), path length of the CoP in antero-posterior direction, path length of the CoP in medio-lateral direction and the area at 95% of the confidence ellipse when protocols without perturbations have been performed.
Assuming folder `out_tests` exists:

```console
./run_posturography_unperturbed ./tests/data/protocol2/input/platformData.csv ./out_tests
```

`PlatformData` must be related to the protocol2, protocol3 or protocol4.

_posturographic_routine_perturbation_

This routine computes the posturographic parameters: path length of the Centre of Pressure (CoP) and the area at 95% of the confidence ellipse in different space directions when protocols with perturbations have been performed.
Assuming folder `out_tests` exists:

```console
./run_posturography_perturbation ./tests/data/protocol5/input/platformData.csv ./out_tests
```

`platformData` must be related to the protocol5, protocol6 or protocol7.

_step_perturbation_

This routine computes the parameters to quantify the reaction of the subject to step perturbation: overshoot of the platform angle, the final angular position of the platform and the range of the excursion of the platform during the last 1.5 s of the task in each space direction when step perturbation protocol with uneven surface has been performed.
Assuming folder `out_tests` exists:

```console
./run_stepperturbation ./tests/data/protocol6/input/platformData.csv ./out_tests
```

`platformData` must be related to protocol6.

_sinusoidal_perturbation_

This routine computes the kinematic parameters to quantify the reaction of the subject to sinusoidal perturbation: gain ratio and shift phase with respect to the imposed sinusoidal wave when sinusoidal perturbation protocol has been performed.
Assuming folder `out_tests` exists:

```console
./run_sinusoidalperturbation ./tests/data/protocol7/input/jointAngles.csv ./tests/data/protocol7/input/platformData.csv ./out_tests
```

`platformData` must be related to protocol7.

## Docker-based code access

The following is valid for Linux machines.
### Get official image

An image ready to be used is available, without downloading that code:

```console
docker pull eurobenchtest/pi_beat
```

Now you can jump on the command to launch the docker image.

### Build docker image

Run the following command in order to create the docker image for this testbed, from the repository code:

```console
docker build . -t beat_routine
```

## Launch the docker image

Assuming the `tests/protocol1/input` contains the input data, and that the directory `out_tests/` is **already created**, and will contain the PI output:

```shell
docker run --rm -v $PWD/tests/data/protocol1/input:/in -v $PWD/out_tests:/out beat_routine ./run_protocol1 /in/jointAngles.csv /in/platformData.csv /in/emg.csv /out
```

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
