// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	DE2-115 TV_BOX
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Peli Li           :| 03/25/2010:| Initial Revision
//   V2.0 :| Peli Li           :| 04/17/2010:| change the megacore of MAC_3,VGA controller bits num
//   V3.0 :| Rosaline          :| 08/03/2010:| change the TD format support PAL
// --------------------------------------------------------------------

module DE2_115_TV
	(
		//////// CLOCK //////////
		CLOCK_50,
		CLOCK2_50,
		CLOCK3_50,
		ENETCLK_25,

		//////// Sma //////////
		SMA_CLKIN,
		SMA_CLKOUT,

		//////// LED //////////
		LEDG,
		LEDR,

		//////// KEY //////////
		KEY,

		//////// SW //////////
		SW,

		//////// SEG7 //////////
		HEX0,
		HEX1,
		HEX2,
		HEX3,
		HEX4,
		HEX5,
		HEX6,
		HEX7,

		//////// LCD //////////
		LCD_BLON,
		LCD_DATA,
		LCD_EN,
		LCD_ON,
		LCD_RS,
		LCD_RW,

		//////// RS232 //////////
		UART_CTS,
		UART_RTS,
		UART_RXD,
		UART_TXD,

		//////// PS2 //////////
		PS2_CLK,
		PS2_DAT,
		PS2_CLK2,
		PS2_DAT2,

		//////// SDCARD //////////
		SD_CLK,
		SD_CMD,
		SD_DAT,
		SD_WP_N,

		//////// VGA //////////
		VGA_B,
		VGA_BLANK_N,
		VGA_CLK,
		VGA_G,
		VGA_HS,
		VGA_R,
		VGA_SYNC_N,
		VGA_VS,

		//////// Audio //////////
		AUD_ADCDAT,
		AUD_ADCLRCK,
		AUD_BCLK,
		AUD_DACDAT,
		AUD_DACLRCK,
		AUD_XCK,

		//////// I2C for EEPROM //////////
		EEP_I2C_SCLK,
		EEP_I2C_SDAT,

		//////// I2C for Audio and Tv-Decode //////////
		I2C_SCLK,
		I2C_SDAT,

		//////// Ethernet 0 //////////
		ENET0_GTX_CLK,
		ENET0_INT_N,
		ENET0_MDC,
		ENET0_MDIO,
		ENET0_RST_N,
		ENET0_RX_CLK,
		ENET0_RX_COL,
		ENET0_RX_CRS,
		ENET0_RX_DATA,
		ENET0_RX_DV,
		ENET0_RX_ER,
		ENET0_TX_CLK,
		ENET0_TX_DATA,
		ENET0_TX_EN,
		ENET0_TX_ER,
		ENET0_LINK100,

		//////// Ethernet 1 //////////
		ENET1_GTX_CLK,
		ENET1_INT_N,
		ENET1_MDC,
		ENET1_MDIO,
		ENET1_RST_N,
		ENET1_RX_CLK,
		ENET1_RX_COL,
		ENET1_RX_CRS,
		ENET1_RX_DATA,
		ENET1_RX_DV,
		ENET1_RX_ER,
		ENET1_TX_CLK,
		ENET1_TX_DATA,
		ENET1_TX_EN,
		ENET1_TX_ER,
		ENET1_LINK100,

		//////// TV Decoder //////////
		TD_CLK27,
		TD_DATA,
		TD_HS,
		TD_RESET_N,
		TD_VS,

		/////// USB OTG controller
		OTG_DATA,
		OTG_ADDR,
		OTG_CS_N,
		OTG_WR_N,
		OTG_RD_N,
		OTG_INT,
		OTG_RST_N,
		OTG_DREQ,
		OTG_DACK_N,
		OTG_FSPEED,
		OTG_LSPEED,
		//////// IR Receiver //////////
		IRDA_RXD,

		//////// SDRAM //////////
		DRAM_ADDR,
		DRAM_BA,
		DRAM_CAS_N,
		DRAM_CKE,
		DRAM_CLK,
		DRAM_CS_N,
		DRAM_DQ,
		DRAM_DQM,
		DRAM_RAS_N,
		DRAM_WE_N,

		//////// SRAM //////////
		SRAM_ADDR,
		SRAM_CE_N,
		SRAM_DQ,
		SRAM_LB_N,
		SRAM_OE_N,
		SRAM_UB_N,
		SRAM_WE_N,

		//////// Flash //////////
		FL_ADDR,
		FL_CE_N,
		FL_DQ,
		FL_OE_N,
		FL_RST_N,
		FL_RY,
		FL_WE_N,
		FL_WP_N,

		//////// GPIO //////////
		GPIO,

		//////// EXTEND IO //////////
		EX_IO	
	   
	);

//===========================================================================
// PARAMETER declarations
//===========================================================================


//===========================================================================
// PORT declarations
//===========================================================================
//////////// CLOCK //////////
input		          		CLOCK_50;
input		          		CLOCK2_50;
input		          		CLOCK3_50;
input		          		ENETCLK_25;

//////////// Sma //////////
input		          		SMA_CLKIN;
output		          		SMA_CLKOUT;

//////////// LED //////////
output		     [8:0]		LEDG;
output		    [17:0]		LEDR;

//////////// KEY //////////
input		     [3:0]		KEY;

//////////// SW //////////
input		    [17:0]		SW;

