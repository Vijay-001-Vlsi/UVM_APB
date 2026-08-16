class generator;
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
endclass
