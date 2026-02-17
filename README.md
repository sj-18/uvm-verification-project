# UVM Verification Project – APB-Based Aligner DUT

This project implements a complete UVM-based verification environment for a DUT featuring:
- AMBA 3 APB interface for register access  
- Custom valid/ready RX and TX interfaces

The DUT contains intentional design bugs, and this environment is built to detect them using constrained-random verification, assertions, and functional coverage.

The EDA playground link has the latest UVM testbench code that can be used for simulation and waveform observation.

**EDA Playground link**: https://edaplayground.com/x/SGa6

## How to Run

1. Open the EDA Playground link:  
   https://edaplayground.com/x/SGa6  

2. Ensure that (should be selected as such by default):
   - Simulator: Cadence Xcelium  
   - UVM Version: 1.2
   - Compile options : -timescale 1ns/1ns -sysv -coverage functional
   - Run Options : -access +rw +UVM_TESTNAME=cfs_algn_test_reg_access +UVM_MAX_QUIT_COUNT=1  

3. Run simulation  

4. Observe:
   - Waveforms (Ensure "Open EPWave after Run" is enabled for this) 
   - UVM logs
   - Assertion failures (if any)
   - Coverage reports  

## Key Learnings (so far)

- UVM agent architecture and TLM communication  
- Driving and monitoring APB protocol transactions  
- Designing reusable verification components  
- Writing assertions for protocol validation  
- Building functional coverage models  
- Handling reset and synchronization in UVM  

## Project Overview / Plan

Key components of the verification environment:

- **APB Agent**: Includes driver, monitor, sequencer, and coverage collection.
- **Environment**: Implements a scoreboard, functional model of the DUT, and coverage mechanisms.
- **Register Access Verification**: Automatic register checks using UVM register model.
- **Randomized Tests**: Stimulus generation to cover a wide range of scenarios.
- **Simulation Platform**: Developed and simulated on **EDA Playground**.

This project showcases step-by-step construction of a robust UVM environment, emphasizing agent creation, DUT verification, functional coverage, and test automation.


## Status

***Work in Progress***

## Work Log

### 1. Testbench Architecture
- [x] Created basic architecture of the testbench

### 2. APB Agent (Master)
- [x] Created APB agent infrastructure
- [x] Implemented APB driving item / sequence item
- [x] Developed sequencer–driver mechanism
- [x] Created three different sequences
- [x] Updated driver to drive APB signals on the interface
- [x] Created monitor item and monitor class to collect DUT response
- [x] Added assertions in the interface file for APB protocol checks
- [x] Implemented coverage inside the APB agent
- [x] APB reset handling

---

## 🔧 Future Enhancements / To do

- [ ] Build **reusable UVM agents** for **RX** and **TX** of the module  
- [ ] Incorporate **advanced UVM agent techniques**  
- [ ] Implement **UVM Register Model**  
- [ ] Functional **modelling and checking**  
- [ ] **Debugging and testing**  
- [ ] **Cleanup** and final wrap-up

---



## Tools
- SystemVerilog
- UVM 1.2
- EDA Playground 

## Author
Sidhartha Jain