//////////// SEG7 //////////
output		     [6:0]		HEX0;
output		     [6:0]		HEX1;
output		     [6:0]		HEX2;
output		     [6:0]		HEX3;
output		     [6:0]		HEX4;
output		     [6:0]		HEX5;
output		     [6:0]		HEX6;
output		     [6:0]		HEX7;

//////////// LCD //////////
output		          		LCD_BLON;
inout		     [7:0]		LCD_DATA;
output		          		LCD_EN;
output		          		LCD_ON;
output		          		LCD_RS;
output		          		LCD_RW;

//////////// RS232 //////////
output		          		UART_CTS;
input		          		UART_RTS;
input		          		UART_RXD;
output		          		UART_TXD;

//////////// PS2 //////////
inout		          		PS2_CLK;
inout		          		PS2_DAT;
inout		          		PS2_CLK2;
inout		          		PS2_DAT2;

//////////// SDCARD //////////
output		          		SD_CLK;
inout		          		SD_CMD;
inout		     [3:0]		SD_DAT;
input		          		SD_WP_N;

//////////// VGA //////////
output reg	 	     [7:0]		VGA_B;
output		          		VGA_BLANK_N;
output		          		VGA_CLK;
output reg 		     [7:0]		VGA_G;
output		          		VGA_HS;
output reg 		     [7:0]		VGA_R;
output		          		VGA_SYNC_N;
output		          		VGA_VS;

//////////// Audio //////////
input		          		AUD_ADCDAT;
inout		          		AUD_ADCLRCK;
inout		          		AUD_BCLK;
output		          		AUD_DACDAT;
inout		          		AUD_DACLRCK;
output		          		AUD_XCK;

//////////// I2C for EEPROM //////////
output		          		EEP_I2C_SCLK;
inout		          		EEP_I2C_SDAT;

//////////// I2C for Audio and Tv-Decode //////////
output		          		I2C_SCLK;
inout		          		I2C_SDAT;

//////////// Ethernet 0 //////////
output		          		ENET0_GTX_CLK;
input		          		ENET0_INT_N;
output		          		ENET0_MDC;
inout		          		ENET0_MDIO;
output		          		ENET0_RST_N;
input		          		ENET0_RX_CLK;
input		          		ENET0_RX_COL;
input		          		ENET0_RX_CRS;
input		     [3:0]		ENET0_RX_DATA;
input		          		ENET0_RX_DV;
input		          		ENET0_RX_ER;
input		          		ENET0_TX_CLK;
output		     [3:0]		ENET0_TX_DATA;
output		          		ENET0_TX_EN;
output		          		ENET0_TX_ER;
input		          		ENET0_LINK100;

//////////// Ethernet 1 //////////
output		          		ENET1_GTX_CLK;
input		          		ENET1_INT_N;
output		          		ENET1_MDC;
inout		          		ENET1_MDIO;
output		          		ENET1_RST_N;
input		          		ENET1_RX_CLK;
input		          		ENET1_RX_COL;
input		          		ENET1_RX_CRS;
input		     [3:0]		ENET1_RX_DATA;
input		          		ENET1_RX_DV;
input		          		ENET1_RX_ER;
input		          		ENET1_TX_CLK;
output		     [3:0]		ENET1_TX_DATA;
output		          		ENET1_TX_EN;
output		          		ENET1_TX_ER;
input		          		ENET1_LINK100;

//////////// TV Decoder 1 //////////
input		          		TD_CLK27;
input		     [7:0]		TD_DATA;
input		          		TD_HS;
output		          		TD_RESET_N;
input		          		TD_VS;


//////////// USB OTG controller //////////
inout            [15:0]     OTG_DATA;
output           [1:0]      OTG_ADDR;
output                      OTG_CS_N;
output                      OTG_WR_N;
output                      OTG_RD_N;
input            [1:0]      OTG_INT;
output                      OTG_RST_N;
input            [1:0]      OTG_DREQ;
output           [1:0]      OTG_DACK_N;
inout                       OTG_FSPEED;
inout                       OTG_LSPEED;

//////////// IR Receiver //////////
input		          		IRDA_RXD;

//////////// SDRAM //////////
output		    [12:0]		DRAM_ADDR;
output		     [1:0]		DRAM_BA;
output		          		DRAM_CAS_N;
output		          		DRAM_CKE;
output		          		DRAM_CLK;
output		          		DRAM_CS_N;
inout		    [31:0]		DRAM_DQ;
output		     [3:0]		DRAM_DQM;
output		          		DRAM_RAS_N;
output		          		DRAM_WE_N;

//////////// SRAM //////////
output		    [19:0]		SRAM_ADDR;
output		          		SRAM_CE_N;
inout		    [15:0]		SRAM_DQ;
output		          		SRAM_LB_N;
output		          		SRAM_OE_N;
output		          		SRAM_UB_N;
output		          		SRAM_WE_N;

//////////// Flash //////////
output		    [22:0]		FL_ADDR;
output		          		FL_CE_N;
inout		     [7:0]		FL_DQ;
output		          		FL_OE_N;
output		          		FL_RST_N;
input		          		FL_RY;
output		          		FL_WE_N;
output		          		FL_WP_N;

//////////// GPIO //////////
inout		    [35:0]		GPIO;

//////// EXTEND IO //////////
inout		    [6:0]		EX_IO;
///////////////////////////////////////////////////////////////////
//=============================================================================
// REG/WIRE declarations
//=============================================================================
//jsw267
wire reset = ~KEY[0];

//
wire	CPU_CLK;
wire	CPU_RESET;
wire	CLK_18_4;
wire	CLK_25;

