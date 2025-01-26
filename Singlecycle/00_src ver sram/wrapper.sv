module wrapper(
	input logic 	 	  CLOCK_50,
	
	input logic  [17:0] SW,
	input logic  [ 3:0] KEY,
	
	output logic [17:0] LEDR,
	output logic [ 7:0] LEDG,
	
	output logic [ 6:0] HEX0,
	output logic [ 6:0] HEX1,
	output logic [ 6:0] HEX2,
	output logic [ 6:0] HEX3,
	output logic [ 6:0] HEX4,
	output logic [ 6:0] HEX5,
	output logic [ 6:0] HEX6,
	output logic [ 6:0] HEX7,
	
	output logic		  LCD_BLON,
	output logic 		  LCD_ON,
	output logic		  LCD_EN,
	output logic 		  LCD_RS,
	output logic		  LCD_RW,
	output logic [ 7:0] LCD_DATA,
	
	output logic [17:0] SRAM_ADDR,
	inout  wire  [15:0] SRAM_DQ  ,
	output logic        SRAM_CE_N,
	output logic        SRAM_WE_N,
	output logic        SRAM_LB_N,
	output logic        SRAM_UB_N,
	output logic        SRAM_OE_N
);

	wire [31:0] switch;
	assign switch = {25'b0, SW[16:0]};
	
	logic [31:0] LED_red;
	assign LEDR[16:0] = LED_red[16:0];
	
	wire [31:0] LED_green;
	assign LEDG[ 7:0] = LED_green[7:0];
	
	wire [31:0] LCD;	
	assign LCD_ON   = LCD[31];
	assign LCD_EN   = LCD[10];
	assign LCD_RS   = LCD[ 9];
	assign LCD_RW   = LCD[ 8];
	assign LCD_DATA = LCD[7:0];
	assign LCD_BLON = 1'b0;
	
	//clock div
	int   count     =    0;
	logic clock_div = 1'b0;
	
	always_ff @(posedge CLOCK_50) begin
		count++;
		if( count == 25) begin
			count <= 0;
			clock_div <= ~clock_div;
		end
	end
	
	singlecycle(
	.i_clk(clock_div),
	.i_rst_n(SW[17]),
	.i_io_btn(KEY),
	.i_io_sw(switch),
	.o_insn_vld(LEDR[17]),
	.o_pc_debug(),
	.o_io_ledr(LED_red),
	.o_io_ledg(LED_green),
	.o_io_lcd(LCD),
	.o_io_hex0(HEX0),
	.o_io_hex1(HEX1),
	.o_io_hex2(HEX2),
	.o_io_hex3(HEX3),
	.o_io_hex4(HEX4),
	.o_io_hex5(HEX5),
	.o_io_hex6(HEX6),
	.o_io_hex7(HEX7),
	.SRAM_ADDR(SRAM_ADDR),
	.SRAM_DQ(SRAM_DQ),
	.SRAM_CE_N(SRAM_CE_N),
	.SRAM_WE_N(SRAM_WE_N),
	.SRAM_LB_N(SRAM_LB_N),
	.SRAM_UB_N(SRAM_UB_N),
	.SRAM_OE_N(SRAM_OE_N)
	);


endmodule
