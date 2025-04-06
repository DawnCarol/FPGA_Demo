
module dawncarol_led #(
    parameter  [31:0]  DAWNCAROL_CNT    = 32'd49_999_999
)
(
  input  logic           sys_clk_p,
  input  logic           sys_clk_n,
  input  logic           resetn,
  output logic           fan,
  output logic  [3:0]    led
);


  logic  [31:0]  pipe_led_cnt_nxt;
  logic  [31:0]  pipe_led_cnt_q;
  logic          pipe_led_grant; 
  logic  [ 3:0]  led_nxt;

  assign fan = 1'b0; // always off


//  IBUFDS #(
//     .DQS_BIAS("FALSE")  // (FALSE, TRUE)
//  )
//  IBUFDS_inst (
//     .O (clk      ), // 1-bit output: Buffer output
//     .I (sys_clk_p), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
//     .IB(sys_clk_n)  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
//  );

  assign clk = sys_clk_p;




  // update led counter
  always_ff @(posedge clk or negedge resetn) begin:u_gen_led_cnt
    if (!resetn) begin
      pipe_led_cnt_q[31:0] <= {$bits(pipe_led_cnt_q){1'b0}};
    end else begin
      pipe_led_cnt_q[31:0] <= pipe_led_cnt_nxt[31:0];
    end
  end

  // update led counter
  assign pipe_led_cnt_nxt[31:0] = pipe_led_grant ? 32'b0 : (pipe_led_cnt_q[31:0] + 32'b1);
  // update led counter grant signal
  assign pipe_led_grant = (pipe_led_cnt_q[31:0] == DAWNCAROL_CNT) ? 1'b1 : 1'b0;
  // shift led
  // 1st led = 1, 2nd led = 0, 3rd led = 0, 4th led = 0 
  assign led_nxt[3:0] = {led[0],led[3:1]};
  // update led state
  always_ff @(posedge clk or negedge resetn) begin:u_gen_led_flow
    if (!resetn) begin
      led[3:0] <= 4'b0001;
    end else if (pipe_led_grant) begin
      led[3:0] <= led_nxt[3:0];
    end
  end


endmodule

