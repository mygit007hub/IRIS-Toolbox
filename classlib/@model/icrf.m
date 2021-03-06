function [S, range, select] = icrf(this, time, varargin)
% icrf  Initial-condition response functions.
%
% Syntax
% =======
%
%     S = icrf(M, NPer, ...)
%     S = icrf(M, Range, ...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the initial condition responses
% will be simulated.
%
% * `Range` [ numeric | char ] - Date range with the first date being the
% shock date.
%
% * `NPer` [ numeric ] - Number of periods.
%
%
% Output arguments
% =================
%
% * `S` [ struct ] - Database with initial condition response series.
%
%
% Options
% ========
%
% * `'delog='` [ *`true`* | `false` ] - Delogarithmise the responses for
% variables declared as `!log_variables`.
%
% * `'size='` [ numeric | *`1`* for linear models | *`log(1.01)`* for non-linear
% models ] - Size of the deviation in initial conditions.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% Parse options.
opt = passvalopt('model.icrf', varargin{:});

% TODO: Introduce `'select='` option.

%--------------------------------------------------------------------------

[~, ~, nb] = sizeOfSolution(this.Vector);

% Set the size of the initial conditions.
if isempty(opt.size)
    % Default.
    if this.IsLinear
        size_ = ones(1, nb);
    else
        size_ = ones(1, nb)*log(1.01);
    end
else
    % User supplied.
    size_ = ones(1, nb)*opt.size;
end

select = get(this, 'initCond');
select = regexprep(select, 'log\((.*?)\)', '$1', 'once');

ixInit = model.Variant.getAnyIxInit(this.Variant, ':');
ixInit = any(ixInit, 3);

func = @(T, R, K, Z, H, D, U, Omg, ~, nPer) ...
    timedom.icrf(T, [ ], [ ], Z, [ ], [ ], U, [ ], ...
    nPer, size_, ixInit);

[S, range] = myrf(this, time, func, select, opt);

end
