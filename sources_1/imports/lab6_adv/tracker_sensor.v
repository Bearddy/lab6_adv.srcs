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

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= FORWARD;
        end else begin
            if (left_track && right_track && ~mid_track) begin // middle black
                state <= FORWARD; //straight
            end 
            else if ((left_track && ~right_track && mid_track) || (left_track && ~right_track && ~mid_track)) begin
                state <= RIGHT; //turn right
            end 
            else if ((~left_track && right_track && mid_track) || (~left_track && right_track && ~mid_track)) begin
                state <= LEFT;//turn left
            end
            else begin
                state <= state;
            end
        end
    end

endmodule
