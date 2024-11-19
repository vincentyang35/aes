module aes_tb;

  timeunit 1ns; timeprecision 1ps;

  `include "uvm_macros.svh"

  import uvm_pkg::*;

  import aes_test_pkg::*;
  import aes_pkg::aes_config;

  // Configuration object for aes-level environment
  aes_config m_config;

  // Test harness
  aes_th th ();

  initial begin
    m_config = new("m_config");
    m_config.is_active = UVM_ACTIVE;
    m_config.checks_enable = 1;
    m_config.coverage_enable = $test$plusargs("coverage_enable") ? 1 : 0;

    m_config.vif = th.aes_if;
    uvm_config_db#(aes_config)::set(null, "uvm_test_top", "config", m_config);
    uvm_config_db#(aes_config)::set(null, "uvm_test_top.m_env", "config", m_config);

    $timeformat(-9, 1, "ns", 10);
    run_test();
  end

endmodule
