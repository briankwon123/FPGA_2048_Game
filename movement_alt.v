module movement_alt(
	input wire up,
	input wire down,
    input wire left,
    input wire right,
    input wire rst,
    input wire enable,
    input wire [63:0] inTilevals,
    output reg [63:0] outTilevals
	);

    //reg [63:0] tilevals = inTilevals;
	 integer i;
    
    reg [3:0] tilevals [0:3][0:3];

    always @(*) begin
	 
        tilevals[0][0] = inTilevals[63:60];   //row 0, col 0
        tilevals[0][1] = inTilevals[59:56];
        tilevals[0][2] = inTilevals[55:52];
        tilevals[0][3] = inTilevals[51:48];
        tilevals[1][0] = inTilevals[47:44];   //row 1, col 0
        tilevals[1][1] = inTilevals[43:40];
        tilevals[1][2] = inTilevals[39:36];
        tilevals[1][3] = inTilevals[35:32];
        tilevals[2][0] = inTilevals[31:28];   //row 2, col 0
        tilevals[2][1] = inTilevals[27:24];
        tilevals[2][2] = inTilevals[23:20];
        tilevals[2][3] = inTilevals[19:16];
        tilevals[3][0] = inTilevals[15:12];   //row 3, col 0
        tilevals[3][1] = inTilevals[11:8];
        tilevals[3][2] = inTilevals[7:4];
        tilevals[3][3] = inTilevals[3:0];
		  
        if (rst) begin
            tilevals[0][0] = 4'd0;
            tilevals[0][1] = 4'd0;
            tilevals[0][2] = 4'd0;
            tilevals[0][3] = 4'd0;
            tilevals[1][0] = 4'd0;
            tilevals[1][1] = 4'd0;
            tilevals[1][2] = 4'd0;
            tilevals[1][3] = 4'd0;
            tilevals[2][0] = 4'd0;
            tilevals[2][1] = 4'd0;
            tilevals[2][2] = 4'd0;
            tilevals[2][3] = 4'd0;
            tilevals[3][0] = 4'd0;
            tilevals[3][1] = 4'd0;
            tilevals[3][2] = 4'd0;
            tilevals[3][3] = 4'd0;
        end
        else if (down) begin
            for(i=0; i<4; i=i+1) begin    //loop per column (Fill up all empty spaces)
                if (tilevals[0][i] == 4'd0) begin
                    tilevals[0][i] = tilevals[1][i];
                    tilevals[1][i] = tilevals[2][i];
                    tilevals[2][i] = tilevals[3][i];
                    tilevals[3][i] = 4'd0;
                end
                else if (tilevals[0][i] == tilevals[1][i]) begin
                    tilevals[0][i] = tilevals[0][i] + 4'd1;
                    tilevals[1][i] = tilevals[2][i];
                    tilevals[2][i] = tilevals[3][i];
                    tilevals[3][i] = 4'd0;
                end
                else begin  //start second row
                    if (tilevals[1][i] == 4'd0) begin
                        tilevals[1][i] = tilevals[2][i];
                        tilevals[2][i] = tilevals[3][i];
                        tilevals[3][i] = 4'd0;
                    end
                    else if (tilevals[1][i] == tilevals[2][i]) begin
                        tilevals[1][i] = tilevals[1][i] + 4'd1;
                        tilevals[2][i] = tilevals[3][i];
                        tilevals[3][i] = 4'd0;
                    end
                    else begin  //start third row
                        if (tilevals[2][i] == 4'd0) begin
                            tilevals[2][i] = tilevals[3][i];
                            tilevals[3][i] = 4'd0;
                        end
                        else if (tilevals[2][i] == tilevals[3][i]) begin
                            tilevals[2][i] = tilevals[2][i] + 4'd1;
                            tilevals[3][i] = 4'd0;
                        end
                        else begin
									//tilevals = tilevals;	//BK: Added this
                        end
                    end
                end
            end
        end //end down
        else if (up) begin
            for(i=0; i<4; i=i+1) begin    //loop per column (Fill up all empty spaces)
                if (tilevals[3][i] == 4'd0) begin
                    tilevals[3][i] = tilevals[2][i];
                    tilevals[2][i] = tilevals[1][i];
                    tilevals[1][i] = tilevals[0][i];
                    tilevals[0][i] = 4'd0;
                end
                else if (tilevals[3][i] == tilevals[2][i]) begin
                    tilevals[3][i] = tilevals[3][i] + 4'd1;
                    tilevals[2][i] = tilevals[1][i];
                    tilevals[1][i] = tilevals[0][i];
                    tilevals[0][i] = 4'd0;
                end
                else begin  //start second row
                    if (tilevals[2][i] == 4'd0) begin
                        tilevals[2][i] = tilevals[1][i];
                        tilevals[1][i] = tilevals[0][i];
                        tilevals[0][i] = 4'd0;
                    end
                    else if (tilevals[2][i] == tilevals[1][i]) begin
                        tilevals[2][i] = tilevals[2][i] + 4'd1;
                        tilevals[1][i] = tilevals[0][i];
                        tilevals[0][i] = 4'd0;
                    end
                    else begin  //start third row
                        if (tilevals[1][i] == 4'd0) begin
                            tilevals[1][i] = tilevals[0][i];
                            tilevals[0][i] = 4'd0;
                        end
                        else if (tilevals[1][i] == tilevals[0][i]) begin
                            tilevals[1][i] = tilevals[1][i] + 4'd1;
                            tilevals[0][i] = 4'd0;
                        end
                        else begin
									//tilevals = tilevals;	//BK: Added this
                        end
                    end
                end
            end
        end //end up
        else if (left) begin
            for(i=0; i<4; i=i+1) begin    //loop per column (Fill up all empty spaces)
                if (tilevals[i][3] == 4'd0) begin
                    tilevals[i][3] = tilevals[i][2];
                    tilevals[i][2] = tilevals[i][1];
                    tilevals[i][1] = tilevals[i][0];
                    tilevals[i][0] = 4'd0;
                end
                else if (tilevals[i][3] == tilevals[i][2]) begin
                    tilevals[i][3] = tilevals[i][3] + 4'd1;
                    tilevals[i][2] = tilevals[i][1];
                    tilevals[i][1] = tilevals[i][0];
                    tilevals[i][0] = 4'd0;
                end
                else begin  //start second row
                    if (tilevals[i][2] == 4'd0) begin
                        tilevals[i][2] = tilevals[i][1];
                        tilevals[i][1] = tilevals[i][0];
                        tilevals[i][0] = 4'd0;
                    end
                    else if (tilevals[i][2] == tilevals[i][1]) begin
                        tilevals[i][2] = tilevals[i][2] + 4'd1;
                        tilevals[i][1] = tilevals[i][0];
                        tilevals[i][0] = 4'd0;
                    end
                    else begin  //start third row
                        if (tilevals[i][1] == 4'd0) begin
                            tilevals[i][1] = tilevals[i][0];
                            tilevals[i][0] = 4'd0;
                        end
                        else if (tilevals[i][1] == tilevals[i][0]) begin
                            tilevals[i][1] = tilevals[i][1] + 4'd1;
                            tilevals[i][0] = 4'd0;
                        end
                        else begin
									//tilevals = tilevals;	//BK: Added this
                        end
                    end
                end
            end
        end //end left
        else if (right) begin
            for(i=0; i<4; i=i+1) begin    //loop per column (Fill up all empty spaces)
                if (tilevals[i][0] == 4'd0) begin
                    tilevals[i][0] = tilevals[i][1];
                    tilevals[i][1] = tilevals[i][2];
                    tilevals[i][2] = tilevals[i][3];
                    tilevals[i][3] = 4'd0;
                end
                else if (tilevals[i][0] == tilevals[i][1]) begin
                    tilevals[i][0] = tilevals[i][0] + 4'd1;
                    tilevals[i][1] = tilevals[i][2];
                    tilevals[i][2] = tilevals[i][3];
                    tilevals[i][3] = 4'd0;
                end
                else begin  //start second row
                    if (tilevals[i][1] == 4'd0) begin
                        tilevals[i][1] = tilevals[i][2];
                        tilevals[i][2] = tilevals[i][3];
                        tilevals[i][3] = 4'd0;
                    end
                    else if (tilevals[i][1] == tilevals[i][2]) begin
                        tilevals[i][1] = tilevals[i][1] + 4'd1;
                        tilevals[i][2] = tilevals[i][3];
                        tilevals[i][3] = 4'd0;
                    end
                    else begin  //start third row
                        if (tilevals[i][2] == 4'd0) begin
                            tilevals[i][2] = tilevals[i][3];
                            tilevals[i][3] = 4'd0;
                        end
                        else if (tilevals[i][2] == tilevals[i][3]) begin
                            tilevals[i][2] = tilevals[i][2] + 4'd1;
                            tilevals[i][3] = 4'd0;
                        end
                        else begin
									//tilevals = tilevals;	//BK: Added this
                        end
                    end
                end
            end
        end //end right
		  /*
		  else if (down) begin
		      for(i=0; i<4; i=i+1) begin    //loop per column (Fill up all empty spaces)
					tilevals[0][i] = tilevals[1][i];
               tilevals[1][i] = tilevals[2][i];
               tilevals[2][i] = tilevals[3][i];
               tilevals[3][i] = 4'd0;
				end
		  end
		  else if (up) begin
				for(i=0; i<4; i=i+1) begin    //loop per column (Fill up all empty spaces)
					tilevals[3][i] = tilevals[2][i];
               tilevals[2][i] = tilevals[1][i];
               tilevals[1][i] = tilevals[0][i];
               tilevals[0][i] = 4'd0;
				end
		  end
		  else if (left) begin
				for(i=0; i<4; i=i+1) begin    //loop per column (Fill up all empty spaces)
					tilevals[i][3] = tilevals[i][2];
               tilevals[i][2] = tilevals[i][1];
               tilevals[i][1] = tilevals[i][0];
               tilevals[i][0] = 4'd0;
				end
		  end
		  else if (right) begin
		      for(i=0; i<4; i=i+1) begin    //loop per column (Fill up all empty spaces)
					tilevals[i][0] = tilevals[i][1];
               tilevals[i][1] = tilevals[i][2];
               tilevals[i][2] = tilevals[i][3];
               tilevals[i][3] = 4'd0;
				end
		  end
*/

        outTilevals[63:60] = tilevals[0][0];
        outTilevals[59:56] = tilevals[0][1];
        outTilevals[55:52] = tilevals[0][2];
        outTilevals[51:48] = tilevals[0][3];
        outTilevals[47:44] = tilevals[1][0];
        outTilevals[43:40] = tilevals[1][1];
        outTilevals[39:36] = tilevals[1][2];
        outTilevals[35:32] = tilevals[1][3];
        outTilevals[31:28] = tilevals[2][0];
        outTilevals[27:24] = tilevals[2][1];
        outTilevals[23:20] = tilevals[2][2];
        outTilevals[19:16] = tilevals[2][3];
        outTilevals[15:12] = tilevals[3][0];
        outTilevals[11:8] = tilevals[3][1];
        outTilevals[7:4] = tilevals[3][2];
        outTilevals[3:0] = tilevals[3][3];
		  
        //Update the output tiles to the updated tile from above
    end
	 

	 
    
endmodule
