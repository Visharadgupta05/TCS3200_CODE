`timescale 1ns / 1ps

module tcs_3200(
    input clk_1MHz,
    input cs_out,
    output reg [1:0] filter,
    output reg [1:0] color
);

    parameter RED = 2'b01, GREEN = 2'b10, BLUE = 2'b11, CLEAR = 2'b00;
    parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
    parameter FILTER_RED   = 2'b00;
    parameter FILTER_GREEN = 2'b11;
    parameter FILTER_BLUE  = 2'b01;
    parameter FILTER_CLEAR = 2'b10;

    reg [1:0] state;
    reg [8:0] counter;
    reg [15:0] red_pulse, green_pulse, blue_pulse;

    initial begin
        color = CLEAR;
        state = S0;
        red_pulse = 0;
        green_pulse = 0;
        blue_pulse = 0;
        counter = 0;
    end

    always @ (posedge clk_1MHz) begin
        case(state)
            S0: begin
                if (counter >= 499) begin
                    state <= S1;
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end

            S1: begin
                if (counter >= 499) begin
                    state <= S2;
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end

            S2: begin
                if (counter >= 499) begin
                    state <= S3;
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end

            S3: begin
                state <= S0;
                red_pulse <= 0;
                green_pulse <= 0;
                blue_pulse <= 0;
            end

            default: begin
                state <= S0;
                counter <= 0;
            end
        endcase
    end

    always @ (*) begin
        case (state)
            S0: begin
                filter = FILTER_GREEN;
                if (cs_out)
                    green_pulse = green_pulse + 1;
            end

            S1: begin
                filter = FILTER_RED;
                if (cs_out)
                    red_pulse = red_pulse + 1;
            end

            S2: begin
                filter = FILTER_BLUE;
                if (cs_out)
                    blue_pulse = blue_pulse + 1;
            end

            S3: begin
                filter = FILTER_CLEAR;
                if (green_pulse > red_pulse && green_pulse > blue_pulse)
                    color = GREEN;
                else if (red_pulse > green_pulse && red_pulse > blue_pulse)
                    color = RED;
                else if (blue_pulse > red_pulse && blue_pulse > green_pulse)
                    color = BLUE;
                else
                    color = CLEAR;
            end
        endcase
    end

endmodule
