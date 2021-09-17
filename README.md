# timing-code

This repository includes basic code for the production of XMM-Newton data for analysis of light curves and spectra

## X-ray data from XMM-Newton

### Pre-processing example (ODF data)

heainit
setsas
setenv SAS_CCFPATH /usr/local/XMM/ccf/
setenv SAS_ODF /data/scratch3/steff/Mrk335/0306870101/ODF
cifbuild
setenv SAS_CCF ccf.cif
odfingest

### Set the SUM.SAS file by
setenv SAS_ODF /data/scratch3/steff/Mrk335/0306870101/ODF/1112_0306870101_SCX00000SUM.SAS

### Copy SUM.SAS and ccf.cif to PROC Directory

cp 1112_0306870101_SCX00000SUM.SAS /data/scratch3/steff/Mrk335/0306870101/PROC

cp ccf.cif /data/scratch3/steff/Mrk335/0306870101/PROC

### Create PN Events

epproc randomizetime=no randomizeenergy=no randomizeposition=no


## Software to perform initial data processing

| Code               | Description                                   |
|--------------------|-----------------------------------------------|
| `blob.c`           | two blobs model code                          |
| `submit-blob.pl`   | submit two blob runs to the supercomputer     |
| `code-img.c`       | ray tracing (C)                               |
| `code-img.cl`      | ray tracing (OpenCL)                          |
| `code-s.c`         | ray tracing (C)                               |
| `code-s.cl`        | ray tracing (OpenCL)                          |
| `code-x.c`         | calculates the spectrum and lags              |
| `submit-code-x.pl` | submit the code-x runs to the supercomputer   |
| `code-tl.c`        | calculates the lag-frequency                  |
| `code-tle.c`       | calculates the lag-energy spectra             |
| `code-ext-sph.c`   | spherical corona (C) [in development]         |
| `code-ext-sph.cl`  | spherical corona (OpenCL) [in development]    |
| `code-x-xillv.c`   | uses the XILLVER model [in development]       |
| `reflionx.mod`     | table model containing reflection spectra     |
| `Makefile`         | Makefile used to compile the codes            |
| `table-models.py`  | Python script to create table model           |

There are more codes that listed in the above table. This will need to be tidied up.

## Notes on different codes / how to run specific tasts

### Makefile
