module spiking_network_top (
    input wire system_clock,
    input wire reset,
    input wire SCLK,
    input wire MOSI,
    input wire SS,
    output wire MISO,
    output wire [7:0] debug_output,
    output wire [1:0] output_spikes
);
    // Internal signals
    wire clk_div_ready_reg_out;
    wire input_spike_ready_reg_out;
    wire debug_config_ready_reg_out;
    wire clk_div_ready_sync;
    wire input_spike_ready_sync;
    wire debug_config_ready_sync;
    wire [2559-4*8*8-4*8*4:0] all_data_out; //wire [2559:0] all_data_out; 2175:0
    wire [23-4:0] input_spikes;   //wire [23:0] input_spikes;
    wire [7:0] decay;
    wire [7:0] refractory_period;
    wire [7:0] threshold;
    wire [7:0] div_value;
    wire [1663-4*8*8:0] weights;
    wire [831-4*8*4:0] delays;
    wire [7:0] debug_config_in;
    wire [79:0] membrane_potentials;
    wire [7:0] output_spikes_layer1;
    wire delay_clk;
    
    wire MOSI_sync; // Synchronized MOSI signal

    // Instantiations
    spi_interface spi_inst (
        .SCLK(SCLK),
        .MOSI(MOSI_sync),
        .SS(SS),
        .RESET(reset),
        .MISO(MISO),
        .clk_div_ready_reg_out(clk_div_ready_reg_out),
        .input_spike_ready_reg_out(input_spike_ready_reg_out),
        .debug_config_ready_reg_out(debug_config_ready_reg_out),
        .all_data_out(all_data_out)
    );

    clock_divider clk_div_inst (
        .clk(system_clock),
        .reset(reset),
        .enable(clk_div_ready_sync),
        .div_value(div_value),
        .clk_out(delay_clk)
    );

    debug_module debug_inst (
        .clk(system_clock),
        .rst(reset),
        .en(debug_config_ready_sync),
        .debug_config_in(debug_config_in),
        .membrane_potentials(membrane_potentials),
        .output_spikes_layer1(output_spikes_layer1),
        .debug_select(debug_output)
    );

    SNNwithDelays_top snn_inst (
        .clk(system_clock),
        .reset(reset),
        .enable(input_spike_ready_sync),
        .delay_clk(delay_clk),
        .input_spikes(input_spikes),
        .weights(weights),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .delays(delays),
        .membrane_potential_out(membrane_potentials),
        .output_spikes_layer1(output_spikes_layer1),
        .output_spikes(output_spikes)
    );

    // Synchronizers
    synchronizer clk_div_sync (
        .clk(system_clock),
        .reset(reset),
        .async_signal(clk_div_ready_reg_out),
        .sync_signal(clk_div_ready_sync)
    );

    synchronizer input_spike_sync (
        .clk(system_clock),
        .reset(reset),
        .async_signal(input_spike_ready_reg_out),
        .sync_signal(input_spike_ready_sync)
    );

    synchronizer debug_config_sync (
        .clk(system_clock),
        .reset(reset),
        .async_signal(debug_config_ready_reg_out),
        .sync_signal(debug_config_ready_sync)
    );

    // MOSI Synchronizer
    synchronizer mosi_sync (
        .clk(SCLK),
        .reset(reset),
        .async_signal(MOSI),
        .sync_signal(MOSI_sync)
    );

    // Corrected Assignments
    assign input_spikes = all_data_out[23-4:0];          // The first 3 bytes of all_data_out are the input spikes for SNNwithDelays_top
    assign decay = all_data_out[31:24];                // The fourth byte of all_data_out is the decay input for SNNwithDelays_top
    assign refractory_period = all_data_out[39:32];    // The fifth byte of all_data_out is the refractory period input for SNNwithDelays_top
    assign threshold = all_data_out[47:40];            // The sixth byte of all_data_out is the threshold input for SNNwithDelays_top
    assign div_value = all_data_out[55:48];            // The seventh byte of all_data_out is the div_value input for clock_divider
    assign weights = all_data_out[8*183-1:8*7];        // Bytes 8 to 215-4*8=183 of all_data_out are the weights input for SNNwithDelays_top
    assign delays = all_data_out[271*8-1 :8*183];       // Bytes 216-4*8-4*4=168 to 319-4*8=287 of all_data_out are the delays input for SNNwithDelays_top
    assign debug_config_in = all_data_out[272*8-1:271*8]; // Byte 320 of all_data_out is the debug_config_in input for debug_module
endmodule
//all_data_out[2559-4*8*8-4*8*4:0] -- 2175-0 272bytes     2449