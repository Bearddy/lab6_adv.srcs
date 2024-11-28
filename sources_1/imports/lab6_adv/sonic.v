// // sonic_top is the module to interface with sonic sensors
// // clk = 100MHz
// // <Trig> and <Echo> should connect to the sensor
// // <distance> is the output distance in cm
// module sonic_top(clk, rst, Echo, Trig, distance);
// 	input clk, rst, Echo;
// 	output Trig;
//     output [19:0] distance;

// 	wire[19:0] dis;
//     wire clk1M;
// 	wire clk_2_17;

//     assign distance = dis;

//     div clk1(clk ,clk1M);
// 	TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
// 	PosCounter u2(.clk(clk1M), .rst(rst), .echo(Echo), .distance_count(dis));
 
// endmodule

// module PosCounter(clk, rst, echo, distance_count); 
//     input clk, rst, echo;
//     output [19:0] distance_count;

//     parameter S0 = 2'b00;
//     parameter S1 = 2'b01; 
//     parameter S2 = 2'b10;
    
//     wire start, finish;
//     reg [1:0] curr_state, next_state;
//     reg echo_reg1, echo_reg2;
//     reg [19:0] count, distance_register;
//     wire [19:0] distance_count; 

//     // Convert count (time in microseconds) to distance in centimeters
//     wire [19:0] distance_in_cm;
//     assign distance_in_cm = (count * 343) / 200;  // Speed of sound 343 m/s or 0.0343 cm/μs, divided by 2 for round trip

//     always@(posedge clk) begin
//         if(rst) begin
//             echo_reg1 <= 0;
//             echo_reg2 <= 0;
//             count <= 0;
//             distance_register <= 0;
//             curr_state <= S0;
//         end else begin
//             echo_reg1 <= echo;   
//             echo_reg2 <= echo_reg1; 
//             case(curr_state)
//                 S0: begin
//                     if (start) curr_state <= next_state; // S1
//                     else count <= 0;
//                 end
//                 S1: begin
//                     if (finish) curr_state <= next_state; // S2
//                     else count <= count + 1;
//                 end
//                 S2: begin
//                     distance_register <= distance_in_cm;  // Store the calculated distance
//                     count <= 0;
//                     curr_state <= next_state; // S0
//                 end
//             endcase
//         end
//     end

//     always @(*) begin
//         case(curr_state)
//             S0: next_state = S1;
//             S1: next_state = S2;
//             S2: next_state = S0;
//             default: next_state = S0;
//         endcase
//     end

//     assign start = echo_reg1 & ~echo_reg2;  
//     assign finish = ~echo_reg1 & echo_reg2;

//     // TODO: trace the code and calculate the distance, output it to <distance_count>

//     // Output the calculated distance
//     assign distance_count = distance_register;

// endmodule

// // send trigger signal to sensor
// module TrigSignal(clk, rst, trig);
//     input clk, rst;
//     output trig;

//     reg trig, next_trig;
//     reg [23:0] count, next_count;

//     // Trigger duration is 10 microseconds, so we need to count for 10us
//     parameter TRIG_PULSE_TIME = 10; // 10 microseconds
//     parameter TRIG_CYCLE_TIME = 100000; // 100 milliseconds

//     always @(posedge clk, posedge rst) begin
//         if (rst) begin
//             count <= 0;
//             trig <= 0;
//         end else begin
//             count <= next_count;
//             trig <= next_trig;
//         end
//     end

//     always @(*) begin
//         next_trig = trig;
//         next_count = count + 1;
//         // TODO: set <next_trig> and <next_count> to let the sensor work properly
//         // Trigger logic: 
//         if (count < TRIG_PULSE_TIME) begin
//             next_trig = 1; // Set trig high for 10 microseconds
//         end else if (count < TRIG_CYCLE_TIME) begin
//             next_trig = 0; // Keep trig low after 10 microseconds until 100ms
//         end else begin
//             next_count = 0; // Reset count every 100ms cycle
//         end
//     end
// endmodule

// // clock divider for T = 1us clock
// module div(clk ,out_clk);
//     input clk;
//     output out_clk;
//     reg out_clk;
//     reg [6:0]cnt;
    
