`include "top.v"
`timescale 1ns/1ns

module top_tb();

reg clk;

Top top(clk);


always @* begin
    #5 clk <= !clk;
end

initial begin
    $dumpfile("top.vcd");
    $dumpvars(0, top_tb);

    clk=0;
    #170;
    $finish;
end

endmodule
