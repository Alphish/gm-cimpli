function CountUpProcessor(_terms) : CimpliTaskProcessor() constructor {
    terms_count = _terms;
    calculated_sum = 0;
    remaining_terms = array_create_ext(_terms, function(i) { return i + 1; });
    
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
}