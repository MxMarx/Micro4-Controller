function varargout = Micro4Keypad(varargin)
% MICRO4KEYPAD MATLAB code for Micro4Keypad.fig
%      MICRO4KEYPAD, by itself, creates a new MICRO4KEYPAD or raises the existing
%      singleton*.
%
%      H = MICRO4KEYPAD returns the handle to a new MICRO4KEYPAD or the handle to
%      the existing singleton*.
%
%      MICRO4KEYPAD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MICRO4KEYPAD.M with the given input arguments.
%
%      MICRO4KEYPAD('Property','Value',...) creates a new MICRO4KEYPAD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Micro4Keypad_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Micro4Keypad_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help Micro4Keypad
% Last Modified by GUIDE v2.5 16-Aug-2018 12:06:57
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Micro4Keypad_OpeningFcn, ...
    'gui_OutputFcn',  @Micro4Keypad_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
% --- Executes just before Micro4Keypad is made visible.
function Micro4Keypad_OpeningFcn(hObject, eventdata, handles, varargin)

% Reset serial devices, and try to connect
instrreset;
try
    handles.s = serial('COM1','databits',8,'baudrate',9600);
catch
    errordlg('Could not connect to serial device.')
end
fopen(handles.s);

setLine(handles.s,2)

handles.airvolume=500.0;
handles.injectvolume = true;
set(handles.figure1, 'units', 'normalized', 'position', [0.05 0.15 0.6 0.8])

handles.HelpSection.String = sprintf(['Help? \n\n 1. Withdraw 500nl of at 200/s \n\n 2. Withdraw injection volume x number of injections(water)'...
    '\n\n 3. Withdraw injection volume x number of injection (virus) \n\n 4. Inject 100nl at 200/s \n\n'...
    '5. Inject remaining injection volume at 200/m \n\n 6. Inject and immediatly wirthdraw 100nl at 200/s'...
    '\n\n ** press 7 on keypad to inject at full speed \n\n ** press 8 on keypad to withdraw at full speed']);
handles.pushbutton1.String = sprintf(['<html><center><b><font size="+7">1</font></b><br> Withdraw <br>',num2str(handles.airvolume), 'nl']);
handles.pushbutton2.String = '<html><center><b><font size="+7">2</font></b><br> Withdraw <br>2000nl at 200/s ';
handles.pushbutton3.String = '<html><center><b><font size="+7">3</font></b><br> Withdraw<br> 2000nl at 200/s';
handles.pushbutton4.String = '<html><center><b><font size="+7">4</font></b><br> Inject<br> 100nl at 200/s';
handles.pushbutton5.String = '<html><center><b><font size="+7">5</font></b><br> Inject<br> remaining at 200/m';
handles.pushbutton6.String = '<html><center><b><font size="+7">6</font></b><br> Inject and Withdraw<br>100nl at 200/s';

handles.keydreleased = 1; % for keys 7 and 8

% Choose default command line output for Micro4Keypad
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Micro4Keypad_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
%   % Try to open the connections.
if checkSyringe(handles); return; end

varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
%% Withdraw Air
function pushbutton1_Callback(hObject, eventdata, handles)
if checkSyringe(handles); return; end

setCounter(handles.s,0)
setVolume(handles.s,num2str(handles.airvolume))
setSeconds(handles.s)
setRate(handles.s,200)
Withdraw(handles.s)
Go(handles.s)



% --- Executes on button press in pushbutton2.
%% Withdraw Water
function pushbutton2_Callback(hObject, eventdata, handles)
if checkSyringe(handles); return; end
if checkValues(handles); return; end

% Withdraw injection volume times number of injections
waterVolume = str2double(handles.InjectionVolume.String) .* str2double(handles.InjectionNumbers.String);

setCounter(handles.s,0)
setVolume(handles.s,waterVolume)
setSeconds(handles.s)
setRate(handles.s,200)
Withdraw(handles.s)
Go(handles.s)


%% Withdraw Virus
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
if checkSyringe(handles); return; end
if checkValues(handles); return; end

% Withdraw injection volume times number of injections plus 200 extra
virusVolume = str2double(handles.InjectionVolume.String) .* str2double(handles.InjectionNumbers.String);
virusVolume = virusVolume + 200;

setCounter(handles.s,0)
setVolume(handles.s,virusVolume)
setSeconds(handles.s)
setRate(handles.s,200)
Withdraw(handles.s)
Go(handles.s)

handles.InjectNotStarted = true;
guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
if checkSyringe(handles); return; end

direction = query(handles.s,'D');
if direction == 'W'
    Infuse(handles.s)
end

if handles.InjectNotStarted
    handles.InjectNotStarted = false;
    guidata(hObject, handles);
    setCounter(handles.s,0)
end

volumeInjected = query(handles.s,'C');
setRate(handles.s,200)
setCounter(handles.s,volumeInjected+100)
setSeconds(handles.s)
Go(handles.s)



% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
handles.InjectNotStarted = true;
guidata(hObject, handles);

direction = query(handles.s,'D');
if direction == 'W'
    Infuse(handles.s)
end

volume = str2double(handles.InjectionVolume.String);
rate = str2double(handles.InjectionRate.String);

setCounter(handles.s,volume)
setRate(handles.s,rate)
setMinute(handles.s)
Go(handles.s)



function pushbutton6_Callback(hObject, eventdata, handles)


volumeInjected = query(handles.s,'C');

Infuse(handles.s)
setCounter(handles.s,0)
setRate(handles.s,200)
setSecond(handles.s)
setVolume(handles.s,100)
Go(handles.s)

pause(0.55);

Withdraw(handles.s)
setCounter(handles.s,0)
setRate(handles.s,200)
setSecond(handles.s)
setVolume(handles.s,100)
Go(handles.s)

