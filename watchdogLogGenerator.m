%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: C:\Users\brook\Downloads\datalog.xlsx
%    Worksheet: datalog
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2018/02/08 15:37:35

%% Import the data, extracting spreadsheet dates in Excel serial date format
[~, ~, raw, dates] = xlsread('C:\Users\brook\Downloads\datalog3.xlsx','datalog','A2:A20000','',@convertSpreadsheetExcelDates);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
dates(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),dates)) = {''};
dates = dates(:,1);

%% Exclude rows with non-numeric cells
I = ~(all(cellfun(@isnumeric,dates),2)); % Find rows with non-numeric cells
raw(I,:) = [];
dates(I,:) = [];

%% Allocate imported array to column variable names
datetime1 = datetime([dates{:,1}].', 'ConvertFrom', 'Excel');
[y, m, d] = ymd(datetime1);
% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% datetime=datenum(datetime1);

%% Clear temporary variables
clearvars raw dates I datetime1;

%% Figure out number of rows of data
rowNum = length(y);

%% Import the data
[~, ~, raw] = xlsread('C:\Users\brook\Downloads\datalog.xlsx','datalog',['E2:V' num2str( rowNum+1)] );
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
datalog = reshape([raw{:}],size(raw));

%% Clear temporary variables
clearvars raw R;

%% Import the data labels
[~, ~, locationType] = xlsread('C:\Users\brook\Downloads\datalog.xlsx','datalog','E1:V1');

% locationType = string(locationType);
% locationType(ismissing(locationType)) = '';

comboVector=[y,m,d];
uniqueDays = unique(comboVector, 'rows'); % Vector for unique sets
numOfCombos = size(uniqueDays, 1);

for i = 1:numOfCombos
    logicTarget = ismember(comboVector, uniqueDays(i,:), 'rows');
    meanVal(i,:) = mean(datalog(logicTarget,:),1, 'omitnan');
    minVal(i,:) = min(datalog(logicTarget,:),[],1, 'omitnan');
    maxVal(i,:) = max(datalog(logicTarget,:),[],1, 'omitnan');   
end

fileName = ['chamberMonitorLog_' num2str(uniqueDays(1,1)) '-' num2str(uniqueDays(1,2)) '-' num2str(uniqueDays(1,3)) '_' ...
    num2str(uniqueDays(end,1)) '-' num2str(uniqueDays(end,2)) '-' num2str(uniqueDays(end,3)) '.xlsx'];

%% Write the average values to a sheet
xlswrite(fileName, locationType, 'average', 'B1')
t = datetime(uniqueDays);
DateString = datestr(t);
cellDays = cellstr(DateString);
xlswrite(fileName, cellDays, 'average', 'A2')
xlswrite(fileName, meanVal, 'average', 'B2')

%% Write the minimum values to a sheet
xlswrite(fileName, locationType, 'minimum', 'B1')
t = datetime(uniqueDays);
DateString = datestr(t);
cellDays = cellstr(DateString);
xlswrite(fileName, cellDays, 'minimum', 'A2')
xlswrite(fileName, minVal, 'minimum', 'B2')

%% Write the maximum values to a sheet
xlswrite(fileName, locationType, 'maximum', 'B1')
t = datetime(uniqueDays);
DateString = datestr(t);
cellDays = cellstr(DateString);
xlswrite(fileName, cellDays, 'maximum', 'A2')
xlswrite(fileName, maxVal, 'maximum', 'B2')
