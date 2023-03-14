module And(a, b, result);

input wire a;
input wire b;

output reg result;

always @* begin

    result <= a & b;
end

endmodule
