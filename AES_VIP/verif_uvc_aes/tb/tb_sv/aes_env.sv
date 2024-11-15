`ifndef AES_ENV_SV
`define AES_ENV_SV

class aes_env extends uvm_env;

  `uvm_component_utils(aes_env)

  extern function new(string name, uvm_component parent);

  aes_scoreboard m_scoreboard;

  aes_config   m_config;
  aes_agent    m_aes_agent;
  aes_coverage m_aes_coverage;

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);

endclass : aes_env


function aes_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void aes_env::build_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In build_phase", UVM_HIGH)


  m_scoreboard = aes_scoreboard::type_id::create("m_scoreboard",this);

  if (!uvm_config_db #(aes_config)::get(this, "", "config", m_config))
    `uvm_fatal(get_type_name(), "Unable to get aes_config")

  uvm_config_db #(aes_config)::set(this, "m_aes_agent", "config", m_config);
  uvm_config_db #(aes_config)::set(this, "m_aes_agent.m_sequencer", "config", m_config);
  uvm_config_db #(aes_config)::set(this, "m_aes_coverage", "config", m_config);

  m_aes_agent = aes_agent::type_id::create("m_aes_agent", this);
  m_aes_coverage = aes_coverage::type_id::create("m_aes_coverage", this);
endfunction : build_phase


function void aes_env::connect_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In connect_phase", UVM_HIGH)

  m_aes_agent.analysis_port.connect(m_aes_coverage.analysis_export);
  m_aes_agent.analysis_port.connect(m_scoreboard.aes_to_scoreboard);
endfunction : connect_phase


function void aes_env::end_of_elaboration_phase(uvm_phase phase);
  uvm_factory factory = uvm_factory::get();
  `uvm_info(get_type_name(), "Information printed from aes_env::end_of_elaboration_phase method",
            UVM_MEDIUM)
  `uvm_info(get_type_name(), $sformatf("Verbosity threshold is %d", get_report_verbosity_level()),
            UVM_MEDIUM)
  uvm_top.print_topology();
  factory.print();
endfunction : end_of_elaboration_phase


`endif // AES_ENV_SV
