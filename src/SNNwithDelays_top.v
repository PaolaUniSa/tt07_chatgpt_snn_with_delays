module SNNwithDelays_top(
    input wire clk,                        // Clock signal
    input wire reset,                      // Asynchronous reset, active high
    input wire enable,                     // Enable input for the entire network
    input wire delay_clk,                  // Delay Clock signal
    input wire [23-4:0] input_spikes,        // M1-bit input spikes for the first layer
    input wire [1664-4*8*8-1:0] weights,           // Combined weights for both layers (N1*M1*8 + N2*N1*8 bits)
    input wire [7:0] threshold,            // Firing threshold for both layers
    input wire [7:0] decay,                // Decay value for both layers
    input wire [7:0] refractory_period,    // Refractory period for both layers
    input wire [831-4*8*4:0] delays,             // Combined delay values and delays for both layers (8*24*4 + 2*8*4 bits)
    output wire [79:0] membrane_potential_out, // (8+2)*8 bits
    output wire [7:0] output_spikes_layer1,    // Output spike signals for the first layer
    output wire [1:0] output_spikes           // Output spike signals for the second layer
);

    // Split delays into delay_values1, delays1, delay_values2, and delays2
    wire [575-4*8*3:0] delay_values1; //20*8*3=480
    wire [191-4*8:0] delays1; //20*8=160
    wire [47:0] delay_values2;
    wire [15:0] delays2;
    
    genvar i;
    generate
        for (i = 0; i < 192-4*8; i = i + 1) begin : unpack_delays1  //160
            assign delay_values1[i*3 +: 3] = delays[i*4 +: 3];
            assign delays1[i] = delays[i*4 + 3];
        end
    endgenerate
    
    generate //160 -176
        for (i = 160; i < 176; i = i + 1) begin : unpack_delays2    //for (i = 192; i < 208; i = i + 1) begin : unpack_delays2
            assign delay_values2[(i-160)*3 +: 3] = delays[i*4 +: 3]; //assign delay_values2[(i-192)*3 +: 3] = delays[i*4 +: 3];
            assign delays2[i-160] = delays[i*4 + 3];//assign delays2[i-192] = delays[i*4 + 3];
        end
    endgenerate

//    generate //160 -176
//        for (i = 192-4*8; i < 192+16-4*8; i = i + 1) begin : unpack_delays2    //for (i = 192; i < 208; i = i + 1) begin : unpack_delays2
//            assign delay_values2[(i-(192-4*8))*3 +: 3] = delays[i*4 +: 3]; //assign delay_values2[(i-192)*3 +: 3] = delays[i*4 +: 3];
//            assign delays2[i-(192-4*8)] = delays[i*4 + 3];//assign delays2[i-192] = delays[i*4 + 3];
//        end
//    endgenerate

    TwoLayerNetwork_debug #(
        .M1(24-4), 
        .N1(8), 
        .N2(2)
    ) two_layer_network_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .delay_clk(delay_clk),
        .input_spikes(input_spikes),
        .weights1(weights[1535-4*8*8:0]),         // weights1 part of the combined weights array
        .weights2(weights[1663-4*8*8:1536-4*8*8]),       // weights2 part of the combined weights array
        .threshold1(threshold),
        .decay1(decay),
        .refractory_period1(refractory_period),
        .threshold2(threshold),
        .decay2(decay),
        .refractory_period2(refractory_period),
        .delay_values1(delay_values1),
        .delays1(delays1),
        .delay_values2(delay_values2),
        .delays2(delays2),
        .membrane_potential_out(membrane_potential_out),
        .output_spikes_layer1(output_spikes_layer1),
        .output_spikes(output_spikes)
    );

endmodule
