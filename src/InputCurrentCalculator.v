module InputCurrentCalculator #(
    parameter M = 24                  // Number of input spikes and weights
)(
    input wire clk,                       // Clock signal
    input wire reset,                     // Asynchronous reset, active high
    input wire enable,                    // Enable input for calculation
    input wire [M-1:0] input_spikes,      // M-bit input spikes
    input wire [M*8-1:0] weights,         // M 8-bit weights
    output reg [7:0] input_current        // 8-bit input current
);
    integer i;
    
    reg signed [7:0] weight_array [0:M-1];
    reg signed [13:0] current_sum;  // Adjusted bit-length for overflow handling [clog2(M*128)-1:0] current_sum;

    // Function to calculate the ceiling of log2
//    function integer clog2;
//        input integer value;
//        integer i;
//        begin
//            clog2 = 0;
//            for (i = value; i > 0; i = i >> 1) begin
//                clog2 = clog2 + 1;
//            end
//        end
//    endfunction

    // Convert the flattened weights array into a 2D array
    always @(*) begin
        for (i = 0; i < M; i = i + 1) begin
            weight_array[i] = weights[i*8 +: 8];
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            input_current <= 8'b0;
            current_sum <= 0;  // Ensure current_sum is also reset
        end else if (enable) begin
            current_sum <= 0;  // Initialize current sum to zero
            for (i = 0; i < M; i = i + 1) begin
                if (input_spikes[i] == 1'b1) begin
                    current_sum <= current_sum + weight_array[i];
                end
            end
            // Handle overflow
            input_current <= current_sum[7:0];
        
        end
    end
endmodule
