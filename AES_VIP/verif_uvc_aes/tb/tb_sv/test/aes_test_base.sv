`ifndef AES_TEST_SV
`define AES_TEST_SV

class aes_test_base extends uvm_test;

  `uvm_component_utils(aes_test_base)

  aes_env m_env;
  bit m_test_is_finished = 1'b0;
  int m_reset_delay;

  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
  extern function void print_test_result(string msg);
  extern task test_arst();

endclass : aes_test_base


function aes_test_base::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void aes_test_base::build_phase(uvm_phase phase);
  m_env = aes_env::type_id::create("m_env", this);
endfunction : build_phase


task aes_test_base::run_phase(uvm_phase phase);
  aes_top_default_seq vseq;
  vseq = aes_top_default_seq::type_id::create("vseq");
  vseq.set_item_context(null, null);
  if (!vseq.randomize()) `uvm_fatal(get_type_name(), "Failed to randomize virtual sequence")
  vseq.m_aes_agent = m_env.m_aes_agent;
  vseq.m_config = m_env.m_aes_agent.m_config;
  vseq.set_starting_phase(phase);
  fork : sequence_start_and_atclken
    begin
      vseq.start(null);
    end
    begin

      test_arst();
    end
  join : sequence_start_and_atclken

  m_test_is_finished = 1'b1;
endtask : run_phase

function void aes_test_base::report_phase(uvm_phase phase);

  if (m_test_is_finished) begin
    print_test_result("TEST PASSED");
  end else begin
    print_test_result("TEST WAS NOT FINISHED");
  end

endfunction : report_phase


task aes_test_base::test_arst();
  int m_num_of_reset = 2;
  m_env.m_aes_agent.m_driver.vif.cb.arst <= 1'b1;
  #(75);
  m_env.m_aes_agent.m_driver.vif.cb.arst <= 1'b0;

  repeat (m_num_of_reset) begin
    if (!randomize(m_reset_delay) with {m_reset_delay inside {[2 : 50]};}) begin
      `uvm_fatal(get_type_name(), "Failed to randomize")
    end

    #(m_reset_delay * 100);
    m_env.m_aes_agent.m_driver.vif.cb.arst <= 1'b1;

    `uvm_info(get_type_name(), $sformatf("RESET TESTED"), UVM_LOW)

    if (!randomize(m_reset_delay) with {m_reset_delay inside {[2 : 50]};}) begin
      `uvm_fatal(get_type_name(), "Failed to randomize")
    end

    #(m_reset_delay * 10);
    m_env.m_aes_agent.m_driver.vif.cb.arst <= 1'b0;

  end
endtask : test_arst

function void aes_test_base::print_test_result(string msg);
  `uvm_info(get_type_name(), $sformatf(
            {
              "\n**********************************",
              "\n         %s",
              "\n**********************************"
            },
            msg
            ), UVM_LOW)
endfunction


`endif  // AES_TEST_SV
