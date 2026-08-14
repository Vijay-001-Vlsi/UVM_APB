class test;
    environment env;

    function new(virtual apb_if vif);
        env = new(vif);
    endfunction

    task run();
        env.run();
    endtask

    task report();
        env.report();
    endtask
endclass
