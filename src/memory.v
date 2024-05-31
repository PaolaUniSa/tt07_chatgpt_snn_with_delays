module memory #(parameter M = 320, parameter N = 8) (
    input wire [N-1:0] data_in,
    input wire [9-1:0] addr, // input wire [$clog2(M)-1:0] addr,
    input wire write_enable,
    input wire clk,
    input wire reset,
    output reg [N-1:0] data_out,
    output reg [M*N-1:0] all_data_out
);

    // Declare individual flip-flops for each bit of the memory
    reg mem [0:M-1][N-1:0];
    integer i, j;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Asynchronous reset: clear all memory contents
            for (i = 0; i < M; i = i + 1) begin
                for (j = 0; j < N; j = j + 1) begin
                    mem[i][j] <= 0;
                end
            end
        end else if (write_enable) begin
            for (j = 0; j < N; j = j + 1) begin
                mem[addr][j] <= data_in[j];
            end
        end
    end

    always @(*) begin
        // Output the data at the current address
        for (j = 0; j < N; j = j + 1) begin
            data_out[j] = mem[addr][j];
        end

        // Concatenate all memory data into all_data_out
        for (i = 0; i < M; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                all_data_out[i*N + j] = mem[i][j];
            end
        end
    end

endmodule
