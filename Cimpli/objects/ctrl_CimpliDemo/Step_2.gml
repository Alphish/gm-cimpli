var _next_timer = get_timer() + 10000;
if (!is_undefined(worker))
    worker.run_until(_next_timer);
