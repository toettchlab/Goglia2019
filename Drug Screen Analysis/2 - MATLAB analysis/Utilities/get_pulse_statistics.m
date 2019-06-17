function PS = get_pulse_statistics(well, p)
frames_to_analyze = p.frames_to_analyze;

MIN_PULSES = 2;

for i = 1:length(well)
    PS(i) = jt_get_pulse_statistics_1well(well(i), frames_to_analyze, MIN_PULSES);
end

PS = orderfields(PS);
