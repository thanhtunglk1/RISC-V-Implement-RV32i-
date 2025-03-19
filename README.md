# RISC-V-Implement-RV32i-
RISC-V Singlecycle, Pipeline

This is an simple implementation about processor with RISC-V architecture (ISA RV32I)

Include:
- 2 model SingleCycle:
  - Create data memory by logic elements
  - Using SRAM (IS61WV25616) as data memory (Contains a IP sram_IS61WV25616_controller_32b_5lr)
- 5 model Pipeline:
  - Non_forwarding/Always_not_taken (Static_prediction)
  - Forwarding/Always_not_taken (Static_prediction)
  - Forwarding/Always_taken (Static_prediction)
  - Forwarding/2_bit_prediction (Dynamic_prediction)
  - Forwarding/Gshare (Dynamic_prediction)
  - Forwarding/Local (Dynamic_prediction)
  - Tournament_prediction (update soon ~~)
