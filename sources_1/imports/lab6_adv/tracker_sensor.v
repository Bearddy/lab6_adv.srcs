module tracker_sensor(clk, reset, left_track, right_track, mid_track, state);
    input clk;
    input reset;
    input left_track, right_track, mid_track;
    output reg [1:0] state;

    // TODO: Receive three tracks and make your own policy.
    // Hint: You can use output state to change your action.

    parameter FORWARD = 2'b00;
    parameter BACKWARD = 2'b01;
    parameter RIGHT = 2'b10;
    parameter LEFT = 2'b11;

    reg [27:0] counter;
    reg [1:0] prev_state;

    always @(posedge clk, posedge reset) begin
        prev_state <= state;
        if (reset) begin
            state <= FORWARD;
            counter <= 0;
        end 
        else begin
            if (left_track && right_track && ~mid_track) begin // middle black
                state <= FORWARD; //straight
                counter <= 0;
            end 
            else if ((left_track && ~right_track && mid_track) || (left_track && ~right_track && ~mid_track)) begin
                state <= RIGHT;   //turn right
                counter <= 0;
            end 
            else if ((~left_track && right_track && mid_track) || (~left_track && right_track && ~mid_track)) begin
                state <= LEFT;    //turn left
                counter <= 0;
            end
            else if (left_track && mid_track && right_track) begin
                if(counter > 28'b1010011011100100100111000000) begin //1.75sec
                    state <= BACKWARD;
                    counter <= counter;
                end
                else begin
                    state <= state;
                    counter <= counter + 1;
                end
            end
            else begin
                state <= state;
                counter <= 0;
            end
           
        end
    end

endmodule
