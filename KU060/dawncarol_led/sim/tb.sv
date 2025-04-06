

module tb();
// 1. Declare the inputs and outputs
  logic              sys_clk_p;
  logic              sys_clk_n;
  logic              resetn;
  logic              fan;
  logic        [3:0] led;

  initial begin
      sys_clk_p = 1'b0;
      sys_clk_n = 1'b0;
      forever begin
          #5 sys_clk_p = ~sys_clk_p;
          #5 sys_clk_n = ~sys_clk_n;
      end
  end

  initial begin
      resetn = 1'b0;
      #1000 resetn = 1'b1;
  end

   dawncarol_led #(
       .DAWNCAROL_CNT(32'd4)
   ) u_dawncarol_led (
       .sys_clk_p  (sys_clk_p),
       .sys_clk_n  (sys_clk_n),
       .resetn     (resetn   ),
       .fan        (fan      ),
       .led        (led      )
   );

  initial
    begin
      $display( "Dumping to dump.fsdb" );
      $fsdbDumpfile( "dump.fsdb" );
      $fsdbDumpvars(0, tb, "+all");
        $fsdbDumpvars("+all" );
      $fsdbDumpon;
    end


  initial
    begin
      #1000000;
      $display( "Simulation finished" );
      $finish;
    end




endmodule