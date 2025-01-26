module pc_hold(
  input logic [4:0]  i_opcode,  // inst[6:2]
  input logic [31:0] i_address, // alu_data
  input logic        i_ack,   // sram_control
  output logic       o_pc_en // control pc_next or halt
);

  localparam [4:0] I_LOAD = 5'b00000,
						 S_TYPE = 5'b01000;

  logic halt;
  assign halt = ((i_opcode == I_LOAD) || (i_opcode == S_TYPE)) && ((i_address[15:12] == 4'h2) || (i_address[15:12] == 4'h3));
  
  always_comb begin: proc_ctrl_pc
    if(halt) o_pc_en = i_ack;
	 else o_pc_en = 1'b1; // always allow
  end

endmodule 