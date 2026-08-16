class generator;
        mailbox #(transaction)gd_mbx;
        transaction tx;

        logic [`ADDR_WIDTH-1:0] written_addr[$];

        function new(mailbox #(transaction)gd_mbx);
                this.gd_mbx=gd_mbx;
                tx=new();
        endfunction

        task run();
                for(int i=0;i<`num_transaction;i++)begin
                        assert(tx.randomize())
                        else $fatal("[GEN]randomization failed");

                        if(tx.present_state==access && !tx.pwrite &&
                           written_addr.size()>0 && ($urandom_range(0,3)==0)) begin
                                tx.addr      = written_addr[$urandom_range(0,written_addr.size()-1)];
                                tx.temp_addr = tx.addr;
                        end
                        if(tx.present_state==access && tx.pwrite && tx.addr<`MEM_DEPTH)
                                written_addr.push_back(tx.addr);
                        tx.print("GEN");
                        gd_mbx.put(tx.copy());
                end
        endtask
endclass
