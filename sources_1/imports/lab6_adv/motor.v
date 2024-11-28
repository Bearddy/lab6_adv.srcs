// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
module motor(
    input clk,
    input rst,
    input [1:0]mode,
    input [19:0] distance,
    input [15:0] sw,
    output [1:0]pwm,
    output [1:0]r_IN,
    output [1:0]l_IN
);

    reg [9:0]left_motor, right_motor;
    wire left_pwm, right_pwm;

    motor_pwm m0(clk, rst, left_motor, left_pwm);
    motor_pwm m1(clk, rst, right_motor, right_pwm);

    assign pwm = {left_pwm,right_pwm};

    // TODO: trace the rest of motor.v and control the speed and direction of the two motors

    parameter FORWARD = 2'b00;
    parameter BACKWARD = 2'b01;
    parameter RIGHT = 2'b10;
    parameter LEFT = 2'b11;

    parameter FAST = 10'd800;
    parameter SLOW = 10'd700;
    parameter TURN_SPEED = 10'd750;

    always@(posedge clk, posedge rst) begin
        if(rst) begin
            left_motor <= 0;
            right_motor <= 0;
        end
        else begin
            case(mode)
                FORWARD:begin
                    left_motor <= FAST;
                    right_motor <= FAST;
                end
                BACKWARD:begin
                    left_motor <= FAST;
                    right_motor <= FAST;
                end
                RIGHT:begin
                    left_motor <= TURN_SPEED;
                    right_motor <= 0;
                end
                LEFT:begin
                    left_motor <= 0;
                    right_motor <= TURN_SPEED;
                end
            endcase
            
        end
    end
    

    reg IN1, IN2, IN3, IN4;

    assign l_IN = {IN1, IN2};
    assign r_IN = {IN3, IN4};

    //always@(posedge clk, posedge rst) begin
    always@(*) begin    
        if(distance < 20'd31) begin
            IN1 = 0;
            IN2 = 0;
            IN3 = 0;
            IN4 = 0;
        end
        else begin
            
            case(mode)
                FORWARD:begin
                    IN1 = 1;
                    IN2 = 0;
                    IN3 = 1;
                    IN4 = 0;
                end
                BACKWARD:begin
                    IN1 = 0;
                    IN2 = 1;
                    IN3 = 0;
                    IN4 = 1;
                end
                RIGHT:begin
                    IN1 = 1;
                    IN2 = 0;
                    IN3 = 0;
                    IN4 = 1;
                end
                LEFT:begin
                    IN1 = 0;
                    IN2 = 1;
                    IN3 = 1;
                    IN4 = 0;
                end
            endcase
        end
    end    
endmodule

module motor_pwm (
    input clk,
    input reset,
    input [9:0]duty,
	output pmod_1 //PWM
);
        
    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1)
    );

endmodule

//generte PWM by input frequency & duty cycle
module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);
    wire [31:0] count_max = 100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            count <= count + 1;
            // TODO: set <PWM> accordingly
            if (count < count_duty) begin
                PWM <= 1;
            end else begin
                PWM <= 0;
            end
        end else begin
            count <= 0;
            PWM <= 0;
        end
    end
endmodule

