`ifndef AES_SCOREBOARD
`define AES_SCOREBOARD

`uvm_analysis_imp_decl(_from_aes)
import "DPI-C" function int compare_to_c_model(int data_in [4], int key_in[4], int data_out[4], int cipher_phase);

class aes_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(aes_scoreboard)

  uvm_analysis_imp_from_aes #(aes_tx, aes_scoreboard) aes_to_scoreboard;

  aes_config m_config;

  aes_tx m_cloned_pkt;

  int m_nb_of_items = 0;
  int m_nb_of_match = 0;
  int m_nb_of_cipher = 0;
  int m_nb_of_decipher = 0;
  int c_compare = 0;
  int m_data_in[4], m_key_in[4], m_data_out[4], m_phase;

  function new(string name, uvm_component parent);
    super.new(name, parent);

    aes_to_scoreboard = new("aes_to_scoreboard", this);
  endfunction : new


  virtual function void write_from_aes(input aes_tx pkt);
    $cast(m_cloned_pkt, pkt.clone()); 
    m_nb_of_items++;

    // If it's an encryption or decryption 
    if(pkt.m_cipher) begin
      m_nb_of_cipher++;
      `uvm_info(get_type_name(), $sformatf("Data encryption detected : [%d]", m_nb_of_items), UVM_HIGH)
    end
    else begin
      m_nb_of_decipher++;
      `uvm_info(get_type_name(), $sformatf("Data decryption detected : [%d]", m_nb_of_items), UVM_HIGH)
    end
    `uvm_info(get_type_name(), $sformatf("\nDin : %h\nKey_in : %h\nDout : %h", m_cloned_pkt.m_din, m_cloned_pkt.m_key_in, m_cloned_pkt.m_dout), UVM_HIGH)
    
    // 128 bits -> 4x32bits array to easily pass arguments to C model
    {m_data_in[3], m_data_in[2],m_data_in[1], m_data_in[0]} = m_cloned_pkt.m_din;
    {m_key_in[3], m_key_in[2], m_key_in[1], m_key_in[0]} = m_cloned_pkt.m_key_in;
    {m_data_out[3], m_data_out[2], m_data_out[1], m_data_out[0]} = m_cloned_pkt.m_dout;
    m_phase = m_cloned_pkt.m_cipher;

    // C model compare
    c_compare = compare_to_c_model(m_data_in, m_key_in, m_data_out, m_phase);

    // Match or not
    if(c_compare == 1)begin
      m_nb_of_match++;
      `uvm_info(get_type_name(), $sformatf("DUT output and model matched : [%d]", m_nb_of_match), UVM_LOW)
    end
    else begin
      `uvm_error(get_type_name(), $sformatf("Error: DUT output and model mismatched"))
    end

  endfunction: write_from_aes

  // Function: report_phase(uvm_phase phase)
  //
  // UVM Report phase
  virtual function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("\n***************************************************\
                                        \n\tAES VIP Scoreboard Summary\
                                        \n***************************************************\
                                        \n\tTransaction number recap\
                                        \nScoreboard checked %0d AES transactions\
                                        \nScoreboard found %0d matched transactions\
                                        \nCheck score: %3.1f%%\
                                        \n\n\tTransaction features\
                                        \nNumber of cipher done   : %0d\
                                        \nNumber of decipher done : %0d\n",
                                        m_nb_of_items,
                                        m_nb_of_match,
                                        (m_nb_of_match/m_nb_of_items)*100,
                                        m_nb_of_cipher,
                                        m_nb_of_decipher),
                                        UVM_LOW)

endfunction: report_phase


endclass : aes_scoreboard


`endif //  `ifndef AES_SCOREBOARD
