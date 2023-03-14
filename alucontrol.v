module AluControl(alu_op, funct, alu_control);

input wire [1:0] alu_op;
input wire [5:0] funct;

output reg [3:0] alu_control;

//combinational block
always @* begin
  case (alu_op)
    0: begin
        alu_control <= 0; //0 for addition (based on alu implementation)
    end
    1: begin
        alu_control <= 1;
    end
    2: begin
        case(funct)
            6'b100000 : alu_control <= 0; //add
            6'b100010 : alu_control <= 1; //sub
            6'b100100 : alu_control <= 4; //
            6'b100101 : alu_control <= 5;
            default   : alu_control <= 0;  //should not reach this
        endcase
    end
    3: begin
        alu_control <= 0;
    end
  endcase

end


endmodule
