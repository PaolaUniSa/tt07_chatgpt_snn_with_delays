module memory #(parameter M = 320, parameter N = 8) (
    input wire [N-1:0] data_in,
    input wire [$clog2(M)-1:0] addr,
    input wire write_enable,
    input wire clk,
    input wire reset,
    output reg [N-1:0] data_out,
    output reg [M*N-1:0] all_data_out
);

    // Declare the memory array
    reg [N-1:0] mem [0:M-1];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Asynchronous reset: clear all memory contents
            mem[0] <= 0;
            mem[1] <= 0;
            mem[2] <= 0;
            mem[3] <= 0;
            mem[4] <= 0;
            mem[5] <= 0;
        end else if (write_enable) begin
            mem[addr] <= data_in;  // Write data to memory
        end
    end

    always @(*) begin
        // Output the data at the current address
        data_out = mem[addr];

        // Concatenate all memory data into all_data_out
        for (i = 0; i < M; i = i + 1) begin
            all_data_out[i*N +: N] = mem[i];
        end
    end
endmodule
