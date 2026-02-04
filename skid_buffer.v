
module skid_buffer #(
    parameter int WIDTH = 32
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             in_valid,
    output logic             in_ready,
    input  logic [WIDTH-1:0] in_data,
    output logic             out_valid,
    input  logic             out_ready,
    output logic [WIDTH-1:0] out_data
);

 
    logic [WIDTH-1:0] main_reg;   // Primary storage
    logic [WIDTH-1:0] skid_reg;   // Secondary storage for backpressure
    logic             skid_valid; // Status of the skid register

    // We are ready for input if the skid register is empty.
    // This breaks the long combinational path from out_ready to in_ready.
    assign in_ready = !skid_valid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            main_reg   <= '0;
            skid_reg   <= '0;
            skid_valid <= 1'b0;
            out_valid  <= 1'b0;
        end else begin
            // Handling Input and Backpressure
            if (in_ready && in_valid) begin
                if (out_valid && !out_ready) begin
                    // Backpressure hit: Move new data to skid register
                    skid_reg   <= in_data;
                    skid_valid <= 1'b1;
                end else begin
                    // Normal flow: Move data to main register
                    main_reg   <= in_data;
                    out_valid  <= 1'b1;
                end
            end    
            // Handling Output and Clearing Skid
            if (out_ready && out_valid) begin
                if (skid_valid) begin
                    // Move data from skid to main register
                    main_reg   <= skid_reg;
                    skid_valid <= 1'b0;
                    out_valid  <= 1'b1;
                end else begin
                    // No more data coming from skid
                    out_valid  <= 1'b0;
                end
            end
        end
    end                           
    assign out_data = main_reg;  // Output Data Logic

endmodule
