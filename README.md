# UVM Verification Project (Ongoing)

This repository contains an ongoing SystemVerilog UVM verification
environment developed as part of structured learning and upskilling.

The DUT is an aligner module that uses a standard AMBA 3 APB for register access. It has one Rx and one Tx interface which both use a custom valid/ready kind of protocol.
The DUT design file used is provided in the course [Design Verification with SystemVerilog & UVM](https://www.udemy.com/course/design-verification-with-systemverilog-uvm/?couponCode=ACCAGE0923) and has hidden bugs. 

The EDA playground link has the latest UVM testbench code that can be used for simulation and waveform observation.

**EDA Playground link**: https://edaplayground.com/x/SGa6

## Project Overview / Plan

This project demonstrates a **UVM-based verification environment** for an APB interface, developed as part of the Udemy course [Design Verification with SystemVerilog & UVM](https://www.udemy.com/course/design-verification-with-systemverilog-uvm/?couponCode=ACCAGE0923).

Key components of the verification environment:

- **APB Agent**: Includes driver, monitor, sequencer, and coverage collection.
- **Environment**: Implements a scoreboard, functional model of the DUT, and coverage mechanisms.
- **Register Access Verification**: Automatic register checks using UVM register model.
- **Randomized Tests**: Stimulus generation to cover a wide range of scenarios.
- **Simulation Platform**: Developed and simulated on **EDA Playground**.

This project showcases step-by-step construction of a robust UVM environment, emphasizing agent creation, DUT verification, functional coverage, and test automation.


## Status

***Work in Progress***

## Work Done

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
- [ ] Implement coverage inside the APB agent

---

## 🔧 To Do (Overview)

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
