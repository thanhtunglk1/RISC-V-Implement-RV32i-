module brc_taken_n_forwarding(

	input  logic [31:0] i_inst,
	input  logic 		  i_br_less,
	input  logic  		  i_br_equal,
	output logic		  brc_taken

);

	//opcode
	localparam [4:0]	B_TYPE = 5'b11000,
							JAL    = 5'b11011,
							JALR   = 5'b11001;
					
	//func3 branch					 
	localparam [2:0]	BEQ  = 3'b000,
							BNE  = 3'b001,
							BLT  = 3'b100,
							BGE  = 3'b101,
							BLTU = 3'b110,
							BGEU = 3'b111;
	
	//brc_taken
	localparam 			pc_four     = 1'b0,
							pc_plus_imm = 1'b1;
	
	always_comb begin: proc_decoder_o_pc
		
		if(i_inst[6:2] == B_TYPE) begin //opcode
		
			case(i_inst[14:12]) //func3
				BEQ  : brc_taken   = i_br_equal;
				
				BNE  : brc_taken   = ~i_br_equal;
	 
				BLT  : brc_taken   = i_br_less;

				BGE  : brc_taken   = ~i_br_less;
	 
				BLTU : brc_taken   = i_br_less;

				BGEU : brc_taken   = ~i_br_less;

				default: brc_taken   = pc_four;
			endcase
		
		end else if((i_inst[6:2] == JAL) || (i_inst[6:2] == JALR)) brc_taken = pc_plus_imm;
		
		else brc_taken = pc_four;
		
	end		  
			  
endmodule 










