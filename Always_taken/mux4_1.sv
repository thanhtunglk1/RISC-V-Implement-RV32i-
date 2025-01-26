module mux4_1(
  input logic [1:0] sel,
  input logic [31:0] i_data_0, i_data_1, i_data_2, i_data_3,
  output logic [31:0] o_data
);

  always_comb begin: proc_mux4_1
    case(sel)
      2'h0: o_data = i_data_0;
      2'h1: o_data = i_data_1;
      2'h2: o_data = i_data_2;
      2'h3: o_data = i_data_3;
    endcase
  end

endmodule
