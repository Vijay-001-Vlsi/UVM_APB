//class driver;
//        mailbox #(transaction)gd_mbx;
//        mailbox #(transaction)dr_mbx;
//        virtual apb_if.DRIVER vif;
//        transaction txn;
//        function new(mailbox #(transaction)gd_mbx,
//                mailbox #(transaction)dr_mbx,
//                virtual apb_if.DRIVER vif);
//                this.gd_mbx=gd_mbx;
//		this.dr_mbx=dr_mbx;
//                this.vif=vif;
//        endfunction
//
//	task reset();
//		vif.drv.PADDR<='0;
//		vif.drv.PSEL<=0;
//		vif.drv.PENABLE<=0;
//		vif.drv.PWRITE<=0;
//		vif.drv.PWDATA<='0;
//		vif.drv.PSTRB<='0;
//	endtask
//
//	task run();
//		repeat(3)@(vif.drv);
//		for(int i=0;i<`num_transaction;i++)begin
//			gd_mbx.get(txn);
//			if(vif.PRESETn==0)begin
//				@(vif.drv);
//				reset();
//				dr_mbx.put(txn);
//				@(vif.drv);
//				$display("[DRIVER][%0t]Driving RESET to interface:PADDR=0,PSEL=0,PENABLE=0,PWRITE=0,PWDATA=0,PSTRB=0",$time);
//			end
//			else begin
//				//@(vif.drv);
//				vif.drv.PADDR<=txn.addr;
//				vif.drv.PSEL<=txn.sel;
//				vif.drv.PENABLE<=txn.penable;
//				vif.drv.PWRITE<=txn.pwrite;
//				vif.drv.PWDATA<=txn.pwdata;
//				vif.drv.PSTRB<=txn.pstrb;
//				dr_mbx.put(txn);
//				@(vif.drv);
//				$display("[DRIVER][%0t]to interface PSEL=%0b PENABLE=%0b,PADDR=%0d,PWRITE=%b,PWDATA=%d,PSTRB=%0b",$time,txn.sel,txn.penable,txn.addr,txn.pwrite,txn.pwdata,txn.pstrb);			end
//		end
//		endtask
//endclass
//
//
//


class driver;
        mailbox #(transaction) gd_mbx;
        mailbox #(transaction) dr_mbx;
        virtual apb_if.DRIVER vif;
        transaction txn;

        covergroup drv_cg;
            option.per_instance = 1;

            cp_reset : coverpoint vif.PRESETn {
                bins reset_active   = {0};
                bins reset_inactive = {1};
            }

            cp_write : coverpoint txn.pwrite {
                bins write = {1};
                bins read  = {0};
            }

            cp_sel : coverpoint txn.sel {
                bins sel_active   = {1};
                bins sel_inactive = {0};
            }

            cp_penable : coverpoint txn.penable {
                bins penable_active   = {1};
                bins penable_inactive = {0};
            }

            cp_addr : coverpoint txn.addr {
                bins low_addr  = {[0:15]};
                bins mid_addr  = {[16:31]};
                bins high_addr = {[32:$]};
            }

            cp_pstrb : coverpoint txn.pstrb {
                bins strb_0000 = {4'b0000};
                bins strb_0001 = {4'b0001};
                bins strb_0011 = {4'b0011};
                bins strb_0111 = {4'b0111};
                bins strb_1111 = {4'b1111};
                bins others    = default;
            }

            cross_write_addr : cross cp_write, cp_addr;

            cross_write_strb : cross cp_write, cp_pstrb;
        endgroup

        function new(mailbox #(transaction) gd_mbx,
                mailbox #(transaction) dr_mbx,
                virtual apb_if.DRIVER vif);
                this.gd_mbx = gd_mbx;
                this.dr_mbx = dr_mbx;
                this.vif    = vif;
                drv_cg = new();
        endfunction

        task reset();
                vif.drv.PADDR   <= '0;
                vif.drv.PSEL    <= 0;
                vif.drv.PENABLE <= 0;
                vif.drv.PWRITE  <= 0;
                vif.drv.PWDATA  <= '0;
                vif.drv.PSTRB   <= '0;
        endtask

        task run();
                repeat(3) @(vif.drv);
                for(int i=0; i<`num_transaction; i++) begin
                        gd_mbx.get(txn);
                         if(vif.PRESETn == 0) begin
                                @(vif.drv);
                                reset();
                                dr_mbx.put(txn);
                                @(vif.drv);
                                drv_cg.sample();   
                                $display("[DRIVER][%0t]Driving RESET to interface:PADDR=0,PSEL=0,PENABLE=0,PWRITE=0,PWDATA=0,PSTRB=0",$time);
                        end
                        else begin
                                vif.drv.PADDR   <= txn.addr;
                                vif.drv.PSEL    <= txn.sel;
                                vif.drv.PENABLE <= txn.penable;
                                vif.drv.PWRITE  <= txn.pwrite;
                                vif.drv.PWDATA  <= txn.pwdata;
                                vif.drv.PSTRB   <= txn.pstrb;
                                dr_mbx.put(txn);
                            
                                drv_cg.sample();   
                                $display("[DRIVER][%0t]to interface PSEL=%0b PENABLE=%0b,PADDR=%0d,PWRITE=%b,PWDATA=%d,PSTRB=%0b",
                                          $time,txn.sel,txn.penable,txn.addr,txn.pwrite,txn.pwdata,txn.pstrb);
				@(vif.drv);
                        end
                end
        endtask

        function void report_coverage();
                $display("-----------------------------------------------------");
                $display(" Functional Coverage = %0.2f %%", drv_cg.get_coverage());
                $display("------------------------------------------------------");
        endfunction

endclass
