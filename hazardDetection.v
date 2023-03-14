module hazardDetection(ID_EX_regwrite, EX_MEM_regwrite, MEM_WB_regwrite, HazardBit, PCWrite, IF_ID_write, ControlMuxBit, ID_EX_MemRead, ID_EX_regdst, ID_EX_rt, ID_EX_rd, IF_ID_rs, IF_ID_rt, EX_MEM_rd, MEM_WB_rd);

    input wire [4:0] ID_EX_rt, IF_ID_rs, IF_ID_rt, ID_EX_rd, EX_MEM_rd, MEM_WB_rd;
    input wire ID_EX_MemRead, ID_EX_regdst, ID_EX_regwrite, EX_MEM_regwrite, MEM_WB_regwrite;
    output reg HazardBit, PCWrite, IF_ID_write, ControlMuxBit;
    input wire [9:0] controlbits;

    /*If PC write signal is asserted then the PC increments normally. If it is deasserted it keeps on reading the same instruction over and over - needed for stalling
      If IF/ID write is deasserted, IF/ID register stays the same - used for stalling
    */

    initial begin
        PCWrite = 1'b1;
        IF_ID_write = 1'b1;
        HazardBit = 1'b0;
        ControlMuxBit = 1'b0; 
    end

    always @* begin
        if(((ID_EX_MemRead == 1) && ((ID_EX_rt == IF_ID_rs)||(ID_EX_rt == IF_ID_rt))) && (ID_EX_rt != 5'b00000)) begin      /*used to detect arithmetic operations after load memory instructions*/
            PCWrite <= 1'b0;
            IF_ID_write <= 1'b0;
            HazardBit <= 1'b1;
            ControlMuxBit <= 1'b1;      /*passes dummy signals (all control signals turned to 0) to next stage*/ 
        end else if(((ID_EX_regdst == 0) && ((ID_EX_rt == IF_ID_rs)||(ID_EX_rt == IF_ID_rt))) && (ID_EX_rt != 5'b00000) && (ID_EX_regwrite == 1'b1)) begin 
            PCWrite <= 1'b0;     
            IF_ID_write <= 1'b0;
            HazardBit <= 1'b1;
            ControlMuxBit <= 1'b1;      
        end else if(((ID_EX_regdst == 1) && ((ID_EX_rd == IF_ID_rs)||(ID_EX_rd == IF_ID_rt))) && (ID_EX_rd != 5'b00000) && (ID_EX_regwrite == 1'b1)) begin 
            PCWrite <= 1'b0;     
            IF_ID_write <= 1'b0;
            HazardBit <= 1'b1;
            ControlMuxBit <= 1'b1;      
        end else if(((EX_MEM_rd == IF_ID_rs)||(EX_MEM_rd == IF_ID_rt)) && (EX_MEM_rd != 5'b00000) && (EX_MEM_regwrite == 1'b1)) begin
            PCWrite <= 1'b0;
            IF_ID_write <= 1'b0;
            HazardBit <= 1'b1;
            ControlMuxBit <= 1'b1;
        end else if(((MEM_WB_rd == IF_ID_rs)||(MEM_WB_rd == IF_ID_rt)) && (MEM_WB_rd != 5'b00000) && (MEM_WB_regwrite == 1'b1)) begin
            PCWrite <= 1'b0;
            IF_ID_write <= 1'b0;
            HazardBit <= 1'b1;
            ControlMuxBit <= 1'b1;                 
        end else begin
            PCWrite <= 1'b1;
            IF_ID_write <= 1'b1;
            HazardBit <= 1'b0;
            ControlMuxBit <= 1'b0; 
        end
    end

endmodule