module PC_plus_4(
input logic [31:0] i_pc,
output logic [31:0] o_pc_next
);

assign o_pc_next = i_pc + 4;

endmodule 