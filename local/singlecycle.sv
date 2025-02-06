module singlecycle(

  input  logic 		 i_clk, i_rst_n,
  input  logic [3:0]  i_io_btn,
  input  logic [31:0] i_io_sw,
  output logic 		 o_insn_vld, o_mispred,
  output logic [31:0] o_pc_debug, o_io_ledr, o_io_ledg, o_io_lcd,
  output logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7

);
//xrun -gui -access +rwc -sv ../01_bench/tbench.sv -f flist
//--------------------------------------------------------------Wire region

	wire [31:0] pc, pc_next, pc_four;	
	logic		IF_mispred;
	wire [31:0] instruction;
	
//IF_ID	
	wire [31:0]	ID_pc_four, ID_pc, ID_inst;
	wire		ID_mispred;
	
//branch_prediction
	wire 		pred_flush;

//control unit
	wire 		rd_wren, insn_vld, br_un, opa_sel, opb_sel, mem_wren, rs1_en, rs2_en;
	wire [1:0]  wb_sel;
	wire [3:0]  alu_op;
	
//register file	
	wire [4:0]  rs1_addr, rs2_addr, rd_addr;
	wire [31:0] rs1_data, rs2_data, wb_data;
	assign rs1_addr = ID_inst[19:15];
	assign rs2_addr = ID_inst[24:20];
	
//immediate generation	
	wire [31:0] immgen_data;
	
//ID_EX	
	wire 			EX_mispred, EX_insn_vld;
	wire [31:0]	EX_pc, EX_pc_four, EX_inst;
	wire [31:0]	EX_imm_data, EX_rs1_data, EX_rs2_data;
	wire			EX_rd_wren, EX_opa_sel, EX_opb_sel, EX_mem_wren, EX_br_un;
	wire [1:0]	EX_wb_sel;
	wire [3:0]	EX_alu_op;

//BRC-brc_taken	
	wire		br_less, br_equal;
	wire		brc_taken;
	
//MUX_ALU
	wire [31:0] operand_a;
	wire [31:0] operand_b;
	wire [31:0] alu_data;
	
//EX_MEM
	wire			MEM_mispred, MEM_insn_vld, MEM_mem_wren, MEM_rd_wren;
	wire [31:0] MEM_pc, MEM_pc_four, MEM_inst;
	wire [31:0]	MEM_alu_data, MEM_forward_b_data;
	wire [1:0]	MEM_wb_sel;
	
//LSU
	wire [31:0] ld_data;
	wire [2:0]  MEM_func3;
	assign MEM_func3 = MEM_inst[14:12];
	
//MEM_WB
	wire		WB_mispred, WB_insn_vld, WB_rd_wren;
	wire [31:0]	WB_pc, WB_pc_four, WB_inst;
	wire [31:0] WB_alu_data, WB_ld_data;
	wire [1:0]	WB_wb_sel;
	
	
//hazard_detect	
	wire		pc_hazard_en, ID_IF_hazard_stall, ID_EX_hazard_flush, ID_EX_flush;
	assign ID_EX_flush = ID_EX_hazard_flush | pred_flush; // | brc_taken

//forwarding
	wire [1:0]	forward_a_sel, forward_b_sel; 
	wire [31:0]	forward_a_data, forward_b_data; 

	wire 		forward_rs1_sel, forward_rs2_sel;
	wire [31:0] forward_rs1_data, forward_rs2_data;
	
//--------------------------------------------------------------IF
	assign IF_mispred = 1'b1;
	
	pc PC(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_en_pc(pc_hazard_en),
	.i_pc_next(pc_next),
	.o_pc(pc)
	);
	
	PC_plus_4 PC_four(
	.i_pc(pc),
	.o_pc_next(pc_four)
	);
/*	
	mux2_1 PC_select(
	.sel(brc_taken),
	.i_data_0(pc_four),
	.i_data_1(alu_data),
	.o_data(pc_next)
	);
*/
	branch_prediction predict(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_IF_pc(pc),
	.i_ID_pc(ID_pc),
	.i_EX_pc(EX_pc),
	.i_EX_pc_four(EX_pc_four),
	
	.i_alu_data(alu_data),
	
	.i_IF_inst(instruction),
	.i_EX_inst(EX_inst),
	
	.i_brc_taken(brc_taken),
	
	.o_flush(pred_flush),
	.o_next_pc(pc_next)
	);

	inst_mem imem(
	.i_pc_addr(pc),
	.o_inst(instruction)
	);
//--------------------------------------------------------------IF_ID
	
	IF_ID IF_ID_m(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_flush(pred_flush), //brc_taken
	.i_stall(ID_IF_hazard_stall),
	
	.i_IF_mispred(IF_mispred),
	.i_IF_pc_four(pc_four),
	.i_IF_pc(pc),
	.i_IF_inst(instruction),
	
	.o_ID_mispred(ID_mispred),
	.o_ID_pc_four(ID_pc_four),
	.o_ID_pc(ID_pc),
	.o_ID_inst(ID_inst)
	);
	
