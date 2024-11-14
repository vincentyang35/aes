`ifndef AES_MONITOR_SV
`define AES_MONITOR_SV

class aes_monitor extends uvm_monitor;

  `uvm_component_utils(aes_monitor)

  virtual aes_if vif;

  aes_config m_config;

  uvm_analysis_port #(aes_tx) analysis_port;

  aes_tx m_trans;
  aes_tx m_trans_cloned;
  
  extern function new(string name, uvm_component parent);

  extern task run_phase(uvm_phase phase);
  extern task do_mon();

endclass : aes_monitor


function aes_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


task aes_monitor::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "run_phase", UVM_HIGH)
  m_trans = aes_tx::type_id::create("m_trans");
  do_mon();
endtask : run_phase


task aes_monitor::do_mon();
  forever begin
    // Get data when DUT has completed its encryption/decryption
    @(vif.cb iff (vif.cb.finish && !vif.cb.rst))
    m_trans.m_din = vif.cb.din;
    m_trans.m_key_in = vif.cb.key_in;
    m_trans.m_cipher = vif.cb.cipher;
    m_trans.m_dout = vif.cb.dout;

    // Clone item
    $cast(m_trans_cloned, m_trans.clone());

    // Write analysis report
    analysis_port.write(m_trans_cloned);
  end
endtask : do_mon


`endif // AES_MONITOR_SV
