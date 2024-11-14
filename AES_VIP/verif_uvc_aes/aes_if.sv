`ifndef AES_IF_SV
`define AES_IF_SV

interface aes_if(
    input clk,
    input wire arst,
    input wire start,
    input wire [127:0] din,
    input wire [127:0] key_in,
    input wire cipher,
    input wire [127:0] dout,
    input wire finish
  );

  timeunit      1ns;
  timeprecision 1ps;

  import aes_pkg::*;

  clocking cb @(posedge clk);
    inout arst;
    inout start;
    inout din;
    inout key_in;
    inout cipher;
    inout dout;
    inout finish;
  endclocking : cb


endinterface : aes_if

`endif // AES_IF_SV
