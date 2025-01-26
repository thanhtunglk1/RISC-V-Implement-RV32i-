module immgen(
input logic [31:0] i_inst,
output logic [31:0] o_imm);
 
localparam //R_TYPE = 5'b01100, //don't care 
	   I_TYPE = 5'b00100,
	   I_LOAD = 5'b00000,
	   S_TYPE = 5'b01000,
	   B_TYPE = 5'b11000,
	   JAL    = 5'b11011,
	   JALR   = 5'b11001,
	   AUIPC  = 5'b00101,
	   LUI    = 5'b01101;

always_comb begin: proc_imm_gen
 case(i_inst[6:2])
  //I type: sign [31:25]
  I_TYPE: o_imm = {{21{i_inst[31]}}, i_inst[30:20]};
  I_LOAD: o_imm = {{21{i_inst[31]}}, i_inst[30:20]};
  JALR  : o_imm = {{21{i_inst[31]}}, i_inst[30:20]};

  S_TYPE: o_imm = {{21{i_inst[31]}}, i_inst[30:25], i_inst[11:7]};

  B_TYPE: o_imm = {{20{i_inst[31]}}, i_inst[7], i_inst[30:25], i_inst[11:8],1'b0};
  JAL   : o_imm = {{12{i_inst[31]}}, i_inst[19:12], i_inst[20], i_inst[30:21],1'b0};

  //shift type: [31:12] << 12
  LUI   : o_imm = {i_inst[31:12], 12'b0};
  AUIPC : o_imm = {i_inst[31:12], 12'b0};
  
  default: o_imm = 32'b0;
 endcase
end

endmodule
