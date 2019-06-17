function output_txt = label_plot_data(obj,event_obj,xdata, WNames, PNames)
% Display an observation's Y-data and label for a data tip
% obj          Currently not used (empty)
% event_obj    Handle to event object
% xdata        x axis data
% labels       State names identifying matrix row
% output_txt   Datatip text (character vector or cell array 
%              of character vectors)

pos = get(event_obj,'Position');
x = pos(1);

idx = find(xdata == x,1);  % Find index to retrieve obs. name
% The find is reliable only if there are no duplicate x values

output_txt = [WNames(idx)
              PNames(idx)];
