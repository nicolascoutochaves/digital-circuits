// This module is a binary to bcd algorithm taken from Wikipedia
module bin2bcd
 #( parameter                bin_length = 10)  // input width
  ( input      [bin_length-1:0] bin   ,  // binary
    output reg [27:0] display);
    parameter bcdlength = 16;
    reg [bcdlength - 1 : 0] bcd;    // bcd {...,thousands,hundreds,tens,ones}
    integer i,j;

    always @(bin) begin
    for(i = 0; i < bcdlength; i = i+1) bcd[i] = 0;     // initialize with zeros
    bcd[bin_length-1:0] = bin;
                                   // initialize with input vector
    for(i = 0; i <= bin_length-4; i = i+1)                       // iterate on structure depth
        for(j = 0; j <= i/3; j = j+1)                     // iterate on structure width
        if (bcd[bin_length-i+4*j -: 4] > 4)                      // if > 4
            bcd[bin_length-i+4*j -: 4] = bcd[bin_length-i+4*j -: 4] + 4'd3; // add 3
    end

    showindiplay seg0 (.nibble(bcd[0 +: 4]), .dispseg(display[0 +: 7]));
    showindiplay seg1 (.nibble(bcd[4 +: 4]), .dispseg(display[7 +: 7]));
    showindiplay seg2 (.nibble(bcd[8 +: 4]), .dispseg(display[14 +: 7]));
    showindiplay seg3 (.nibble(bcd[12 +: 4]), .dispseg(display[21 +: 7]));

endmodule


//table to convert a nibble to a 7 bit value and turn on the display
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