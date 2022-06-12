//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input [9:0] DrawX, DrawY,
                       input [9:0] Ball_X, Ball_Y,
                       input [7:0] keycodeshoot,
                       input Reset,
                       input Start,
                       input clk,
                       input blank,
                       output logic [3:0]  Red, Green, Blue );

    logic GameEnd;

    logic [10:0] screenOffset;
    logic [3:0] Current_BG_Bit;
    logic [11:0] RGB_BG_out;

    logic [3:0] Current_Sky_Bit;
    logic [11:0] RGB_Sky_out;

    logic [10:0] screenMidOffset;
    logic [3:0] Current_Mid_Bit;
    logic [11:0] RGB_Mid_out;

    logic [3:0] Current_Start_Bit;
    logic [11:0] RGB_Start_out;

    logic [3:0] Current_End_Bit;
    logic [11:0] RGB_End_out;

    logic [10:0] Main_Character_Animation_Counter;
    logic [3:0] Current_MC_Bit;
    logic [11:0] RGB_MC_out;
    logic [4:0] Main_Character_X_Cursor;
    logic [4:0] Main_Character_Y_Cursor;
	 
    logic [3:0] world_data_out1[47:0][63:0];
    logic [3:0] world_data_out2[47:0][63:0];
    logic [3:0] world_mid_out1[47:0][63:0];
    logic [3:0] world_back_out1[47:0][63:0];
    logic [3:0] world_start [19:0][63:0];
    logic [3:0] world_end [19:0][63:0];

    logic [9:0] bullet_counter;
    logic bullet_fired;
    logic [9:0] bullet_X;
    logic [9:0] bullet_Y;

    logic [9:0] Missile1_Animation_Counter;
    logic [9:0] Missile1_Explosion_Animation_Counter;
    logic [3:0] Current_MS1_Bit;
    logic [11:0] RGB_MS1_out;
    logic Missile1_Flight;
    logic Missile1_Explode;
    logic [10:0] Missile1_X;
    logic [10:0] Missile1_Y;
    logic [9:0] Missile1_X_Cursor;
    logic [9:0] Missile1_Y_Cursor;

    logic [9:0] Missile2_Animation_Counter;
    logic [9:0] Missile2_Explosion_Animation_Counter;
    logic [3:0] Current_MS2_Bit;
    logic [11:0] RGB_MS2_out;
    logic Missile2_Flight;
    logic Missile2_Explode;
    logic [10:0] Missile2_X;
    logic [10:0] Missile2_Y;
    logic [9:0] Missile2_X_Cursor;
    logic [9:0] Missile2_Y_Cursor;
	 
    world_data wd0 (
        .world_back_out1(world_back_out1),
        .world_mid_out1(world_mid_out1),
        .world_data_out1(world_data_out1),
        .world_data_out2(world_data_out2),
        .world_start(world_start),
        .world_end(world_end)
    );

    logic [3:0] character0_run [19:0][9:0];
    logic [3:0] character1_run [19:0][9:0];
    logic [3:0] character2_run [19:0][9:0];
    logic [3:0] missile0 [9:0][19:0];
    logic [3:0] missile1 [9:0][19:0];
    logic [3:0] missile0_explode [9:0][19:0];
    logic [3:0] missile1_explode [9:0][19:0];
    logic [3:0] missile2_explode [9:0][19:0];

    // logic [3:0] collision_map [47:0][63:0];

    character_data cd0 (
        .character0_run(character0_run),
        .character1_run(character1_run),
        .character2_run(character2_run),
        .missile0(missile0),
        .missile1(missile1),
        .missile0_explode(missile0_explode),
        .missile1_explode(missile1_explode),
        .missile2_explode(missile2_explode)
    );

    always_ff @(posedge clk) begin
        // Background Offset
        if (screenOffset >= 1280) begin
            screenOffset <= 0;
        end else begin
            screenOffset <= screenOffset + 4;
        end

        // Background Midground Offset
        if (screenMidOffset >= 640) begin
            screenMidOffset <= 0;
        end else begin
            screenMidOffset <= screenMidOffset + 2;
        end

        // Main Character Animation Counter
        if (Main_Character_Animation_Counter >= 20) begin
            Main_Character_Animation_Counter = 0;
        end else begin
            Main_Character_Animation_Counter <= Main_Character_Animation_Counter + 1;
        end

        // Main Character Fire Control
        if (keycodeshoot) begin
            if (bullet_fired) begin
                if (bullet_counter < 60 && bullet_X < 640) begin
                    bullet_X = bullet_X + 20;
                    bullet_counter <= bullet_counter + 1;
                end
                else begin
                    bullet_X = Ball_X + 20;
                    bullet_Y = Ball_Y + 35;
                    bullet_fired <= 0;
                    bullet_counter <= 0;
                end
            end
            else begin
                bullet_X = Ball_X + 20;
                bullet_Y = Ball_Y + 35;
                bullet_fired <= 1;
                bullet_counter <= 0;
            end
        end
        else begin
            if (bullet_fired) begin
                if (bullet_counter < 60 && bullet_X < 640) begin
                    bullet_X = bullet_X + 20;
                    bullet_counter <= bullet_counter + 1;
                end
                else begin
                    bullet_X = Ball_X + 20;
                    bullet_Y = Ball_Y + 35;
                    bullet_fired <= 0;
                    bullet_counter <= 0;
                end
            end
            else begin
                bullet_X = Ball_X + 20;
                bullet_Y = Ball_Y + 35;
                bullet_fired <= 0;
                bullet_counter <= 0;
            end 
        end

        // Missile 1 Control
        if (Start && !GameEnd) begin
            if (screenOffset == 0) begin
                Missile1_Flight <= 1;
                Missile1_X = 640;
                Missile1_Y = Ball_Y + 30;
                Missile1_Animation_Counter <= 0;
                Missile1_Explosion_Animation_Counter <= 0;
            end
            else if (Missile1_Explode && screenOffset >= 0 && screenOffset < 640) begin
                // Missile1_Flight <= 0;
                Missile1_Explosion_Animation_Counter <= Missile1_Explosion_Animation_Counter + 1;
            end
            else if (!Missile1_Explode && screenOffset >= 0 && screenOffset < 640) begin
                Missile1_X <= Missile1_X - 10;
                Missile1_Animation_Counter <= Missile1_Animation_Counter + 1;
            end
            else begin
                Missile1_Flight <= 0;
                Missile1_Animation_Counter <= 0;
            end

            if (Missile1_Animation_Counter > 10) begin
                Missile1_Animation_Counter <= 0;
            end
        end
        else begin
            Missile1_Flight <= 0;
            Missile1_X <= 0;
            Missile1_Y <= 0;
            Missile1_Animation_Counter <= 0;
            Missile1_Explosion_Animation_Counter <= 0;
        end

        // Missile 2 Control
        if (Start && !GameEnd) begin
            if (screenOffset == 640) begin
                Missile2_Flight <= 1;
                Missile2_X = 640;
                Missile2_Y = Ball_Y + 30;
                Missile2_Animation_Counter <= 0;
                Missile2_Explosion_Animation_Counter <= 0;
            end
            else if (Missile2_Explode && screenOffset >= 640 && screenOffset <= 1280) begin
                // Missile2_Flight <= 0;
                Missile2_Explosion_Animation_Counter <= Missile2_Explosion_Animation_Counter + 1;
            end
            else if (!Missile2_Explode && screenOffset >= 640 && screenOffset <= 1280) begin
                Missile2_X <= Missile2_X - 10;
                Missile2_Animation_Counter <= Missile2_Animation_Counter + 1;
            end
            else begin
                Missile2_Flight <= 0;
                Missile2_Animation_Counter <= 0;
            end

            if (Missile2_Animation_Counter > 10) begin
                Missile2_Animation_Counter <= 0;
            end
        end
        else begin
            Missile2_Flight <= 0;
            Missile2_X <= 0;
            Missile2_Y <= 0;
            Missile2_Animation_Counter <= 0;
            Missile2_Explosion_Animation_Counter <= 0;
        end
    end

    always_comb begin
	    if ((DrawX >= 0 && DrawX <= 639) && (DrawY >= 0 && DrawY <= 479)) begin
            //////////////////////
            // COLLISION CHECKS //
            //////////////////////


            if (Start) begin
                if (!GameEnd) begin
                    if ((Missile1_Flight && Missile1_X >= Ball_X && Missile1_X <= Ball_X + 50 && Missile1_Y >= Ball_Y && Missile1_Y <= Ball_Y + 100) ||
                        (Missile2_Flight && Missile2_X >= Ball_X && Missile2_X <= Ball_X + 50 && Missile2_Y >= Ball_Y && Missile2_Y <= Ball_Y + 100)) begin
                        GameEnd <= 1;
                    end
                    else begin
                        GameEnd <= 0;
                    end
                end
                else begin
                    GameEnd <= 1;
                end
            end
            else begin
                GameEnd <= 0;
            end

            // check if bullet collided with missile 1
            if (Missile1_Flight) begin
                if (!Missile1_Explode) begin
                    if (bullet_X >= Missile1_X && bullet_X <= Missile1_X + 100 && bullet_Y >= Missile1_Y && bullet_Y <= Missile1_Y + 50) begin
                        Missile1_Explode <= 1;
                    end
                    else begin
                        Missile1_Explode <= 0;
                    end
                end
                else begin
                    Missile1_Explode <= 1;
                end
            end
            else begin
                Missile1_Explode <= 0;
            end

            // check if bullet collided with missile 2
            if (Missile2_Flight) begin
                if (!Missile2_Explode) begin
                    if (bullet_X >= Missile2_X && bullet_X <= Missile2_X + 100 && bullet_Y >= Missile2_Y && bullet_Y <= Missile2_Y + 50) begin
                        Missile2_Explode <= 1;
                    end
                    else begin
                        Missile2_Explode <= 0;
                    end
                end
                else begin
                    Missile2_Explode <= 1;
                end
            end
            else begin
                Missile2_Explode <= 0;
            end


