# Gluttonous_Snake

## Project Overview

This work won the second prize in the Activation track of the FPT Design Competition and the first prize was awarded in the FPGA category of the National College Students' Embedded Chip and System Design Competition.

**project brief : **This project integrates 7 common non-linear functions (Softmax, LayerNorm, RMSNorm, SiLu, GeLu, EADD, EMUL) from LLMs into a unified architecture (Gluttonous Snake), achieving acceleration of LLM non-linear function inference through a unified hardware architecture.

**doc:** Store the papers and the PPTs for presentation and report.

**python:** Store the test code built using Python.

**rtl:** Store our Verilog/System Verilog source code.

**vivado_prj:** The Vivado project for storing the project files.

## The use of python test codes

`main.py`is the core program for running the tests. It obtains the simulation results by comparing and calculating the L2 error, etc., and generates a comparison report between the simulated results/printed-on-board calculation results and the actual calculation results.

Before running the main calculation program, it is necessary to prepare the simulation results or the board test results, which should be stored in the folder named "python/fpga_result".

"python/ref_bin_bf16" folder contains the reference results. The Python program will use the contents of this folder as the reference for outputting the test results, and the test results will be stored in the folder "python/dif_result".

