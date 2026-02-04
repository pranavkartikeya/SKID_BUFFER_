`timescale 1ns/1ps

module skid_buffer_tb;
    parameter int WIDTH = 32;
    parameter int CLK_PERIOD = 10;

    // Signals
    logic clk, rst_n, in_valid, in_ready, out_valid, out_ready;
    logic [WIDTH-1:0] in_data, out_data;

    // Instantiate DUT
    skid_buffer #(WIDTH) dut (.*);

    // Simple Clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // --- Descriptive Monitoring Block ---
    initial begin
        // Using a cleaner format: [Time] Signal: Value | Signal: Value
        $monitor("[%0t ns] RST_n:%b | IN: vld:%b rdy:%b data:%h | OUT: vld:%b rdy:%b data:%h", 
                 $time, rst_n, in_valid, in_ready, in_data, out_valid, out_ready, out_data);
    end

    initial begin
        // VCD Setup
        $dumpfile("waveform.vcd");
        $dumpvars(0, skid_buffer_tb);

        // --- Step 1: Initialization ---
        rst_n = 0; in_valid = 0; in_data = 0; out_ready = 0;
        #(CLK_PERIOD * 2);
        rst_n = 1;
        $display("\n--- Reset De-asserted ---");

        // --- Step 2: Normal Flow ---
        @(posedge clk);
        out_ready <= 1;
        in_valid  <= 1; in_data <= 32'h0001; @(posedge clk);
        in_valid  <= 1; in_data <= 32'h0002; @(posedge clk);
        in_valid  <= 1; in_data <= 32'h0003; @(posedge clk);
        in_valid  <= 0;
        repeat(2) @(posedge clk);

        // --- Step 3: Triggering Backpressure (The Skid) ---
        $display("\n--- Starting Backpressure Test ---");
        @(posedge clk);
        out_ready <= 0; // Downstream stops
        in_valid  <= 1; in_data <= 32'hAAAA; @(posedge clk);
        
        // Skid cycle: in_ready still 1, out_ready is 0
        in_data   <= 32'hBBBB; @(posedge clk);

        in_valid  <= 0;
        $display("\n--- Buffer is Full (Skid Loaded) ---");
        repeat(2) @(posedge clk);

        // --- Step 4: Draining ---
        $display("\n--- Releasing Backpressure ---");
        out_ready <= 1; 
        repeat(4) @(posedge clk);

        $display("\n--- Test Finished ---");
        $finish;
    end

endmodule
