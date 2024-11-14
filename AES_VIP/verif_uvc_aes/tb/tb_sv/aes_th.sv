module aes_th;

  timeunit      1ns;
  timeprecision 1ps;
  import aes_test_pkg::*;
  import aes_pkg::*;

  logic clk = 0;
  logic rst;

  always #10 clk = ~clk;

  initial
  begin
    rst = 1;
    #75 rst = 0;
  end

  wire start;
  wire [127:0] din;
  wire [127:0] key_in;
  wire cipher;
  wire [127:0] dout;
  wire finish;

  aes_if aes_if(
    .clk    (clk),
    .rst    (rst),
    .start  (start),
    .din    (din),
    .key_in (key_in),
    .cipher (cipher),
    .dout   (dut.dout),
    .finish (dut.finish)
  );

  AES128 dut(
    .clk (clk),
    .rst (rst),
    .start (aes_if.start),
    .din (aes_if.din),
    .key_in (aes_if.key_in),
    .cipher (aes_if.cipher),
    .dout (dout),
    .finish (finish)
  );
  
endmodule
