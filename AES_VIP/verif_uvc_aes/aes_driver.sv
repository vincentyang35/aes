`ifndef AES_DRIVER_SV
`define AES_DRIVER_SV

class aes_driver extends uvm_driver #(aes_tx);

  `uvm_component_utils(aes_driver)

  virtual aes_if vif;

  aes_config m_config;

  extern function new(string name, uvm_component parent);

  extern task run_phase(uvm_phase phase);
  extern task do_drive();

  extern task handle_reset();

endclass : aes_driver


function aes_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


task aes_driver::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "run_phase", UVM_HIGH)
  // Handle first reset
  vif.cb.start <= 'h0;
  vif.cb.din <= 'h0;
  vif.cb.key_in <= 'h0;
  vif.cb.cipher <= 'h0;
  @(vif.cb iff !(vif.cb.arst));

  forever
  begin
    seq_item_port.get_next_item(req);
    `uvm_info(get_type_name(), {"req item\n",req.sprint}, UVM_HIGH)
    do_drive();
    seq_item_port.item_done();
  end
endtask : run_phase


task aes_driver::do_drive();

  // Fork with join_any:
  // If any of these task finish, end of do_drive
  fork : din_and_reset
    // Task 1
      // 1. Wait delay
      // 2. Drive data to interface
      // 3. Wait that the DUT finish its AES encryption/decryption
      // 4. Set data to 0
    begin
      repeat(req.m_delay) @(vif.cb);
      vif.cb.start <= 1'b1;
      vif.cb.din <= req.m_din;
      vif.cb.key_in <= req.m_key_in;
      vif.cb.cipher <= req.m_cipher;
      @(vif.cb iff vif.cb.finish);
      vif.cb.start <= 'h0;
      vif.cb.din <= 'h0;
      vif.cb.key_in <= 'h0;
      vif.cb.cipher <= 'h0;
    end

    // Task 2
      // Wait until reset = 1
    begin
      handle_reset();
    end
  join_any : din_and_reset

endtask : do_drive

task aes_driver::handle_reset();
  while(!vif.cb.arst) begin
    @(vif.cb);
  end
  vif.cb.start <= 'h0;
  vif.cb.din <= 'h0;
  vif.cb.key_in <= 'h0;
  vif.cb.cipher <= 'h0;
endtask : handle_reset


`endif // AES_DRIVER_SV
