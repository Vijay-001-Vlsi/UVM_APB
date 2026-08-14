class monitor;
        transaction txn;
        mailbox #(transaction) act_mbx;
        virtual apb_if.MONITOR vif;   


        function new(mailbox #(transaction) act_mbx,
                virtual apb_if.MONITOR vif);
                this.act_mbx=act_mbx;
                this.vif=vif;
        endfunction

	task run();
		for(int i=0;i<`num_transaction;i++)begin
                @(vif.mon);

                $display("[MONITOR][%0t]sample PSEL=%0b PENABLE=%0b PADDR=%0d PWRITE=%b PREADY=%0b PSLVERR=%0b",
                          $time, vif.mon.PSEL, vif.mon.PENABLE, vif.mon.PADDR, vif.mon.PWRITE,
                          vif.mon.PREADY, vif.mon.PSLVERR);

                if(vif.mon.PSEL && vif.mon.PENABLE) begin
                        txn=new();
                        txn.addr=vif.mon.PADDR;
                        txn.pwdata=vif.mon.PWDATA;
                        txn.pready=vif.mon.PREADY;
                        txn.pslverr=vif.mon.PSLVERR;
                        txn.sel=vif.mon.PSEL;
                        txn.penable=vif.mon.PENABLE;
                        txn.pwrite=vif.mon.PWRITE;
                        txn.pstrb=vif.mon.PSTRB;
                        txn.prdata=vif.mon.PRDATA;
                        $display("[MONITOR][%0t]to SCOREBOARD PSEL=%0b PENABLE=%0b,PADDR=%0d,PWRITE=%b,PWDATA=%d,PSTRB=%0b PSLVERR=%0b,PREADY=%0b,PRDATA=%0d",
                                  $time,txn.sel,txn.penable,txn.addr,txn.pwrite,txn.pwdata,txn.pstrb,txn.pslverr,txn.pready,txn.prdata);
                        act_mbx.put(txn);
                end
        end
endtask	
endclass


