module fsm (clock, reset, op3, op2, op1, op0, selPC, enREM, write, selMEM, opULA, enAC, enPC);

    input clock, reset, op3, op2, op1, op0;
    output selPC, enREM, write, selMEM, opULA, enAC, enPC;
    wire [2:0] state;
    wire [2:0] next_state;
    
    ccnextstate calcnextstate(.op1(op1), .op0(op0), .state(state), .next_state(next_state));

    reg3 regstate(.d(next_state), .clk(clock), .rst(reset), .q(state));

    ccout calcout(.state(state), .op3(op3), .op2(op2), .op1(op1), .op0(op0), .selPC(selPC), .enREM(enREM), .write(write), .selMEM(selMEM), .opULA(opULA), .enAC(enAC), .enPC(enPC));
    
endmodule

module ccout (state, op3, op2, op1, op0, selPC, enREM, write, selMEM, opULA, enAC, enPC);
    input [2:0] state;
    input op3, op2, op1, op0;
    output selPC, enREM, write, selMEM, opULA, enAC, enPC;
    wire notstate1notstate0;
    wire nstate2, nstate1, nstate0; 
    not (nstate2, state[2]);
    not (nstate1, state[1]);
    not (nstate0, state[0]);

    nand(enPC, op3, op2, op1, op0); //enPC

    and (notstate1notstate0, nstate1, nstate0); //selPC
    or (selPC, notstate1notstate0, nstate2);

    and (enREM, nstate2, nstate1, state[0]); //enREM

    and (write, state[2], nstate1, nstate0); //write

    and (selMEM, nstate2, nstate1); //selMEM

    and (opULA, nstate2, state[1], state[0]); //opULA

    and (enAC, nstate2, state[1]); //enAC


endmodule

module ccnextstate(op1, op0, state, next_state);
    input op1, op0;
    input [2:0] state;
    output [2:0] next_state;

    wire nop1, nstate2, nstate1, nstate0;
    wire sumop;
    not (nop1, op1);
    not (nstate2, state[2]);
    not (nstate1, state[1]);
    not (nstate0, state[0]);
    or (sumop, op1, op0);

    and (next_state[0], sumop, nstate2, nstate1, nstate0);
    and (next_state[1], nstate2, nstate1, state[0], op1);
    and (next_state[2], nstate2, nstate1, state[0], nop1, op0);
endmodule

module reg3 (d, q, clk, rst);
    input [2:0] d;
    output [2:0] q;
    input clk, rst;
    ffdrse dff2(.d(d[2]), .clk(clk), .rst(rst), .set(1'b0), .enable(1'b1), .q(q[2]));
    ffdrse dff1(.d(d[1]), .clk(clk), .rst(rst), .set(1'b0), .enable(1'b1), .q(q[1]));
    ffdrse dff0(.d(d[0]), .clk(clk), .rst(rst), .set(1'b0), .enable(1'b1), .q(q[0]));
endmodule

module ffdrse(d, clk, rst, set, enable, q);
// Sinais de Controle    
input       d;          // entrada D    
input       clk;        // relógio do sistema (clock)    
input       rst;        // reset, zera saida q    
input       set;        // set, seta a saida para 1    
input       enable;        // habilita o relogio       
output      reg q;        // saida do bit memorizado internamente     
// Bloco de controle do FFD    
always@(posedge clk) 
begin
        if(rst)            q <= 1'b0;   // reseta, ou seja q=0
        else if(set)            q <= 1'b1;   // seta, ou seja q=1
        else if (enable)  // so vai flip-flopear se habilitado
            q <= d;   // flip-flopeia, ou seja copia d para q
    end
endmodule

