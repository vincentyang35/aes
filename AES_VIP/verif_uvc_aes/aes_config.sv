`ifndef AES_CONFIG_SV
`define AES_CONFIG_SV

class aes_config extends uvm_object;

  // do not register config class with the factory

  virtual aes_if vif;

  uvm_active_passive_enum  is_active = UVM_ACTIVE;
  bit                      coverage_enable;
  bit                      checks_enable;

  extern function new(string name = "");

endclass : aes_config


function aes_config::new(string name = "");
  super.new(name);
endfunction : new


`endif // AES_CONFIG_SV
