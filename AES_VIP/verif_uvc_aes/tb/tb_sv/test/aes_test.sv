`ifndef AES_TEST_SV
`define AES_TEST_SV

class aes_test extends uvm_test;

  `uvm_component_utils(aes_test)

  aes_env m_env;

  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);


endclass : aes_test


function aes_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void aes_test::build_phase(uvm_phase phase);

  // you can modify any test-specific configuration object variables here,
  // or override the default sequence

  m_env = aes_env::type_id::create("m_env", this);
endfunction : build_phase


task aes_test::run_phase(uvm_phase phase);
  aes_top_default_seq vseq;
  vseq = aes_top_default_seq::type_id::create("vseq");
  vseq.set_item_context(null, null);
  if ( !vseq.randomize() )
    `uvm_fatal(get_type_name(), "Failed to randomize virtual sequence")
  vseq.m_aes_agent = m_env.m_aes_agent;
  vseq.m_config = m_env.m_aes_agent.m_config;
  vseq.set_starting_phase(phase);
  vseq.start(null);
endtask : run_phase


`endif // AES_TEST_SV
