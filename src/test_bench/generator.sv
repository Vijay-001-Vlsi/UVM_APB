/*class generator;
        mailbox #(transaction)gd_mbx;
	transaction tx;
	function new(mailbox #(transaction)gd_mbx);
                this.gd_mbx=gd_mbx;
		tx=new();
        endfunction

	task run();
		for(int i=0;i<`num_transaction;i++)begin
			assert(tx.randomize())
			else $fatal("[GEN]randomization failed");
			tx.print("GEN");
			gd_mbx.put(tx.copy());
		end
	endtask
endclass*/
class generator;
        mailbox #(transaction)gd_mbx;
	transaction tx;

        // Pool of in-range addresses we've actually written. Used to bias
        // some reads onto addresses that already have non-zero data, so the
        // scoreboard's PRDATA compare is actually meaningful instead of
        // always trivially matching 0 == 0 on untouched memory.
        logic [`ADDR_WIDTH-1:0] written_addr[$];

	function new(mailbox #(transaction)gd_mbx);
                this.gd_mbx=gd_mbx;
		tx=new();
        endfunction

	task run();
		for(int i=0;i<`num_transaction;i++)begin
			assert(tx.randomize())
			else $fatal("[GEN]randomization failed");

			// Force ~1 in 4 completed reads onto a previously written
			// address so we actually verify DUT reads back what was
			// stored, instead of only ever reading zeroed memory.
			if(tx.present_state==access && !tx.pwrite &&
			   written_addr.size()>0 && ($urandom_range(0,3)==0)) begin
				tx.addr      = written_addr[$urandom_range(0,written_addr.size()-1)];
				tx.temp_addr = tx.addr;
			end

			// Track every in-range write so it can be targeted by a
			// later read.
			if(tx.present_state==access && tx.pwrite && tx.addr<`MEM_DEPTH)
				written_addr.push_back(tx.addr);

			tx.print("GEN");
			gd_mbx.put(tx.copy());
		end
	endtask
endclass





