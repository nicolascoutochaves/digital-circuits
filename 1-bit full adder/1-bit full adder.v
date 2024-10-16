module sum(a, b, cin, display);
    input a, b;
    input cin;
    reg [1 : 0] s;
    output [6 : 0] display;

    fulladder a0 (.a(a), .b(b), .cin(cin), .s(s[0]), .cout(s[1]));
    bcdconverter s0 (.in(s), .dispseg(display));


endmodule

module fulladder(a, b, cin, s, cout);
input a, b, cin;
output s, cout;

wire w1, w2, w3;
wire na, nb;
not (na, a);
not (nb, b);

wire x0, x1, x2, x3;
and (x0, a, nb);
and (x1, na, b);
or (w1, x0, x1);
and(w2, a, b);

wire nw1, ncin;
not (nw1, w1);
not (ncin, cin);

and (x2, w1, ncin);
and (x3, nw1, cin);
or (s, x2, x3);
and(w3, w1, cin);
or(cout, w3, w2);

endmodule

module bcdconverter(in, dispseg);
    input [1:0] in;
    output [6:0] dispseg;

    //Conecta os fios a cada um dos segmentos do display
    wire a, b, c, d, e, f, g, x, y;
    assign a = dispseg[0];
    assign b = dispseg[1];
    assign c = dispseg[2];
    assign d = dispseg[3];
    assign e = dispseg[4];
    assign f = dispseg[5];
    assign g = dispseg[6];

    //Conecta fios às entradas x e y
    assign y = in[0];
    assign x = in[1];

    //versoes negadas de x e y
    wire nx, ny;
    not (nx, x);
    not (ny, y);

    // logica or (x, !y) e reutilizada nos segmentos a, d, e, g
    wire w0;
    or (w0, x, ny);


    buf (a, w0);
    //segmento b esta sempre ativo nesse circuito
    buf (b, 1);

    or (c, nx, y);

    buf (d, w0);
    
    wire w1;
    or (w1, nx, ny);
    and (e, w0, w1);

    and (f, nx, ny);

    wire w2;
    or (w2, x, y);
    and (g, w0, w2);
    
endmodule