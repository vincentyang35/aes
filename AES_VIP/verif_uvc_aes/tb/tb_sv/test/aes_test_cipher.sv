`ifndef AES_TEST_CIPHER_SV
`define AES_TEST_CIPHER_SV

class aes_test_cipher extends aes_test_base;

  `uvm_component_utils(aes_test_cipher)


  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);


endclass : aes_test_cipher


function aes_test_cipher::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void aes_test_cipher::build_phase(uvm_phase phase);
  set_type_override_by_type(aes_top_default_seq::get_type(), aes_top_cipher_seq::get_type());
  super.build_phase(phase);
endfunction : build_phase


task aes_test_cipher::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("AES Test Cipher Started"), UVM_HIGH)
  super.run_phase(phase);
endtask : run_phase


`endif // AES_TEST_CIPHER_SV
