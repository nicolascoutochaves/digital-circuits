module eightbitfulladder(a, b, cin, cout, sevendisp);
input [3:0] a, b;
input cin;
output [6:0] sevendisp;
reg [3:0] s;
output cout;

wire x0, x1, x2, x3;
wire c0, c1, c2;

//Caso receba o sinal de carry, os bits serao invertidos para fazer subtracao;
xor (x0, cin, b[0]);
xor (x1, cin, b[1]);
xor (x2, cin, b[2]);
xor (x3, cin, b[3]);

fulladder d0 (.b(x0), .a(a[0]), .cin(cin), .s(s[0]), .cout(c0));
fulladder d1 (.b(x1), .a(a[1]), .cin(c0), .s(s[1]), .cout(c1));
fulladder d2 (.b(x2), .a(a[2]), .cin(c1), .s(s[2]), .cout(c2));
fulladder d3 (.b(x3), .a(a[3]), .cin(c2), .s(s[3]), .cout(cout));

sevensegdecoder display0 (.nibble(s[0 +: 4]), .dispseg(sevendisp[0 +: 7]));


endmodule