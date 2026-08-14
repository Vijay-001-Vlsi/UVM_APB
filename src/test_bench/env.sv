class environment;
    generator   gen;
    driver      dr;
    reference   rf;
    monitor     mon;
    scoreboard  srb;

    mailbox #(transaction) gd_mbx;
    mailbox #(transaction) dr_mbx;
    mailbox #(transaction) exp_mbx;
    mailbox #(transaction) act_mbx;

    virtual apb_if vif;

    function new(virtual apb_if vif);
        this.vif = vif;

        gd_mbx  = new();
        dr_mbx  = new();
        exp_mbx = new();
        act_mbx = new();

        gen = new(gd_mbx);
        dr  = new(gd_mbx, dr_mbx, vif);
        rf  = new(dr_mbx, exp_mbx, vif);
        mon = new(act_mbx, vif);
        srb = new(exp_mbx, act_mbx);
    endfunction

    task run();
        fork
            gen.run();
            dr.run();
            rf.run();
            mon.run();
            srb.run();
        join_any
    endtask

    task report();
        srb.report();
    endtask
endclass