//     always @(posedge clk) begin   
//         if(cnt < 7'd50) begin
//             cnt <= cnt + 1'b1;
//             out_clk <= 1'b1;
//         end 
//         else if(cnt < 7'd100) begin
// 	        cnt <= cnt + 1'b1;
// 	        out_clk <= 1'b0;
//         end
//         else if(cnt == 7'd100) begin
//             cnt <= 0;
//             out_clk <= 1'b1;
//         end
//     end
// endmodule

// sonic_top is the module to interface with sonic sensors
// clk = 100MHz
// <Trig> and <Echo> should connect to the sensor
// <distance> is the output distance in cm
module sonic_top(clk, rst, Echo, Trig, distance);
	input clk, rst, Echo;
	output Trig;
    output [19:0] distance;

	wire[19:0] dis;
    wire clk1M;
	wire clk_2_17;

    assign distance = dis;

    div clk1(clk ,clk1M);
	TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
	PosCounter u2(.clk(clk1M), .rst(rst), .echo(Echo), .distance_count(dis));
 
endmodule

module PosCounter(clk, rst, echo, distance_count); 
    input clk, rst, echo;
    output[19:0] distance_count;

    parameter S0 = 2'b00;
    parameter S1 = 2'b01; 
    parameter S2 = 2'b10;
    
    wire start, finish;
    reg[1:0] curr_state, next_state;
    reg echo_reg1, echo_reg2;
    reg[19:0] count, distance_register;
    wire[19:0] distance_count; 

    always@(posedge clk) begin
        if(rst) begin
            echo_reg1 <= 0;
            echo_reg2 <= 0;
            count <= 0;
            distance_register  <= 0;
            curr_state <= S0;
        end
        else begin
            echo_reg1 <= echo;   
            echo_reg2 <= echo_reg1; 
            case(curr_state)
                S0:begin
                    if (start) curr_state <= next_state; //S1
                    else count <= 0;
                end
                S1:begin
                    if (finish) curr_state <= next_state; //S2
                    else count <= count + 1;
                end
                S2:begin
                    distance_register <= count;
                    count <= 0;
                    curr_state <= next_state; //S0
                end
            endcase
        end
    end

    always @(*) begin
        case(curr_state)
            S0:next_state = S1;
            S1:next_state = S2;
            S2:next_state = S0;
            default:next_state = S0;
        endcase
    end

    assign start = echo_reg1 & ~echo_reg2;  
    assign finish = ~echo_reg1 & echo_reg2;

    // TODO: trace the code and calculate the distance, output it to <distance_count>
    assign distance_count = (distance_register * 34) / 2000; // Convert count to cm
endmodule

// send trigger signal to sensor
module TrigSignal(clk, rst, trig);
    input clk, rst;
    output trig;

    reg trig, next_trig;
    reg[23:0] count, next_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            trig <= 0;
        end
        else begin
            count <= next_count;
            trig <= next_trig;
        end
    end

    // count 10us to set <trig> high and wait for 100ms, then set <trig> back to low
    always @(*) begin
        next_trig = trig;
        next_count = count + 1;
        // TODO: set <next_trig> and <next_count> to let the sensor work properly
        if (count < 1000) begin // Keep trig high for 10 μs
            next_trig = 1;
        end
        else if (count < 10_000_000) begin // Wait for 100 ms
            next_trig = 0;
        end
        else begin // Reset count after 100 ms
            next_count = 0;
        end
    end
endmodule

// clock divider for T = 1us clock
module div(clk ,out_clk);
    input clk;
    output out_clk;
    reg out_clk;
    reg [6:0]cnt;
    
    always @(posedge clk) begin   
        if(cnt < 7'd50) begin
            cnt <= cnt + 1'b1;
            out_clk <= 1'b1;
        end 
        else if(cnt < 7'd100) begin
	        cnt <= cnt + 1'b1;
	        out_clk <= 1'b0;
        end
        else if(cnt == 7'd100) begin
            cnt <= 0;
            out_clk <= 1'b1;
        end
    end
endmodule