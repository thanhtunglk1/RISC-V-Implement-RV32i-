module singlecycle(
  input  logic 		 i_clk, i_rst_n,
  input  logic [3:0]  i_io_btn,
  input  logic [31:0] i_io_sw,
  output logic 		 o_insn_vld,
  output logic [31:0] o_pc_debug, o_io_ledr, o_io_ledg, o_io_lcd,
  output logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7
  /*
  output logic [17:0] SRAM_ADDR,
  inout  wire  [15:0] SRAM_DQ  ,
  output logic        SRAM_CE_N,
  output logic        SRAM_WE_N,
  output logic        SRAM_LB_N,
  output logic        SRAM_UB_N,
  output logic        SRAM_OE_N
 */
);


	wire [31:0] pc, pc_next, pc_four;
	wire		pc_sel;
	
	pc PC(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_en_pc(1'b1),
	.i_pc_next(pc_next),
	.o_pc(pc)
	);
	
	PC_plus_4 PC_four(
	.i_pc(pc),
	.o_pc_next(pc_four)
	);
	
	wire [31:0] alu_data;
	
	mux2_1 PC_select(
	.sel(pc_sel),
	.i_data_0(pc_four),
	.i_data_1(alu_data),
	.o_data(pc_next)
	);
//--------------------------------------------------------------	
	wire [31:0] instruction;
	wire [2:0]  func3;
	wire        func7;
	
	inst_mem imem(
	.i_pc_addr(pc),
	.o_inst(instruction)
	);
//--------------------------------------------------------------	
	assign func3 = instruction[14:12];
	assign func7 = instruction[30];
	
	
	wire 		rd_wren, insn_vld, br_un, opa_sel, opb_sel, wr_en, rd_en;
	wire [1:0]  wb_sel;
	wire		br_less, br_equal;
	wire [3:0]  alu_op;
	
	control_unit ctrl(
	.i_inst(instruction),
	.i_br_less(br_less),
	.i_br_equal(br_equal),
	.o_pc_sel(pc_sel),
	.o_rd_wren(rd_wren),
	.o_insn_vld(insn_vld),
	.o_br_un(br_un),
	.o_opa_sel(opa_sel),
	.o_opb_sel(opb_sel),
	.o_mem_wren(wr_en),
	.o_mem_rden(rd_en),
	.o_alu_op(alu_op),
	.o_wb_sel(wb_sel)
	);
	
	wire [4:0]  rs1_addr, rs2_addr, rd_addr;
	assign rs1_addr = instruction[19:15];
	assign rs2_addr = instruction[24:20];
	assign rd_addr  = instruction[11:7 ];
	
	wire [31:0] rs1_data, rs2_data, wb_data;
	
	regfile reg_file(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_rd_wren(rd_wren),
	.i_rs1_addr(rs1_addr),
	.i_rs2_addr(rs2_addr),
	.i_rd_addr(rd_addr),
	.i_rd_data(wb_data),
	.o_rs1_data(rs1_data),
	.o_rs2_data(rs2_data)
	);
	
	brc branch(
	.i_br_un(br_un),
	.i_rs1_data(rs1_data),
	.i_rs2_data(rs2_data),
	.o_br_less(br_less),
	.o_br_equal(br_equal)
	);
	
	wire [31:0] immgen_data;
	
	immgen immediate(
	.i_inst(instruction),
	.o_imm(immgen_data)
	);
	
	wire [31:0] operand_a;
	
	mux2_1 OPA_sel(
	.sel(opa_sel),
	.i_data_0(rs1_data),
	.i_data_1(pc),
	.o_data(operand_a)
	);
	
	wire [31:0] operand_b;
	
	mux2_1 OPB_sel(
	.sel(opb_sel),
	.i_data_0(rs2_data),
	.i_data_1(immgen_data),
	.o_data(operand_b)
	);
	
	alu arith_logic(
	.i_operand_a(operand_a),
	.i_operand_b(operand_b),
	.i_alu_op(alu_op),
	.o_alu_data(alu_data)
	);
	
	wire [31:0] ld_data;
	wire			ack;
	
	lsu load_store_unit(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_lsu_addr(alu_data),
	.i_st_data(rs2_data),
	.i_lsu_wren(wr_en),
	.i_lsu_rden(rd_en),
	.i_control(func3),
	.o_ld_data(ld_data),
	.o_io_ledr(o_io_ledr),
	.o_io_ledg(o_io_ledg),
	.o_io_hex0(o_io_hex0),
	.o_io_hex1(o_io_hex1),
	.o_io_hex2(o_io_hex2),
	.o_io_hex3(o_io_hex3),
	.o_io_hex4(o_io_hex4),
	.o_io_hex5(o_io_hex5),
	.o_io_hex6(o_io_hex6),
	.o_io_hex7(o_io_hex7),
	.o_io_lcd (o_io_lcd),
	.i_io_sw  (i_io_sw),
	.i_io_btn (i_io_btn)
/*
	.o_ack(ack),
	.SRAM_ADDR(SRAM_ADDR),
	.SRAM_DQ(SRAM_DQ),
	.SRAM_CE_N(SRAM_CE_N),
	.SRAM_WE_N(SRAM_WE_N),
	.SRAM_LB_N(SRAM_LB_N),
	.SRAM_UB_N(SRAM_UB_N),
	.SRAM_OE_N(SRAM_OE_N)
*/
	);
/*	
	pc_hold hold(
	.i_opcode(instruction[6:2]),
	.i_address(alu_data),
	.i_ack(ack),
	.o_pc_en(pc_en)
	);
*/	
	mux4_1 WB_sel(
	.sel(wb_sel),
	.i_data_0(pc_four),
	.i_data_1(alu_data),
	.i_data_2(ld_data),
	.i_data_3(32'b0),
	.o_data(wb_data)
	);
	
	always_ff @(posedge i_clk) begin
		if(~i_rst_n) begin
			o_insn_vld <= 1'b0;
		end else begin
			o_insn_vld <= insn_vld;
		end
		o_pc_debug <= pc;
	end
	
endmodule 
