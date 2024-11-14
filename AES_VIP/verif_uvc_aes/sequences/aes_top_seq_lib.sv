`ifndef AES_TOP_SEQ_LIB_SV
`define AES_TOP_SEQ_LIB_SV

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class: aes_top_default_seq
//
// Top basic sequence that randomizes a sequence item.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class aes_top_default_seq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(aes_top_default_seq)

  aes_config m_config;

  aes_agent m_aes_agent;

  int m_seq_count = 1000;

  extern function new(string name = "");
  extern task body();
  extern task pre_start();
  extern task post_start();

endclass : aes_top_default_seq


function aes_top_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task aes_top_default_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)

  repeat (m_seq_count)
  begin
    fork
      if (m_aes_agent.m_config.is_active == UVM_ACTIVE)
      begin
        aes_default_seq seq;
        seq = aes_default_seq::type_id::create("seq");
        seq.set_item_context(this, m_aes_agent.m_sequencer);
        if ( !seq.randomize() )
          `uvm_error(get_type_name(), "Failed to randomize sequence")
        seq.m_config = m_aes_agent.m_config;
        seq.set_starting_phase( get_starting_phase() );
        seq.start(m_aes_agent.m_sequencer, this);
      end
    join
  end

  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body


task aes_top_default_seq::pre_start();
  uvm_phase phase = get_starting_phase();
  if (phase != null)
    phase.raise_objection(this);
endtask: pre_start


task aes_top_default_seq::post_start();
  uvm_phase phase = get_starting_phase();
  if (phase != null)
    phase.drop_objection(this);
endtask: post_start

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class: aes_top_cipher_seq
//
// Top cipher sequence that randomizes a sequence item with cipher = 1.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class aes_top_cipher_seq extends aes_top_default_seq;

  `uvm_object_utils(aes_top_cipher_seq)

  extern function new(string name = "");
  extern task body();

endclass : aes_top_cipher_seq


function aes_top_cipher_seq::new(string name = "");
  super.new(name);
endfunction : new


task aes_top_cipher_seq::body();
  `uvm_info(get_type_name(), "Top cipher sequence starting", UVM_HIGH)

  repeat (m_seq_count)
  begin
    fork
      if (m_aes_agent.m_config.is_active == UVM_ACTIVE)
      begin
        aes_cipher_seq seq;
        seq = aes_cipher_seq::type_id::create("seq");
        seq.set_item_context(this, m_aes_agent.m_sequencer);
        if ( !seq.randomize() )
          `uvm_error(get_type_name(), "Failed to randomize sequence")
        seq.m_config = m_aes_agent.m_config;
        seq.set_starting_phase( get_starting_phase() );
        seq.start(m_aes_agent.m_sequencer, this);
      end
    join
  end

  `uvm_info(get_type_name(), "Top cipher sequence completed", UVM_HIGH)
endtask : body

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class: aes_top_decipher_seq
//
// Top decipher sequence that randomizes a sequence item with cipher = 1.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class aes_top_decipher_seq extends aes_top_default_seq;

  `uvm_object_utils(aes_top_decipher_seq)

  extern function new(string name = "");
  extern task body();

endclass : aes_top_decipher_seq


function aes_top_decipher_seq::new(string name = "");
  super.new(name);
endfunction : new


task aes_top_decipher_seq::body();
  `uvm_info(get_type_name(), "Top decipher sequence starting", UVM_HIGH)

  repeat (m_seq_count)
  begin
    fork
      if (m_aes_agent.m_config.is_active == UVM_ACTIVE)
      begin
        aes_decipher_seq seq;
        seq = aes_decipher_seq::type_id::create("seq");
        seq.set_item_context(this, m_aes_agent.m_sequencer);
        if ( !seq.randomize() )
          `uvm_error(get_type_name(), "Failed to randomize sequence")
        seq.m_config = m_aes_agent.m_config;
        seq.set_starting_phase( get_starting_phase() );
        seq.start(m_aes_agent.m_sequencer, this);
      end
    join
  end

  `uvm_info(get_type_name(), "Top decipher sequence completed", UVM_HIGH)
endtask : body



`endif // AES_TOP_SEQ_LIB_SV