//////////////////

            /////////////////
            // DRAWING SKY //
            /////////////////

            Current_Sky_Bit <= world_back_out1[47 - (DrawY / 10)][64 - (DrawX / 10)];

            case (Current_Sky_Bit)
                4'h01: RGB_Sky_out = {4'h4, 4'h3, 4'h7}; // MASK
                4'h02: RGB_Sky_out = {4'hE, 4'hE, 4'hD}; // SUN
                4'h03: RGB_Sky_out = {4'hD, 4'hD, 4'hB}; // SKY
                4'h04: RGB_Sky_out = {4'hC, 4'hA, 4'hC}; // SKY
                4'h05: RGB_Sky_out = {4'hC, 4'h8, 4'h9}; // SKY
                4'h06: RGB_Sky_out = {4'hB, 4'h7, 4'h9}; // SKY
                4'h07: RGB_Sky_out = {4'hA, 4'h5, 4'hA}; // SKY
                4'h08: RGB_Sky_out = {4'h7, 4'h4, 4'h9}; // SKY
                4'h09: RGB_Sky_out = {4'h4, 4'h3, 4'h8}; // SKY
                4'h0A: RGB_Sky_out = {4'h2, 4'h3, 4'h7}; // SKY
                default: RGB_Sky_out = {4'h0, 4'h0, 4'h0}; // SUN
            endcase 

            //////////////////////////
            // DRAWING MIDDLEGROUND //
            //////////////////////////

            if ((DrawX + screenMidOffset) > 639) begin
                Current_Mid_Bit <= world_mid_out1[47 - (DrawY / 10)][64 - ((DrawX + screenMidOffset - 639) / 10)];
            end
            else begin
                Current_Mid_Bit <= world_mid_out1[47 - (DrawY / 10)][64 - ((DrawX + screenMidOffset) / 10)];
            end

            if (Current_Mid_Bit != 0) begin
                case (Current_Mid_Bit)
                    4'h01: RGB_Mid_out = {4'h0, 4'h0, 4'h0}; // MASK
                    4'h02: RGB_Mid_out = {4'h0, 4'h2, 4'h0}; // HILL
                    4'h03: RGB_Mid_out = {4'h1, 4'h5, 4'h1}; // HILL
                    default : RGB_Mid_out = {4'h0, 4'h0, 4'h0}; // BLACK
                endcase
            end
            else begin
                RGB_Mid_out = RGB_Sky_out;
            end

            ////////////////////////
            // DRAWING BACKGROUND //
            ////////////////////////
            if (screenOffset < 640) begin
                if ((DrawX + screenOffset) > 639) begin
                    Current_BG_Bit <= world_data_out2[47 - (DrawY / 10)][63 - ((DrawX + screenOffset - 639) / 10)];
                end
                else begin
                    Current_BG_Bit <= world_data_out1[47 - (DrawY / 10)][63 - (((DrawX + screenOffset) / 10))];
                end
            end
            else begin
                if ((DrawX + screenOffset) > 1279) begin
                    Current_BG_Bit <= world_data_out1[47 - (DrawY / 10)][63 - ((DrawX + screenOffset - 1279) / 10)];
                end
                else begin
                    Current_BG_Bit <= world_data_out2[47 - (DrawY / 10)][63 - ((DrawX + screenOffset - 639) / 10)];
                end
            end
            
            // BG Palette Decoder
            if (Current_BG_Bit != 0) begin
                case (Current_BG_Bit)
                    4'h00: RGB_BG_out = {4'h0, 4'h0, 4'h0}; // BLACK
                    4'h01: RGB_BG_out = {4'h0, 4'h2, 4'h0}; // DARK GREEN
                    4'h02: RGB_BG_out = {4'h0, 4'h3, 4'h0}; // LIGHT GREEN
                    4'h03: RGB_BG_out = {4'h0, 4'h3, 4'h2}; // LIGHT WARM GREEN
                    default : RGB_BG_out = {4'h0, 4'h0, 4'h0};
                endcase
            end
            else begin
                RGB_BG_out = RGB_Mid_out;
            end

            ////////////////////////////
            // DRAWING MAIN CHARACTER //
            ////////////////////////////
            Main_Character_X_Cursor <= (DrawX - Ball_X) / 5;
            Main_Character_Y_Cursor <= (DrawY - Ball_Y) / 5;
            if (Main_Character_Animation_Counter < 5) begin
                Current_MC_Bit <= character0_run[19 - Main_Character_Y_Cursor][9 - Main_Character_X_Cursor];
            end
            else if (Main_Character_Animation_Counter < 10) begin
                Current_MC_Bit <= character1_run[19 - Main_Character_Y_Cursor][9 - Main_Character_X_Cursor];
            end
            else if (Main_Character_Animation_Counter < 15) begin
                Current_MC_Bit <= character2_run[19 - Main_Character_Y_Cursor][9 - Main_Character_X_Cursor];
            end
            else begin
                Current_MC_Bit <= character1_run[19 - Main_Character_Y_Cursor][9 - Main_Character_X_Cursor];
            end

            if (!GameEnd) begin
                if (Current_MC_Bit != 0) begin
                    case (Current_MC_Bit)
                        4'h01: RGB_MC_out = {4'h0, 4'h0, 4'h0}; // BLACK
                        4'h02: RGB_MC_out = {4'h6, 4'h4, 4'h3}; // DARK BROWN (HAIR)
                        4'h03: RGB_MC_out = {4'h6, 4'h4, 4'h4}; // LIGHT BROWN (HAIR)
                        4'h04: RGB_MC_out = {4'hF, 4'hE, 4'hB}; // SKIN
                        4'h05: RGB_MC_out = {4'h9, 4'h9, 4'h9}; // GUN METAL GRAY (FOR GUN, DUH)
                        4'h06: RGB_MC_out = {4'hF, 4'h3, 4'h0}; // DARK ORANGE (FLAME)
                        4'h07: RGB_MC_out = {4'hF, 4'h6, 4'h0}; // LIGHT ORANGE (FLAME)
                        4'h09: RGB_MC_out = {4'hF, 4'hF, 4'h7}; // YELLOW (FLAME/STRIPE)
                        4'h08: RGB_MC_out = {4'hf, 4'hf, 4'hf}; // WHITE (TUX)
                        default: RGB_MC_out = {4'h0, 4'h0, 4'h0}; // BLACK
                    endcase
                end
                else begin
                    RGB_MC_out = RGB_BG_out;
                end
            end
            else begin
                RGB_MC_out = RGB_BG_out;
            end

            /////////////////////
            // DRAWING MISSILE //
            /////////////////////
            Missile1_X_Cursor <= (DrawX - Missile1_X) / 5;
            Missile1_Y_Cursor <= (DrawY - Missile1_Y) / 5;
            if (!Missile1_Explode) begin
                if (Missile1_Animation_Counter < 5) begin
                    Current_MS1_Bit <= missile0[9 - Missile1_Y_Cursor][19 - Missile1_X_Cursor];
                end
                else begin
                    Current_MS1_Bit <= missile1[9 - Missile1_Y_Cursor][19 - Missile1_X_Cursor];
                end
            end
            else begin
                if (Missile1_Explosion_Animation_Counter < 5) begin
                    Current_MS1_Bit <= missile0_explode[9 - Missile1_Y_Cursor][19 - Missile1_X_Cursor];
                end
                else if (Missile1_Explosion_Animation_Counter < 10) begin
                    Current_MS1_Bit <= missile1_explode[9 - Missile1_Y_Cursor][19 - Missile1_X_Cursor];
                end 
                else if (Missile1_Explosion_Animation_Counter < 15) begin
                    Current_MS1_Bit <= missile2_explode[9 - Missile1_Y_Cursor][19 - Missile1_X_Cursor];
                end
                else begin
                    Current_MS1_Bit <= 0;
                end
            end

            Missile2_X_Cursor <= (DrawX - Missile2_X) / 5;
            Missile2_Y_Cursor <= (DrawY - Missile2_Y) / 5;
            if (!Missile2_Explode) begin
                if (Missile2_Animation_Counter < 5) begin
                    Current_MS2_Bit <= missile0[9 - Missile2_Y_Cursor][19 - Missile2_X_Cursor];
                end
                else begin
                    Current_MS2_Bit <= missile1[9 - Missile2_Y_Cursor][19 - Missile2_X_Cursor];
                end
            end
            else begin
                if (Missile2_Explosion_Animation_Counter < 5) begin
                    Current_MS2_Bit <= missile0_explode[9 - Missile2_Y_Cursor][19 - Missile2_X_Cursor];
                end
                else if (Missile2_Explosion_Animation_Counter < 10) begin
                    Current_MS2_Bit <= missile1_explode[9 - Missile2_Y_Cursor][19 - Missile2_X_Cursor];
                end 
                else if (Missile2_Explosion_Animation_Counter < 15) begin
                    Current_MS2_Bit <= missile2_explode[9 - Missile2_Y_Cursor][19 - Missile2_X_Cursor];
                end
                else begin
                    Current_MS2_Bit <= 0;
                end
            end
            
            if (Current_MS1_Bit != 0) begin
                case (Current_MS1_Bit)
                    4'h01: RGB_MS1_out = {4'h0, 4'h0, 4'h0}; // BLACK
                    4'h02: RGB_MS1_out = {4'hB, 4'hA, 4'hA}; // DARK METAL GRAY (MISSILE)
                    4'h03: RGB_MS1_out = {4'hC, 4'hD, 4'hD}; // MID METAL GRAY (MISSILE)
                    4'h04: RGB_MS1_out = {4'hE, 4'hE, 4'hE}; // LIGHT METAL GRAY (MISSILE)
                    4'h05: RGB_MS1_out = {4'hF, 4'h3, 4'h0}; // DARK ORANGE (FLAME)
                    4'h06: RGB_MS1_out = {4'hF, 4'h6, 4'h0}; // LIGHT ORANGE (FLAME)
                    4'h07: RGB_MS1_out = {4'hF, 4'hF, 4'h7}; // YELLOW (FLAME/STRIPE)
                    4'h08: RGB_MS1_out = {4'h3, 4'h3, 4'h3}; // DARK GRAY (SMOKE)
                    4'h09: RGB_MS1_out = {4'h7, 4'h7, 4'h7}; // MID GRAY (SMOKE)
                    4'h0A: RGB_MS1_out = {4'hB, 4'hB, 4'hB}; // LIGHT GRAY (SMOKE)
                    default: RGB_MS1_out = {4'h0, 4'h0, 4'h0}; // BLACK
                endcase
            end
            else begin
                RGB_MS1_out = RGB_BG_out;
            end

            if (Current_MS2_Bit != 0) begin
                case (Current_MS2_Bit)
                    4'h01: RGB_MS2_out = {4'h0, 4'h0, 4'h0}; // BLACK
                    4'h02: RGB_MS2_out = {4'hB, 4'hA, 4'hA}; // DARK METAL GRAY (MISSILE)
                    4'h03: RGB_MS2_out = {4'hC, 4'hD, 4'hD}; // MID METAL GRAY (MISSILE)
                    4'h04: RGB_MS2_out = {4'hE, 4'hE, 4'hE}; // LIGHT METAL GRAY (MISSILE)
                    4'h05: RGB_MS2_out = {4'hF, 4'h3, 4'h0}; // DARK ORANGE (FLAME)
                    4'h06: RGB_MS2_out = {4'hF, 4'h6, 4'h0}; // LIGHT ORANGE (FLAME)
                    4'h07: RGB_MS2_out = {4'hF, 4'hF, 4'h7}; // YELLOW (FLAME/STRIPE)
                    4'h08: RGB_MS2_out = {4'h3, 4'h3, 4'h3}; // DARK GRAY (SMOKE)
                    4'h09: RGB_MS2_out = {4'h7, 4'h7, 4'h7}; // MID GRAY (SMOKE)
                    4'h0A: RGB_MS2_out = {4'hB, 4'hB, 4'hB}; // LIGHT GRAY (SMOKE)
                    default: RGB_MS2_out = {4'h0, 4'h0, 4'h0}; // BLACK
                endcase
            end
            else begin
                RGB_MS2_out = RGB_BG_out;
            end

            // DRAWING SCREEN PROMPTS START/END
            if (DrawY >= 100 && DrawY < 200) begin
                Current_Start_Bit <= world_start[20 - (DrawY / 10)][63 - (DrawX / 10)];
            end
            else begin
                Current_Start_Bit <= 0;
            end

            if (Current_Start_Bit != 0) begin
                case (Current_Start_Bit)
                    4'h01: RGB_Start_out = {4'hF, 4'h0, 4'h0}; // RED
                    default: RGB_Start_out = {4'h0, 4'h0, 4'h0}; // BLACK
                endcase
            end
            else begin
                RGB_Start_out = RGB_BG_out;
            end

            if (DrawY >= 100 && DrawY < 200) begin
                Current_End_Bit <= world_end[20 - (DrawY / 10)][63 - (DrawX / 10)];
            end
            else begin
                Current_End_Bit <= 0;
            end

            if (Current_End_Bit != 0) begin
                case (Current_End_Bit)
                    4'h01: RGB_End_out = {4'hF, 4'h0, 4'h0}; // RED
                    default: RGB_End_out = {4'h0, 4'h0, 4'h0}; // BLACK
                endcase
            end
            else begin
                RGB_End_out = RGB_BG_out;
            end


//////////////////
            if (!blank) begin
                Red     = 4'h0;
                Green   = 4'h0;
                Blue    = 4'h0;
            end

            ////////////////////////
            // PAINTING CHARACTER //
            ////////////////////////
            else if (DrawX >= Ball_X && DrawY >= Ball_Y && DrawX < Ball_X + 50 && DrawY < Ball_Y + 100) begin
                Red     = RGB_MC_out[11:8];
                Green   = RGB_MC_out[7:4];
                Blue    = RGB_MC_out[3:0];
            end

            /////////////////////
            // PAINTING BULLET //
            /////////////////////
            else if (bullet_fired &&DrawX >= bullet_X && DrawY >= bullet_Y && DrawX < bullet_X + 5 && DrawY < bullet_Y + 5) begin
                Red     = 4'hF;
                Green   = 4'hD;
                Blue    = 4'h0;
            end

            ////////////////////////
            // PAINTING MISSILE 1 //
            ////////////////////////
            else if (Missile1_Flight && DrawX >= Missile1_X && DrawY >= Missile1_Y && DrawX < Missile1_X + 100 && DrawY < Missile1_Y + 50) begin
                Red     = RGB_MS1_out[11:8];
                Green   = RGB_MS1_out[7:4];
                Blue    = RGB_MS1_out[3:0];
            end

            else if (Missile2_Flight && DrawX >= Missile2_X && DrawY >= Missile2_Y && DrawX < Missile2_X + 100 && DrawY < Missile2_Y + 50) begin
                Red     = RGB_MS2_out[11:8];
                Green   = RGB_MS2_out[7:4];
                Blue    = RGB_MS2_out[3:0];
            end

            /////////////////////////
            // PAINTING BACKGROUND //
            /////////////////////////
            else if (Current_BG_Bit != 0) begin
                Red     = RGB_BG_out[11:8];
                Green   = RGB_BG_out[7:4];
                Blue    = RGB_BG_out[3:0];
            end
            else if (Current_Mid_Bit != 0) begin
                Red     = RGB_Mid_out[11:8];
                Green   = RGB_Mid_out[7:4];
                Blue    = RGB_Mid_out[3:0];
            end
            else begin
                Red     = RGB_Sky_out[11:8];
                Green   = RGB_Sky_out[7:4];
                Blue    = RGB_Sky_out[3:0];
            end

            if (!Start) begin
                if (DrawY >= 100 && DrawY < 200) begin
                    Red     = RGB_Start_out[11:8];
                    Green   = RGB_Start_out[7:4];
                    Blue    = RGB_Start_out[3:0];
                end
                else begin
                    Red     = RGB_BG_out[11:8];
                    Green   = RGB_BG_out[7:4];
                    Blue    = RGB_BG_out[3:0];
                end
            end

            if (GameEnd) begin
                if (DrawY >= 100 && DrawY < 200) begin
                    Red     = RGB_End_out[11:8];
                    Green   = RGB_End_out[7:4];
                    Blue    = RGB_End_out[3:0];
                end
                else begin
                    Red     = RGB_BG_out[11:8];
                    Green   = RGB_BG_out[7:4];
                    Blue    = RGB_BG_out[3:0];
                end
            end

            // if (DrawX == 0 && DrawY == 0) begin
            //     if (Missile1_Explode) begin
            //         Red     = 4'h0;
            //         Green   = 4'hF;
            //         Blue    = 4'h0;        
            //     end
            //     else begin
            //         Red     = 4'hF;
            //         Green   = 4'h0;
            //         Blue    = 4'h0;
            //     end
            // end
            // if (DrawX == 1 && DrawY == 0) begin
            //     if (Missile1_Flight) begin
            //         Red     = 4'h0;
            //         Green   = 4'hF;
            //         Blue    = 4'h0;        
            //     end
            //     else begin
            //         Red     = 4'hF;
            //         Green   = 4'h0;
            //         Blue    = 4'h0;
            //     end
            // end

            // if (DrawX == 0 && DrawY == 1) begin
            //     if (Missile2_Explode) begin
            //         Red     = 4'h0;
            //         Green   = 4'hF;
            //         Blue    = 4'h0;        
            //     end
            //     else begin
            //         Red     = 4'hF;
            //         Green   = 4'h0;
            //         Blue    = 4'h0;
            //     end
            // end
            // if (DrawX == 1 && DrawY == 1) begin
            //     if (Missile2_Flight) begin
            //         Red     = 4'h0;
            //         Green   = 4'hF;
            //         Blue    = 4'h0;        
            //     end
            //     else begin
            //         Red     = 4'hF;
            //         Green   = 4'h0;
            //         Blue    = 4'h0;
            //     end
            // end

        end
        else begin
            GameEnd = GameEnd ? 1'b1 : 1'b0;
			Current_BG_Bit = 4'h0;
            Current_MC_Bit = 4'h0;
            Current_MS1_Bit = 4'h0;
            Current_MS2_Bit = 4'h0;
            Current_Start_Bit = 4'h0;
            Current_End_Bit = 4'h0;
            Current_Mid_Bit = 4'h0;
            Current_Sky_Bit = 4'h0;
			RGB_BG_out = 12'h0;
            RGB_MC_out = 12'h0;
            RGB_MS1_out = 12'h0;
            RGB_MS2_out = 12'h0;
            RGB_Start_out = 12'h0;
            RGB_End_out = 12'h0;
            RGB_Mid_out = 12'h0;
            RGB_Sky_out = 12'h0;
            Main_Character_X_Cursor = 4'h0;
            Main_Character_Y_Cursor = 4'h0;
            if (Missile1_Flight) begin
                if (Missile1_Explode) begin
                    Missile1_Explode = 1;
                end
                else begin
                    Missile1_Explode = 0;
                end
            end
            else begin
                Missile1_Explode = 0;
            end
            Missile1_X_Cursor = 4'h0;
            Missile1_Y_Cursor = 4'h0;
            if (Missile2_Flight) begin
                if (Missile2_Explode) begin
                    Missile2_Explode = 1;
                end
                else begin
                    Missile2_Explode = 0;
                end
            end
            else begin
                Missile2_Explode = 0;
            end
            Missile2_X_Cursor = 4'h0;
            Missile2_Y_Cursor = 4'h0;
            Red = 4'h0; 
            Green = 4'h0;
            Blue = 4'h0; 
        end
    end
    
endmodule