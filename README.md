# AXI-to-APB Bridge Verification Using SystemVerilog UVM


## Project Overview

This project implements a **UVM-based verification environment for an AXI-to-APB Bridge** using SystemVerilog and UVM 1.2.

The AXI-to-APB Bridge acts as a protocol converter between an AXI master and an APB slave. It translates AXI read/write requests into corresponding APB transactions and returns the appropriate responses to the AXI interface.

The primary goal of this project is to develop a **modular, reusable, and coverage-driven verification environment** capable of validating bridge functionality, protocol handshaking, wait-state handling, error propagation, and transaction correctness.

The verification environment is simulated using **Synopsys VCS**.

---

## Verification Objectives

The project focuses on verifying:

- AXI-to-APB read transactions
- AXI-to-APB write transactions
- AXI and APB protocol handshaking
- APB wait-state handling
- AXI response generation
- APB slave error propagation
- Read and write data integrity
- Address correctness
- Delayed AXI response acceptance
- Simultaneous read/write traffic
- Back-to-back transactions
- Reset handling
- Functional coverage
- Scoreboard-based transaction checking

---

## Verification Architecture

The testbench follows a modular UVM architecture.

```text
                      +----------------------+
                      |       UVM TEST       |
                      +----------+-----------+
                                 |
                                 v
                      +----------------------+
                      |   VIRTUAL SEQUENCE   |
                      +----------+-----------+
                                 |
                                 v
                      +----------------------+
                      |  VIRTUAL SEQUENCER   |
                      +----------+-----------+
                                 |
                  +--------------+--------------+
                  |                             |
                  v                             v
          +---------------+             +---------------+
          | AXI SEQUENCER |             | APB SEQUENCER |
          +-------+-------+             +-------+-------+
                  |                             |
                  v                             v
          +---------------+             +---------------+
          |  AXI DRIVER   |             |  APB DRIVER   |
          +-------+-------+             +-------+-------+
                  |                             |
                  v                             v
          +-------------------------------------------+
          |              AXI-TO-APB DUT               |
          |                                           |
          |       AXI SLAVE  -->  APB MASTER          |
          +-------------------------------------------+
                  |                             |
                  v                             v
          +---------------+             +---------------+
          |  AXI MONITOR  |             |  APB MONITOR  |
          +-------+-------+             +-------+-------+
                  |                             |
                  +--------------+--------------+
                                 |
                                 v
                      +----------------------+
                      |      SCOREBOARD      |
                      |  Transaction Checks  |
                      +----------------------+

                           APB MONITOR
                                |
                                v
                      +----------------------+
                      | FUNCTIONAL COVERAGE  |
                      | Coverpoints & Crosses|
                      +----------------------+
```

### AXI Agent

The AXI agent is configured as an active UVM agent and contains:

- AXI Sequencer
- AXI Driver
- AXI Monitor

The AXI driver generates protocol-level transactions on the AXI interface.

The AXI monitor observes bus activity and publishes completed transactions through a UVM analysis port.

### APB Agent

The APB agent is configured as an active UVM agent that models the APB slave side of the bridge.

It contains:

- APB Sequencer
- APB Driver
- APB Monitor

The APB driver generates slave responses, including:

- `PREADY`
- `PRDATA`
- `PSLVERR`

The APB monitor captures completed transfers and records wait states.

### Virtual Sequencer

The virtual sequencer coordinates the AXI and APB sequencers.

It enables synchronized stimulus generation across both protocol interfaces.

### Scoreboard

The scoreboard compares observed AXI and APB transactions to check functional correctness.

It tracks:

- AXI read transactions
- AXI write transactions
- APB read transactions
- APB write transactions
- Passed transactions
- Failed transactions
- APB wait states
- APB slave errors

The scoreboard helps detect transaction mismatches and incorrect bridge behavior.

### Functional Coverage

A UVM subscriber collects functional coverage from completed APB transactions.

The APB monitor broadcasts transactions to both:

1. Scoreboard
2. Functional Coverage Subscriber

This allows transaction checking and coverage collection to operate independently.

---

## Verification Test Scenarios

The testbench includes the following test scenarios.

