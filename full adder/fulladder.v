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