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


## 📌 Status
**Work in progress**

---

## ✅ Work Done

### 1. Testbench Architecture
- Created basic architecture of the testbench.

### 2. APB Agent (Master)
- Created APB agent infrastructure.
- Implemented APB driving item / sequence item.
- Developed sequencer–driver mechanism.
- Created three different sequences.
- Currently updating driver to drive APB signals on the interface.

---

## 🔧 To Do (Overview)

3. Build **reusable UVM agents** for **RX** and **TX** of the module  
4. Incorporate **advanced UVM agent techniques**  
5. Implement **UVM Register Model**  
6. Functional **modelling and checking**  
7. **Debugging and testing**  
8. **Cleanup** and final wrap-up

---


## Tools
- SystemVerilog
- UVM 1.2
- EDA Playground 

## Author
Sidhartha Jain
