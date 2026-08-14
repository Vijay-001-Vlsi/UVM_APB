class scoreboard;
        transaction exp,act;
        mailbox #(transaction)exp_mbx;
        mailbox #(transaction)act_mbx;
        reg[`DATA_WIDTH-1:0]exp_mem[0:`MEM_DEPTH-1];
        reg[`DATA_WIDTH-1:0]act_mem[0:`MEM_DEPTH-1];
        int pass_count,fail_count;

        function new(mailbox #(transaction)exp_mbx,
                mailbox #(transaction)act_mbx);
                this.exp_mbx=exp_mbx;
                this.act_mbx=act_mbx;
        endfunction

	task run();
        forever begin
                fork
                        begin
                                exp_mbx.get(exp);
                                if(exp.pwrite)
                                        exp_mem[exp.addr]=exp.pwdata;
                        end
                        begin
                                act_mbx.get(act);
                                if(act.pwrite)
                                        act_mem[act.addr]=act.pwdata;
                        end
                join
                compare_report();
        end
endtask

task compare_report();
        logic match;
        logic [`DATA_WIDTH-1:0] exp_val, act_val;

        if(exp.addr >= `MEM_DEPTH) begin
                // invalid address: only PSLVERR matters, no data to compare
                match = (exp.pslverr === act.pslverr);
                $display("[SCOREBOARD] [%0t] ADDR=%0d (out of range) REF PSLVERR=%0b | MON PSLVERR=%0b",
                          $time, exp.addr, exp.pslverr, act.pslverr);
        end
        else if(exp.pwrite) begin
                exp_val = exp_mem[exp.addr];
                act_val = act_mem[act.addr];
                match = (exp_val === act_val);
                $display("[SCOREBOARD] [%0t] ADDR=%0d REF DATA_OUT = %0h | MON DATA_OUT = %0h",
                          $time, exp.addr, exp_val, act_val);
        end
        else begin
                exp_val = exp.prdata;
                act_val = act.prdata;
                match = (exp_val === act_val);
                $display("[SCOREBOARD] [%0t] ADDR=%0d REF DATA_OUT = %0h | MON DATA_OUT = %0h",
                          $time, exp.addr, exp_val, act_val);
        end

        if(match) begin
                pass_count++;
                $display("[SCOREBOARD] DATA MATCH SUCCESSFUL. pass_count = %0d",pass_count);
        end
        else begin
                fail_count++;
                $display("[SCOREBOARD] DATA MATCH FAILURE. fail_count = %0d",fail_count);
        end
endtask
function void report();
	                $display("---------------------------------------------------");
	                $display("[SCOREBOARD] TOTAL PASS = %0d", pass_count);
	                $display("[SCOREBOARD] TOTAL FAIL = %0d", fail_count);
	                $display("---------------------------------------------------");
	        endfunction
endclass