//--------------------------------------------------------------ID	
	
	control_unit_pipeline ctrl(
	.i_inst(ID_inst),
	.o_rd_wren(rd_wren),
	.o_insn_vld(insn_vld),
	.o_br_un(br_un),
	.o_opa_sel(opa_sel),
	.o_opb_sel(opb_sel),
	.o_mem_wren(mem_wren),
	.o_mem_rden(),
	.o_rs1_en(rs1_en), 
	.o_rs2_en(rs2_en),
	.o_alu_op(alu_op),
	.o_wb_sel(wb_sel)
	);
	
	regfile reg_file(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_rd_wren(WB_rd_wren),
	.i_rs1_addr(rs1_addr),
	.i_rs2_addr(rs2_addr),
	.i_rd_addr(rd_addr),
	.i_rd_data(wb_data),
	.o_rs1_data(rs1_data),//change
	.o_rs2_data(rs2_data) //change
	);
	
	mux2_1 forward_rs1(
	.sel(forward_rs1_sel),
	.i_data_0(rs1_data),
	.i_data_1(wb_data),
	.o_data(forward_rs1_data)
	);

	mux2_1 forward_rs2(
	.sel(forward_rs2_sel),
	.i_data_0(rs2_data),
	.i_data_1(wb_data),
	.o_data(forward_rs2_data)
	);

	immgen immediate(
	.i_inst(ID_inst),
	.o_imm(immgen_data)
	);

//--------------------------------------------------------------ID_EX
	
	ID_EX ID_EX_m(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_flush(ID_EX_flush),
	
	//IF-ID-EX
	.i_ID_pc_four(ID_pc_four),
	.i_ID_pc(ID_pc),	
	.i_ID_inst(ID_inst),	//use it's func3 to control LSU at MEM, rd_addr to regfile
	.i_ID_mispred(ID_mispred),
	
	.o_EX_pc_four(EX_pc_four),
	.o_EX_pc(EX_pc),  
	.o_EX_inst(EX_inst),	//use it's func3 to control LSU at MEM, rd_addr to regfile
	.o_EX_mispred(EX_mispred),
	
	//ID-EX immediate generation
	.i_ID_imm_data(immgen_data),
	.o_EX_imm_data(EX_imm_data),

	//ID-EX regfile
	.i_ID_rs1_data(forward_rs1_data),
	.i_ID_rs2_data(forward_rs2_data),
	
	.o_EX_rs1_data(EX_rs1_data),
	.o_EX_rs2_data(EX_rs2_data),
	
	//ID-EX control unit
		//note design again Control Unit (remove br_less and br_equal and pc_sel) and BRC (move BRC from ID to EX, use instruction)  
	.i_ID_rd_wren(rd_wren), 	//return to regfile at WB stage
	.i_ID_opa_sel(opa_sel),
	.i_ID_opb_sel(opb_sel),
	.i_ID_mem_wren(mem_wren),	//lsu control
	//.i_ID_mem_rden(mem_rden,	//lsu control (available if use sram)
	.i_ID_alu_op(alu_op),
	.i_ID_br_un(br_un),
	.i_ID_wb_sel(wb_sel),
	.i_ID_insn_vld(insn_vld),
	 
	.o_EX_rd_wren(EX_rd_wren), 	//return to regfile at WB stage
	.o_EX_opa_sel(EX_opa_sel),
	.o_EX_opb_sel(EX_opb_sel),
	.o_EX_mem_wren(EX_mem_wren),	//lsu control
	//output logic		  o_EX_mem_rden,	//lsu control (available if use sram)
	.o_EX_alu_op(EX_alu_op),
	.o_EX_br_un(EX_br_un),
	.o_EX_wb_sel(EX_wb_sel),
	.o_EX_insn_vld(EX_insn_vld)
	);
	