| Test | Verification Objective |
|------|------------------------|
| Smoke Test | Basic bridge read/write functionality |
| Single Read | Verify a single AXI-to-APB read |
| Single Write | Verify a single AXI-to-APB write |
| Read Wait | Verify read transfer with APB wait states |
| Write Wait | Verify write transfer with APB wait states |
| PSLVERR | Verify APB slave error handling |
| Delayed RREADY | Verify delayed AXI read-response acceptance |
| Delayed BREADY | Verify delayed AXI write-response acceptance |
| Simultaneous Read/Write | Exercise concurrent AXI read/write requests |
| Back-to-Back Reads | Verify consecutive read requests |
| Back-to-Back Writes | Verify consecutive write requests |
| Mixed Traffic | Exercise a combination of read/write operations |
| ID/User | Verify supported AXI ID and user-field handling |

Tests use virtual sequences to coordinate AXI requests and APB slave responses.

---

## Functional Coverage Model

Functional coverage is implemented using SystemVerilog covergroups inside a UVM subscriber.

### Operation Coverage

Checks whether both APB operations are exercised:

- READ
- WRITE

### Wait-State Coverage

Checks different APB response delays:

- Immediate response
- One wait state
- Multiple wait states
- Long wait-state scenarios

### Slave Error Coverage

Checks both successful and error responses:

- No Error (`PSLVERR = 0`)
- Slave Error (`PSLVERR = 1`)

### Scenario Coverage

The coverage model tracks:

| Coverage Scenario | Description |
|-------------------|-------------|
| Immediate Read | Read without wait states or errors |
| Immediate Write | Write without wait states or errors |
| Read With Wait | Read with one or more wait states |
| Write With Wait | Write with one or more wait states |
| Read PSLVERR | Read transaction with APB slave error |
| Write PSLVERR | Write transaction with APB slave error |

Cross coverage is also used to observe combinations of:

- Operation × Wait States
- Operation × Slave Error

Functional coverage is sampled from transactions observed by the APB monitor rather than directly from sequence stimulus.

---

## Protocol Features

### AXI Interface

The AXI driver handles the following channels:

**Write Address Channel**
- AWVALID
- AWREADY

**Write Data Channel**
- WVALID
- WREADY

**Write Response Channel**
- BVALID
- BREADY
- BRESP

**Read Address Channel**
- ARVALID
- ARREADY

**Read Data Channel**
- RVALID
- RREADY
- RRESP

The driver supports independent read and write activity and configurable response-ready delays.

### APB Interface

The APB side includes:

- PCLK
- PRESETn
- PSEL
- PENABLE
- PWRITE
- PADDR
- PWDATA
- PRDATA
- PREADY
- PSLVERR

APB transfers follow the standard setup and access phases.

```text
              SETUP PHASE        ACCESS PHASE

PSEL              1                  1
PENABLE           0                  1
PREADY            -                  1

                              Transfer Completes
```

When `PREADY = 0` during the access phase, the transfer remains pending until the slave becomes ready.

---

## APB Wait-State Verification

The APB slave driver supports configurable wait states.

This allows the testbench to verify that the bridge correctly holds the transfer while waiting for `PREADY`.

Example:

```text
Cycle       1       2       3       4
-----------------------------------------
PSEL        1       1       1       1
PENABLE     0       1       1       1
PREADY      0       0       0       1
-----------------------------------------
Phase      SETUP   WAIT    WAIT    COMPLETE
```

The APB monitor counts observed wait cycles and sends the completed transaction to the scoreboard and coverage subscriber.

---

## APB Slave Error Verification

The APB slave driver can inject error responses through `PSLVERR`.

Two cases are verified:

**Successful Transfer**

```text
PSLVERR = 0
Expected AXI Response = OKAY
```

**Slave Error Transfer**

```text
PSLVERR = 1
Expected AXI Response = SLVERR
```

This verifies the bridge's error-response translation behavior.

---

## Project Directory Structure

The repository is organized into RTL, testbench, UVM, and simulation directories.

