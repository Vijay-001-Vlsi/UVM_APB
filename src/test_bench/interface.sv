`include "defines.svh"
interface apb_if(input logic PCLK ,input logic PRESETn);
	logic [`ADDR_WIDTH-1:0]PADDR;
	logic PSEL;
	logic PENABLE;
	logic PWRITE;
	logic [`DATA_WIDTH-1:0]PWDATA;
	logic [`DATA_WIDTH/8-1:0]PSTRB; 
	logic [`DATA_WIDTH-1:0]PRDATA;    
	logic PREADY;                    
        logic PSLVERR;

        property p_setup_to_access;
                @(posedge PCLK)
                (PSEL &&  !PENABLE)
                |=>PENABLE;
        endproperty
        assert property(p_setup_to_access);

	property p_addr_stable;
		@(posedge PCLK)
		(PSEL && PENABLE && !PREADY)
			|=>$stable(PADDR);
	endproperty
	assert property(p_addr_stable);

	property p_data_stable;
		@(posedge PCLK)
		(PSEL && PENABLE && !PREADY && PWRITE)
			|=>$stable(PWDATA);
	endproperty
	assert property(p_data_stable);

	property p_pwrite_stable;
		@(posedge PCLK)
		(PSEL && PENABLE && !PREADY)
			|=>$stable(PWRITE);
	endproperty
	assert property (p_pwrite_stable);

	property p_pstrb_stable;
		@(posedge PCLK)
		(PSEL && PENABLE && !PREADY && PWRITE)
			|=>$stable(PSTRB);
	endproperty
	assert property(p_pstrb_stable);

	property p_read_data_valid;
		@(posedge PCLK)
		(PSEL && PENABLE && PREADY && !PWRITE)
			|->!$isunknown(PRDATA);
	endproperty
	assert property(p_read_data_valid);

	property p_pstrb_read;
		@(posedge PCLK)
		(PSEL && !PWRITE)
			|->(PSTRB==0);
	endproperty
	assert property(p_pstrb_read);

	property p_pslverr_timing;
		@(posedge PCLK)
		PSLVERR
		|->(PREADY && PENABLE && PSEL);
	endproperty
	assert property(p_pslverr_timing);


	clocking drv @(posedge PCLK);
			default input #1 output #1;
			output PADDR;
			output PSEL;
			output PENABLE;
			output PWRITE;
			output PWDATA;
			output PSTRB;
			input PRDATA;
			input PREADY;
			input PSLVERR;
		endclocking

        clocking mon @(posedge PCLK);
                default input #1 output #1;
                input PADDR;
                input PSEL;
                input PENABLE;
                input PWRITE;
                input PWDATA;
                input PSTRB;
                input PRDATA;
                input PREADY;
                input PSLVERR;
        endclocking

        clocking refm @(posedge PCLK);
                default input #1 output #1;
                input PADDR;
                input PSEL;
                input PENABLE;
                input PWRITE;
                input PWDATA;
                input PSTRB;
                output PRDATA;
                output PREADY;
                output PSLVERR;
        endclocking

	modport DRIVER(clocking drv,input PCLK,input PRESETn);
	modport MONITOR(clocking mon,input PCLK,input PRESETn);
	 modport REF(clocking refm,input PCLK,input PRESETn);
endinterface
