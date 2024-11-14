`ifndef AES_TEST_SV
`define AES_TEST_SV

class aes_test_base extends uvm_test;

  `uvm_component_utils(aes_test_base)

  aes_env m_env;
  bit m_test_is_finished = 1'b0;
  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
  extern function void print_test_result(string msg);


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
  if ( !vseq.randomize() )
    `uvm_fatal(get_type_name(), "Failed to randomize virtual sequence")
  vseq.m_aes_agent = m_env.m_aes_agent;
  vseq.m_config = m_env.m_aes_agent.m_config;
  vseq.set_starting_phase(phase);
  vseq.start(null);
  m_test_is_finished = 1'b1;
endtask : run_phase

function void aes_test_base::report_phase(uvm_phase phase);

  if(m_test_is_finished) begin
    print_test_result("TEST PASSED");
  end
  else begin
    print_test_result("TEST WAS NOT FINISHED");
  end

endfunction : report_phase

function void aes_test_base::print_test_result(string msg);
  `uvm_info(get_type_name(), $sformatf({"\n**********************************",
                                        "\n         %s",
                                        "\n**********************************"},msg), UVM_LOW)
endfunction


`endif // AES_TEST_SV
