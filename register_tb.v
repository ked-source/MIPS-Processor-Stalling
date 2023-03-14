`include "register.v"
`timescale 1ns/1ns

module register_tb();

reg clk;
reg [31:0] in;

wire [31:0] out;

Register register(clk, in, out);
Register #(1) reg2(clk, in[0], outB);

always @* begin
    #5 clk <= !clk;
end

initial begin
    $dumpfile("register.vcd");
    $dumpvars(0, register_tb);

    clk = 0;

    #10;
    in=1;

    #10;
    in=7;

    #10;
    in=6;

    #10;
    in=5;

    #10;
    $finish;

end

endmodule
