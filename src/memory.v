module memory (
    input [7:0] data_in,
    input [8:0] addr,
    input write_enable,
    input clk,
    input reset,
    output reg [7:0] data_out,
    output reg [320*8-1:0] all_data_out
);

    // Define the memory array
    reg [7:0] mem [0:319];
    integer i;

    // Memory write and read operation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset memory contents
            for (i = 0; i < 320; i = i + 1) begin
                mem[i] <= 8'b0;
            end
            data_out <= 8'b0;
        end else if (write_enable) begin
            mem[addr] <= data_in;
        end
    end

    // Data output operation
    always @(posedge clk) begin
        if (!reset) begin
            data_out <= mem[addr];
        end else begin
            data_out <= 8'b0;
        end
    end

    // Update all_data_out
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            all_data_out <= {(320*8){1'b0}};
        end else begin
            for (i = 0; i < 320; i = i + 1) begin
                all_data_out[i*8 +: 8] = mem[i];
            end
        end
    end

endmodule
