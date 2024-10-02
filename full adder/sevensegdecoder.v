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