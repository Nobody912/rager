//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


// FSM based drawing
// FSM - background
// FSM - character
// Collision detection 

module ball (
	input Reset, frame_clk,
	input [7:0] keycode0,
	input [7:0] keycode1,
	input [7:0] keycodeshoot,
	output logic [9:0] Ball_X,
	output logic [9:0] Ball_Y
	// output logic [1:0] character_map [47:0][63:0],
	// output logic [1:0] character_map_prev [47:0][63:0]
);

	parameter [9:0] Ball_X_Center = 10;
	parameter [9:0] Ball_Y_Center = 250;
	parameter [9:0] Ball_X_Min = 10;
	parameter [9:0] Ball_X_Max = 560;
	parameter [9:0] Ball_Y_Min = 10;
	parameter [9:0] Ball_Y_Max = 250;

	logic On_Ground;
	logic Is_Jump;
	logic [9:0] Jump_Counter;

	logic [9:0] Ball_X_Int, Ball_Y_Int;
	logic [9:0] Ball_X_Vel, Ball_Y_Vel;
  // logic [9:0] Ball_Y_Gravity;
	logic [9:0] Ball_Y_Jump_Vel;

  // assign Ball_Y_Gravity = 10;

	always_ff @(posedge frame_clk) begin
		if (Reset) begin
			Ball_X_Vel <= 0;
			Ball_Y_Vel <= 0; 
			Ball_X_Int <= 0;
			Ball_Y_Int <= 0;
			Ball_X <= Ball_X_Center;
			Ball_Y <= Ball_Y_Center;
		end
		else begin
			if (keycode1) begin
				case (keycode1)
					8'h04 : begin // A
							Ball_X_Vel <= -10;
					end
					8'h07 : begin // D
							Ball_X_Vel <= 10;
					end
					8'h16 : begin // S
						  Ball_Y_Vel <= 10;
					end
					8'h1A : begin // W
            Ball_Y_Vel <= -10;
					end
					default: begin
            if (Ball_X / 10 == 0) begin
							Ball_X_Vel <= 0;
							Ball_Y_Vel <= 10;
						end
					end
				endcase
			end
			else if (keycode0) begin
        case (keycode1)
					8'h04 : begin // A
							Ball_X_Vel <= -10;
					end
					8'h07 : begin // D
							Ball_X_Vel <= 10;
					end
					8'h16 : begin // S
						  Ball_Y_Vel <= 10;
					end
					8'h1A : begin // W
            Ball_Y_Vel <= -10;
					end
					default: begin
            if (Ball_X / 10 == 0) begin
							Ball_X_Vel <= 0;
							Ball_Y_Vel <= 10;
						end
					end
				endcase
			end
			else begin
				if (On_Ground) begin
					Ball_X_Vel <= 0;
					Ball_Y_Vel <= 0;
				end
				else begin
					Ball_Y_Vel <= Ball_Y_Jump_Vel;
				end
			end

			Ball_X_Int <= Ball_X + Ball_X_Vel;
			Ball_Y_Int <= Ball_Y + Ball_Y_Vel + Ball_Y_Gravity;

			if (Ball_X_Int >= Ball_X_Min && Ball_X_Int <= Ball_X_Max) begin
				Ball_X <= Ball_X_Int;
			end

			if (Ball_Y_Int >= Ball_Y_Min && Ball_Y_Int <= Ball_Y_Max) begin
				Ball_Y <= Ball_Y_Int;
			end
		end
	end
endmodule