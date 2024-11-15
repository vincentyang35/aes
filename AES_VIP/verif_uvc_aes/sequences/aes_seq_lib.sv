`ifndef AES_SEQ_LIB_SV
`define AES_SEQ_LIB_SV

class aes_default_seq extends uvm_sequence #(aes_tx);

  `uvm_object_utils(aes_default_seq)
  rand bit[127:0] m_din_s;
  rand bit[127:0] m_key_in_s;
  rand bit m_cipher_s;

  aes_config  m_config;

  /*
  constraint m_din_c {
    m_din_s == 128'hf5819905b1bc51d64d2475b775df355c;
  }

  constraint m_key_in_c {
    m_key_in_s == 128'h8686315fb937a005e079b9e0e45da722;
  }

  constraint m_cipher_c {
    m_cipher_s == 1'b1;
  }
  */

  extern function new(string name = "");
  extern task body();

endclass : aes_default_seq


function aes_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task aes_default_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)
  `uvm_do_with (req, {m_din == m_din_s; m_key_in == m_key_in_s; m_cipher == m_cipher_s;})
  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body

`endif // AES_SEQ_LIB_SV
