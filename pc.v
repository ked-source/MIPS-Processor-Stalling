module PC(PCWrite, clk, in, out);

input wire clk;
input wire [31:0] in;
input wire PCWrite;
output wire [31:0] out;

reg [31:0] pc = 0;


always @(posedge clk) begin
    if(PCWrite == 1'b1) begin
        pc <= in;
    end
end

assign out = pc;

endmodule
