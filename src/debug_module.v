module debug_module (
    input wire clk,
    input wire rst,    // Active high reset
    input wire en,     // Enable signal
    input wire [7:0] debug_config_in,
    input wire [79:0] membrane_potentials, // Flattened array (10*8 = 80 bits)
    input wire [7:0] output_spikes_layer1,
    output reg [7:0] debug_select
);

    reg [7:0] debug_config;
    reg [7:0] selected_output;

    // 8-bit register with enable and active high reset
    always @(posedge clk or posedge rst) begin
        if (rst)
            debug_config <= 8'b0;
        else if (en)
            debug_config <= debug_config_in;
    end

    // Multiplexer to select the 8-bit signal based on debug_config
    always @(*) begin
        case (debug_config)
            8'b00000000: selected_output = membrane_potentials[7:0];
            8'b00000001: selected_output = membrane_potentials[15:8];
            8'b00000010: selected_output = membrane_potentials[23:16];
            8'b00000011: selected_output = membrane_potentials[31:24];
            8'b00000100: selected_output = membrane_potentials[39:32];
            8'b00000101: selected_output = membrane_potentials[47:40];
            8'b00000110: selected_output = membrane_potentials[55:48];
            8'b00000111: selected_output = membrane_potentials[63:56];
            8'b00001000: selected_output = membrane_potentials[71:64];
            8'b00001001: selected_output = membrane_potentials[79:72];
            default: selected_output = output_spikes_layer1;
        endcase
    end

    // Register to store the output
    always @(posedge clk or posedge rst) begin
        if (rst)
            debug_select <= 8'b0;
        else
            debug_select <= selected_output;
    end

endmodule
