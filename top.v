`include "adder.v"
`include "alu.v"
`include "dmem.v"
`include "imem.v"
`include "mux.v"
`include "pc.v"
`include "regfile.v"
`include "signextend.v"
`include "sll2.v"
`include "control.v"
`include "alucontrol.v"
`include "and.v"
`include "register.v"
`include "hazardDetection.v"

module Top(clk);

input wire clk;
wire reg_dst;
wire reg_write;
wire alu_src;
wire [1:0] alu_op;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire pc_src;
wire jump;
wire branch;

wire zero;

//Wires for pipeline registers
wire [31:0] pc_next_fd;
wire [31:0] instruction_fd;

wire [31:0] imm_ix;
wire [4:0] rt_ix;
wire [4:0] rd_ix;
wire reg_dst_ix;
wire jump_ix;
wire branch_ix;
wire mem_read_ix;
wire mem_to_reg_ix;
wire [1:0] alu_op_ix;
wire mem_write_ix;
wire reg_write_ix;
wire alu_src_ix;
wire [31:0] pc_next_ix;
wire [31:0] rs_value_ix;
wire [31:0] rt_value_ix;

wire jump_xm;
wire branch_xm;
wire mem_read_xm;
wire mem_to_reg_xm;
wire mem_write_xm;
wire reg_write_xm;
wire [31:0] branch_addr_xm;
wire zero_xm;
wire [31:0] result_xm;
wire [31:0] rt_value_xm;
wire [4:0] write_reg_xm;

wire mem_to_reg_mb;
wire reg_write_mb;
wire [31:0] read_data_mb;
wire [31:0] result_mb;
wire [4:0] write_reg_mb;

wire [31:0] pc_in;
wire [31:0] pc_out;
wire [31:0] instruction;
wire [31:0] pc_next;
wire [4:0] write_reg;
wire [31:0] write_data;
wire [31:0] rs_value;
wire [31:0] rt_value;
wire [31:0] imm;
wire [31:0] simm;
wire [31:0] branch_addr;
wire [31:0] alu_b; //alu operand b
wire [3:0] op;
wire [31:0] alu_result;
wire [31:0] read_data;
wire [31:0] mux_br_out;
wire [31:0] jump_addr32;
wire [27:0] jump_addr;
wire pcwrite;
wire ifidWrite;
wire hazardbit;
wire controlmuxbit;

parameter WIDTH = 32;

PC pc(pcwrite, clk, pc_in, pc_out);
Adder pc_adder(pc_out, 4, pc_next);
Imem imem(pc_out, instruction);

//IF/ID Pipeline Register Implementation
Register reg_fd_1(ifidWrite, clk, pc_next, pc_next_fd);
Register reg_fd_2(ifidWrite, clk, instruction, instruction_fd);


hazardDetection HD(reg_write_ix, reg_write_xm, reg_write_mb, hazardbit, pcwrite, ifidWrite, controlmuxbit, mem_read_ix, reg_dst_ix, rt_ix, rd_ix, instruction_fd[25:21], instruction_fd[20:16], write_reg_xm, write_reg_mb);
Sll2 #(26,28) shift_jump(instruction_fd[25:0], jump_addr);
assign jump_addr32 = {pc_next_fd[31:28], jump_addr[27:0]};
Control control(instruction_fd[31:26], reg_dst, jump, branch, mem_read, mem_to_reg, alu_op, mem_write, alu_src, reg_write);
wire hazardRegDst;
wire hazardJump;
wire hazardBranch;
wire hazardMemRead;
wire hazardMemtoReg;
wire hazardMemWrite;
wire hazardAluSrc;
wire hazardRegWrite;
wire [1:0] hazardAluOp;

Mux #(1) hazard_regdst(controlmuxbit, reg_dst, 1'b0, hazardRegDst);
Mux #(1) hazard_jump(controlmuxbit, jump, 1'b0, hazardJump);
Mux #(1) hazard_branch(controlmuxbit, branch, 1'b0, hazardBranch);
Mux #(1) hazard_mem_read(controlmuxbit, mem_read, 1'b0, hazardMemRead);
Mux #(1) hazard_memtoreg(controlmuxbit, mem_to_reg, 1'b0, hazardMemtoReg);
Mux #(1) hazard_memwrite(controlmuxbit, mem_write, 1'b0, hazardMemWrite);
Mux #(1) hazard_alusrc(controlmuxbit, alu_src, 1'b0, hazardAluSrc);
Mux #(1) hazard_regwrite(controlmuxbit, reg_write, 1'b0, hazardRegWrite);
Mux #(2) hazard_aluop(controlmuxbit, alu_op, 2'b00, hazardAluOp);


