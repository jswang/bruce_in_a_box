module detectColor (oRed,
					oGreen,
					oBlue,
					oDVAL,
					iColorTarget,
					iRed,
					iGreen,
					iBlue,
					iDVAL,
					targetRed,
					targetBlue,
					targetGreen,
					/////////////////////
					iX_Cont,
					iY_Cont,
					oXLeft,
					oXRight,
					oYTop,
					oYBot,
					oXLeftPrev,
					oXRightPrev,
					oYTopPrev,
					oYBotPrev,
					oXLeftPrev2,
					oXRightPrev2,
					oYTopPrev2,
					oYBotPrev2,
					oXLeftPrev3,
					oXRightPrev3,
					oYTopPrev3,
					oYBotPrev3,
					oRedArea,
					/////////////////////
					iCLK,
					iRST
);

	input			iDVAL;
	input			iCLK;
	input			iRST;
	input 	[21:0] 	iColorTarget;
	input	[9:0]	iRed;
	input	[9:0]	iGreen;
	input	[9:0]	iBlue;
	input	[9:0]	targetRed;
	input	[9:0]	targetGreen;
	input	[9:0]	targetBlue;
	
	input	[10:0]	iX_Cont;
	input	[10:0]	iY_Cont;
		
	output	[9:0]	oRed;
	output	[9:0]	oGreen;
	output	[9:0]	oBlue;
	output			oDVAL;
	
	//////////////////////////////////////
	output	[10:0]	oXLeft;
	output	[10:0]	oXRight;
	output	[10:0]	oYTop;
	output	[10:0]	oYBot;
	output	[10:0]	oXLeftPrev;
	output	[10:0]	oXRightPrev;
	output	[10:0]	oYTopPrev;
	output	[10:0]	oYBotPrev;
	output	[10:0]	oXLeftPrev2;
	output	[10:0]	oXRightPrev2;
	output	[10:0]	oYTopPrev2;
	output	[10:0]	oYBotPrev2;
	output	[10:0]	oXLeftPrev3;
	output	[10:0]	oXRightPrev3;
	output	[10:0]	oYTopPrev3;
	output	[10:0]	oYBotPrev3;
	output	[18:0]	oRedArea;
	//////////////////////////////////////
	
	reg		[9:0]	regRed;
	reg		[9:0]	regGreen;
	reg		[9:0]	regBlue;
	
	//////////////////////////////////////
	reg		[10:0]	leftX;
	reg		[10:0]	rightX;
	reg		[10:0]	topY;
	reg		[10:0]	botY;
	reg		[10:0]	newLeftX;
	reg		[10:0]	newRightX;
	reg		[10:0]	newTopY;
	reg		[10:0]	newBotY;
	
	reg		[10:0]	prevLeftX;
	reg		[10:0]	prevRightX;
	reg		[10:0]	prevTopY;
	reg		[10:0]	prevBotY;
	
	reg		[10:0]	prev2LeftX;
	reg		[10:0]	prev2RightX;
	reg		[10:0]	prev2TopY;
	reg		[10:0]	prev2BotY;
	
	reg		[10:0]	prev3LeftX;
	reg		[10:0]	prev3RightX;
	reg		[10:0]	prev3TopY;
	reg		[10:0]	prev3BotY;
	
	reg		[18:0]	redArea;
	reg		[18:0]	newRedArea;
	
	reg				frameClock;
	wire	[10:0]	avgLeftX;
	wire	[10:0]	avgRightX;
	wire	[10:0]	avgTopY;
	wire	[10:0]	avgBotY;
	//////////////////////////////////////
	
	wire	[21:0]	rgbSquaredSum;
	wire	[19:0]	rSquared;
	wire	[19:0]	gSquared;
	wire	[19:0]	bSquared;
	wire	[21:0]	distance;
	wire	[9:0]	grayValue;
