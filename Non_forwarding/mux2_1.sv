module mux2_1(
  input logic sel,
  input logic [31:0] i_data_0, i_data_1,
  output logic [31:0] o_data
);

  assign o_data = (sel)?i_data_1:i_data_0;

endmodule