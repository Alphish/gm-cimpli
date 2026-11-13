function CountUpProcessor(_terms) : CimpliTaskProcessor() constructor {
    terms_count = _terms;
    calculated_sum = 0;
    remaining_terms = undefined;
    next_milestone = 0;
    
    static init = function() {
        remaining_terms = array_create_ext(terms_count, function(i) { return i + 1; });
        next_milestone = (terms_count div 5000) - 1;
    }
    
    static process_step = function() {
        if (keyboard_check_pressed(ord("P")))
            throw "PANIC!";
        
        calculated_sum += array_shift(remaining_terms);
        if (array_length(remaining_terms) <= 0)
            return complete_with(calculated_sum);
        else
            return false;
    }
    
    // the update preparation prevents reporting after every run
    // and instead it makes the task report progress every 5k terms
    static prepare_update = function() {
        var _bulk_remaining = array_length(remaining_terms) / 5000;
        if (_bulk_remaining > next_milestone)
            return false;
        
        next_milestone -= 1;
        return true;
    }
    
    static cleanup = function(_auto) {
        // it may or may not tell the garbage collector to grab it faster
        delete remaining_terms;
        ctrl_CounterObserver.logger.log_debug($"Counter task cleanup completed. AUTO={_auto}");
    }
}