RegisterFile regfile(clk, instruction_fd[25:21], instruction_fd[20:16], write_reg_mb, write_data, reg_write_mb, rs_value, rt_value);
SignExtend signextend(instruction_fd[15:0], imm);

// ID/Ex Pipeline register
Register #(1) reg_ix_regDst(1'b1, clk, hazardRegDst, reg_dst_ix);
Register #(1) reg_ix_jump(1'b1, clk, hazardJump, jump_ix);         //jump could be executed immediately but its better to watch for branch
Register #(1) reg_ix_branch(1'b1, clk, hazardBranch, branch_ix);
Register #(1) reg_ix_memRead(1'b1, clk, hazardMemRead, mem_read_ix);
Register #(1) reg_ix_memToReg(1'b1, clk, hazardMemtoReg, mem_to_reg_ix);
Register #(2) reg_ix_aluOp(1'b1, clk, hazardAluOp, alu_op_ix);
Register #(1) reg_ix_memWrite(1'b1, clk, hazardMemWrite, mem_write_ix);
Register #(1) reg_ix_aluSrc(1'b1, clk, hazardAluSrc, alu_src_ix);
Register #(1) reg_ix_regWrite(1'b1, clk, hazardRegWrite, reg_write_ix);

Register reg_ix_pc(1'b1, clk, pc_next_fd, pc_next_ix);

Register reg_ix_readData1(1'b1, clk, rs_value, rs_value_ix);
Register reg_ix_readData2(1'b1, clk, rt_value, rt_value_ix);

wire[4:0] rs_ix;
Register reg_ix_imm(1'b1, clk, imm, imm_ix);
Register #(5) reg_ix_rs(1'b1, clk, instruction_fd[25:21], rs_ix);
Register #(5) reg_ix_rt(1'b1, clk, instruction_fd[20:16], rt_ix);
Register #(5) reg_ix_rd(1'b1, clk, instruction_fd[15:11], rd_ix);


Mux #(5) mux_reg(reg_dst_ix, rt_ix, rd_ix, write_reg);
Adder branch_adder(pc_next_ix, simm, branch_addr);
Sll2 shift_branch(imm_ix, simm);

AluControl alu_control(alu_op_ix, imm_ix[5:0], op);
Mux mux_alu(alu_src_ix, rt_value_ix, imm_ix, alu_b);
Alu alu(op, rs_value_ix, alu_b, alu_result, zero);

//EX/Mem pipeline registers
Register #(1) reg_xm_jump(1'b1, clk, jump_ix, jump_xm);
Register #(1) reg_xm_branch(1'b1, clk, branch_ix, branch_xm);
Register #(1) reg_xm_memRead(1'b1, clk, mem_read_ix, mem_read_xm);
Register #(1) reg_xm_memToReg(1'b1, clk, mem_to_reg_ix, mem_to_reg_xm);
Register #(1) reg_xm_memWrite(1'b1, clk, mem_write_ix, mem_write_xm);
Register #(1) reg_xm_regWrite(1'b1, clk, reg_write_ix, reg_write_xm);

Register reg_xm_branchAddr(1'b1, clk, branch_addr, branch_addr_xm);
Register #(1) reg_xm_zero(1'b1, clk, zero, zero_xm);
Register reg_xm_alu(1'b1, clk, alu_result, result_xm);
Register reg_xm_readData2(1'b1, clk, rt_value_ix, rt_value_xm);
Register #(5) reg_xm_writeReg(1'b1, clk, write_reg, write_reg_xm);

And and_branch(branch_xm, zero_xm, pc_src);
Mux mux_branch(pc_src, pc_next, branch_addr_xm, mux_br_out);
Mux mux_jump(jump_xm, mux_br_out,jump_addr32, pc_in);

Dmem dmem(clk, result_xm, rt_value_xm, mem_read_xm, mem_write_xm, read_data);

//Mem/Wb Pipeline register
Register #(1) reg_mw_memToReg(1'b1, clk, mem_to_reg_xm, mem_to_reg_mb);
Register #(1) reg_mw_regWrite(1'b1, clk, reg_write_xm, reg_write_mb);
Register reg_mw_readData(1'b1, clk, read_data, read_data_mb);
Register reg_mw_alu(1'b1, clk, result_xm, result_mb);
Register #(5) reg_mw_writeReg(1'b1, clk, write_reg_xm, write_reg_mb);

Mux mux_mem(mem_to_reg_mb, result_mb, read_data_mb, write_data);


endmodule
