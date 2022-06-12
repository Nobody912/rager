/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

//logic [31:0] LOCAL_REG [`NUM_REGS]; // Registers
//put other local variables here
logic [9:0] drawX, drawY;
logic [10:0] index;			// index in font ROM
logic [7:0] charData;		// character data from font ROM
logic [11:0] address;
logic currentBit;
logic inverse;
logic pixel_clk;
logic blank, sync;

// ram init
logic [31:0] ram_output;
logic [11:0] ram_read_address;

// palette init
logic [31:0] PALETTE_REG [8];

always_ff @(posedge CLK) begin
	if(AVL_WRITE & AVL_ADDR[11])
		PALETTE_REG[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
		
	if(AVL_READ & AVL_ADDR[11])
		AVL_READDATA <= PALETTE_REG[AVL_ADDR[2:0]];
end

//Declare submodules..e.g. VGA controller, ROMS, etc
	vga_controller vc0 (
		.Clk(CLK),
		.Reset(RESET),
		.hs(hs),
		.vs(vs),
		.pixel_clk(pixel_clk),
		.blank(blank),
		.sync(sync),
		.DrawX(drawX),
		.DrawY(drawY)
	);
	
	font_rom fr0 (
		.addr(index),
		.data(charData)
	);
	
	ram ram0 (
		.address_a(AVL_ADDR),
		.address_b(ram_read_address),
		.byteena_a(AVL_BYTE_EN),
		.byteena_b(),
		.clock(CLK),
		.data_a(AVL_WRITEDATA),
		.data_b(),
		.rden_a(1'b1),
		.rden_b(1'b1),
		.wren_a(AVL_CS & AVL_WRITE & ~AVL_ADDR[11]),
		.wren_b(1'b0),
		.q_a(),
		.q_b(ram_output)
	);
  

always_comb begin
//	address = (drawY[9:4] * 80 + drawX[9:3]);
//	ram_read_address = address[11:1];
//	
//	case (address[0])
//		0: begin
//			index = {ram_output[14:8], drawY[3:0]};
//			inverse = ram_output[15];
//		end
//		1: begin
//			index = {ram_output[30:24], drawY[3:0]};
//			inverse = ram_output[31];
//		end
//	endcase
//
//	currentBit = charData[~drawX[2:0]];
//	
//	if (inverse) begin
//		currentBit = ~currentBit;
//	end

end

always_ff @(posedge pixel_clk) begin
	if (!blank) begin
		red <= 4'h0;
		green <= 4'h0;
		blue <= 4'h0;
	end
	else begin
		if (drawY < 320) begin
			red <= 4'h8;
			green <= 4'ha;
			blue <= 4'hf;
		end
		else begin
			red <= 4'h4;
			green <= 4'hf;
			blue <= 4'h4;
		end
	end
end

endmodule
