function CountUpProcessor(_terms) : CimpliTaskProcessor() constructor {
    terms_count = _terms;
    calculated_sum = 0;
    remaining_terms = undefined;
    
    static init = function() {
        remaining_terms = array_create_ext(terms_count, function(i) { return i + 1; });
    }
    
    static process_step = function() {
        calculated_sum += array_shift(remaining_terms);
        if (array_length(remaining_terms) <= 0)
            return complete_with(calculated_sum);
        else
            return false;
    }
    
    static get_progress = function() {
        return $"{terms_count - array_length(remaining_terms)}/{terms_count}";
    }
    
    static cleanup = function(_auto) {
        // it may or may not tell the garbage collector to grab it faster
        delete remaining_terms;
        ctrl_CimpliDemo.logger.log_debug($"Counter task cleanup completed. AUTO={_auto}");
    }
}