`ifndef AES_SEQ_ITEM_SV
`define AES_SEQ_ITEM_SV

class aes_tx extends uvm_sequence_item;

  `uvm_object_utils(aes_tx)

  // transaction variables
  rand bit [127:0] m_din;
  rand bit [127:0] m_key_in;
  rand bit [127:0] m_dout;
  rand bit m_cipher;
  rand int m_delay;

  // Constraint to set delay between 1 and 100 clk
  constraint max_delay_rate_c {
    m_delay inside {[1:100]};
  }

  extern function new(string name = "");
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

endclass : aes_tx


function aes_tx::new(string name = "");
  super.new(name);
endfunction : new


function void aes_tx::do_copy(uvm_object rhs);
  aes_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  m_din = rhs_.m_din;
  m_dout = rhs_.m_dout;
  m_key_in = rhs_.m_key_in;
  m_cipher = rhs_.m_cipher;
endfunction : do_copy


function bit aes_tx::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  aes_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("m_din", m_din, rhs_.m_din, $bits(m_din));
  result &= comparer.compare_field("m_dout", m_dout, rhs_.m_dout, $bits(m_dout));
  result &= comparer.compare_field("m_key_in", m_key_in, rhs_.m_key_in, $bits(m_key_in));
  result &= comparer.compare_field("m_cipher", m_cipher, rhs_.m_cipher, $bits(m_cipher));
  return result;
endfunction : do_compare


function void aes_tx::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void aes_tx::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  `uvm_record_field("m_din", m_din)
  `uvm_record_field("m_dout", m_dout)
  `uvm_record_field("m_key_in", m_key_in)
  `uvm_record_field("m_cipher", m_cipher)
endfunction : do_record


function void aes_tx::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(m_din)
  `uvm_pack_int(m_dout)
  `uvm_pack_int(m_key_in)
  `uvm_pack_int(m_cipher)
endfunction : do_pack


function void aes_tx::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(m_din)
  `uvm_unpack_int(m_dout)
  `uvm_unpack_int(m_key_in)
  `uvm_unpack_int(m_cipher)
endfunction : do_unpack


function string aes_tx::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "m_din = 'h%0h  'd%0d\n",
    "m_dout = 'h%0h  'd%0d\n",
    "m_key_in = 'h%0h  'd%0d\n",
    "m_cipher = 'h%0h  'd%0d\n"},
    get_full_name(), m_din, m_din, m_dout, m_dout, m_key_in, m_key_in, m_cipher, m_cipher);
  return s;
endfunction : convert2string


`endif // AES_SEQ_ITEM_SV
