`ifndef AES_TEST_PKG_SV
`define AES_TEST_PKG_SV

package aes_test_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;
  import aes_pkg::*;

  `include "aes_scoreboard.sv"
  `include "aes_env.sv"
  `include "../../sequences/aes_top_seq_lib.sv"

  // Tests
  `include "test/aes_test_base.sv"
  `include "test/aes_test_cipher.sv"
  `include "test/aes_test_decipher.sv"


endpackage : aes_test_pkg

`endif // AES_TEST_PKG_SV
