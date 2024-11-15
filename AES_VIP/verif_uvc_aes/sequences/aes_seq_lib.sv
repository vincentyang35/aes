`ifndef AES_SEQ_LIB_SV
`define AES_SEQ_LIB_SV
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class: aes_default_seq
//
// Basic sequence that randomizes a sequence item.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class aes_default_seq extends uvm_sequence #(aes_tx);

  `uvm_object_utils(aes_default_seq)
  aes_config  m_config;

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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class: aes_cipher_seq
//
// Cipher sequence that randomizes a sequence item with m_cipher = 1
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class aes_cipher_seq extends uvm_sequence #(aes_tx);

  `uvm_object_utils(aes_cipher_seq)

  aes_config  m_config;

  extern function new(string name = "");
  extern task body();

endclass : aes_cipher_seq


function aes_cipher_seq::new(string name = "");
  super.new(name);
endfunction : new


task aes_cipher_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)
  `uvm_do_with (req, {m_cipher == 1'b1;})
  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class: aes_decipher_seq
//
// Decipher sequence that randomizes a sequence item with m_cipher = 0
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class aes_decipher_seq extends uvm_sequence #(aes_tx);

  `uvm_object_utils(aes_decipher_seq)

  aes_config  m_config;

  extern function new(string name = "");
  extern task body();

endclass : aes_decipher_seq


function aes_decipher_seq::new(string name = "");
  super.new(name);
endfunction : new


task aes_decipher_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)
  `uvm_do_with (req, {m_cipher == 1'b0;})
  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body
`endif // AES_SEQ_LIB_SV
