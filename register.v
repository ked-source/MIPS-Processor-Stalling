module Register #(parameter WIDTH=32) (IF_ID_write, clk, in, out);

input wire clk;
input wire IF_ID_write;
input wire [WIDTH-1 : 0] in;
output reg [WIDTH-1 : 0] out;

always @(posedge clk) begin
    if(IF_ID_write == 1'b1) begin
        out <= in;
    end
end

initial begin
    out<=0;
end

endmodule
