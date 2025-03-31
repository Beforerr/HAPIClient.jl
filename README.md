# HAPIClient

[![Build Status](https://github.com/Beforerr/HAPIClient.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Beforerr/HAPIClient.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![DOI](https://zenodo.org/badge/935193759.svg)](https://doi.org/10.5281/zenodo.15108960)

A Julia client for the Heliophysics Application Programmer's Interface (HAPI).

## Installation

```julia
using Pkg
Pkg.add("https://github.com/Beforerr/HAPIClient.jl")
```

## Usage Example

```julia
using HAPIClient
using Dates

# List available HAPI servers
servers = hapi()

# Use a predefined server (CDAWeb or CSA)
# Get catalog of available datasets from CDAWeb
catalog = hapi(CDAWeb)

# Get information about parameters in a dataset
dataset = "AC_H0_MFI"
params = hapi(CDAWeb, dataset)

# Retrieve data for specific parameters within a time range
parameters = "Magnitude,BGSEc"
start_time = DateTime(2001, 1, 1, 5, 0, 0)
end_time = DateTime(2001, 1, 1, 6, 0, 0)
data = hapi(CDAWeb, dataset, parameters, start_time, end_time)

# Alternative method using path format
data = get_data("CDAWeb/AC_H0_MFI/Magnitude,BGSEc", start_time, end_time)

# Access the data
Magnitude = data[1]
BGSEc = data[2]

# Example with CSA server
csa_dataset = "C4_CP_FGM_FULL"
csa_parameters = "B_vec_xyz_gse,B_mag"
csa_start = DateTime(2001, 6, 11, 0, 0, 0)
csa_end = DateTime(2001, 6, 11, 0, 1, 0)
csa_data = hapi(CSA, csa_dataset, csa_parameters, csa_start, csa_end)
```