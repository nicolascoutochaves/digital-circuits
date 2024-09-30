module bcddisplay(bits, display);
    parameter bitslength = 8;
    parameter displaynum = 2;
    input [bitslength - 1 : 0] bits;
    output [displaynum * 7 - 1 : 0] display;


    showindiplay seg0 (.nibble(bits[3: 0]), .dispseg(display[6: 0]));
    showindiplay seg1 (.nibble(bits[7: 4]), .dispseg(display[13 : 7]));
endmodule


module showindiplay(nibble, dispseg);
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
                              7'b0111111;
endmodule