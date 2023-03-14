module Mux
#(parameter WIDTH = 32)
(flag, in1, in2, out);

input wire flag;
input wire [WIDTH-1:0] in1;
input wire [WIDTH-1:0] in2;

output wire [WIDTH-1:0] out;

assign out = flag ? in2 : in1;

endmodule
