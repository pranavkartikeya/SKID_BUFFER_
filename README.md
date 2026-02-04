High-Frequency Skid Buffer (Pipeline Register)

In high-performance SoC design, a standard pipeline register often creates a long combinational path on the "ready" (backpressure) signal. As the pipeline depth increases, this path can become the critical timing bottleneck, preventing the chip from hitting its target .
This repository implements a Skid Buffer a specialized pipeline stage that decouples the input and output interfaces by registering the backpressure signal. This design ensures full throughput and zero-latency operation while providing the timing isolation necessary for high-speed valid/ready handshakes.

Key Architectural Features

Timing Isolation: The input `ready` signal is locally generated from the internal state, breaking the combinational chain from the downstream receiver.
Zero-Latency Pass-Through: When the buffer is empty, data is presented to the output interface on the very next clock edge.
Full Throughput: Supports a sustained data transfer rate of one word per clock cycle ( efficiency).
Backpressure Handling: Features a secondary "Skid Register" to capture incoming data when a downstream stall occurs, preventing data loss.
AXI-Style Handshaking: Utilizes standard `valid`/`ready` semantics compatible with AMBA AXI4-Stream and AHB protocols.

How It Works

The design uses two internal storage slots:

1. Main Register: Stores the data currently being presented to the output.
2. Skid Register: An overflow buffer that captures one "skid" beat if the downstream interface (`out_ready`) drops while the upstream is still transmitting.

Handshake Logic

Input Ready: `assign in_ready = !skid_valid;` (Independent of downstream `ready`).
Output Data: Always driven by the `main_reg` to ensure clean, registered electrical signals.

Verification & Simulation

The design has been verified with a SystemVerilog testbench covering normal flow, backpressure stalls, and buffer draining scenarios.