//	For Audio CODEC
wire		AUD_CTRL_CLK;	//	For Audio Controller

//	For ITU-R 656 Decoder
wire	[15:0]	YCbCr;
wire	[9:0]	TV_X;
wire			TV_DVAL;

//	For VGA Controller
wire	[9:0]	mRed;
wire	[9:0]	mGreen;
wire	[9:0]	mBlue;
wire	[10:0]	VGA_X_d0;
wire	[10:0]	VGA_Y_d0;
wire			VGA_Read;	//	VGA data request
wire			m1VGA_Read;	//	Read odd field
wire			m2VGA_Read;	//	Read even field

//	For YUV 4:2:2 to YUV 4:4:4
wire	[7:0]	mY;
wire	[7:0]	mCb;
wire	[7:0]	mCr;

//	For field select
wire	[15:0]	mYCbCr;
wire	[15:0]	mYCbCr_d;
wire	[15:0]	m1YCbCr;
wire	[15:0]	m2YCbCr;
wire	[15:0]	m3YCbCr;

//	For Delay Timer
wire			TD_Stable;
wire			DLY0;
wire			DLY1;
wire			DLY2;

//	For Down Sample
wire	[3:0]	Remain;
wire	[9:0]	Quotient;

wire			mDVAL;

wire	[15:0]	m4YCbCr;
wire	[15:0]	m5YCbCr;
wire	[8:0]	Tmp1,Tmp2;
wire	[7:0]	Tmp3,Tmp4;

wire            NTSC;
wire            PAL;
//=============================================================================
// Structural coding
//=============================================================================

//	Flash
assign	FL_RST_N	=	1'b1;

//	16*2 LCD Module
assign	LCD_ON		=	1'b1;	//	LCD ON
assign	LCD_BLON	=	1'b1;	//	LCD Back Light	

//	All inout port turn to tri-state 
assign	SD_DAT		=	4'b1zzz;  //Set SD Card to SD Mode
assign	AUD_ADCLRCK	=	AUD_DACLRCK;
assign	GPIO	=	36'hzzzzzzzzz;
assign	EX_IO   	=	7'bzzzzzzz;

//	Disable USB speed select
assign	OTG_FSPEED	=	1'bz;
assign	OTG_LSPEED	=	1'bz;

//	Turn On TV Decoder
assign	TD_RESET_N	=	1'b1;

assign	AUD_XCK	=	AUD_CTRL_CLK;

// assign	LEDG	=	VGA_Y;
// assign	LEDR	=	VGA_X;

assign	m1VGA_Read	=	VGA_Y_d0[0]		?	1'b0		:	VGA_Read	;
assign	m2VGA_Read	=	VGA_Y_d0[0]		?	VGA_Read	:	1'b0		;
assign	mYCbCr_d	=	!VGA_Y_d0[0]		?	m1YCbCr		:
											      m2YCbCr		;
assign	mYCbCr		=	m5YCbCr;

assign	Tmp1	=	m4YCbCr[7:0]+mYCbCr_d[7:0];
assign	Tmp2	=	m4YCbCr[15:8]+mYCbCr_d[15:8];
assign	Tmp3	=	Tmp1[8:2]+m3YCbCr[7:1];
assign	Tmp4	=	Tmp2[8:2]+m3YCbCr[15:9];
assign	m5YCbCr	=	{Tmp4,Tmp3};

//	7 segment LUT
SEG7_LUT_8 			u0	(	.oSEG0(HEX0),
							.oSEG1(HEX1),
							.oSEG2(HEX2),
							.oSEG3(HEX3),
							.oSEG4(HEX4),
							.oSEG5(HEX5),
							.oSEG6(HEX6),
							.oSEG7(HEX7),
							.iDIG(SW) );
							
//	TV Decoder Stable Check
TD_Detect			u2	(	.oTD_Stable(TD_Stable),
							.oNTSC(NTSC),
							.oPAL(PAL),
							.iTD_VS(TD_VS),
							.iTD_HS(TD_HS),
							.iRST_N(!reset)	);

//	Reset Delay Timer
Reset_Delay			u3	(	.iCLK(CLOCK_50),
							.iRST(TD_Stable),
							.oRST_0(DLY0),
							.oRST_1(DLY1),
							.oRST_2(DLY2));

