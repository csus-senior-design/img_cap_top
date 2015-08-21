/*
----------------------------------------
Stereoscopic Vision System
Senior Design Project - Team 11
California State University, Sacramento
Spring 2015 / Fall 2015
----------------------------------------

Image Capture Controller

Authors:  Greg M. Crist, Jr. (gmcrist@gmail.com)

Description:
    Top-Level Control State Machine
*/
module img_cap_ctrl #(
        parameter PLACEHOLDER = 0
    )(
        input  clk,
        input  reset,
        input  init_done,
        output reg   init_start
    );

    localparam s_idle       = 0,
               s_reset      = 1,
               s_init       = 2,
               s_init_wait  = 3,
               s_init_done  = 4,
               s_fb_prefill = 5,
               s_fb_stream  = 6;
               
    (* syn_encoding = "safe" *)
    reg [3:0] state;
    
    always @ (posedge clk) begin
        if (~reset) begin
            state <= s_reset;
            init_start <= 1'b0;
        end
        else begin
            case (state)
                // Placeholder for just chilling out
                s_idle: begin
                end

                // When put in a reset state, just jump straight to init
                s_reset: begin
                    state <= s_init;
                end
                
                // Kickoff initialization of system components
                s_init: begin
                    state <= s_init_wait;
                    init_start <= 1'b1;
                end
                
                // Wait for system components to finish initializing
                s_init_wait: begin
                    state <= init_done ? s_init_done : s_init_wait;
                    init_start <= 1'b0;
                end
                
                // Transition from initialization to filling the framebuffers
                s_init_done: begin
                    state <= s_fb_prefill;
                end
                
                // Pre-fill the camera input framebuffers before pushing forward
                s_fb_prefill: begin
                    state <= s_fb_stream;
                end
               
                // Stream from the first framebuffer stage to the next and enable outputs
                s_fb_stream: begin
                    state <= s_idle;
                end
            endcase
        end
    end
endmodule