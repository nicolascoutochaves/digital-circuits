module fsm (clock, reset, selPC, enREM, write, selMEM, opALU, enAC, enPC, display0, display1, display2, display3, state, insw);
    input clock, reset;
    output selPC, enREM, write, selMEM, opALU, enAC, enPC;
    output [2:0] state;
    wire [2:0] next_state;
    output [6:0] display0, display1, display2, display3;
    wire [7:0] wMEM128;
    input [3:0] insw;

    wire z;
    assign z = 1'b0;

    wire [7:0] infsm;
    buf (infsm[4], insw[0]);
    buf (infsm[5], insw[1]);
    buf (infsm[6], insw[2]);
    buf (infsm[7], insw[3]);
    buf (infsm[0], 1'b0);
    buf (infsm[1], 1'b0);
    buf (infsm[2], 1'b0);
    buf (infsm[3], 1'b0);

    wire [7:0] OutMem, Qrem, DregPC, QregPC, EndMem, PCm1, DregAC, QregAC;

    wire [3:0] voided;

    ccnextstate calcnextstate(.memcontent(OutMem) , .state(state), .next_state(next_state));
    reg3 regstate(.d(next_state), .clk(clock), .rst(reset), .q(state), .set(z), .en(1'b1));

    ccout calcout(.state(state), .memcontent(OutMem), .selPC(selPC), .enREM(enREM), .write(write), .selMEM(selMEM), .opALU(opALU), .enAC(enAC), .enPC(enPC));


 

    mux8 AddrMUX(.a(Qrem), .b(QregPC), .s(selMEM), .y(EndMem));
    
    reg8 REM(.d(OutMem), .clk(clock), .rst(reset), .en(enREM), .q(Qrem), .set(z));

    mux8 muxselPC(.a(OutMem), .b(PCm1), .s(selPC), .y(DregPC));
    PC pc(.d(DregPC), .clk(clock), .rst(reset), .en(enPC), .q(QregPC), .set(z));
    eightbitadder addpc(.a(QregPC), .b(8'b00000001), .cin(8'b00000000), .s(PCm1), .cout(voided[0]));

    memoria_pit mem(.write(write), .clk(clock), .rst(reset), .address(EndMem), .din(QregAC), .dout(OutMem), .oMem128(wMEM128));

    sevensegdecoder disp0(.nibble(QregPC[0 +: 4]), .dispseg(display0));
    sevensegdecoder disp1(.nibble(QregAC[0 +: 4]), .dispseg(display1));
    sevensegdecoder disp2(.nibble(OutMem[0 +: 4]), .dispseg(display2));
    sevensegdecoder disp3(.nibble(OutMem[4 +: 4]), .dispseg(display3));

    ALU alu(.b(QregAC), .a(OutMem), .opALU(opALU), .s(DregAC));
    reg8 ACC(.d(DregAC), .clk(clock), .rst(reset), .en(enAC), .q(QregAC), .set(z));
    
endmodule

module ALU(a, b, opALU, s);
    input [7:0] a, b;
    input opALU;
    output [7:0] s;
    wire  [7:0] sum;
    wire voided;
    eightbitadder adder0(.a(a), .b(b), .cin(1'b0), .s(sum), .cout(voided));
    mux8 seloutput(.a(a), .b(sum), .s(opALU), .y(s));
    
endmodule

module PC (d, clk, rst, en, q, set);
    input [7:0] d;
    output [7:0] q;
    input clk, rst, en, set;
    wire [7:0] sum;
    reg8 regpc(.d(d), .clk(clk), .rst(rst), .en(en), .q(q), .set(set));
    
endmodule

module ccout (state, memcontent, selPC, enREM, write, selMEM, opALU, enAC, enPC);
    input [2:0] state;
    input [7:0] memcontent;
    output selPC, enREM, write, selMEM, opALU, enAC, enPC;
    wire op3, op2, op1, op0;
    buf(op3, memcontent[7]);
    buf(op2, memcontent[6]);
    buf(op1, memcontent[5]);
    buf(op0, memcontent[4]);

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

module ccnextstate(memcontent, state, next_state);
    input [7 : 0] memcontent;
    input [2:0] state;
    output [2:0] next_state;

    wire op3, op2, op1, op0;
    buf(op3, memcontent[7]);
    buf(op2, memcontent[6]);
    buf(op1, memcontent[5]);
    buf(op0, memcontent[4]);

    wire next_hlt, and_ops;
    and (and_ops, op3, op2, op1, op0);
    not (next_hlt, and_ops);

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
    and (next0, andop, w0, next_hlt);
    and (next0_1, sumop, nstate2, nstate1, nstate0, next_hlt);

    or (next_state[0], next0, next0_1);

    and (next_state[1], w0, op1, next_hlt);

    and (next_state[2], w0, nop1, op0, next_hlt);
endmodule


module reg3 (d, q, clk, rst, set, en);
    input [2:0] d;
    output [2:0] q;
    input clk, rst, set, en;
    ffdrse dff2(.d(d[2]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[2]));
    ffdrse dff1(.d(d[1]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[1]));
    ffdrse dff0(.d(d[0]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[0]));
endmodule

module reg8(clk, rst, set, en, d, q);
    input clk, rst, en, set;
	 input [7:0] d;
    output reg [7:0] q;

    always@(posedge clk, posedge rst) begin
        if(rst)
            q <= 8'b00000000;
        else if(en)
            q <= d;
        else if(set)
            q <= 8'b11111111;
        else
            q <= q;
    end
endmodule

/* module reg8 (d, q, clk, rst, en, set);
    input [7:0] d;
    output [7:0] q;
    input clk, rst, en, set;
    ffdrse dff7(.d(d[7]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[7]));
    ffdrse dff6(.d(d[6]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[6]));
    ffdrse dff5(.d(d[5]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[5]));
    ffdrse dff4(.d(d[4]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[4]));
    ffdrse dff3(.d(d[3]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[3]));
    ffdrse dff2(.d(d[2]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[2]));
    ffdrse dff1(.d(d[1]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[1]));
    ffdrse dff0(.d(d[0]), .clk(clk), .rst(rst), .set(set), .enable(en), .q(q[0]));
endmodule */



module mux8(a, b, s, y);
    input [7: 0] a, b;
    input s;
    output [7: 0] y;
    mux m0(.a(a[0]), .b(b[0]), .s(s), .y(y[0]));
    mux m1(.a(a[1]), .b(b[1]), .s(s), .y(y[1]));
    mux m2(.a(a[2]), .b(b[2]), .s(s), .y(y[2]));
    mux m3(.a(a[3]), .b(b[3]), .s(s), .y(y[3]));
    mux m4(.a(a[4]), .b(b[4]), .s(s), .y(y[4]));
    mux m5(.a(a[5]), .b(b[5]), .s(s), .y(y[5]));
    mux m6(.a(a[6]), .b(b[6]), .s(s), .y(y[6]));
    mux m7(.a(a[7]), .b(b[7]), .s(s), .y(y[7]));
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

module demux8(a, sel, y0, y1);
    input [7:0] a;
    input sel;
    output [7:0] y0, y1;
    wire notsel;
    not (notsel, sel);
    and (y0, a, notsel);
    and (y1, a, sel);
endmodule

module demux(a, s, y0, y1);
    input a, s;
    output y0, y1;
    wire nots;
    not (nots, s);
    and (y0, a, nots);
    and (y1, a, s);
endmodule

module eightbitadder(a, b, cin, s, cout);
    input [7:0] a, b;
    input cin;
    output [7:0] s;
    output cout;
    wire c1, c2, c3, c4, c5, c6, c7;
    fulladder fand_ops(.a(a[0]), .b(b[0]), .cin(cin), .s(s[0]), .cout(c1));
    fulladder fa1(.a(a[1]), .b(b[1]), .cin(c1), .s(s[1]), .cout(c2));
    fulladder fa2(.a(a[2]), .b(b[2]), .cin(c2), .s(s[2]), .cout(c3));
    fulladder fa3(.a(a[3]), .b(b[3]), .cin(c3), .s(s[3]), .cout(c4));
    fulladder fa4(.a(a[4]), .b(b[4]), .cin(c4), .s(s[4]), .cout(c5));
    fulladder fa5(.a(a[5]), .b(b[5]), .cin(c5), .s(s[5]), .cout(c6));
    fulladder fa6(.a(a[6]), .b(b[6]), .cin(c6), .s(s[6]), .cout(c7));
    fulladder fa7(.a(a[7]), .b(b[7]), .cin(c7), .s(s[7]), .cout(cout));
    

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

module memoria_pit(
    input write,
	 input clk,
	 input rst,
    input [7:0] address,      // 8-bit register input
	 input [7:0] din,
    output  [7:0] dout,
	 output  [7:0] oMem128
	 );   // 8-bit register output

	wire [7:0] saida_rom;
	wire [7:0] saida_ram;
	wire enable;
	wire zero, nrst;
	not (nrst, rst);
	and (zero, nrst, rst);
	and(enable, address[7], write);

    rom_prog_pit rp(.address(address), .content(saida_rom));

    reg8 r(.d(din), .q(saida_ram), .clk(clk), .rst(rst), .en(enable), .set());

    mux8 mux(.a(saida_rom), .b(saida_ram), .s(address[7]), .y(dout));
	//mux21_8b_pit m8b(.e0(saida_rom), .e1(saida_ram), .sel(address[7]), .saida(dout));
	
	assign oMem128 = saida_ram;
 
endmodule

module rom_prog_pit(
    
    input [7:0] address,      // 8-bit register input
    output  [7:0] content);   // 8-bit register output

   wire [7:0] naddress;
   wire [7:0] minterm;
   not(naddress[0], address[0]);
   not(naddress[1], address[1]);
   not(naddress[2], address[2]);
   not(naddress[3], address[3]);
   not(naddress[4], address[4]);
   not(naddress[5], address[5]);
   not(naddress[6], address[6]);
   not(naddress[7], address[7]);
   
   and(minterm[0], naddress[2], naddress[1], naddress[0]);
   and(minterm[1], naddress[2], naddress[1],  address[0]);
   and(minterm[2], naddress[2],  address[1], naddress[0]);
   and(minterm[3], naddress[2],  address[1],  address[0]);
   and(minterm[4],  address[2], naddress[1], naddress[0]);
   and(minterm[5],  address[2], naddress[1],  address[0]);
   and(minterm[6],  address[2],  address[1], naddress[0]);
   and(minterm[7],  address[2],  address[1],  address[0]);

   or(content[0], minterm[1], minterm[3], minterm[7]);
   or(content[1], minterm[1], minterm[3]);
   or(content[2], minterm[1], minterm[3], minterm[7]);
   and(content[3], address[0], naddress[0]); //none
   or(content[4], minterm[2], minterm[4], minterm[6]);
   or(content[5], minterm[0], minterm[2], minterm[6]);
   buf(content[6], minterm[6]);
   or(content[7], minterm[5], minterm[6]);
 
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