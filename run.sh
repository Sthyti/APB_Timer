#!/bin/bash

#Step-1: Compile RTL and Testbench using verilator

verilator --binary -j 0 -Wall apb_timer.v apb_timer_tb.v --top apb_timer_tb --timing --trace --CFLAGS "-std=c++20"

#Step-2: Build directory

cd obj_dir || { echo "Error: obj_dir not found"; exit 1; }

#Step-3: Build simulation executable

make -f Vapb_timer_tb.mk Vapb_timer_tb || { echo "Error: Compilation failed"; exit 1; }

#Step-4: Run simulation

./Vapb_timer_tb || { echo "Error: Simulation failed"; exit 1; }

#Step-5: Open Waveform

gtkwave apb_timer.vcd