//	ITU-R 656 to YUV 4:2:2
ITU_656_Decoder		u4	(	//	TV Decoder Input
							.iTD_DATA(TD_DATA),
							//	Position Output
							.oTV_X(TV_X),
							//	YUV 4:2:2 Output
							.oYCbCr(YCbCr),
							.oDVAL(TV_DVAL),
							//	Control Signals
							.iSwap_CbCr(Quotient[0]),
							.iSkip(Remain==4'h0),
							.iRST_N(DLY1),
							.iCLK_27(TD_CLK27)	);

//	For Down Sample 720 to 640
DIV 				u5	(	.aclr(!DLY0),	
							.clock(TD_CLK27),
							.denom(4'h9),
							.numer(TV_X),
							.quotient(Quotient),
							.remain(Remain));

//	SDRAM frame buffer
Sdram_Control_4Port	u6	(	//	HOST Side
						    .REF_CLK(TD_CLK27),
							.CLK_18(AUD_CTRL_CLK),
						    .RESET_N(DLY0),
							//	FIFO Write Side 1
						    .WR1_DATA(YCbCr),
							.WR1(TV_DVAL),
							.WR1_FULL(WR1_FULL),
							.WR1_ADDR(0),
							.WR1_MAX_ADDR(NTSC ? 640*507 : 640*576),		//	525-18
							.WR1_LENGTH(9'h80),
							.WR1_LOAD(!DLY0),
							.WR1_CLK(TD_CLK27),
							//	FIFO Read Side 1
						    .RD1_DATA(m1YCbCr),
				        	.RD1(m1VGA_Read),
				        	.RD1_ADDR(NTSC ? 640*13 : 640*42),			//	Read odd field and bypess blanking
							.RD1_MAX_ADDR(NTSC ? 640*253 : 640*282),
							.RD1_LENGTH(9'h80),
				        	.RD1_LOAD(!DLY0),
							.RD1_CLK(TD_CLK27),
							//	FIFO Read Side 2
						    .RD2_DATA(m2YCbCr),
				        	.RD2(m2VGA_Read),
				        	.RD2_ADDR(NTSC ? 640*267 : 640*330),			//	Read even field and bypess blanking
							.RD2_MAX_ADDR(NTSC ? 640*507 : 640*570),
							.RD2_LENGTH(9'h80),
				        	.RD2_LOAD(!DLY0),
							.RD2_CLK(TD_CLK27),
							//	SDRAM Side
						    .SA(DRAM_ADDR),
						    .BA(DRAM_BA),
						    .CS_N(DRAM_CS_N),
						    .CKE(DRAM_CKE),
						    .RAS_N(DRAM_RAS_N),
				            .CAS_N(DRAM_CAS_N),
				            .WE_N(DRAM_WE_N),
						    .DQ(DRAM_DQ),
				            .DQM({DRAM_DQM[1],DRAM_DQM[0]}),
							.SDR_CLK(DRAM_CLK)	);

//	YUV 4:2:2 to YUV 4:4:4
YUV422_to_444		u7	(	//	YUV 4:2:2 Input
							.iYCbCr(mYCbCr),
							//	YUV	4:4:4 Output
							.oY(mY),
							.oCb(mCb),
							.oCr(mCr),
							//	Control Signals
							.iX(VGA_X_d0-160),
							.iCLK(TD_CLK27),
							.iRST_N(DLY0));

wire [7:0] Y, Cb, Cr;
//	YCbCr 8-bit to RGB-10 bit 
YCbCr2RGB 			u8	(	//	Output Side
							.Red 	(mRed),
							.Green 	(mGreen),
							.Blue 	(mBlue),
							.oDVAL 	(mDVAL),
							.Y_out 	(Y), 
							.Cb_out (Cb), 
							.Cr_out (Cr),
							//	Input Side
							.iY 	(mY),
							.iCb 	(mCb),
							.iCr 	(mCr),
							.iDVAL 	(VGA_Read),
							//	Control Signal
							.iRESET (!DLY2),
							.iCLK 	(TD_CLK27));

//	VGA Controller
wire [9:0] VGA_R10_d0;
wire [9:0] VGA_G10_d0;
wire [9:0] VGA_B10_d0;

//////////-------------jsw267
wire VGA_HS_d0, VGA_VS_d0, VGA_SYNC_N_d0, VGA_BLANK_N_d0;
wire [2:0] color_d3, color_d20;
wire [7:0] VGA_R_, VGA_G_, VGA_B_;
wire [21:0] VGA_Addr_full;
wire [18:0] VGA_Addr_d0 = VGA_Addr_full[18:0];

VGA_Ctrl	u9	(	
	//	Host Side
	.iRed 		(mRed),
	.iGreen 	(mGreen),
	.iBlue 		(mBlue),
	.oCurrent_X (VGA_X_d0),
	.oCurrent_Y (VGA_Y_d0),
	.oAddress 	(VGA_Addr_full), 
	.oRequest 	(VGA_Read),
	//	VGA Side
	.oVGA_R 	(VGA_R10_d0),
	.oVGA_G 	(VGA_G10_d0),
	.oVGA_B 	(VGA_B10_d0),
	.oVGA_HS 	(VGA_HS_d0),
	.oVGA_VS 	(VGA_VS_d0),
	.oVGA_SYNC 	(VGA_SYNC_N_d0),
	.oVGA_BLANK (VGA_BLANK_N_d0),
	.oVGA_CLOCK (VGA_CLK),
	//	Control Signal
	.iCLK 		(TD_CLK27),
	.iRST_N 	(DLY2)	
);

wire [7:0] VGA_R_d3, VGA_G_d3, VGA_B_d3;
wire signed [53:0] harris_feature_, harris_feature, threshold;
wire corner_detected_, corner_detected;
wire VGA_BLANK_N_d3;
wire [7:0] scale;
assign threshold = {1'b0, 16'h3fff, 37'd0};
assign scale = {2'b00, 2'd0, 4'b1111};

delay #( .DATA_WIDTH(24), .DELAY(3) ) delay_rgb_3
( 
	.clk 		(VGA_CLK), 
	.data_in 	({VGA_R10_d0[9:2], VGA_G10_d0[9:2], VGA_B10_d0[9:2]}), 
	.data_out 	({VGA_R_d3, VGA_G_d3, VGA_B_d3})
);
delay #( .DATA_WIDTH(1), .DELAY(3) ) vga_blank_n
(
	.clk 		(VGA_CLK), 
	.data_in	(VGA_BLANK_N_d0), 
	.data_out   (VGA_BLANK_N_d3)
);
harris_corner_detect find_corners(
	.clk(VGA_CLK), 
	.reset(reset), 
	.ram_clr(!VGA_VS_d0),
	.VGA_BLANK_N(VGA_BLANK_N_d0), 
	.VGA_R(VGA_R10_d0[9:2]), //VGA_R10_d0[9:2]
	.VGA_G(VGA_G10_d0[9:2]), //VGA_G10_d0[9:2]
	.VGA_B(VGA_B10_d0[9:2]), //VGA_B10_d0[9:2]
	.scale(scale),
	.harris_feature(harris_feature_)
);
//If you make this 52 you get solid edge detection
//set threshold = 0 and scale = 0000_1111
delay #(.DATA_WIDTH(54), .DELAY(15)) delay_harris_feature
(
	.clk(VGA_CLK), 
	.data_in(harris_feature_), 
	.data_out(harris_feature)
);

//---------------------------------Delayers
wire [10:0] VGA_X_d20, VGA_Y_d20;
wire VGA_VS_d3, VGA_VS_d7;
wire [7:0] Cb_d3, Cr_d3;

//Delay the VGA control signals for the VGA Side
delay #( .DATA_WIDTH(4), .DELAY(20) ) delay_vga_ctrl_20
( 
	.clk 		(VGA_CLK), 
	.data_in 	({VGA_HS_d0, VGA_VS_d0, VGA_SYNC_N_d0, VGA_BLANK_N_d0}), 
	.data_out 	({VGA_HS, VGA_VS, VGA_SYNC_N, VGA_BLANK_N})
);
//Delay RGB values
delay #( .DATA_WIDTH(24), .DELAY(20) ) delay_rgb_20
( 
	.clk 		(VGA_CLK), 
	.data_in 	({VGA_R10_d0[9:2], VGA_G10_d0[9:2], VGA_B10_d0[9:2]}), 
	.data_out 	({VGA_R_, VGA_G_, VGA_B_})
);

//Delay the x y just for referencing
delay #( .DATA_WIDTH(22), .DELAY(20) ) delay_x_y_20
( 
	.clk 		(VGA_CLK), 
	.data_in 	({VGA_X_d0,VGA_Y_d0}), 
	.data_out 	({VGA_X_d20, VGA_Y_d20})
);

delay #( .DATA_WIDTH(1), .DELAY(3) ) vga_vsync_delay3
(
	.clk 		(VGA_CLK), 
	.data_in	(VGA_VS_d0), 
	.data_out   (VGA_VS_d3)
);

delay #( .DATA_WIDTH(1), .DELAY(7) ) vga_vsync_delay7
(
	.clk 		(VGA_CLK), 
	.data_in	(VGA_VS_d0), 
	.data_out   (VGA_VS_d7)
);

delay #( .DATA_WIDTH(8), .DELAY(3) ) Cb_delay3
(
	.clk 		(VGA_CLK), 
	.data_in	(Cb), 
	.data_out   (Cb_d3)
);
delay #( .DATA_WIDTH(8), .DELAY(3) ) Cr_delay3
(
	.clk 		(VGA_CLK), 
	.data_in	(Cr), 
	.data_out   (Cr_d3)
);

//Read the history of this (x,y) pixel
wire [18:0] color_write_addr;
wire [3:0] 	color_write_data;
wire       	color_we;

wire [18:0] color_just_read_addr;
wire [3:0] 	color_read_data;
wire 		color_data_valid;

wire [9:0] color_just_read_x, color_just_read_y;

color_history color_hist (
	.clk(VGA_CLK), 
	.reset(reset), 
 
	.write_addr(color_write_addr),  
	.write_data(color_write_data), 
	.write_en(color_we), 

	.read_x(VGA_X_d0), 
	.read_y(VGA_Y_d0),
	.read_addr(VGA_Addr_d0),
	.read_data(color_read_data), 
	.data_valid(color_data_valid), 
	.just_read_x(color_just_read_x), 
	.just_read_y(color_just_read_y),
	.just_read_addr(color_just_read_addr)

);

localparam x = 0;
localparam y = 1;
wire unsigned [9:0] top_left 	[0:1];
wire unsigned [9:0] top_right 	[0:1];
wire unsigned [9:0] bot_left 	[0:1];
wire unsigned [9:0] bot_right 	[0:1];

wire unsigned [9:0] top_left_d20 	[0:1];
wire unsigned [9:0] top_right_d20 	[0:1];
wire unsigned [9:0] bot_left_d20 	[0:1];
wire unsigned [9:0] bot_right_d20 	[0:1];

wire signed [10:0] top_left_fsm [0:1];
wire signed [10:0] top_right_fsm [0:1];
wire signed [10:0] bot_left_fsm [0:1];
wire signed [10:0] bot_right_fsm [0:1];

wire signed [10:0] top_left_fsm_d20 [0:1];
wire signed [10:0] top_right_fsm_d20 [0:1];
wire signed [10:0] bot_left_fsm_d20 [0:1];
wire signed [10:0] bot_right_fsm_d20 [0:1];


//Y, Cb, Cr are synced up with RGB out of the VGA controller.
//Y, Cb, Cr are synced up wtih X and Y out of the VGA controller

wire [9:0] color_x, color_y, color_x_d7, color_y_d7;
//delays output color_ by 3
color_detect color_detect (
	.clk(VGA_CLK), 
	.reset(reset), 
	.VGA_VS(VGA_VS_d3),
	.Cb(Cb_d3), 
	.Cr(Cr_d3),
	.color_history(color_read_data),
	.color_valid(color_data_valid),
	.read_addr(color_just_read_addr),
	.read_x(color_just_read_x), 
	.read_y(color_just_read_y),
	.threshold_Cb_green(8'b01111100),
	.threshold_Cr_green(8'b01111000),
	.threshold_history(2'b11), 

	.color_detected(color_d3), //3 bits -> color of pixel
	.color_x(color_x), 
	.color_y(color_y),

	.top_left_prev_x(top_left[x]), 
	.top_right_prev_x(top_right[x]), 
	.bot_left_prev_x(bot_left[x]), 
	.bot_right_prev_x(bot_right[x]),
	.top_left_prev_y(top_left[y]),
	.top_right_prev_y(top_right[y]),
	.bot_left_prev_y(bot_left[y]),
	.bot_right_prev_y(bot_right[y]),

	.updated_color_history(color_write_data), 
	.we(color_we), 
	.write_addr(color_write_addr)
);
delay #( .DATA_WIDTH(3), .DELAY(17) ) color_detected_delay
( 
	.clk 		(VGA_CLK), 
	.data_in 	(color_d3), 
	.data_out 	(color_d20)
);
delay #( .DATA_WIDTH(80), .DELAY(17) ) old_corner_delay
(
	.clk 		(VGA_CLK), 
	.data_in 	({	top_left[x], top_right[x], 
					bot_left[x], bot_right[x],
					top_left[y], top_right[y],
					bot_left[y], bot_right[y]}), 
	.data_out   ({	top_left_d20[x], top_right_d20[x], 
					bot_left_d20[x], bot_right_d20[x],
					top_left_d20[y], top_right_d20[y],
					bot_left_d20[y], bot_right_d20[y]})
);


delay #(.DATA_WIDTH(20), .DELAY(4)) delay_color_xy
(
	.clk 		(VGA_CLK), 
	.data_in 	({color_x, color_y}), 
	.data_out 	({color_x_d7, color_y_d7})
);

wire median_color_, median_color;
wire color_detected = (color_d3 == GREEN);
//delays output by 4
// should the controls on this be delayed? todo
median_filter median_filter_color (
	.clk(VGA_CLK), 
	.reset(reset), 
	.ram_clr(!VGA_VS_d3),
	.VGA_BLANK_N(VGA_BLANK_N_d3), 
	.data_in(color_detected), 
	.data_out(median_color_)
);
delay #( .DATA_WIDTH(1), .DELAY(13) ) median_color_delay
( 
	.clk 		(VGA_CLK), 
	.data_in 	(median_color_), 
	.data_out 	(median_color)
);

//delays corner (x,y) by 1
//inputs are delayed by 7 already
wire [9:0] test_x_max, test_x_min, test_y_max, test_y_min;
wire [9:0] test_x_max_ylocalmin, test_x_max_ylocalmax,
		   test_x_min_ylocalmin, test_x_min_ylocalmax,
		   test_y_max_xlocalmin, test_y_max_xlocalmax, 
		   test_y_min_xlocalmin, test_y_min_xlocalmax;

fsm corner_follower (
	.clk(VGA_CLK), 
	.reset(reset), 
	.VGA_VS(VGA_VS_d7), 
	.pixel_valid(median_color_), 
	.pixel_x({1'b0, color_x_d7}),
	.pixel_y({1'b0, color_y_d7}),
	// .movement_threshold(SW[17:7]), 
	.threshold({1'b0, SW[17:8]}),
	.offset(SW[7:2]),
	.out_top_left_x(top_left_fsm[x]),
    .out_top_left_y(top_left_fsm[y]),
    .out_top_right_x(top_right_fsm[x]),
    .out_top_right_y(top_right_fsm[y]),
    .out_bot_left_x(bot_left_fsm[x]),
    .out_bot_left_y(bot_left_fsm[y]),
    .out_bot_right_x(bot_right_fsm[x]),
    .out_bot_right_y(bot_right_fsm[y]), 

    .state(LEDG[3:0]), 
    .thresh_exceeded_flags(LEDG[7:4]),
    .count(),
    .thresh_flags(LEDR[15:0]), 
    .test_x_max(test_x_max), 
    .test_x_min(test_x_min), 
    .test_y_max(test_y_max),
    .test_y_min(test_y_min), 
    .test_x_max_ylocalmin(test_x_max_ylocalmin),
    .test_x_max_ylocalmax(test_x_max_ylocalmax),
    .test_x_min_ylocalmin(test_x_min_ylocalmin),
    .test_x_min_ylocalmax(test_x_min_ylocalmax),
    .test_y_max_xlocalmin(test_y_max_xlocalmin),
    .test_y_max_xlocalmax(test_y_max_xlocalmax),
    .test_y_min_xlocalmin(test_y_min_xlocalmin),
    .test_y_min_xlocalmax(test_y_min_xlocalmax),
);

delay #( .DATA_WIDTH(88), .DELAY(12) ) fsm_corner_delay
(
	.clk 		(VGA_CLK), 
	.data_in 	({	top_left_fsm[x], top_right_fsm[x], 
					bot_left_fsm[x], bot_right_fsm[x],
					top_left_fsm[y], top_right_fsm[y],
					bot_left_fsm[y], bot_right_fsm[y]}), 
	.data_out   ({	top_left_fsm_d20[x], top_right_fsm_d20[x], 
					bot_left_fsm_d20[x], bot_right_fsm_d20[x],
					top_left_fsm_d20[y], top_right_fsm_d20[y],
					bot_left_fsm_d20[y], bot_right_fsm_d20[y]})
);

localparam NONE = 3'd0;
localparam TOP_LEFT = 3'd1;
localparam TOP_RIGHT = 3'd2;
localparam BOTTOM_LEFT = 3'd3; 
localparam BOTTOM_RIGHT = 3'd4;
localparam GREEN = 3'd5;

always @ (*) begin
	case (SW[1:0])
		//old corners
		2'd0: begin
			//Red: top left
			if (VGA_X_d20 < top_left_d20[x] + 5 && VGA_X_d20 >= top_left_d20[x] - 5
			 && VGA_Y_d20 < top_left_d20[y] + 5 && VGA_Y_d20 >= top_left_d20[y] - 5) begin
					VGA_R = 8'hFF;
					VGA_G = 8'h00;
					VGA_B = 8'h00;
				end
			//orange: top right
			else if (VGA_X_d20 < top_right_d20[x] + 5 && VGA_X_d20 >= top_right_d20[x] - 5
			 	  && VGA_Y_d20 < top_right_d20[y] + 5 && VGA_Y_d20 >= top_right_d20[y] - 5) begin
					VGA_R = 8'hFF;
					VGA_G = 8'd125;
					VGA_B = 8'h00;
				end
			//yellow: bottom left
			else if (VGA_X_d20 < bot_left_d20[x] + 5 && VGA_X_d20 >= bot_left_d20[x] - 5
			      && VGA_Y_d20 < bot_left_d20[y] + 5 && VGA_Y_d20 >= bot_left_d20[y] - 5) begin
					VGA_R = 8'hFF;
					VGA_G = 8'hFF;
					VGA_B = 8'h00;
				end
			//cyan: bottom right
			else if (VGA_X_d20 < bot_right_d20[x] + 5 && VGA_X_d20 >= bot_right_d20[x] - 5
			      && VGA_Y_d20 < bot_right_d20[y] + 5 && VGA_Y_d20 >= bot_right_d20[y] - 5) begin
					VGA_R = 8'h00;
					VGA_G = 8'hFF;
					VGA_B = 8'hFF;
				end

			//Green area : pink
			else if (color_d20 == GREEN) begin
				VGA_R = 8'hFF;
				VGA_G = 8'h00;
				VGA_B = 8'hFF;
			end
			
			else begin
				VGA_R = VGA_R_;
				VGA_G = VGA_G_;
				VGA_B = VGA_B_;
			end
		end

		//new fsm with median filtering
		2'd1: begin
			//Red: top left
			if (VGA_X_d20 < top_left_fsm_d20[x] + 5 && VGA_X_d20 >= top_left_fsm_d20[x] - 5
			 && VGA_Y_d20 < top_left_fsm_d20[y] + 5 && VGA_Y_d20 >= top_left_fsm_d20[y] - 5) begin
					VGA_R = 8'hFF;
					VGA_G = 8'h00;
					VGA_B = 8'h00;
				end
			//orange: top right
			else if (VGA_X_d20 < top_right_fsm_d20[x] + 5 && VGA_X_d20 >= top_right_fsm_d20[x] - 5
			 	  && VGA_Y_d20 < top_right_fsm_d20[y] + 5 && VGA_Y_d20 >= top_right_fsm_d20[y] - 5) begin
					VGA_R = 8'hFF;
					VGA_G = 8'd125;
					VGA_B = 8'h00;
				end
			//yellow: bottom left
			else if (VGA_X_d20 < bot_left_fsm_d20[x] + 5 && VGA_X_d20 >= bot_left_fsm_d20[x] - 5
			      && VGA_Y_d20 < bot_left_fsm_d20[y] + 5 && VGA_Y_d20 >= bot_left_fsm_d20[y] - 5) begin
					VGA_R = 8'hFF;
					VGA_G = 8'hFF;
					VGA_B = 8'h00;
				end
			//cyan: bottom right
			else if (VGA_X_d20 < bot_right_fsm_d20[x] + 5 && VGA_X_d20 >= bot_right_fsm_d20[x] - 5
			      && VGA_Y_d20 < bot_right_fsm_d20[y] + 5 && VGA_Y_d20 >= bot_right_fsm_d20[y] - 5) begin
					VGA_R = 8'h00;
					VGA_G = 8'hFF;
					VGA_B = 8'hFF;
				end

			//Green area : pink
			else if (median_color) begin
				VGA_R = 8'hFF;
				VGA_G = 8'h00;
				VGA_B = 8'hFF;
			end
			
			else begin
				VGA_R = VGA_R_;
				VGA_G = VGA_G_;
				VGA_B = VGA_B_;
			end

			//red
			if(VGA_X_d20 == test_x_max
				&& VGA_Y_d20 >= test_x_max_ylocalmin
				&& VGA_Y_d20 <= test_x_max_ylocalmax ) begin
				VGA_R = 8'hFF;
				VGA_G = 8'h00;
				VGA_B = 8'h00;
			end
			//orange
			else if(VGA_X_d20 == test_x_min 
				&& VGA_Y_d20 >= test_x_min_ylocalmin
				&& VGA_Y_d20 <= test_x_min_ylocalmax ) begin
				VGA_R = 8'hFF;
				VGA_G = 8'd125;
				VGA_B = 8'h00;
			end

			//yellow
			else if (VGA_Y_d20 == test_y_max 
				&& VGA_X_d20 >= test_y_max_xlocalmin
				&& VGA_X_d20 <= test_y_max_xlocalmax ) begin
				VGA_R = 8'hFF;
				VGA_G = 8'hFF;
				VGA_B = 8'h00;
			end
			//cyan
			else if (VGA_Y_d20 == test_y_min 
				&& VGA_X_d20 >= test_y_min_xlocalmin
				&& VGA_X_d20 <= test_y_min_xlocalmax ) begin
				VGA_R = 8'h00;
				VGA_G = 8'hFF;
				VGA_B = 8'hFF;
			end

		end

	    //ymax
		2'd2: begin
			//red
			if(VGA_X_d20 == test_x_max
				&& VGA_Y_d20 >= test_x_max_ylocalmin
				&& VGA_Y_d20 <= test_x_max_ylocalmax ) begin
				VGA_R = 8'hFF;
				VGA_G = 8'h00;
				VGA_B = 8'h00;
			end
			//orange
			else if(VGA_X_d20 == test_x_min 
				&& VGA_Y_d20 >= test_x_min_ylocalmin
				&& VGA_Y_d20 <= test_x_min_ylocalmax ) begin
				VGA_R = 8'hFF;
				VGA_G = 8'd125;
				VGA_B = 8'h00;
			end

			//yellow
			else if (VGA_Y_d20 == test_y_max 
				&& VGA_X_d20 >= test_y_max_xlocalmin
				&& VGA_X_d20 <= test_y_max_xlocalmax ) begin
				VGA_R = 8'hFF;
				VGA_G = 8'hFF;
				VGA_B = 8'h00;
			end
			//cyan
			else if (VGA_Y_d20 == test_y_min 
				&& VGA_X_d20 >= test_y_min_xlocalmin
				&& VGA_X_d20 <= test_y_min_xlocalmax ) begin
				VGA_R = 8'h00;
				VGA_G = 8'hFF;
				VGA_B = 8'hFF;
			end
			else if (median_color) begin
				VGA_R = 8'hFF;
				VGA_G = 8'h00;
				VGA_B = 8'hFF;
			end
			else begin
				VGA_R = VGA_R_;
				VGA_G = VGA_G_;
				VGA_B = VGA_B_;
			end
			//Red: top left
			//orange: top right
			//yellow: bottom left
			//cyan: bottom right
		end

		//median filtering
		2'd3: begin
			if (median_color) begin
				VGA_R = 8'hFF;
				VGA_G = 8'h00;
				VGA_B = 8'hFF;
			end
			
			else begin
				VGA_R = VGA_R_;
				VGA_G = VGA_G_;
				VGA_B = VGA_B_;
			end
		end

		default: begin
			if (harris_feature > threshold && color_d20==GREEN) begin
				VGA_R = 8'hFF;
				VGA_G = 8'hFF;
				VGA_B = 8'h00;
			end
			else begin
				VGA_R = VGA_R_;
				VGA_G = VGA_G_;
				VGA_B = VGA_B_;
			end
		end
	 endcase
end

//	Line buffer, delay one line
Line_Buffer u10	(	.aclr(!DLY0),
					.clken(VGA_Read),
					.clock(TD_CLK27),
					.shiftin(mYCbCr_d),
					.shiftout(m3YCbCr));

Line_Buffer u11	(	.aclr(!DLY0),
					.clken(VGA_Read),
					.clock(TD_CLK27),
					.shiftin(m3YCbCr),
					.shiftout(m4YCbCr));

AUDIO_DAC 	u12	(	//	Audio Side
					.oAUD_BCK(AUD_BCLK),
					.oAUD_DATA(AUD_DACDAT),
					.oAUD_LRCK(AUD_DACLRCK),
					//	Control Signals
					.iSrc_Select(2'b01),
			        .iCLK_18_4(AUD_CTRL_CLK),
					.iRST_N(DLY1)	);

//	Audio CODEC and video decoder setting
I2C_AV_Config 	u1	(	//	Host Side
						.iCLK(CLOCK_50),
						.iRST_N(!reset),
						//	I2C Side
						.I2C_SCLK(I2C_SCLK),
						.I2C_SDAT(I2C_SDAT)	);	

//----------Read from the ROM------------//
wire [10:0] draw_start [0:1]; //(x,y) coordinates of where to start drawing
wire [10:0] draw_end   [0:1]; //(x,y) coordinates of where to stop drawing
assign draw_start[x] = 11'd100; 
assign draw_start[y] = 11'd100;
wire signed [16:0] rom_addr_d20;
wire signed [16:0] rom_addr = 7'd80 * (VGA_Y_d0-draw_start[y]) + (VGA_X_d0-draw_start[x]);
wire [7:0] rom_R, rom_G, rom_B, rom_R_d20, rom_G_d20, rom_B_d20;
rom_clocktower clocktower (
	.clock(VGA_CLK), 
	.address_a(rom_addr[15:0]), 
	.address_b(), 
	.q_a({rom_R, rom_G, rom_B}), 
	.q_b()
);

delay #( .DATA_WIDTH(24), .DELAY(18) ) delay_rom_rgb
( 
	.clk 		(VGA_CLK), 
	.data_in 	({rom_R, rom_G, rom_B}), 
	.data_out 	({rom_R_d20, rom_G_d20, rom_B_d20})
);
delay #( .DATA_WIDTH(17), .DELAY(18) ) delay_rom_addr
( 
	.clk 		(VGA_CLK), 
	.data_in 	(rom_addr), 
	.data_out 	(rom_addr_d20)

);


endmodule

