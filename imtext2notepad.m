function varargout = imtext2notepad(varargin)
% IMTEXT2NOTEPAD MATLAB code for imtext2notepad.fig
%      IMTEXT2NOTEPAD, by itself, creates a new IMTEXT2NOTEPAD or raises the existing
%      singleton*.
%
%      H = IMTEXT2NOTEPAD returns the handle to a new IMTEXT2NOTEPAD or the handle to
%      the existing singleton*.
%
%      IMTEXT2NOTEPAD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMTEXT2NOTEPAD.M with the given input arguments.
%
%      IMTEXT2NOTEPAD('Property','Value',...) creates a new IMTEXT2NOTEPAD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imtext2notepad_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imtext2notepad_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imtext2notepad

% Last Modified by GUIDE v2.5 03-Mar-2019 16:54:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imtext2notepad_OpeningFcn, ...
                   'gui_OutputFcn',  @imtext2notepad_OutputFcn, ...
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


% --- Executes just before imtext2notepad is made visible.
function imtext2notepad_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imtext2notepad (see VARARGIN)

% Choose default command line output for imtext2notepad
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imtext2notepad wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imtext2notepad_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in LoadAndDisplayImage.
function LoadAndDisplayImage_Callback(hObject, eventdata, handles)
% hObject    handle to LoadAndDisplayImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Load:
[file_name, path_name] = uigetfile('*');
full_path = [path_name '\' file_name];
handles.im_original = imread(full_path);

% Display:
axes(handles.axes1)
imagesc(handles.im_original);
guidata(hObject, handles);
axis off


% --- Executes on button press in ConvertToNotePad.
function ConvertToNotePad_Callback(hObject, eventdata, handles)
% hObject    handle to ConvertToNotePad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


user_response = savedlg('Title', 'Confirm Save');
switch user_response
    case {'No'}
        % no
    case 'Yes'
        
        exBW=imbinarize(handles.im_original); %making pic binary.
        exBW=exBW(:,:,1);     %making pic one dimentional.
        exBWinv=1.-exBW;      %inverting black and white.
        exBWlabel=bwlabel(exBWinv); %labeling all letters

        textReader;
            
        
        
        [fileName, pathname] = uiputfile([path,'/*.txt'], 'Save as');
        newNotePad = fopen(fileName, 'a');
       
        for x=1 : length(str)
            fprintf(newNotePad, string(str(1,x)));
            
        end
        fclose(newNotePad);
end