/*
wire	RED_match, GREEN_match, BLUE_match, RED_GT_GREEN_match,RED_GT_BLUE_match;
wire	y_RED_match, y_GREEN_match, y_BLUE_match;
wire	g_RED_match, g_GREEN_match, g_BLUE_match;
wire	detect, R_detect, G_detect, Y_detect;

wire	[9:0]	VGA_data_iRed, VGA_data_iGreen, VGA_data_iBlue;//data from SDRAM

//original data coming from SDRAM
assign	VGA_data_iRed = iRed;
assign	VGA_data_iGreen = iGreen;
assign	VGA_data_iBlue	= iBlue;

	//Red Color intensity checks
assign	RED_match=(VGA_data_iRed > 10'h100)? 1'b1:1'b0;  //Red > 128
assign	GREEN_match=(VGA_data_iGreen > 10'h080)? 1'b1:1'b0;	//Green > 128
assign	BLUE_match=(VGA_data_iBlue > 10'h080)? 1'b1:1'b0;		//Blue > 128

//Yellow Color intensity check
assign	y_RED_match=(VGA_data_iRed > 10'h100)? 1'b1:1'b0;  //Red > 128 100
assign	y_GREEN_match=(VGA_data_iGreen > 10'h100)? 1'b1:1'b0;	//Green > 128  140
assign	y_BLUE_match=(VGA_data_iBlue < 10'h080)? 1'b1:1'b0;		//Blue > 128  100

//Green color intensity check
assign	g_RED_match=(VGA_data_iRed < 10'd100)? 1'b1:1'b0;  //Red > 128 100
assign	g_GREEN_match=(VGA_data_iGreen > 10'd140)? 1'b1:1'b0;	//Green > 128  140
assign	g_BLUE_match=(VGA_data_iBlue < 10'h100)? 1'b1:1'b0;		//Blue > 128  100

//For RED Greater Then Green detection
assign	RED_GT_GREEN_match=(VGA_data_iRed > (VGA_data_iGreen + VGA_data_iGreen[9:1]))?1'b1:1'b0; //Red > 1.5(Green)
//For RED Greater Then Blue detection
assign	RED_GT_BLUE_match=(VGA_data_iRed > {VGA_data_iBlue[8:0],1'b0})?1'b1:1'b0;  //Red > 2(Blue)

//For Green Greater Then Red detection
assign	GREEN_GT_RED_match=(VGA_data_iGreen > {VGA_data_iRed[8:0],1'b0})?1'b1:1'b0; 
//For Green Greater Then Blue detection
assign	GREEN_GT_BLUE_match=(VGA_data_iGreen> {VGA_data_iBlue[8:0],1'b0})?1'b1:1'b0;  


// set match if R>128 and R> 2(G) and R > 2(B) and G < 128 and B < 128
assign	R_detect = RED_match & RED_GT_GREEN_match & RED_GT_BLUE_match & ~GREEN_match &  ~BLUE_match;
assign	Y_detect = y_RED_match & y_GREEN_match & y_BLUE_match;
assign	G_detect = g_RED_match & g_GREEN_match & g_BLUE_match;
*/
			
	assign	rSquared		=	(targetRed - iRed) * (targetRed - iRed);
	assign	gSquared		=	(iGreen>targetGreen) ? ((iGreen - targetGreen) * (iGreen - targetGreen)) : ((targetGreen - iGreen) * (targetGreen - iGreen));
	assign	bSquared		=	(targetBlue - iBlue) * (targetBlue - iBlue);

	assign	rgbSquaredSum	=	rSquared + gSquared + bSquared;
	assign	grayValue		=	(iRed >> 2) + (iBlue >> 2) + (iGreen >> 1);
	
	assign	oRed			=	regRed;
	assign	oGreen			=	regGreen;
	assign	oBlue			=	regBlue;
	assign	oDVAL			=	iDVAL;
	
	//////////////////////////////////////////////////
	//assign	oXLeft			=	leftX;
	//assign	oXRight			=	rightX;
	//assign	oYTop				=	topY;
	//assign	oYBot				=	botY;
	assign	oXLeft			=	avgLeftX;
	assign	oXRight			=	avgRightX;
	assign	oYTop			=	avgTopY;
	assign	oYBot			=	avgBotY;
	assign	oXLeftPrev		=	prevLeftX;
	assign	oXRightPrev		=	prevRightX;
	assign	oYTopPrev		=	prevTopY;
	assign	oYBotPrev		=	prevBotY;
	assign	oXLeftPrev2		=	prev2LeftX;
	assign	oXRightPrev2	=	prev2RightX;
	assign	oYTopPrev2		=	prev2TopY;
	assign	oYBotPrev2		=	prev2BotY;
	assign	oXLeftPrev3		=	prev3LeftX;
	assign	oXRightPrev3	=	prev3RightX;
	assign	oYTopPrev3		=	prev3TopY;
	assign	oYBotPrev3		=	prev3BotY;
	assign	oRedArea			=	redArea;
	//////////////////////////////////////////////////
	
	average	leftXAvg	(avgLeftX, 	leftX, 	3'd4, frameClock);
	average	rightXAvg	(avgRightX, rightX, 3'd4, frameClock);
	average	topYAvg		(avgTopY, 	topY, 	3'd4, frameClock);
	average	botYAvg		(avgBotY, 	botY, 	3'd4, frameClock);
	
	always@(posedge iCLK or posedge iRST)
	begin
		if(iRST) begin
			regRed		<=	10'b0;
			regGreen	<=	10'b0;
			regBlue		<=	10'b0;
			
			leftX		<=	11'b11111111111;
			rightX		<=	11'h0;
			topY		<=	11'b11111111111;
			botY		<=	11'h0;
			/*
			newLeftX	<= 11'b11111111111;
			newRightX 	<= 11'h0;
			newTopY	 	<= 11'b11111111111;
			newBotY	 	<= 11'h0;
			
			prevLeftX  	<=	11'b11111111111;
			prevRightX 	<=	11'h0;
			prevTopY	<=	11'b11111111111;
			prevBotY	<=	11'h0;
			
			prev2LeftX	<=	11'b11111111111;
			prev2RightX	<=	11'h0;
			prev2TopY	<=	11'b11111111111;
			prev2BotY	<=	11'h0;
			
			prev3LeftX	<=	11'b11111111111;
			prev3RightX	<=	11'h0;
			prev3TopY	<=	11'b11111111111;
			prev3BotY	<=	11'h0;
			
			redArea		<=	19'h0;
			newRedArea	<=	19'h0;
			*/
			frameClock	<=	1'b1;
		end
		else begin
			if ((iX_Cont > 11'd5) && (iX_Cont < 11'd635) && (iY_Cont > 11'd5) && (iY_Cont < 11'd475))
			begin
				//if case when we are seeing a valid red
				if (rgbSquaredSum < iColorTarget)
				begin
					regRed		<=	10'b1111111111;
					regGreen	<=	10'h0000;
					regBlue		<=	10'h0000;
					
					if (iX_Cont <= newLeftX) begin
						if (iX_Cont >= 10'd6)
							newLeftX 	<=	iX_Cont - 10'd1;
					end
					if (iX_Cont >= newRightX) begin
						if (iX_Cont <= 10'd634)
							newRightX	<=	iX_Cont + 10'd1;
					end
					if (iY_Cont <= newTopY)	begin
						if (iY_Cont >= 10'd6)
							newTopY		<=	iY_Cont - 10'd1;
					end
					if (iY_Cont >= newBotY)	begin
						if (iY_Cont <= 10'd474)
							newBotY		<=	iY_Cont + 10'd1;
					end
				end
				//not seeing a valid red
				else begin
					//generic case - set to gray
					regRed		<=	grayValue;
					regGreen	<=	grayValue;
					regBlue		<=	grayValue;
					/*
					////////////////prev3///////////////
					if ((iY_Cont == prev3BotY) && ((iX_Cont >= prev3LeftX) && (iX_Cont <= prev3RightX))) begin
						regRed		<=	10'hFFFF;
						regGreen	<=	10'h0;
						regBlue		<=	10'hFFFF;
					end
					else if ((iY_Cont == prev3TopY) && ((iX_Cont >= prev3LeftX) && (iX_Cont <= prev3RightX))) begin
						regRed		<=	10'hFFFF;
						regGreen	<=	10'h0;
						regBlue		<=	10'hFFFF;
					end
					else if ((iX_Cont == prev3LeftX) && ((iY_Cont >= prev3TopY) && (iY_Cont <= prev3BotY)))	begin
						regRed		<=	10'hFFFF;
						regGreen	<=	10'h0;
						regBlue		<=	10'hFFFF;
					end
					else if ((iX_Cont == prev3RightX) && ((iY_Cont >= prev3TopY) && (iY_Cont <= prev3BotY))) begin
						regRed		<=	10'hFFFF;
						regGreen	<=	10'h0;
						regBlue		<=	10'hFFFF;
					end
					////////////////prev2///////////////
					if ((iY_Cont == prev2BotY) && ((iX_Cont >= prev2LeftX) && (iX_Cont <= prev2RightX))) begin
						regRed		<=	10'h0;
						regGreen	<=	10'hFFFF;
						regBlue		<=	10'hFFFF;
					end
					else if ((iY_Cont == prev2TopY) && ((iX_Cont >= prev2LeftX) && (iX_Cont <= prev2RightX))) begin
						regRed		<=	10'h0;
						regGreen	<=	10'hFFFF;
						regBlue		<=	10'hFFFF;
					end
					else if ((iX_Cont == prev2LeftX) && ((iY_Cont >= prev2TopY) && (iY_Cont <= prev2BotY)))	begin
						regRed		<=	10'h0;
						regGreen	<=	10'hFFFF;
						regBlue		<=	10'hFFFF;
					end
					else if ((iX_Cont == prev2RightX) && ((iY_Cont >= prev2TopY) && (iY_Cont <= prev2BotY))) begin
						regRed		<=	10'h0;
						regGreen	<=	10'hFFFF;
						regBlue		<=	10'hFFFF;
					end
					////////////////prev///////////////
					if ((iY_Cont == prevBotY) && ((iX_Cont >= prevLeftX) && (iX_Cont <= prev2RightX))) begin
						regRed		<=	10'h0;
						regGreen	<=	10'hFFFF;
						regBlue		<=	10'hFFFF;
					end
					else if ((iY_Cont == prevTopY) && ((iX_Cont >= prevLeftX) && (iX_Cont <= prevRightX))) begin
						regRed		<=	10'h0;
						regGreen	<=	10'h0;
						regBlue		<=	10'hFFFF;
					end
					else if ((iX_Cont == prevLeftX) && ((iY_Cont >= prevTopY) && (iY_Cont <= prevBotY))) begin
						regRed		<=	10'h0;
						regGreen	<=	10'h0;
						regBlue		<=	10'hFFFF;
					end
					else if ((iX_Cont == prevRightX) && ((iY_Cont >= prevTopY) && (iY_Cont <= prevBotY))) begin
						regRed		<=	10'h0;
						regGreen		<=	10'h0;
						regBlue		<=	10'hFFFF;
					end
					////////////////current///////////////
					if ((iY_Cont == botY) && ((iX_Cont >= leftX) && (iX_Cont <= rightX))) begin
						regRed		<=	10'h0;
						regGreen	<=	10'hFFFF;
						regBlue		<=	10'h0;
					end
					else if ((iY_Cont == topY) && ((iX_Cont >=leftX) && (iX_Cont <= rightX))) begin
						regRed		<=	10'h0;
						regGreen	<=	10'hFFFF;
						regBlue		<=	10'h0;
					end
					else if ((iX_Cont == leftX) && ((iY_Cont >= topY) && (iY_Cont <= botY))) begin
						regRed		<=	10'h0;
						regGreen	<=	10'hFFFF;
						regBlue		<=	10'h0;
					end
					else if ((iX_Cont == rightX) && ((iY_Cont >= topY) && (iY_Cont <= botY))) begin
						regRed		<=	10'h0;
						regGreen	<=	10'hFFFF;
						regBlue		<=	10'h0;
					end
					else if ((iY_Cont > topY) && (iY_Cont < botY) && (iX_Cont > leftX) &&  (iX_Cont < rightX))	begin
						regRed		<=	iRed;
						regGreen	<=	iGreen;
						regBlue		<=	iBlue;
						newRedArea	<=	newRedArea + 1'b1;
					end
					*/
				end
			end
			//***************************************************************************\\
			//border around the image
			else
			begin
				regRed		<=	10'b1111111111;
				regGreen	<=	10'b1111111111;
				regBlue		<=	10'b1111111111;
			end
			//***************************************************************************\\
			//shift the bounding box register values and reset the current frame bound box
			if ((iX_Cont == 10'd639) && (iY_Cont == 10'd239))
				frameClock	<=	~frameClock;
			if ((iX_Cont == 10'd639) && (iY_Cont == 10'd479))
			begin
				leftX		<=	newLeftX;
				rightX		<=	newRightX;
				topY		<=	newTopY;
				botY		<=	newBotY;
				
				prevLeftX	<=	leftX;
				prevRightX	<=	rightX;
				prevTopY	<=	topY;
				prevBotY	<=	botY;
				
				prev2LeftX	<=	prevLeftX;
				prev2RightX	<=	prevRightX;
				prev2TopY	<=	prevTopY;
				prev2BotY	<=	prevBotY;
				
				prev3LeftX	<=	prev2LeftX;
				prev3RightX	<=	prev2RightX;
				prev3TopY	<=	prev2TopY;
				prev3BotY	<=	prev2BotY;
				
				newLeftX	<=	11'b11111111111;
				newRightX	<=	11'h0;
				newTopY		<=	11'b11111111111;
				newBotY		<=	11'h0;
				
				redArea		<=	newRedArea;
				newRedArea	<=	19'h0;
				
				frameClock	<=	~frameClock;
			end	//end of shifting
		end
	end

endmodule

/////////////////////////////////////////////////////
//// Time weighted average amplitude          ///////
/////////////////////////////////////////////////////
// dk_const
// 3
// 4
// 5
// 6
// 7
module average (out, in, dk_const, clk);

	output reg signed [10:0] out ;
	input wire signed [10:0] in ;
	input wire [2:0] dk_const ;
	input wire clk;
	
	wire signed  [10:0] new_out ;
	//first order lowpass of absolute value of input
	assign new_out = out - (out>>dk_const) + (in>>dk_const) ;
	always @(posedge clk)
	begin
		 out <= new_out ;
	end
endmodule
//////////////////////////////////////////////////