```text
axi2apb/
|
+-- rtl/
|   +-- AXI-to-APB RTL files
|
+-- tb/
|   +-- AXI/APB interfaces
|   +-- Testbench top module
|
+-- uvm/
|   |
|   +-- axi_agent/
|   |   +-- AXI transaction items
|   |   +-- AXI sequences
|   |   +-- AXI sequencer
|   |   +-- AXI driver
|   |   +-- AXI monitor
|   |   +-- AXI agent
|   |
|   +-- apb_agent/
|   |   +-- APB transaction items
|   |   +-- APB sequences
|   |   +-- APB sequencer
|   |   +-- APB driver
|   |   +-- APB monitor
|   |   +-- APB agent
|   |
|   +-- virtual_sequencer/
|   |   +-- axi2apb_virtual_sequences.sv
|   |
|   +-- coverage/
|   |   +-- axi2apb_coverage.sv
|   |
|   +-- env/
|   |   +-- axi2apb_env.sv
|   |   +-- AXI2APB scoreboard
|   |
|   +-- tests/
|       +-- axi2apb_base_test.sv
|       +-- axi2apb_tests.sv
|
+-- sim/
|   +-- Makefile
|   +-- build.flist
|
+-- README.md
```

*Some filenames are represented by their functional roles. Refer to the repository for the exact source filenames.*

---

## Tools and Technologies

| Category | Technology |
|----------|------------|
| Hardware Description Language | SystemVerilog |
| Verification Methodology | UVM 1.2 |
| Simulator | Synopsys VCS |
| Verification Approach | Constrained-Random and Directed Testing |
| Transaction Checking | UVM Scoreboard |
| Coverage | SystemVerilog Functional Coverage |
| Version Control | Git and GitHub |
| Automation | GNU Make |

---

## Running the Simulation

### Requirements

- Synopsys VCS
- SystemVerilog support
- UVM 1.2
- GNU Make
- Linux environment

### Step 1: Clone the Repository

```bash
git clone <YOUR_REPOSITORY_URL>
cd axi2apb
```

Replace `<YOUR_REPOSITORY_URL>` with the actual GitHub repository URL.

### Step 2: Navigate to Simulation Directory

```bash
cd sim
```

### Step 3: Compile the Testbench

```bash
make compile TEST=axi2apb_smoke_test
```

### Step 4: Run the Smoke Test

```bash
make sim TEST=axi2apb_smoke_test
```

### Step 5: Run Other Tests

For example:

```bash
make compile TEST=axi2apb_single_read_test
make sim TEST=axi2apb_single_read_test
```

```bash
make compile TEST=axi2apb_single_write_test
make sim TEST=axi2apb_single_write_test
```

For other tests, replace the `TEST` value with the corresponding UVM test class name.

---

## Simulation Results

The verification environment reports transaction-level checking through the UVM scoreboard.

The following basic scenarios have been exercised successfully during development:

| Test | Result |
|------|--------|
| Smoke Test | PASS |
| Single Read | PASS |
| Single Write | PASS |

Functional coverage is collected and reported through the coverage subscriber.

Additional regression testing and coverage closure are ongoing.

---

## Verification Methodology

The verification process follows these steps:

1. Generate AXI requests using UVM sequences.
2. Drive AXI requests to the DUT using the AXI driver.
3. Generate APB slave responses through APB sequences.
4. Observe AXI and APB protocol activity using monitors.
5. Send completed transactions to the scoreboard.
6. Compare corresponding transactions and responses.
7. Sample functional coverage from observed APB activity.
8. Review simulation logs, failures, and coverage reports.

This structure separates stimulus generation, bus driving, monitoring, checking, and coverage collection.

---

## Future Improvements

Planned enhancements include:

- Expanded constrained-random testing
- Additional protocol corner-case verification
- Functional coverage closure
- Improved regression automation
- More detailed protocol assertions
- Additional reset and error-injection scenarios
- Coverage-driven test development
- Regression summary generation

---

## Key Learning Outcomes

This project provides hands-on experience with:

- SystemVerilog UVM architecture
- UVM factory registration
- UVM component phases
- UVM agents and sequencers
- UVM sequences and virtual sequences
- UVM analysis ports and subscribers
- AXI and APB protocol verification
- Transaction-level scoreboarding
- Functional coverage modeling
- Synopsys VCS simulation and debugging
- Git-based project development

---

## Project Status

**Active Development**

The UVM verification environment includes AXI and APB agents, a virtual sequencer, transaction-level scoreboard, and functional coverage subscriber.

Basic read/write tests are passing, while additional verification scenarios and coverage closure are being developed.

---

## Author

**Digital Design Verification Project**

Developed using SystemVerilog, UVM 1.2, and Synopsys VCS.

---

⭐ If you find this project useful, consider starring the repository.
