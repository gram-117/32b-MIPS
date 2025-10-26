# 32-bit Pipelined MIPS Processor

A 5-stage pipelined MIPS CPU implemented in **VHDL** for FPGA deployment.

## Overview
Implements a 32-bit MIPS architecture with standard 5-stage pipeline:
1. **IF** – Instruction Fetch  
2. **ID** – Instruction Decode / Register Fetch  
3. **EX** – Execute / ALU  
4. **MEM** – Memory Access  
5. **WB** – Write Back  

Includes:
- Hazard detection and forwarding units  
- Branch handling  
- Basic testbench for simulation  

## Features
- 32-bit ALU and register file  
- Data and control hazard resolution  
- Instruction and data memory modules  
- Fully synthesizable on **Basys 3 (Artix-7)** FPGA  

## Demo
Demo of MIPS processor computing Fibonacci number sequence and outputting to a 7-segment display:  
[![MIPS Processor Demo](https://img.youtube.com/vi/hcZKd-PMrHA/0.jpg)](https://youtu.be/hcZKd-PMrHA)
