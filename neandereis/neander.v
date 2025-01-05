module fsm (clock, reset, op3, op2, op1, op0, selPC, enREM, write, selMEM, opALU, enAC, enPC, display0, display1, state);

    input clock, reset, op3, op2, op1, op0;
    output selPC, enREM, write, selMEM, opALU, enAC, enPC;
    output [2:0] state;
    wire [2:0] next_state;
    output [6:0] display0, display1;

    ccnextstate calcnextstate(.op1(op1), .op0(op0), .state(state), .next_state(next_state));

    reg3 regstate(.d(next_state), .clk(clock), .rst(reset), .q(state));

    ccout calcout(.state(state), .op3(op3), .op2(op2), .op1(op1), .op0(op0), .selPC(selPC), .enREM(enREM), .write(write), .selMEM(selMEM), .opALU(opALU), .enAC(enAC), .enPC(enPC));

    wire [3:0] voided;

    wire [3: 0] a;
    assign a[0] = op0;
    assign a[1] = op1;
    assign a[2] = op2;
    assign a[3] = op3;
    ALU alu(.a(a), .opALU(opALU), .enAC(enAC), .s(voided[0]), .cout(voided[1]), .clk(clock), .display0(display0), .display1(display1));
    
endmodule

module ccout (state, op3, op2, op1, op0, selPC, enREM, write, selMEM, opALU, enAC, enPC);
    input [2:0] state;
    input op3, op2, op1, op0;
    output selPC, enREM, write, selMEM, opALU, enAC, enPC;
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

    and (opALU, nstate2, state[1], state[0]); //opALU

    and (enAC, nstate2, state[1]); //enAC


endmodule

module ccnextstate(op1, op0, state, next_state);
    input op1, op0;
    input [2:0] state;
    output [2:0] next_state;

    wire nop1, nstate2, nstate1, nstate0;
    wire sumop, andop;
    not (nop1, op1);
    not (nstate2, state[2]);
    not (nstate1, state[1]);
    not (nstate0, state[0]);
    or (sumop, op1, op0);
    and (andop, op1, op0);

    wire w0; // and ntate2, nstate1, state0
    and (w0, nstate2, nstate1, state[0]);

    wire next0, next0_1;
    and (next0, andop, w0);
    and (next0_1, sumop, nstate2, nstate1, nstate0);
    or (next_state[0], next0, next0_1);

    and (next_state[1], w0, op1);

    and (next_state[2], w0, nop1, op0);
endmodule

module reg3 (d, q, clk, rst);
    input [2:0] d;
    output [2:0] q;
    input clk, rst;
    ffdrse dff2(.d(d[2]), .clk(clk), .rst(rst), .set(1'b0), .enable(1'b1), .q(q[2]));
    ffdrse dff1(.d(d[1]), .clk(clk), .rst(rst), .set(1'b0), .enable(1'b1), .q(q[1]));
    ffdrse dff0(.d(d[0]), .clk(clk), .rst(rst), .set(1'b0), .enable(1'b1), .q(q[0]));
endmodule

module reg4 (d, q, clk, rst, en);
    input [3:0] d;
    output [3:0] q;
    input clk, rst, en;
    ffdrse dff3(.d(d[3]), .clk(clk), .rst(rst), .set(1'b0), .enable(en), .q(q[3]));
    ffdrse dff2(.d(d[2]), .clk(clk), .rst(rst), .set(1'b0), .enable(en), .q(q[2]));
    ffdrse dff1(.d(d[1]), .clk(clk), .rst(rst), .set(1'b0), .enable(en), .q(q[1]));
    ffdrse dff0(.d(d[0]), .clk(clk), .rst(rst), .set(1'b0), .enable(en), .q(q[0]));
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

module ALU(a, opALU, s, enAC, cout, clk, display0, display1);
    input [3:0] a;
    input opALU, clk, enAC;
    output [3:0] s;
    output [6:0] display0, display1;
    output cout;
    wire [3:0] bypass;
    wire [3:0] operandA;

    demux demux0(.a(a[0]), .s(opALU), .y0(bypass[0]), .y1(operandA[0]));
    demux demux1(.a(a[1]), .s(opALU), .y0(bypass[1]), .y1(operandA[1]));
    demux demux2(.a(a[2]), .s(opALU), .y0(bypass[2]), .y1(operandA[2]));
    demux demux3(.a(a[3]), .s(opALU), .y0(bypass[3]), .y1(operandA[3]));

    wire [3:0] outacc;

    fourbitadder adder0(.a(operandA), .b(outacc), .cin(1'b0), .s(s), .cout(cout));

    reg4 acc(.d(s), .clk(clk), .rst(1'b0), .en(enAC), .q(outacc));
    
    //mux mux0(.b(outacc[0]), .a(bypass[0]), .s(opALU), .y(s[0]));

    sevensegdecoder disp0(.nibble(s), .dispseg(display0));
    sevensegdecoder disp1(.nibble(outacc), .dispseg(display1));
    
endmodule

module mux(a, b, s, y);
    input a, b, s;
    output y;
    wire nots;
    wire y0, y1;
    not (nots, s);
    and (y0, a, nots);
    and (y1, b, s);
    or (y, y0, y1);
endmodule

module demux(a, s, y0, y1);
    input a, s;
    output y0, y1;
    wire nots;
    not (nots, s);
    and (y0, a, nots);
    and (y1, a, s);
endmodule

module fourbitadder(a, b, cin, s, cout);
    input [3:0] a, b;
    input cin;
    output [3:0] s;
    output cout;
    wire c1, c2, c3;
    fulladder fa0(.a(a[0]), .b(b[0]), .cin(cin), .s(s[0]), .cout(c1));
    fulladder fa1(.a(a[1]), .b(b[1]), .cin(c1), .s(s[1]), .cout(c2));
    fulladder fa2(.a(a[2]), .b(b[2]), .cin(c2), .s(s[2]), .cout(c3));
    fulladder fa3(.a(a[3]), .b(b[3]), .cin(c3), .s(s[3]), .cout(cout));

endmodule

module fulladder(a, b, cin, s, cout);
input a, b, cin;
output s, cout;

wire m1, m2, m3;
xor(m1, a, b);
and(m2, a, b);
xor(s, m1, cin);
and(m3, m1, cin);
or(cout, m3, m2);

endmodule

module sevensegdecoder(nibble, dispseg);
    input [3:0] nibble;
    output [6:0] dispseg;
    assign dispseg = 
        (nibble == 4'b0000) ? 7'b0111111:
        (nibble == 4'b0001) ? 7'b0000110:
        (nibble == 4'b0010) ? 7'b1011011:
        (nibble == 4'b0011) ? 7'b1001111:
        (nibble == 4'b0100) ? 7'b1100110:
        (nibble == 4'b0101) ? 7'b1101101:
        (nibble == 4'b0110) ? 7'b1111101:
        (nibble == 4'b0111) ? 7'b0000111:
        (nibble == 4'b1000) ? 7'b1111111:
        (nibble == 4'b1001) ? 7'b1100111:
        (nibble == 4'b1010) ? 7'b1110111:
        (nibble == 4'b1011) ? 7'b1111100:
        (nibble == 4'b1100) ? 7'b0111001:
        (nibble == 4'b1101) ? 7'b1011110:
        (nibble == 4'b1110) ? 7'b1111001:
        (nibble == 4'b1111) ? 7'b1110001:
                              7'b0111111;
endmodule