pause(0.55);

setCounter(handles.s,volumeInjected)
Infuse(handles.s)
setMinute(handles.s)




function InjectionNumbers_Callback(hObject, eventdata, handles)
handles.pushbutton2.String = sprintf([ '<html><center><b><font size="+7">2</font></b><br> Withdraw <br>',...
    num2str(str2num(handles.InjectionVolume.String)*str2num(handles.InjectionNumbers.String)),' nl at 200/s']);
handles.pushbutton3.String = sprintf([ '<html><center><b><font size="+7">3</font></b><br> Withdraw <br>',...
    num2str(200+(str2num(handles.InjectionVolume.String)*str2num(handles.InjectionNumbers.String))),' nl at 200/s']);

% --- Executes during object creation, after setting all properties.
function InjectionNumbers_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function InjectionVolume_Callback(hObject, eventdata, handles)
handles.pushbutton3.String = sprintf([ '<html><center><b><font size="+7">3</font></b><br> Withdraw <br>',...
    num2str(str2num(handles.InjectionVolume.String)*str2num(handles.InjectionNumbers.String)),' nl at 200/s']);
handles.pushbutton2.String = sprintf([ '<html><center><b><font size="+7">2</font></b><br> Withdraw <br>',...
    num2str(str2num(handles.InjectionVolume.String)*str2num(handles.InjectionNumbers.String)),' nl at 200/s']);
function InjectionNumbers_KeyPressFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function InjectionVolume_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)

switch eventdata.Key
    case 'numpad1'
        pushbutton1_Callback(hObject, eventdata, handles)
    case 'numpad2'
        pushbutton2_Callback(hObject, eventdata, handles)
    case 'numpad3'
        pushbutton3_Callback(hObject, eventdata, handles)
    case 'numpad4'
        pushbutton4_Callback(hObject, eventdata, handles)
    case 'numpad5'
        pushbutton5_Callback(hObject, eventdata, handles)
    case 'numpad6'
        pushbutton6_Callback(hObject, eventdata, handles)
    case 'numpad7'
        if handles.keydreleased
            handles.keydreleased = 0;
            fprintf(handles.s,['V9999.0;']);
            fprintf(handles.s,'S');
            fprintf(handles.s,'R200.0;');
            fprintf(handles.s,'IG');
        end
    case 'numpad8'
        if handles.keydreleased
            handles.keydreleased = 0;
            fprintf(handles.s,['V9999.0;']);
            fprintf(handles.s,'S');
            fprintf(handles.s,'R200.0;');
            fprintf(handles.s,'WG');
        end
end
guidata(hObject, handles);

% --- Executes on key release with focus on figure1 and none of its controls.
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
switch eventdata.Key
    case {'numpad7','numpad8'}
        handles.keydreleased = 1;
        fprintf(handles.s,'H');
end
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)

switch eventdata.NewValue.String
    case 'Syringe 1'
        fprintf(handles.s, 'L1;');
    case 'Syringe 2'
        fprintf(handles.s, 'L2;');
    case 'Syringe 3'
        fprintf(handles.s, 'L3;');
    case 'Syringe 4'
        fprintf(handles.s, 'L4;');
end
handles.uibuttongroup1.HitTest = 'off';
uicontrol(hObject);
set(hObject, 'enable', 'off');
drawnow;
set(hObject, 'enable', 'on');
guidata(hObject, handles);


function InjectionRate_Callback(hObject, eventdata, handles)
handles.pushbutton5.String = sprintf([ '<html><center><b><font size="+7">5</font></b><br>',...
    'Inject<br> remaining at', handles.InjectionRate.String,'/m']);

handles.pushbutton4.String = (['<html><center><b><font size="+7">4</font></b><br> Inject<br> 100nl at', handles.InjectionRate.String,'/s']);

% --- Executes during object creation, after setting all properties.
function InjectionRate_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function CommError = checkSyringe(handles)
flushinput(handles.s);
fprintf(handles.s, '?S'); % Check syringe type
max = fgetl(handles.s);
out = sscanf(max,'?S%c');
if (~(out == 'F' || out == 'D'))
    f = errordlg('Syringe not found. Is it turned on?','Communication Error');
    CommError = true;
else
    CommError = false;
end



function ValsMissing = checkValues(handles)
if isempty(str2num(handles.InjectionVolume.String)) || isempty(str2num(handles.InjectionNumbers.String))...
        || isempty(str2num(handles.InjectionRate.String))
    f = errordlg('Make Sure To Input All variables','input Error');
    ValsMissing = true;
else
    ValsMissing = false;
end










function setVolume(s,volume)
Str = num2str(volume,'%.0f');
fprintf(s,['V' Str '.;']);
fgetl(s);

function setCounter(s,counter)
Str = num2str(counter,'%.0f');
fprintf(s,['C' Str '.;']);
fgetl(s);

function setRate(s,rate)
Str = num2str(rate,'%.0f');
fprintf(s,['R' Str '.;']);
fgetl(s);

function Infuse(s)
fprintf(s,'I');
fgetl(s);

function Withdraw(s)
fprintf(s,'W');
fgetl(s);

function Go(s)
fprintf(s,'G');
fgetl(s);

function Halt(s)
fprintf(s,'H');
fgetl(s);

function setSeconds(s)
fprintf(s,'S');
fgetl(s);

function setMinutes(s)
fprintf(s,'M');
fgetl(s);

function setLine(s,line)
Str = num2str(line,'%.0f');
fprintf(s,['L' Str ';']);
fgetl(s);

function out = query(s,q)
flushinput(s);
fprintf(s,['?' q]);
out = fgetl(s);
switch q
    case {'V','C','R'}
        out = sscanf(out,['?' q '%f']);
end



