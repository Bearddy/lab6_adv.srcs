module lab6_advanced(
    input clk,
    input rst,
    input echo,
    input left_track,
    input right_track,
    input mid_track,
    output trig,
    output IN1,
    output IN2,
    output IN3, 
    output IN4,
    output left_pwm,
    output right_pwm,
    output [6:0] DISPLAY,
	output [3:0] DIGIT,
	output [7:0] LED
    // You may modify or add more input/ouput yourself.
);
    // We have connected the motor and sonic_top modules in the template file for you.
    // TODO: control the motors with the information you get from ultrasonic sensor and 3-way track sensor.

	wire [19:0] distance;

	wire [3:0] num1;
	wire [3:0] num2;
	wire [3:0] num3;
	wire [1:0] mode;
	assign LED = {left_pwm, right_pwm, mode, IN1, IN2, IN3, IN4};

	SevenSegment seg(
		.display(DISPLAY),
		.digit(DIGIT),
		.nums({mode + 10, num3, num2, num1}),
		.rst(rst),
		.clk(clk)
	);
	

	number_change num_change(
		.num(distance),
		.num1(num1),
		.num2(num2),
		.num3(num3)
	);

	


	
    motor A(
        .clk(clk),
        .rst(rst),
        .mode(mode),
		.distance(distance),
        .pwm({left_pwm, right_pwm}),
        .l_IN({IN1, IN2}),
        .r_IN({IN3, IN4})
    );

    sonic_top B(
        .clk(clk), 
        .rst(rst), 
        .Echo(echo), 
        .Trig(trig),
        .distance(distance)
    );


	tracker_sensor sensor(
		.clk(clk),
		.reset(rst),
		.left_track(left_track),
		.right_track(right_track),
		.mid_track(mid_track),
		.state(mode)
	);

endmodule

module number_change(
	input wire [19:0] num,
	output reg [3:0] num1,
	output reg [3:0] num2,
	output reg [3:0] num3
	);

	wire [8:0] num_to_511;
	assign num_to_511 = num[8:0];

	always @ (*) begin
		if(num_to_511 > 400) begin
			num3 = 15;
			num2 = 15;
			num1 = 15;
		end
		else begin
			num3 = (num_to_511)/100;
			num2 = (num_to_511%100)/10;
			num1 = num_to_511%10;	
		end
	end

	// always@(*) begin
	// 	num4 = 5;
	// 	num3 = num_to_8192[11:8];
	// 	num2 = num_to_8192[7:4];
	// 	num1 = num_to_8192[3:0];
		
	// end
endmodule

module SevenSegment(
	output reg [6:0] display,
	output reg [3:0] digit,
	input wire [15:0] nums,
	input wire rst,
	input wire clk
    );
    
    reg [15:0] clk_divider;
    reg [3:0] display_num;
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		clk_divider <= 15'b0;
    	end else begin
    		clk_divider <= clk_divider + 15'b1;
    	end
    end
    
    always @ (posedge clk_divider[15], posedge rst) begin
    	if (rst) begin
    		display_num <= 4'b0000;
    		digit <= 4'b1111;
    	end else begin
    		case (digit)
    			4'b1110 : begin
    					display_num <= nums[7:4];
    					digit <= 4'b1101;
    				end
    			4'b1101 : begin
						display_num <= nums[11:8];
						digit <= 4'b1011;
					end
    			4'b1011 : begin
						display_num <= nums[15:12];
						digit <= 4'b0111;
					end
    			4'b0111 : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end
    			default : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end				
    		endcase
    	end
    end
    
    always @ (*) begin
    	case (display_num)
    		0 : display = 7'b1000000;	//0000
			1 : display = 7'b1111001;   //0001                                                
			2 : display = 7'b0100100;   //0010                                                
			3 : display = 7'b0110000;   //0011                                             
			4 : display = 7'b0011001;   //0100                                               
			5 : display = 7'b0010010;   //0101                                               
			6 : display = 7'b0000010;   //0110
			7 : display = 7'b1111000;   //0111
			8 : display = 7'b0000000;   //1000
			9 : display = 7'b0010000;	//1001
			10 : display = 7'b0001110; // F
			11 : display = 7'b0000011; // b
			12 : display = 7'b0101111; // r
			13 : display = 7'b1000111; // L
			
			default : display = 7'b0111111;
    	endcase
    end
    
endmodule