//--------------------------------------------------------------EX	
	
	mux4_1 forward_a(
	.sel(forward_a_sel),
	.i_data_0(EX_rs1_data),
	.i_data_1(wb_data),
	.i_data_2(MEM_alu_data),
	.i_data_3(32'b0),
	.o_data(forward_a_data)
	);

	mux4_1 forward_b(
	.sel(forward_b_sel),
	.i_data_0(EX_rs2_data),
	.i_data_1(wb_data),
	.i_data_2(MEM_alu_data),
	.i_data_3(32'b0),
	.o_data(forward_b_data)
	);

	brc branch(
	.i_br_un(EX_br_un),
	.i_rs1_data(forward_a_data),
	.i_rs2_data(forward_b_data),
	.o_br_less(br_less),
	.o_br_equal(br_equal)
	);
	
	brc_taken_n_forwarding brc_taken_unit(
	.i_inst(EX_inst),
	.i_br_less(br_less),
	.i_br_equal(br_equal),
	.brc_taken(brc_taken) //pc_sel, flush_IF_ID, flush_ID_EX_taken | hazard detection
	);

	mux2_1 OPA_sel(
	.sel(EX_opa_sel),
	.i_data_0(forward_a_data),
	.i_data_1(EX_pc),
	.o_data(operand_a)
	);
	
	mux2_1 OPB_sel(
	.sel(EX_opb_sel),
	.i_data_0(forward_b_data),
	.i_data_1(EX_imm_data),
	.o_data(operand_b)
	);
	
	alu arith_logic(
	.i_operand_a(operand_a),
	.i_operand_b(operand_b),
	.i_alu_op(EX_alu_op),
	.o_alu_data(alu_data)
	);

//--------------------------------------------------------------EX_MEM
	
	EX_MEM EX_MEM_m(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	
	//IF-ID-EX-MEM
	.i_EX_pc(EX_pc),			//pc_debug
	.i_EX_pc_four(EX_pc_four),	//WB
	.i_EX_inst(EX_inst),		//func3, rd_addr
	.i_EX_mispred(EX_mispred),
	
	.o_MEM_pc(MEM_pc),
	.o_MEM_pc_four(MEM_pc_four),
	.o_MEM_inst(MEM_inst),
	.o_MEM_mispred(MEM_mispred),
	
	//LSU
	.i_EX_alu_data(alu_data),	//LSU address
	.i_EX_rs2_data(forward_b_data),	//LSU store data
	
	.o_MEM_alu_data(MEM_alu_data),	
	.o_MEM_rs2_data(MEM_forward_b_data),	
	
	//Control unit
	.i_EX_mem_wren(EX_mem_wren),
	.i_EX_rd_wren(EX_rd_wren),
	.i_EX_wb_sel(EX_wb_sel),
	.i_EX_insn_vld(EX_insn_vld),
	
	.o_MEM_mem_wren(MEM_mem_wren),
	.o_MEM_rd_wren(MEM_rd_wren),
	.o_MEM_wb_sel(MEM_wb_sel),
	.o_MEM_insn_vld(MEM_insn_vld)
	
);
//--------------------------------------------------------------MEM
	

	lsu load_store_unit(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_lsu_addr(MEM_alu_data),
	.i_st_data(MEM_forward_b_data),
	.i_lsu_wren(MEM_mem_wren),
	//.i_lsu_rden(mem_rden),
	.i_control(MEM_func3),
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
	);

//--------------------------------------------------------------MEM_WB

	MEM_WB MEM_WB_m(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	
	//IF-ID-EX-MEM
	.i_MEM_pc(MEM_pc),			//pc_debug
	.i_MEM_pc_four(MEM_pc_four),	//WB
	.i_MEM_inst(MEM_inst),		//rd_addr
	.i_MEM_mispred(MEM_mispred),
	
	.o_WB_pc(WB_pc),
	.o_WB_pc_four(WB_pc_four),
	.o_WB_inst(WB_inst),
	.o_WB_mispred(WB_mispred),

	.i_MEM_alu_data(MEM_alu_data),
	.i_MEM_ld_data(ld_data),
	
	.o_WB_alu_data(WB_alu_data),
	.o_WB_ld_data(WB_ld_data),
	
	.i_MEM_rd_wren(MEM_rd_wren),
	.i_MEM_wb_sel(MEM_wb_sel),
	.i_MEM_insn_vld(MEM_insn_vld),
	
	.o_WB_rd_wren(WB_rd_wren),
	.o_WB_wb_sel(WB_wb_sel),
	.o_WB_insn_vld(WB_insn_vld)
	);
//--------------------------------------------------------------WB
	mux4_1 WB_sel(
	.sel(WB_wb_sel),
	.i_data_0(WB_pc_four),
	.i_data_1(WB_alu_data),
	.i_data_2(WB_ld_data),
	.i_data_3(32'b0),
	.o_data(wb_data)
	);
	
	assign rd_addr  = WB_inst[11:7];
//--------------------------------------------------------------hazard_detect

	hazard_detect hazard_detect_unit(
	.i_EX_inst(EX_inst),   //rd
	.i_EX_rd_wren(EX_rd_wren),
	
	.i_ID_inst(ID_inst),
	.i_rs1_en(rs1_en),		//ID stage
	.i_rs2_en(rs2_en),		//ID stage
	
	.i_WB_inst(WB_inst),
	.i_WB_rd_wren(WB_rd_wren),

	.o_pc_en(pc_hazard_en),
	.o_IF_ID_stall(ID_IF_hazard_stall),
	.o_ID_EX_flush(ID_EX_hazard_flush)
	);
//--------------------------------------------------------------forwarding
	forwarding_unit forwarding_unit_m(

	.i_ID_inst(ID_inst),
	.i_EX_inst(EX_inst),
	
	.i_MEM_inst(MEM_inst),
	.i_MEM_rd_wren(MEM_rd_wren),
	
	.i_WB_inst(WB_inst),
	.i_WB_rd_wren(WB_rd_wren),
	
	.o_forward_rs1_sel(forward_rs1_sel),
	.o_forward_rs2_sel(forward_rs2_sel),

	.o_forward_a_sel(forward_a_sel),
	.o_forward_b_sel(forward_b_sel)
	);	
//--------------------------------------------------------------
	always_ff @(posedge i_clk) begin
		if(~i_rst_n) begin
			o_insn_vld <= 1'b0;
		end else begin
			o_insn_vld <= WB_insn_vld;
		end
		
		o_pc_debug 	<= WB_pc;
		o_mispred	<= WB_mispred;
	end
	
endmodule 
