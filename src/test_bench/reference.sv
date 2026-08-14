class reference;
	mailbox #(transaction)dr_mbx;
	mailbox #(transaction)exp_mbx;
	virtual apb_if.REF vif;
	transaction txn;
	reg[`DATA_WIDTH-1:0]mem[0:`MEM_DEPTH-1];

	function new( mailbox #(transaction)dr_mbx,
		mailbox #(transaction)exp_mbx,
		virtual apb_if.REF vif);
		this.dr_mbx=dr_mbx;
		this.exp_mbx=exp_mbx;
		this.vif=vif;
	endfunction

	task run();
		for(int i=0;i<`MEM_DEPTH;i++)
		          mem[i]={`DATA_WIDTH{1'b0}};
		for(int i=0;i<`num_transaction;i++)begin
			dr_mbx.get(txn);
			@(vif.refm)
			txn.pready=1'b1;
                         
			if(txn.addr>=`MEM_DEPTH)begin				                                
				txn.pslverr=1;end
			else begin
				      txn.pslverr=0;
			end
			if(txn.sel && txn.penable)begin
				
				if(txn.pwrite && txn.addr<`MEM_DEPTH)begin
					for(int i=0;i<$bits(txn.pstrb);i++)begin
						if(txn.pstrb[i])begin
							mem[txn.addr][8*i+:8]=txn.pwdata[8*i+:8];
					//$display("[REFERENCE][%0t]to SCOREBOARD PSEL=%0b PENABLE=%0b,PADDR=%0d,PWRITE=%b,PWDATA=%d,PSTRB=%0b PSLVERR=%0b,PREADY=%0b",$time,txn.sel,txn.penable,txn.addr,txn.pwrite,txn.pwdata,txn.pstrb,txn.pslverr,txn.pready);
						end
					end
					$display("[REFERENCE][%0t]to SCOREBOARD PSEL=%0b PENABLE=%0b,PADDR=%0d,PWRITE=%b,PWDATA=%d,PSTRB=%0b PSLVERR=%0b,PREADY=%0b",$time,txn.sel,txn.penable,txn.addr,txn.pwrite,txn.pwdata,txn.pstrb,txn.pslverr,txn.pready);
			end
			else if(!txn.pwrite)begin
				txn.prdata=mem[txn.addr];
				$display("[REFERENCE][%0t]to SCOREBOARD PSEL=%0b PENABLE=%0b,PADDR=%0d,PWRITE=%b,PWDATA=%d,PSTRB=%0b PSLVERR=%0b,PREADY=%0b,PRDATA=%0d",$time,txn.sel,txn.penable,txn.addr,txn.pwrite,txn.pwdata,txn.pstrb,txn.pslverr,txn.pready,txn.prdata);
			end
				exp_mbx.put(txn);

			end
		end
	endtask
endclass





