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
	input [7:0] keycode2,
	output Start,
	output [9:0] Ball_X,
	output [9:0] Ball_Y
);

	parameter [9:0] Ball_X_Center = 40; // REVERT TO ~20
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

	always_ff @(posedge Reset or posedge frame_clk) begin
		if (Reset) begin
			Ball_X_Vel <= 0;
			Ball_Y_Vel <= 0; 
			Ball_X_Int <= 0;
			Ball_Y_Int <= 0;
			Ball_X <= Ball_X_Center;
			Ball_Y <= Ball_Y_Center;
			Start <= 0;
		end
		else begin
			if (!Start) begin
				if (keycode0) begin
					Start <= 1;
				end
				else begin
					Start <= 0;
				end
			end
			else begin
				Start <= 1;
			end

			case (keycode2)
				8'h04 : begin // A
					Ball_X_Vel <= -5;
				end
				8'h07 : begin // D
					Ball_X_Vel <= 5;
				end
				8'h16 : begin // S
					Ball_Y_Vel <= 5;
				end
				8'h1A : begin // W
					Ball_Y_Vel <= -5;
				end
				default: begin
					Ball_X_Vel <= 0;
					if (Ball_Y >= Ball_Y_Max) begin
						Ball_Y_Vel <= 0;
					end
					else begin
						Ball_Y_Vel <= 5;
					end
				end
			endcase
			case (keycode1)
				8'h04 : begin // A
					if (keycode2 != 8'h04 && keycode2 != 8'h07) begin
						Ball_X_Vel <= -5;
					end
				end
				8'h07 : begin // D
				if (keycode1 != 8'h04 && keycode1 != 8'h07) begin
						Ball_X_Vel <= 5;
					end
				end
				8'h16 : begin // S
					Ball_Y_Vel <= 5;
				end
				8'h1A : begin // W
					Ball_Y_Vel <= -5;
				end
				default: begin
					Ball_X_Vel <= 0;
					if (Ball_Y >= Ball_Y_Max) begin
						Ball_Y_Vel <= 0;
					end
					else begin
						Ball_Y_Vel <= 5;
					end
				end
			endcase
			case (keycode0)
				8'h04 : begin // A
					if ((keycode1 != 8'h04 && keycode1 != 8'h07) && (keycode2 != 8'h04 && keycode2 != 8'h07)) begin
						Ball_X_Vel <= -5;
					end
				end
				8'h07 : begin // D
					if ((keycode1 != 8'h04 && keycode1 != 8'h07) && (keycode2 != 8'h04 && keycode2 != 8'h07)) begin
						Ball_X_Vel <= 5;
					end
				end
				8'h16 : begin // S
					Ball_Y_Vel <= 5;
				end
				8'h1A : begin // W
					Ball_Y_Vel <= -5;
				end
				default: begin
					Ball_X_Vel <= 0;
					if (Ball_Y >= Ball_Y_Max) begin
						Ball_Y_Vel <= 0;
					end
					else begin
						Ball_Y_Vel <= 5;
					end
				end
			endcase

			Ball_X_Int <= Ball_X + Ball_X_Vel;
			Ball_Y_Int <= Ball_Y + Ball_Y_Vel;

			if (Ball_X_Int >= Ball_X_Min && Ball_X_Int <= Ball_X_Max) begin
					Ball_X <= Ball_X + Ball_X_Vel;
			end
			if (Ball_Y_Int >= Ball_Y_Min && Ball_Y_Int <= Ball_Y_Max) begin
					Ball_Y <= Ball_Y + Ball_Y_Vel;
			end

		end
	end
endmodule