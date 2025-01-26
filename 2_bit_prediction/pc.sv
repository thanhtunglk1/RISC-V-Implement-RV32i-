module pc(
  input logic i_clk, i_rst_n, i_en_pc,
  input logic [31:0] i_pc_next,
  output logic [31:0] o_pc
);

  logic [31:0] next_pc, present_pc;

  always_comb begin: proc_en_pc
    next_pc = i_en_pc ? i_pc_next : present_pc; 
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin: proc_pc
    if(i_rst_n == 0) present_pc <= 32'b0;
    else  present_pc <= next_pc;
end

  assign o_pc = present_pc;
  
endmodule 