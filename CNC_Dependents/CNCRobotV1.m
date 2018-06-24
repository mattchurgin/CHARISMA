function varargout = CNCRobotV1(varargin)
%CNCROBOTV1 M-file for CNCRobotV1.fig
%      CNCROBOTV1, by itself, creates a new CNCROBOTV1 or raises the existing
%      singleton*.
%
%      H = CNCROBOTV1 returns the handle to a new CNCROBOTV1 or the handle to
%      the existing singleton*.
%
%      CNCROBOTV1('Property','Value',...) creates a new CNCROBOTV1 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to CNCRobotV1_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CNCROBOTV1('CALLBACK') and CNCROBOTV1('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CNCROBOTV1.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CNCRobotV1

% Last Modified by GUIDE v2.5 24-Apr-2018 14:55:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CNCRobotV1_OpeningFcn, ...
    'gui_OutputFcn',  @CNCRobotV1_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before CNCRobotV1 is made visible.
function CNCRobotV1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for CNCRobotV1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CNCRobotV1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CNCRobotV1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in cameraConnect.
function cameraConnect_Callback(hObject, eventdata, handles)
% hObject    handle to cameraConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find cameras
warning('off')
path = '';
filename = 'TISImaq_R2013_';
adapter = 'tisimaq_r2013_';

b =  strfind(mexext, '64');

try
    if isempty(b)
        path = 'C:\Program Files (x86)\TIS IMAQ for MATLAB R2013b\win32\';
        filename = strcat(path,filename,'32.dll');
        adapter = strcat(adapter,'32');
    else
        path = 'C:\Program Files (x86)\TIS IMAQ for MATLAB R2013b\x64\';
        filename = strcat(path,filename,'64.dll');
        adapter = strcat(adapter,'64');
    end
    
    try
        objs = imaqhwinfo(adapter);                % get installed imaq hardware info
        
        %fprintf('Unegister DLL file:\n');
        %fprintf(filename);
        %fprintf( '\n' );
        imaqregister(filename,'unregister');
    catch exception
        %fprintf('Register DLL file:\n');
        %fprintf(filename);
        %fprintf( '\n' );
        imaqregister(filename);
        %fprintf( ['Installed Adaptor: ', adapter, '\n'] );
    end
    
    % SETUP IMAGING SOURCE CAMERA WITH ADAPTER TISImaq_R2013_64
    % NB: Editable device properties change and camera speed increases after
    % the USB cam driver usbcam_2.9.4_tis for IC Capture is installed, even
    % though this driver is not actually needed for MATLAB to use the camera.
    
    % run to see list of installed adapters
    % adapters = imaqhwinfo;
    devices = imaqhwinfo('tisimaq_r2013_64');
    handles.AvailableCameras=devices;
    
    % The following code can be modified to present the user with a choice of
    % camera
    % For now camera choice is hardcoded
%     for d = 1:length(devices.DeviceInfo)
%         try
%             if devices.DeviceInfo(d).DeviceName == 'DMK 72AUC02'
%                 device_ID = d; break;
%             end
%         catch
%         end
%     end
    
    %handles.cameraToUse=device_ID;
    device_ID=1;
    % assume only one camera device is connected
    handles.cameraToUse=device_ID;
    
    % works in r2017a, in r2017b, this can see both the USB and GIGE cameras,
    % but crashes when an attempt is made to connect to either one.
    
    % other adapters
    % devices = imaqhwinfo('tisimaq_r2013'); % this is the old adapter for USB
    % cameras
    % devices = imaqhwinfo('gige'); % this crashes MATLAB
    % devices = imaqhwinfo('gentl'); % for Basler cameras
    
    ROI = [1 1 2592 1944];
    format = 'Y800 (2592x1944)';
    global cam1
    try
        % if camera has already been initialized, release it for re-setting
        % properties
       release(cam1) 
    catch
    end
    cam1 = imaq.VideoDevice('tisimaq_r2013_64',device_ID);
    cam1.VideoFormat = format;
    cam1.ROI = ROI;
    
    try
        % if exposure has been set, update camera exposure
        cam1.DeviceProperties.Exposure =  handles.cameraExposureTime;
    catch
        % if handles.cameraExposureTime doesn't exist yet, default is 0.32
        % seconds
        handles.cameraExposureTime=0.32;
        cam1.DeviceProperties.Exposure = handles.cameraExposureTime;  
    end
    
    cam1.DeviceProperties.FrameRate = 1;
    cam1.DeviceProperties.Gain = 4;  
catch
   set(handles.InstructionText1,'string','Failed to set up camera.  Try restarting matlab.')
end


guidata(hObject,handles);

% --- Executes on button press in cameraTest.
function cameraTest_Callback(hObject, eventdata, handles)
% hObject    handle to cameraTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global cam1
frametime=.1; %frame time in seconds
tic
elapsed=toc;
t1=toc;

i=1;
while i==1
    if elapsed>frametime
        t1=toc;
        I1 = step(cam1);
        imshow(I1,'Parent',handles.axes1)
        drawnow
    end
    pause(0.1)
    set(handles.InstructionText1,'string','Live camera feed.')
    elapsed=abs(t1-toc);
end

guidata(hObject,handles);



function grblComPortNumber_Callback(hObject, eventdata, handles)
% hObject    handle to grblComPortNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of grblComPortNumber as text
%        str2double(get(hObject,'String')) returns contents of grblComPortNumber as a double
grblComPortNumber = str2double(get(hObject,'String'))
handles.grblComPortNumber=grblComPortNumber;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function grblComPortNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grblComPortNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in connectToGRBL.
function connectToGRBL_Callback(hObject, eventdata, handles)
% hObject    handle to connectToGRBL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

grblConnected=0;
nidaqConnected=0;

global grblBoard
grblComPort = (inputdlg({sprintf('Input GRBL Com Port Number')},'Com Port Selection',1,{'COM4'}));
grblBoard=serial([grblComPort{1}],'BaudRate',115200);
try
    fopen(grblBoard);
    grblBoard.ReadAsyncMode='continuous';
    grblConnected=1;
    set(handles.InstructionText1,'string','GRBL Connection Successful.')
    
    global myNidaq % blue light channel
    global myRedLed % red light channel
    devices=daq.getDevices;
    myNidaq=daq.createSession('ni');
    myRedLed=daq.createSession('ni');
    nidaqName = (inputdlg({sprintf('Input Nidaq Device Name')},'Nidaq Selection',1,{'Dev2'}));
    nidaqCh = (inputdlg({sprintf('Input Nidaq Blue Light Channel')},'Nidaq Channel',1,{'0'}));
    blueCh=str2num(nidaqCh{1}); % blue channel
    redCh = 1-blueCh; % red channel
    addAnalogOutputChannel(myNidaq,nidaqName{1},blueCh,'Voltage');
    addAnalogOutputChannel(myRedLed,nidaqName{1},redCh,'Voltage');
    nidaqConnected=1;
    set(handles.InstructionText1,'string','Nidaq Connection Successful.')
    pause(2)
    set(handles.InstructionText1,'string','GRBL and Nidaq Connection Successful. Please home the robot before continuing.')
    
    handles.grblComPort=grblComPort;
    handles.nidaqName=nidaqName;
    handles.nidaqCh=nidaqCh;
catch
    if grblConnected==0
        set(handles.InstructionText1,'string','Failed to connect to GRBL Board.  If you are having trouble, try restarting Matlab and/or the GRBL Board.')
    else
        set(handles.InstructionText1,'string','Failed to connect to Nidaq.  Check connection and device number.')
    end
end

set(handles.imagingButton,'Enable','off')
set(handles.initializeImaging,'Enable','on')

guidata(hObject,handles);

% --- Executes on button press in homeRobotManual.
function homeRobotManual_Callback(hObject, eventdata, handles)
% hObject    handle to homeRobotManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grblBoard

try
    set(handles.InstructionText1,'string','Homing robot.')
    fprintf(grblBoard,'$H')
catch
    % disconnect grbl
    disconnectGrbl_Callback(handles.disconnectGrbl, eventdata, handles)
    
    % reconnect grbl
    reconnectToGrblAndNidaq_Callback(handles.reconnectToGrblAndNidaq, eventdata, handles)
    
    set(handles.InstructionText1,'string','Homing robot.')
    fprintf(grblBoard,'$H')
end

guidata(hObject,handles);

% --- Executes on button press in connectToCamera.
function connectToCamera_Callback(hObject, eventdata, handles)
% hObject    handle to connectToCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in setHomeDirectory.
function setHomeDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to setHomeDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.InstructionText1,'string',['Please set the Home directory.  This should contain the folder "CNC_Dependents".'])
dname = uigetdir();

handles.homeDirectory=dname;

try
    addpath([handles.homeDirectory '\CNC_Dependents']);
    set(handles.InstructionText1,'string',['Home directory set to ' dname])
catch
    set(handles.InstructionText1,'string',['Please ensure the folder "CNC_Dependents" is present in the home directory.'])
end

guidata(hObject,handles);

% --- Executes on button press in initializeRobot.
function initializeRobot_Callback(hObject, eventdata, handles)
% hObject    handle to initializeRobot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    cd(handles.homeDirectory)
    
    loadPreviousState=inputdlg({'Would you like to load previous robot state?'},'Load previous robot state?',1,{'Y'});
    lps=loadPreviousState{1};
    
    if lps=='N'
        % initialize robot system parameters
        fields={'Imaging Time Per Plate (seconds)','Stimulus Duration (seconds)','Time Between Images (seconds)','Plate Spacing X Direction (mm)','Plate Spacing Y Direction (mm)','Plate height (mm)','Number of Plates in X Direction','Number of Plates in Y Direction','Number of Image Periods per day','Camera Exposure Time (s)'};
        Ans = inputdlg(fields,'Set Parameters',1,{'300','5','5','101.1','146.9','20','13','7','2','0.32'});
        
        handles.timePerPlate = str2num(Ans{1});
        handles.stimulusTime = str2num(Ans{2});
        handles.timePerImg = str2num(Ans{3});
        handles.xSpacing = str2num(Ans{4});
        handles.ySpacing = str2num(Ans{5});
        handles.zSpacing = str2num(Ans{6});
        handles.NxPlates = str2num(Ans{8});
        handles.NyPlates = str2num(Ans{7});
        handles.numImagingPeriods = str2num(Ans{9});
        handles.cameraExposureTime = str2num(Ans{10});

        [xx yy]=meshgrid(1:handles.NxPlates,1:handles.NyPlates);
        plateLocs=xx+(yy-1)*handles.NxPlates;
        currPlates=zeros(handles.NyPlates,handles.NxPlates);
        twentyFourWellPlateYorN=zeros(handles.NyPlates,handles.NxPlates);
        timesImagedToday=NaN*zeros(handles.NyPlates,handles.NxPlates);
        plateIDs=cell(handles.NyPlates,handles.NxPlates);
        plateAddDate=cell(handles.NyPlates,handles.NxPlates);
        plateAddedBy=cell(handles.NyPlates,handles.NxPlates);
        plateSaveDirectory=cell(handles.NyPlates,handles.NxPlates);
        
        handles.plateLocs=plateLocs;
        handles.currPlates=currPlates;
        handles.twentyFourWellPlateYorN=twentyFourWellPlateYorN;
        handles.timesImagedToday=timesImagedToday;
        handles.plateIDs=plateIDs;
        handles.plateAddDate=plateAddDate;
        handles.plateAddedBy=plateAddedBy;
        handles.plateSaveDirectory=plateSaveDirectory;
        handles.nextPlateToImage=0;
        handles.lastBlueLightImage=0.6;
        handles.processedYet=1;
        
        % create Grid
        xdraw=[];
        ydraw=[];
        for i=1:handles.NxPlates
            xdraw(2*i-1)=[i-0.5];
            xdraw(2*i)=[i-0.5];
            ydraw(2*i-1)=[0.5];
            ydraw(2*i)=[handles.NyPlates+0.5];
        end
        
        for j=1:handles.NyPlates
            xdraw(2*i+2*j-1)=[0.5];
            xdraw(2*i+2*j)=[handles.NxPlates+0.5];
            ydraw(2*i+2*j-1)=[j-0.5];
            ydraw(2*i+2*j)=[j-0.5];
        end
        
        handles.xGrid=xdraw;
        handles.yGrid=ydraw;
        
        savename = (inputdlg({sprintf('Input save name for system parameters')},'Parameters File Name',1,{'Parameters1'}));
        handles.currentStateName=savename{1};
        savehandles=handles;
        save([handles.homeDirectory '\' handles.currentStateName '.mat'], 'savehandles');
        
        set(handles.InstructionText1,'string',['Robot Parameters initialized'])
        
    elseif lps=='Y'
        uiopen('load')
        try
            handles.timePerPlate = savehandles.timePerPlate;
            handles.stimulusTime = savehandles.stimulusTime;
            handles.timePerImg = savehandles.timePerImg;
            handles.xSpacing = savehandles.xSpacing;
            handles.ySpacing = savehandles.ySpacing;
            handles.zSpacing = savehandles.zSpacing;
            handles.NxPlates = savehandles.NxPlates;
            handles.NyPlates = savehandles.NyPlates;
            handles.numImagingPeriods=savehandles.numImagingPeriods;
            handles.plateLocs=savehandles.plateLocs;
            handles.currPlates=savehandles.currPlates;
            handles.twentyFourWellPlateYorN=savehandles.twentyFourWellPlateYorN;
            handles.plateIDs=savehandles.plateIDs;
            handles.plateAddDate=savehandles.plateAddDate;
            handles.timesImagedToday=savehandles.timesImagedToday;
            handles.plateAddedBy=savehandles.plateAddedBy;
            handles.nextPlateToImage=savehandles.nextPlateToImage;
            handles.plateSaveDirectory=savehandles.plateSaveDirectory;
            handles.xGrid=savehandles.xGrid;
            handles.yGrid=savehandles.yGrid;
            handles.imagingInitialized=0;
            handles.cameraExposureTime=savehandles.cameraExposureTime;
            handles.processedYet=savehandles.processedYet;
            handles.cameraExposureTime = savehandles.cameraExposureTime;
            handles.lastBlueLightImage=savehandles.lastBlueLightImage;

            savename = (inputdlg({sprintf('Input save name for system parameters')},'Parameters File Name',1,{'Parameters1'}));
            handles.currentStateName=savename{1};
            set(handles.InstructionText1,'string',['Previous Robot State Loaded'])
        catch
            set(handles.InstructionText1,'string',['Failed to load previous robot state.  Please check the correct file was selected.'])
        end
        
    end
    
    
catch
    set(handles.InstructionText1,'string',['Please set a home directory before attempting to set parameters.'])
end
set(handles.imagingButton,'Enable','off')
set(handles.initializeImaging,'Enable','on')
guidata(hObject,handles);


% --- Executes on button press in addPlate.
function addPlate_Callback(hObject, eventdata, handles)
% hObject    handle to addPlate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    cd(handles.homeDirectory)
    xdraw=handles.xGrid;
    ydraw=handles.yGrid;
    
    hold off
    imshow(handles.currPlates,'Parent',handles.axes1)
    hold on
    for k=1:(length(xdraw)/2)
        plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
    end
    for i=1:handles.NxPlates
        for j=1:handles.NyPlates
            if handles.currPlates(j,i)==1
                
                % Check if plate has been on robot for more than a month
                % if so, display information in red
                currdate=clock;
                pinfo=load([handles.plateSaveDirectory{j,i} '\' handles.plateIDs{j,i} '\' handles.plateIDs{j,i} '_plateInfo.mat']);
                addDate=pinfo.plateAddDate;
                
                displaycolor=[0 0 0];
                timeDifference=ComputeTimeDiffBtwTwoDateVectorsMatt(currdate,addDate)/(60*60*24);
                % if time elapsed between plate creation and current date
                % is greater than 30, show plate info in red
                if timeDifference>=30
                   displaycolor=[1 0 0]; 
                end
                
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)],'Color',displaycolor);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)],'Color',displaycolor);
                end

                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))],'Color',displaycolor);
            end
        end
    end
    set(handles.InstructionText1,'string',['Please select the location to which you would like to add a plate'])
    
    [newy newx]=ginput(1);
    newx=round(newx);
    newy=round(newy);
    
    while handles.currPlates(newx,newy)==1
        set(handles.InstructionText1,'string',['A plate is already present there.  Please select a new location to add the plate.'])
        
        [newy newx]=ginput(1);
        newx=round(newx);
        newy=round(newy);
    end
    
    plot(newy,newx,'go','LineWidth',2,'MarkerSize',35)
    
    answer=inputdlg({'Add plate to selected location?  (Y/N):'},'Confirm Plate Addition',1,{'Y'});
    if answer{1}=='Y'
        handles.currPlates(newx,newy)=1;
        
        newSaveDir=uigetdir(handles.homeDirectory,'Please select a folder in which to save images for this plate');%(inputdlg({'Please give the plate a name'},'Enter plate name',1,{'Plate924'}));
        handles.plateSaveDirectory{newx,newy}=newSaveDir;
        
        
        newPlate=(inputdlg({'Please give the plate a name'},'Enter plate name',1,{'Plate_XYZ'}));
        newPlateName=newPlate{1};
        nameok=0;
        currContents=dir(handles.plateSaveDirectory{newx,newy});
        while nameok==0
            nameok=1;
            % insert code here to ensure the new plate name is unique
            for i=1:length(currContents)
                if length(currContents(i).name)==length(newPlateName)
                    if currContents(i).name==newPlateName
                        nameok=0;
                    end
                end
            end
            
            if nameok==1
                break
            end
            set(handles.InstructionText1,'string',['A plate with that name already exists in that directory.  Please enter a new name for the plate.'])
            
            newPlate=(inputdlg({'Please give the plate a name'},'Enter plate name',1,{'Plate_XYZ'}));
            newPlateName=newPlate{1};
        end
        
        handles.plateIDs{newx,newy}=newPlateName;
        plateAddDate=clock;
        handles.plateAddDate{newx,newy}=plateAddDate;
        
        twentyFourWellPlateCheck=inputdlg({'Is this a 24 Well Plate (1) or Other Type of Plate (2)'},'Is this a 24 Well Plate (Enter "1") or Other Type of Plate (Enter "2") ',1,{'1'});
        twentyFourWellPlateYorN=str2num(twentyFourWellPlateCheck{1});
        plateAdder=(inputdlg({'Enter the name of the person adding this plate'},'Plate added by ',1,{'Matt'}));
        plateAddedBy=plateAdder{1};
        handles.plateAddedBy{newx,newy}=plateAddedBy;
        handles.twentyFourWellPlateYorN(newx,newy)=twentyFourWellPlateYorN;
       
        userComments=(inputdlg({'Please enter any comments about the plates (e.g. well numbers that did not successfully grow). Do not use commas.'},'Plate added by ',1,{'Input your comment here'}));
        plateAdderComment=userComments{1};
        
        % Set new plate to imaged if robot has already passed it.
        % Set new plate to not image if robot has not passed it.
        if handles.nextPlateToImage==0
           handles.timesImagedToday(newx,newy)=1;
        elseif handles.plateLocs(newx,newy)<handles.nextPlateToImage
            handles.timesImagedToday(newx,newy)=1;
        elseif handles.plateLocs(newx,newy)>=handles.nextPlateToImage
            handles.timesImagedToday(newx,newy)=0;          
        end
        
        mkdir([handles.plateSaveDirectory{newx,newy} '\' newPlateName])
        save([handles.plateSaveDirectory{newx,newy} '\' newPlateName '\' newPlateName '_plateInfo.mat'],'plateAddedBy','newPlateName','plateAddDate','twentyFourWellPlateYorN','plateAdderComment');
        set(handles.InstructionText1,'string',[newPlateName ' has been added to location ' num2str(newx) ', ' num2str(newy) '!'])
        
        hold off
        
        imshow(handles.currPlates,'Parent',handles.axes1)
        hold on
        for k=1:(length(xdraw)/2)
            plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
        end
        for i=1:handles.NxPlates
            for j=1:handles.NyPlates
                if handles.currPlates(j,i)==1
                   
                % Check if plate has been on robot for more than a month
                % if so, display information in red
                currdate=clock;
                pinfo=load([handles.plateSaveDirectory{j,i} '\' handles.plateIDs{j,i} '\' handles.plateIDs{j,i} '_plateInfo.mat']);
                addDate=pinfo.plateAddDate;
                
                displaycolor=[0 0 0];
                timeDifference=ComputeTimeDiffBtwTwoDateVectorsMatt(currdate,addDate)/(60*60*24);
                % if time elapsed between plate creation and current date
                % is greater than 30, show plate info in red
                if timeDifference>=30
                   displaycolor=[1 0 0]; 
                end
                
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)],'Color',displaycolor);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)],'Color',displaycolor);
                end

                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))],'Color',displaycolor);
                end
            end
        end
    else
        hold off
        
        imshow(handles.currPlates,'Parent',handles.axes1)
        hold on
        for k=1:(length(xdraw)/2)
            plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
        end
        for i=1:handles.NxPlates
            for j=1:handles.NyPlates
                if handles.currPlates(j,i)==1
                    
                % Check if plate has been on robot for more than a month
                % if so, display information in red
                currdate=clock;
                pinfo=load([handles.plateSaveDirectory{j,i} '\' handles.plateIDs{j,i} '\' handles.plateIDs{j,i} '_plateInfo.mat']);
                addDate=pinfo.plateAddDate;
                
                displaycolor=[0 0 0];
                timeDifference=ComputeTimeDiffBtwTwoDateVectorsMatt(currdate,addDate)/(60*60*24);
                % if time elapsed between plate creation and current date
                % is greater than 30, show plate info in red
                if timeDifference>=30
                   displaycolor=[1 0 0]; 
                end
                
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)],'Color',displaycolor);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)],'Color',displaycolor);
                end

                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))],'Color',displaycolor);
                end
            end
        end
        set(handles.InstructionText1,'string',['No new plates have been added.'])
        
    end
    
    savehandles=handles;
    save([handles.homeDirectory '\' handles.currentStateName '.mat'], 'savehandles');
    guidata(hObject,handles);
catch
    set(handles.InstructionText1,'string',['Please set home directory and set parameters before trying to retrieve plate information'])
end
hold off
set(handles.imagingButton,'Enable','off')


% --- Executes on button press in removePlate.
function removePlate_Callback(hObject, eventdata, handles)
% hObject    handle to removePlate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    cd(handles.homeDirectory)
    xdraw=handles.xGrid;
    ydraw=handles.yGrid;
    
    hold off
    imshow(handles.currPlates,'Parent',handles.axes1)
    hold on
    for k=1:(length(xdraw)/2)
        plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
    end
    for i=1:handles.NxPlates
        for j=1:handles.NyPlates
            if handles.currPlates(j,i)==1
                
                % Check if plate has been on robot for more than a month
                % if so, display information in red
                currdate=clock;
                pinfo=load([handles.plateSaveDirectory{j,i} '\' handles.plateIDs{j,i} '\' handles.plateIDs{j,i} '_plateInfo.mat']);
                addDate=pinfo.plateAddDate;
                
                displaycolor=[0 0 0];               
                timeDifference=ComputeTimeDiffBtwTwoDateVectorsMatt(currdate,addDate)/(60*60*24);
                % if time elapsed between plate creation and current date
                % is greater than 30, show plate info in red
                if timeDifference>=30
                   displaycolor=[1 0 0]; 
                end
                
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)],'Color',displaycolor);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)],'Color',displaycolor);
                end

                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))],'Color',displaycolor);
            end
        end
    end
    set(handles.InstructionText1,'string',['Please select plate you would like to remove'])
    
    [newy newx]=ginput(1);
    newx=round(newx);
    newy=round(newy);
    
    while handles.currPlates(newx,newy)==0
        set(handles.InstructionText1,'string',['No plate is present there.  Please select a location with an existing plate.'])
        
        [newy newx]=ginput(1);
        newx=round(newx);
        newy=round(newy);
    end
    
    plot(newy,newx,'rx','LineWidth',2,'MarkerSize',35)
    
    set(handles.InstructionText1,'string',['Are you sure you want to remove plate: ' handles.plateIDs{newx,newy} '?'])
    
    answer=inputdlg({'Remove plate from selected location?  (Y/N):'},'Confirm Plate Removal',1,{'N'});
    
    if answer{1}=='Y'
        set(handles.InstructionText1,'string',['Plate ' handles.plateIDs{newx,newy} ' has been removed from location ' num2str(newx) ', ' num2str(newy) '!'])
        
        handles.currPlates(newx,newy)=0;
        handles.twentyFourWellPlateYorN(newx,newy)=0;
        handles.plateIDs{newx,newy}=[];
        handles.plateAddDate{newx,newy}=[];
        handles.plateAddedBy{newx,newy}=[];
        handles.plateSaveDirectory{newx,newy}=[];
        handles.timesImagedToday(newx,newy)=NaN;
        hold off
        
        imshow(handles.currPlates,'Parent',handles.axes1)
        hold on
        for k=1:(length(xdraw)/2)
            plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
        end
        for i=1:handles.NxPlates
            for j=1:handles.NyPlates
                if handles.currPlates(j,i)==1
                    
                % Check if plate has been on robot for more than a month
                % if so, display information in red
                currdate=clock;
                pinfo=load([handles.plateSaveDirectory{j,i} '\' handles.plateIDs{j,i} '\' handles.plateIDs{j,i} '_plateInfo.mat']);
                addDate=pinfo.plateAddDate;
                
                displaycolor=[0 0 0];
                timeDifference=ComputeTimeDiffBtwTwoDateVectorsMatt(currdate,addDate)/(60*60*24);
                % if time elapsed between plate creation and current date
                % is greater than 30, show plate info in red
                if timeDifference>=30
                   displaycolor=[1 0 0]; 
                end
                
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)],'Color',displaycolor);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)],'Color',displaycolor);
                end

                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))],'Color',displaycolor);
                end
            end
        end
    else
        hold off
        
        imshow(handles.currPlates,'Parent',handles.axes1)
        hold on
        for k=1:(length(xdraw)/2)
            plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
        end
        for i=1:handles.NxPlates
            for j=1:handles.NyPlates
                if handles.currPlates(j,i)==1
                    
                % Check if plate has been on robot for more than a month
                % if so, display information in red
                currdate=clock;
                pinfo=load([handles.plateSaveDirectory{j,i} '\' handles.plateIDs{j,i} '\' handles.plateIDs{j,i} '_plateInfo.mat']);
                addDate=pinfo.plateAddDate;
                
                displaycolor=[0 0 0];
                timeDifference=ComputeTimeDiffBtwTwoDateVectorsMatt(currdate,addDate)/(60*60*24);
                % if time elapsed between plate creation and current date
                % is greater than 30, show plate info in red
                if timeDifference>=30
                   displaycolor=[1 0 0]; 
                end
                
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)],'Color',displaycolor);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)],'Color',displaycolor);
                end

                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))],'Color',displaycolor);
                end
            end
        end
        set(handles.InstructionText1,'string',['No plates have been removed.'])
        
    end
    guidata(hObject,handles);
    savehandles=handles;
    save([handles.homeDirectory '\' handles.currentStateName '.mat'], 'savehandles');
    
catch
    set(handles.InstructionText1,'string',['Please set home directory and set parameters before trying to retrieve plate information'])
end

hold off
set(handles.imagingButton,'Enable','off')


% --- Executes on button press in imagingLoop.
function imagingLoop_Callback(hObject, eventdata, handles)
% hObject    handle to imagingLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in imagingButton.
function imagingButton_Callback(hObject, eventdata, handles)
% hObject    handle to imagingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of imagingButton

cd(handles.homeDirectory)

global grblBoard
global myNidaq
global myRedLed
global cam1

pauseTime=15; % time between imaging plates in seconds (allows user to add/remove plates during an imaging period)
secondsPerFrame=handles.timePerImg; % seconds per frame
imagingTime=handles.timePerPlate; %seconds to image each plate
blueLightOnTime=handles.stimulusTime;
numImagingPeriods=handles.numImagingPeriods; % number of imaging periods per day

imageTimes=[00 00]; % hours and minute to begin first image period.  Imaging periods occur evenly spaced dependent on the number of image periods set per day

imageHours=zeros(1,length(numImagingPeriods));
for i=1:numImagingPeriods
   imageHours(i)=round(imageTimes(1)+(i-1)*24/numImagingPeriods);
end

% If imaging only twice per day, start the first image period 1 hour later
% than expected.
% This allows image processing from the previous day to finish before
% starting the morning imaging period.
% Note: this can be commented out if processing time is not an issue, for
% example if fewer than ~91 plates are being imaged.
if numImagingPeriods==2
   imageHours(1)=imageHours(1)+1; 
end

handles.blueLightImageMin=0.6; % minimum average intensity for blue light imag.  If blue light falls below this threshold, software will notify user.
handles.LSMetric=99; % Metric for calculating Aggregate Lifespan score during data analysis
handles.HSMetric=85; % Metric for calculating Aggregate Lifespan score during data analysis

while get(hObject,'Value') % this code runs only when toggle button is pressed
    cd(handles.homeDirectory)
    set(handles.imagingButton,'string','Stop imaging')
    
    % Disable these buttons during imaging
    set(handles.getPlateInfo, 'Enable','off')
    set(handles.addPlate, 'Enable','off')
    set(handles.removePlate, 'Enable','off')
    set(handles.manualPlateCalibration, 'Enable','off')
    set(handles.initializeImaging,'Enable','off')
    set(handles.testCamera,'Enable','off')
    set(handles.testRedLed,'Enable','off')
    set(handles.testBlueLight,'Enable','off')
    set(handles.manualMoveToPlate,'Enable','off')
   
    currentTime=clock;
 
    % Reset timesImagedToday at the beginning of each imaging period
    currImageHour=find(imageHours==currentTime(4));
    if currImageHour
        if (currentTime(5)<(imageTimes(2)+3))
            % find available plates
            platesToImage=find((handles.currPlates').*(handles.plateLocs')~=0);
                        
            % reset all plates to not imaged
            timesImagedToday=handles.timesImagedToday;
            timesImagedToday(timesImagedToday==1)=0;
            handles.timesImagedToday=timesImagedToday;
            
            % set next plate to image as the lowest numbered plate available
            handles.nextPlateToImage=platesToImage(1);
            
            % Move to correct plate
            % find next plate coordinates and move to next plate
            manualPlatePositions=handles.manualPlatePositions';
            newcoords=manualPlatePositions{handles.nextPlateToImage};
            
            % if grbl fails, disconnect and reconnect
            try
                % home robot
                set(handles.InstructionText1,'string',['Beginning new imaging period.  Currently homing robot.'])
                homeRobotManual_Callback(handles.homeRobotManual, eventdata, handles)
                pause(60)
                
                response=moveAbsoluteCNC_MinTravelHeight(newcoords(1), newcoords(2), newcoords(3), newcoords(3));
                %response=moveAbsoluteCNC(newcoords(1), newcoords(2), newcoords(3));
                
                % give some time to allow robot to move to plate before
                % beginning imaging
                pause(5)
            catch
                display(['GRBL disconnected.  Attempting to reconnect GRBL.'])
                
                % disconnect grbl
                disconnectGrbl_Callback(handles.disconnectGrbl, eventdata, handles)
                
                % reconnect grbl
                reconnectToGrblAndNidaq_Callback(handles.reconnectToGrblAndNidaq, eventdata, handles)
                
                % home robot
                set(handles.InstructionText1,'string',['Beginning new imaging period.  Currently homing robot.'])
                homeRobotManual_Callback(handles.homeRobotManual, eventdata, handles)
                
                % pause to give enough time for robot to home
                pause(60)
                display(['GRBL successfully reconnected!'])
                
                % move to next plate
                response=moveAbsoluteCNC_MinTravelHeight(newcoords(1), newcoords(2), newcoords(3), newcoords(3));
                %response=moveAbsoluteCNC(newcoords(1), newcoords(2), newcoords(3));
                
                % give some time to allow robot to move to plate before
                % beginning imaging
                pause(5)
            end
            pause(5)
            
            if currImageHour==length(imageHours)
                % Reset all plates as not processed during the last imaging
                % period of the day
                handles.processedYet=0;
                display('Last imaging period of the day.  New data will be processed after this imaging period.')
            end       
        end
    end
    
    nextPlateToImage=handles.nextPlateToImage;
    
    plateIDs=handles.plateIDs';
    plateTypes=handles.twentyFourWellPlateYorN';
    plateSaveDirs=handles.plateSaveDirectory';
    timesImagedToday=handles.timesImagedToday';
    currentDate=[num2str(currentTime(1)) '-' num2str(currentTime(2)) '-' num2str(currentTime(3))];
    
    
    % Take images for current plate
    
    % Don't allow user to stop imaging while a plate is being imaged
    % Only allow user to stop imaging when robot moves between plates (plus
    % waiting period)
    set(handles.imagingButton,'Enable','off')
    
    % only image plates if they have noy been imaged this period
    if timesImagedToday(nextPlateToImage)==0
        
        % save images in each plate's respective save directory.  Save images
        % for each day in a separate folder to facilitate real time imaging
        % If plate is 24-well plate, save each set of images in a folder for
        % each day
        % If plate is not a 24 well plate, save all images together (so images can be
        % processed with WorMotel GUI)
        if plateTypes(nextPlateToImage)==1
            currSaveDir=[plateSaveDirs{nextPlateToImage} '\' plateIDs{nextPlateToImage} '\' currentDate];
            if exist(currSaveDir)==0
                mkdir(currSaveDir);
            end
        elseif plateTypes(nextPlateToImage)==2
            currSaveDir=[plateSaveDirs{nextPlateToImage} '\' plateIDs{nextPlateToImage}];
        end
        
        % Turn red LEDs on
        outputSingleScan(myRedLed,4)
        
       % adjust x/y position
%         manualPlatePositions=handles.manualPlatePositions';
%         newcoords=manualPlatePositions{handles.nextPlateToImage};
%         
%         set(handles.InstructionText1,'string',['Testing to ensure plate position is correct.'])
%         mind=50;
%         while mind<150
%             idealUL=[200 200];
%             idealUR=[2350 240];
%             idealBL=[200 1500];
%             idealBR=[2350 1500];
%             myTolerance=50;
%             outputSingleScan(myRedLed,4)
%             cameraConnect_Callback(handles.cameraConnect, eventdata, handles)
%             I1 = step(cam1);
%             imwrite(I1,['temp.png'],'PNG')
%             [maskSorted  center]= AutomaticallyFind_24WellPlateROIs('temp.png');
%             while maskSorted==0
%                 homeRobotManual_Callback(handles.homeRobotManual, eventdata, handles)
%                 pause(60)
%                 outputSingleScan(myRedLed,4)
%                 response=moveAbsoluteCNC_MinTravelHeight(newcoords(1), newcoords(2), newcoords(3), newcoords(3));
%                 cameraConnect_Callback(handles.cameraConnect, eventdata, handles)
%                 I1 = step(cam1);
%                 imwrite(I1,['temp.png'],'PNG')
%                 [maskSorted center] = AutomaticallyFind_24WellPlateROIs('temp.png');
%             end
%             
%             %find minimum distance between all centers
%             dis=[];
%             z=1;
%             for i=1:24
%                 for j=(i+1):24
%                     dis(z)=sqrt((center(i,1)-center(j,1))^2+((center(i,2)-center(j,2))^2));
%                     z=z+1;
%                 end
%             end
%             
%             mind=min(dis);
%             if mind<150
%                 set(handles.InstructionText1,'string',['Error detected in plate position.  Homing robot and resetting position.'])
%                 homeRobotManual_Callback(handles.homeRobotManual, eventdata, handles)
%                 pause(60)
%                 outputSingleScan(myRedLed,4)
%                 response=moveAbsoluteCNC_MinTravelHeight(newcoords(1), newcoords(2), newcoords(3), newcoords(3));
%             end
%         end
%         
%         % For finer adjustment
%         for i=1:24
%             circlesize(i)=sum(sum(maskSorted(:,:,i)));
%         end
%         reallyoff=find(circlesize<(0.75*mean(circlesize)));
%         distancemultiplier=8;
%         if length(reallyoff)>0
%             if sum(ismember(reallyoff,[1 7 13 19]))>1
%                 % if left side is cut off
%                 r=jogCNC('Y',-distancemultiplier*mean(circlesize)/circlesize(reallyoff(1)),2000);
%             end
%             if sum(ismember(reallyoff,[6 12 18 24]))>1
%                 % if right side is cut off
%                 r=jogCNC('Y',distancemultiplier*mean(circlesize)/circlesize(reallyoff(1)),2000);
%             end
%             if sum(ismember(reallyoff,[1 2 3 4 5 6]))>1
%                 % if top is cut off
%                 r=jogCNC('X',-distancemultiplier*mean(circlesize)/circlesize(reallyoff(1)),2000);
%             end
%             if sum(ismember(reallyoff,[19 20 21 22 23 24]))>1
%                 % if bottom is cut off
%                 r=jogCNC('X',distancemultiplier*mean(circlesize)/circlesize(reallyoff(1)),2000);
%             end
%         end
%         %save('mymask','maskSorted','center')

        % Image plate before blue light
        tic
        tElapse=toc;
        
        while tElapse<round(imagingTime/2)
            currentTime=clock;
            if mod(round(currentTime(6)),secondsPerFrame)==0 % acquire and save an image
                hold off
                try
                    cameraConnect_Callback(handles.cameraConnect, eventdata, handles)
                catch
                    display('did not reconnect')
                end
                I1 = step(cam1);
                imshow(I1,'Parent',handles.axes1)
                text(0,-20,['Image successfully acquired at ' num2str(currentTime(4),'%02d') ':' num2str(currentTime(5),'%02d') ':' num2str(round(currentTime(6)),'%02d') ' on ' num2str(currentTime(1)) '-' num2str(currentTime(2),'%02d') '-' num2str(currentTime(3),'%02d')  '. Last blue light image intensity: ' num2str(handles.lastBlueLightImage) '.  Minimum acceptable: ' num2str(handles.blueLightImageMin)])
                drawnow
                axis tight
                imwrite(I1,[currSaveDir  '\' num2str(currentTime(1)) '-' num2str(currentTime(2),'%02d') '-' num2str(currentTime(3),'%02d') ' (' num2str(currentTime(4),'%02d') '-' num2str(currentTime(5),'%02d') '-' num2str(round(currentTime(6)),'%02d') ').png'],'PNG')
            end
            pause(0.1)
            tElapse=toc;
            set(handles.InstructionText1,'string',['Imaging plate number ' num2str(nextPlateToImage) ': ' plateIDs{nextPlateToImage} ', before blue light stimulation. ' num2str(round(imagingTime/2-tElapse)) ' seconds until blue light stimulation.'])
        end
        
        % Turn blue LED on and take a single picture during that time
        tic
        set(handles.InstructionText1,'string',['Imaging plate number ' num2str(nextPlateToImage) ': ' plateIDs{nextPlateToImage} '.  Turning blue light on for ' num2str(blueLightOnTime) ' seconds!'])
        outputSingleScan(myNidaq,4)
        
        % Take picture
        try
            cameraConnect_Callback(handles.cameraConnect, eventdata, handles)
        catch
            display('did not reconnect')
        end
        I1 = step(cam1);
        handles.lastBlueLightImage=mean(mean(I1));
        imshow(I1,'Parent',handles.axes1)
        currentTime=clock;
        text(0,-20,['Image successfully acquired at ' num2str(currentTime(4),'%02d') ':' num2str(currentTime(5),'%02d') ':' num2str(round(currentTime(6)),'%02d') ' on ' num2str(currentTime(1)) '-' num2str(currentTime(2),'%02d') '-' num2str(currentTime(3),'%02d') '. Last blue light image intensity: ' num2str(handles.lastBlueLightImage) '.  Minimum acceptable: ' num2str(handles.blueLightImageMin)])
        drawnow
        axis tight
        imwrite(I1,[currSaveDir  '\' num2str(currentTime(1)) '-' num2str(currentTime(2),'%02d') '-' num2str(currentTime(3),'%02d') ' (' num2str(currentTime(4),'%02d') '-' num2str(currentTime(5),'%02d') '-' num2str(round(currentTime(6)),'%02d') ').png'],'PNG')
        
        % Turn blue LED off after blueLightOnTime has elapsed
        tElapse=toc;
        while tElapse<blueLightOnTime
            pause(0.2)
            tElapse=toc;
        end
        outputSingleScan(myNidaq,0)
        
        % Image plate after blue light
        tic
        tElapse=toc;
        while tElapse<round(imagingTime/2)
            currentTime=clock;
            if mod(round(currentTime(6)),secondsPerFrame)==0 % acquire and save an image
                hold off
                try
                    cameraConnect_Callback(handles.cameraConnect, eventdata, handles)
                catch
                    display('did not reconnect')
                end
                I1 = step(cam1);
                imshow(I1,'Parent',handles.axes1)
                text(0,-20,['Image successfully acquired at ' num2str(currentTime(4),'%02d') ':' num2str(currentTime(5),'%02d') ':' num2str(round(currentTime(6)),'%02d') ' on ' num2str(currentTime(1)) '-' num2str(currentTime(2),'%02d') '-' num2str(currentTime(3),'%02d')  '. Last blue light image intensity: ' num2str(handles.lastBlueLightImage) '.  Minimum acceptable: ' num2str(handles.blueLightImageMin)])
                drawnow
                axis tight
                imwrite(I1,[currSaveDir  '\' num2str(currentTime(1)) '-' num2str(currentTime(2),'%02d') '-' num2str(currentTime(3),'%02d') ' (' num2str(currentTime(4),'%02d') '-' num2str(currentTime(5),'%02d') '-' num2str(round(currentTime(6)),'%02d') ').png'],'PNG')
            end
            pause(0.1)
            tElapse=toc;
            set(handles.InstructionText1,'string',['Imaging plate number ' num2str(nextPlateToImage) ': ' plateIDs{nextPlateToImage} ', after blue light stimulation. ' num2str(round(imagingTime/2-tElapse)) ' seconds until moving to the next plate.'])
        end
        
        % Turn red LEDs off
        outputSingleScan(myRedLed,0)
        
        % Enable imaging button
        set(handles.imagingButton,'Enable','on')
        
        % set plate status to "imaged" for this imaging period
        timesImagedToday(nextPlateToImage)=1; 
        
        % update next plate to image
        platesToImage=find((handles.currPlates').*(handles.plateLocs')~=0);
        currentPlate=find(platesToImage==nextPlateToImage);
        if currentPlate==length(platesToImage)
            nextPlateToImage=platesToImage(1);
        else
            nextPlateToImage=platesToImage(currentPlate+1);
        end
        
        handles.nextPlateToImage=nextPlateToImage;
        handles.timesImagedToday=timesImagedToday';
        
        % find next plate coordinates and move to next plate
        manualPlatePositions=handles.manualPlatePositions';
        newcoords=manualPlatePositions{handles.nextPlateToImage};
        
        % if grbl connection fails, disconnect and reconnect
        % this requires homing the robot first
        try
            response=moveAbsoluteCNC_MinTravelHeight(newcoords(1), newcoords(2), newcoords(3), newcoords(3));
            %response=moveAbsoluteCNC(newcoords(1), newcoords(2), newcoords(3));
        catch
            display(['GRBL disconnected.  Attempting to reconnect GRBL.'])
            
            % disconnect grbl
            disconnectGrbl_Callback(handles.disconnectGrbl, eventdata, handles)
            
            % reconnect grbl
            reconnectToGrblAndNidaq_Callback(handles.reconnectToGrblAndNidaq, eventdata, handles)
            
            % home grbl
            homeRobotManual_Callback(handles.homeRobotManual, eventdata, handles)
            
            % pause to give enough time for robot to home
            pause(60)
            display(['GRBL successfully reconnected!'])
            
            % move to next plate
            response=moveAbsoluteCNC_MinTravelHeight(newcoords(1), newcoords(2), newcoords(3), newcoords(3));
            pause(15) % allow time for robot to reach new destination
            %response=moveAbsoluteCNC(newcoords(1), newcoords(2), newcoords(3));
        end

        for i=1:pauseTime
            set(handles.InstructionText1,'string',['Moving camera to plate number ' num2str(nextPlateToImage) '.  Imaging begins in ' num2str(pauseTime-i) ' seconds.  You may stop imaging at this time if you would like to add or remove plates.'])
            pause(1)
            if get(hObject,'Value')==0
                break
            end
        end
    else
        set(handles.imagingButton,'Enable','on')

        currentTime=clock;
        % Find next image period for display purposes
        currImageTime=find(currentTime(4)<imageHours);
        if currImageTime
            set(handles.InstructionText1,'string',['All plates have been imaged this period.  Next imaging period occurs at ' num2str(imageHours(currImageTime(1)),'%02d') ':' num2str(imageTimes(2),'%02d') '.'])
        else
            set(handles.InstructionText1,'string',['All plates have been imaged this period.  Next imaging period occurs at ' num2str(imageHours(1),'%02d') ':' num2str(imageTimes(2),'%02d') '.'])
        end
        
        pause(1)
        % if current time after last image period of the day:
        % run real-time image analysis 
        % only run real-time analysis on 24-well plates
        if (currentTime(4) >= imageHours(end))
         
            platesToImage=find((handles.currPlates').*(handles.plateLocs')~=0);
            plateSaveDirs=handles.plateSaveDirectory';
            
            % only process the images once per day
            if handles.processedYet==0
            
                set(handles.imagingButton,'Enable','off')
                processstarttime=clock;
                
                for currPlateToProcess_=1:length(platesToImage)
                    currPlateToProcess=platesToImage(currPlateToProcess_);
                    display(['Beginning to process plate #' num2str(currPlateToProcess)])
                    if plateTypes(currPlateToProcess)==1
                        currDirToProcess=[plateSaveDirs{currPlateToProcess} '\' plateIDs{currPlateToProcess}];
                        currFolders=dir(currDirToProcess);
                        
                        imageFolders=cell(1,1);
                        realImageFolderdate=zeros(2,1);
                        tempVar=2;
                        for wantToProcess=3:length(currFolders)
                            tempname=currFolders(wantToProcess).name;
                            if tempname((end-2):end)~='mat'
                                imageFolders{tempVar}=currFolders(wantToProcess).name;
                                realImageFolderdate(tempVar)=currFolders(wantToProcess).datenum;
                                tempVar=tempVar+1;
                            end
                        end

                        [kk kki]=sort(realImageFolderdate);
                        
                        currTime=clock;
                        roifilename=['ROI_Official_' num2str(currTime(1),'%04d') num2str(currTime(2),'%02d') num2str(currTime(3),'%02d') '.mat'];
                        if length(imageFolders)>1 % check to see if any image folders exist
                            % if no ROI file exists, make the ROI file
                            
                            if ~exist([currDirToProcess '\' roifilename])
                                
                                files=dir([currDirToProcess '\' imageFolders{kki(end)}]);
                                for imageYN = length(files):-1:3
                                    tempname=files(imageYN).name;
                                    if tempname((end-3):end)=='.png'
                                        break
                                    end
                                end
                                % Automatically find ROIs for 24 well plate
                                %maskSorted = AutomaticallyFind_24WellPlateROIs([currDirToProcess '\' imageFolders{2} '\' tempname]);
                                [maskSorted center]= AutomaticallyFind_24WellPlateROIs([currDirToProcess '\' imageFolders{kki(end)} '\' tempname]);
                                save([currDirToProcess '\' roifilename],'maskSorted');
                                if size(maskSorted,1)~=1
                                    display(['successfully made ROIs for plate ' num2str(currPlateToProcess)])
                                else
                                    display(['failed to make ROIs for plate ' num2str(currPlateToProcess)])
                                end
                            end
                            
                            for currFolderToProcess=2:length(imageFolders)
                                % for each folder in the plate's directory,
                                % run real time analysis if an analysis
                                % folder cannot already be found within the
                                % folder
                                
                                if exist([currDirToProcess '\' imageFolders{currFolderToProcess} '\Analysis60'])==0
                                    % run the real-time analysis code
                                    display(['Beginning to process plate #' num2str(currPlateToProcess) ', plate name ' currDirToProcess ', folder ' imageFolders{currFolderToProcess}])
                                    realTimeImageProcessing_24WellPlate([currDirToProcess '\' imageFolders{currFolderToProcess}],'png',roifilename,currDirToProcess,imageFolders{currFolderToProcess});
                                end
                            end
                            
                            % Consolidate all pdata into a single .mat
                            % file accessible in the plate's home
                            % directory
                            [success] = consolidatePdata(currDirToProcess,[plateIDs{currPlateToProcess} '_Consolidated.mat']);
                            
                            % Analyze the consolidated data into a file
                            % with time vector, spontaneous and
                            % stimulated activity, and aggregated lifespan
                            % score
                            if success==1
                                [stimulated, spontaneous, t, AggLS, CDFsum, mySuccess] = processPdata24WellPlate(currDirToProcess,[plateIDs{currPlateToProcess} '_Consolidated.mat'],handles.LSMetric,handles.HSMetric,[plateIDs{currPlateToProcess} '_Analyzed.mat']);
                                if mySuccess==1
                                    display(['Successfully processed images, consolidated, and analyzed data for plate number '  num2str(currPlateToProcess) '!'])
                                end
                            end
                        else
                            display(['No images yet for plate number '  num2str(currPlateToProcess) '.'])
                        end
                    end
                end
                
                % Display time it took to process new images
                display(['Started analyzing new data at ' num2str(processstarttime(4),'%02d') ':' num2str(processstarttime(5),'%02d') ' on ' num2str(processstarttime(2),'%02d') '-' num2str(processstarttime(3),'%02d') '.'])
                currT=clock;
                display(['Finished analyzing new data at ' num2str(currT(4),'%02d') ':' num2str(currT(5),'%02d') ' on ' num2str(currT(2),'%02d') '-' num2str(currT(3),'%02d') '.'])
                
                % Warn user if blue light image average intensity falls too low
                if handles.lastBlueLightImage < handles.blueLightImageMin
                    display(['WARNING: Blue light image average intensity has fallen below the minimum.  Check blue light power and LED status.  Last blue light image average intensity: ' num2str(handles.lastBlueLightImage) '.  Minimum acceptable value: ' num2str(handles.blueLightImageMin)])
                end
                
                handles.processedYet=1;
            end
            
            currentTime=clock;
            currImageTime=find(currentTime(4)<imageHours);
            if currImageTime
                set(handles.InstructionText1,'string',['All plates have been imaged this period and new images have been analyzed.  Next imaging period occurs at ' num2str(imageHours(currImageTime(1)),'%02d') ':' num2str(imageTimes(2),'%02d') '.'])
            else
                set(handles.InstructionText1,'string',['All plates have been imaged this period and new images have been analyzed.  Next imaging period occurs at ' num2str(imageHours(1),'%02d') ':' num2str(imageTimes(2),'%02d') '.'])
            end
                      
            set(handles.imagingButton,'Enable','on')
        end
    end
    
    % save handles
    savehandles=handles;
    save([handles.homeDirectory '\' handles.currentStateName '.mat'], 'savehandles');
end

set(handles.InstructionText1,'string','Imaging stopped.  You may add or remove plates or move the robot at this time.  Please press "Initialize Imaging" before resuming imaging.')
set(handles.imagingButton,'string','Begin imaging')
% save handles
savehandles=handles;
save([handles.homeDirectory '\' handles.currentStateName '.mat'], 'savehandles');

pause(1)

% Require user to always press initialize imaging before re-starting
% imaging
set(handles.imagingButton,'Enable','off')

% Re-enable these buttons
set(handles.getPlateInfo, 'Enable','on')
set(handles.addPlate, 'Enable','on')
set(handles.removePlate, 'Enable','on')
set(handles.manualPlateCalibration, 'Enable','on')
set(handles.initializeImaging,'Enable','on')
set(handles.testCamera,'Enable','on')
set(handles.testRedLed,'Enable','on')
set(handles.testBlueLight,'Enable','on')
set(handles.manualMoveToPlate,'Enable','on')

cd(handles.homeDirectory)
guidata(hObject,handles);

% --- Executes on button press in testCamera.
function testCamera_Callback(hObject, eventdata, handles)
% hObject    handle to testCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of testCamera
global cam1
hold off
set(handles.InstructionText1,'string','Live camera feed.')
frametime=.1; %frame time in seconds
tic
elapsed=toc;
t1=toc;
while get(hObject,'Value')
    set(handles.getPlateInfo, 'Enable','off')
    set(handles.addPlate, 'Enable','off')
    set(handles.removePlate, 'Enable','off')
    set(handles.manualPlateCalibration, 'Enable','off')
    set(handles.initializeImaging,'Enable','off')
    
    if elapsed>frametime
        t1=toc;
        cameraConnect_Callback(handles.cameraConnect, eventdata, handles)
        I1 = step(cam1);
        imshow(I1,'Parent',handles.axes1)
        drawnow
        axis tight
    end
    pause(0.1)
    
    elapsed=abs(t1-toc);
    set(handles.testCamera,'string','Stop camera live feed')
end
set(handles.InstructionText1,'string','Live camera feed stopped')
set(handles.testCamera,'string','Start live camera feed')

set(handles.getPlateInfo, 'Enable','on')
set(handles.addPlate, 'Enable','on')
set(handles.removePlate, 'Enable','on')
set(handles.manualPlateCalibration, 'Enable','on')
set(handles.initializeImaging,'Enable','on')
    
guidata(hObject,handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over testCamera.
function testCamera_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to testCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in calibrateRobot.
function calibrateRobot_Callback(hObject, eventdata, handles)
% hObject    handle to calibrateRobot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% After calibrating, save calibration parameters for loading at a later
% date
% That way calibration only needs to be done once or as needed

% Will need to ask for the robot calibration file in the "Set Parameters"
% callback


% --- Executes on button press in getPlateInfo.
function getPlateInfo_Callback(hObject, eventdata, handles)
% hObject    handle to getPlateInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    cd(handles.homeDirectory)
    xdraw=handles.xGrid;
    ydraw=handles.yGrid;
    
    hold off
    imshow(handles.currPlates,'Parent',handles.axes1)
    hold on
    for k=1:(length(xdraw)/2)
        plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
    end
    for i=1:handles.NxPlates
        for j=1:handles.NyPlates
            if handles.currPlates(j,i)==1
                
                % Check if plate has been on robot for more than a month
                % if so, display information in red
                currdate=clock;
                pinfo=load([handles.plateSaveDirectory{j,i} '\' handles.plateIDs{j,i} '\' handles.plateIDs{j,i} '_plateInfo.mat']);
                addDate=pinfo.plateAddDate;
                
                displaycolor=[0 0 0];
                
                timeDifference=ComputeTimeDiffBtwTwoDateVectorsMatt(currdate,addDate)/(60*60*24);
                % if time elapsed between plate creation and current date
                % is greater than 30, show plate info in red
                if timeDifference>=30
                   displaycolor=[1 0 0]; 
                end
                
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)],'Color',displaycolor);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)],'Color',displaycolor);
                end

                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))],'Color',displaycolor);
            end
        end
    end

    set(handles.InstructionText1,'string',['Please select plate you would like information about'])
    
    [newy newx]=ginput(1);
    newx=round(newx);
    newy=round(newy);
    
    if handles.currPlates(newx,newy)==0
        set(handles.InstructionText1,'string',['No plate is currently in that location.'])
    else
        plot(newy,newx,'mo','LineWidth',3,'MarkerSize',35)
        addTime=handles.plateAddDate{newx,newy};
        plateT=handles.twentyFourWellPlateYorN(newx,newy);
        if plateT==1
            plateType='24 Well Plate';
        elseif plateT==2
            plateType='Not a 24 Well Plate';
        end
        set(handles.InstructionText1,'string',['Plate name: ' handles.plateIDs{newx,newy} '.  Type: ' plateType '. Added by ' handles.plateAddedBy{newx,newy} ' on ' num2str(addTime(1)) '-' num2str(addTime(2)) '-' num2str(addTime(3)) ' at ' num2str(addTime(4)) ':' num2str(addTime(5)) ':' num2str(round(addTime(6))) '. Image save directory: ' handles.plateSaveDirectory{newx,newy}])
    end
catch
    set(handles.InstructionText1,'string',['Please set home directory and set parameters before trying to retrieve plate information.'])
end


hold off
guidata(hObject,handles);

% --- Executes on button press in xJogPlus.
function xJogPlus_Callback(hObject, eventdata, handles)
% hObject    handle to xJogPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grblBoard
try
    r=jogCNC('X',handles.xyJog,2000);
    
    if r(1)=='o'
        set(handles.InstructionText1,'string',['Jogging robot X+' num2str(handles.xyJog)])
    elseif r(1)=='e'
        set(handles.InstructionText1,'string',['Jog distance exceeds robot boundary'])
    end
catch
    set(handles.InstructionText1,'string',['Please confirm xy jog distance'])
end
set(handles.imagingButton,'Enable','off')
guidata(hObject,handles);

% --- Executes on button press in xJogMinus.
function xJogMinus_Callback(hObject, eventdata, handles)
% hObject    handle to xJogMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grblBoard
try
    r=jogCNC('X',-handles.xyJog,2000);
    
    if r(1)=='o'
        set(handles.InstructionText1,'string',['Jogging robot X-' num2str(handles.xyJog)])
    elseif r(1)=='e'
        set(handles.InstructionText1,'string',['Jog distance exceeds robot boundary'])
    end
catch
    set(handles.InstructionText1,'string',['Please confirm xy jog distance'])
end
set(handles.imagingButton,'Enable','off')
guidata(hObject,handles);

% --- Executes on button press in yJogMinus.
function yJogMinus_Callback(hObject, eventdata, handles)
% hObject    handle to yJogMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grblBoard
try
    r=jogCNC('Y',handles.xyJog,2000);
    
    if r(1)=='o'
        set(handles.InstructionText1,'string',['Jogging robot Y-' num2str(handles.xyJog)])
    elseif r(1)=='e'
        set(handles.InstructionText1,'string',['Jog distance exceeds robot boundary'])
    end
catch
    set(handles.InstructionText1,'string',['Please confirm xy jog distance'])
end
set(handles.imagingButton,'Enable','off')
guidata(hObject,handles);

% --- Executes on button press in yJogPlus.
function yJogPlus_Callback(hObject, eventdata, handles)
% hObject    handle to yJogPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grblBoard
try
    r=jogCNC('Y',-handles.xyJog,2000);
    
    if r(1)=='o'
        set(handles.InstructionText1,'string',['Jogging robot Y+' num2str(handles.xyJog)])
    elseif r(1)=='e'
        set(handles.InstructionText1,'string',['Jog distance exceeds robot boundary'])
    end
catch
    set(handles.InstructionText1,'string',['Please confirm xy jog distance'])
end
set(handles.imagingButton,'Enable','off')
guidata(hObject,handles);

% --- Executes on button press in zJogPlus.
function zJogPlus_Callback(hObject, eventdata, handles)
% hObject    handle to zJogPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grblBoard
try
    r=jogCNC('Z',handles.zJog,2000);
    
    if r(1)=='o'
        set(handles.InstructionText1,'string',['Jogging robot Z+' num2str(handles.zJog)])
    elseif r(1)=='e'
        set(handles.InstructionText1,'string',['Jog distance exceeds robot boundary'])
    end
catch
    set(handles.InstructionText1,'string',['Please confirm z jog distance'])
end
set(handles.imagingButton,'Enable','off')
guidata(hObject,handles);

% --- Executes on button press in zJogMinus.
function zJogMinus_Callback(hObject, eventdata, handles)
% hObject    handle to zJogMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grblBoard
try
    r=jogCNC('Z',-handles.zJog,2000);
    
    if r(1)=='o'
        set(handles.InstructionText1,'string',['Jogging robot Z-' num2str(handles.zJog)])
    elseif r(1)=='e'
        set(handles.InstructionText1,'string',['Jog distance exceeds robot boundary'])
    end
catch
    set(handles.InstructionText1,'string',['Please confirm z jog distance'])
end
set(handles.imagingButton,'Enable','off')
guidata(hObject,handles);

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
xyJog=str2double(get(hObject,'String'));
handles.xyJog=xyJog;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
zJog=str2double(get(hObject,'String'));
handles.zJog=zJog;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in disconnectGrbl.
function disconnectGrbl_Callback(hObject, eventdata, handles)
% hObject    handle to disconnectGrbl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard
fclose(grblBoard)
pause(3)
set(handles.InstructionText1,'string','GRBL successfully disconnected.')
guidata(hObject,handles);

% --- Executes on button press in setPlateOneLoc.
function setPlateOneLoc_Callback(hObject, eventdata, handles)
% hObject    handle to setPlateOneLoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grblBoard

[x1Pos, y1Pos, z1Pos]=getCurrentPosition();

handles.x1Pos=x1Pos;
handles.y1Pos=y1Pos;
handles.z1Pos=z1Pos;

set(handles.InstructionText1,'string',['First plate position set to x = ' num2str(x1Pos) ', y = ' num2str(y1Pos) ', z = ' num2str(z1Pos) '.'])
guidata(hObject,handles);

% --- Executes on button press in setPlateTwoLoc.
function setPlateTwoLoc_Callback(hObject, eventdata, handles)
% hObject    handle to setPlateTwoLoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard

[x2Pos, y2Pos, z2Pos]=getCurrentPosition();

handles.x2Pos=x2Pos;
handles.y2Pos=y2Pos;
handles.z2Pos=z2Pos;

set(handles.InstructionText1,'string',['Second plate position set to x = ' num2str(x2Pos) ', y = ' num2str(y2Pos) ', z = ' num2str(z2Pos) '.'])
guidata(hObject,handles);

% --- Executes on button press in setPlateThreeLoc.
function setPlateThreeLoc_Callback(hObject, eventdata, handles)
% hObject    handle to setPlateThreeLoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard

[x3Pos, y3Pos, z3Pos]=getCurrentPosition();

handles.x3Pos=x3Pos;
handles.y3Pos=y3Pos;
handles.z3Pos=z3Pos;

set(handles.InstructionText1,'string',['Third plate position set to x = ' num2str(x3Pos) ', y = ' num2str(y3Pos) ', z = ' num2str(z3Pos) '.'])
guidata(hObject,handles);

% --- Executes on button press in setPlateFourLoc.
function setPlateFourLoc_Callback(hObject, eventdata, handles)
% hObject    handle to setPlateFourLoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard

[x4Pos, y4Pos, z4Pos]=getCurrentPosition();

handles.x4Pos=x4Pos;
handles.y4Pos=y4Pos;
handles.z4Pos=z4Pos;

set(handles.InstructionText1,'string',['Fourth plate position set to x = ' num2str(x4Pos) ', y = ' num2str(y4Pos) ', z = ' num2str(z4Pos) '.'])
guidata(hObject,handles);

% --- Executes on button press in moveToPlateOne.
function moveToPlateOne_Callback(hObject, eventdata, handles)
% hObject    handle to moveToPlateOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard

try
    x1Pos=handles.x1Pos;
catch
end

if exist('x1Pos')==1
    
    r=moveAbsoluteCNC_MinTravelHeight(handles.x1Pos,handles.y1Pos,handles.z1Pos,handles.z1Pos);
    
    set(handles.InstructionText1,'string','Robot moved to plate position 1')
else
    set(handles.InstructionText1,'string','No position set for plate 1 yet')
end
guidata(hObject,handles);

% --- Executes on button press in moveToPlateTwo.
function moveToPlateTwo_Callback(hObject, eventdata, handles)
% hObject    handle to moveToPlateTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard
try
    x2Pos=handles.x2Pos;
catch
end

if exist('x2Pos')==1
    r=moveAbsoluteCNC_MinTravelHeight(handles.x2Pos,handles.y2Pos,handles.z2Pos,handles.z2Pos);
    set(handles.InstructionText1,'string','Robot moved to plate position 2')
    
else
    set(handles.InstructionText1,'string','No position set for plate 2 yet')
end
guidata(hObject,handles);

% --- Executes on button press in moveToPlateThree.
function moveToPlateThree_Callback(hObject, eventdata, handles)
% hObject    handle to moveToPlateThree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard
try
    x3Pos=handles.x3Pos;
catch
end

if exist('x3Pos')==1
    r=moveAbsoluteCNC_MinTravelHeight(handles.x3Pos,handles.y3Pos,handles.z3Pos,handles.z3Pos);
    set(handles.InstructionText1,'string','Robot moved to plate position 3')
    
else
    set(handles.InstructionText1,'string','No position set for plate 3 yet')
end
guidata(hObject,handles);

% --- Executes on button press in moveToPlateFour.
function moveToPlateFour_Callback(hObject, eventdata, handles)
% hObject    handle to moveToPlateFour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard
try
    x4Pos=handles.x4Pos;
catch
end

if exist('x4Pos')==1
    r=moveAbsoluteCNC_MinTravelHeight(handles.x4Pos,handles.y4Pos,handles.z4Pos,handles.z4Pos);
    set(handles.InstructionText1,'string','Robot moved to plate position 4')
    
else
    set(handles.InstructionText1,'string','No position set for plate 4 yet')
end
guidata(hObject,handles);

% --- Executes on button press in loadPreviousCalibration.
function loadPreviousCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to loadPreviousCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    exist(handles.homeDirectory,'dir');
    cd(handles.homeDirectory)
    uiopen('load')
    
    handles.x1Pos=x1Pos;
    handles.x2Pos=x2Pos;
    handles.x3Pos=x3Pos;
    handles.x4Pos=x4Pos;
    handles.y1Pos=y1Pos;
    handles.y2Pos=y2Pos;
    handles.y3Pos=y3Pos;
    handles.y4Pos=y4Pos;
    handles.z1Pos=z1Pos;
    handles.z2Pos=z2Pos;
    handles.z3Pos=z3Pos;
    handles.z4Pos=z4Pos;
    
    
    set(handles.InstructionText1,'string','Previous robot calibration successfully loaded.')
catch
    set(handles.InstructionText1,'string','Please set a home directory before attempting to load a previous robot calibration.')
end

guidata(hObject,handles);

% --- Executes on button press in saveCalibration.
function saveCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to saveCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


x1Pos=handles.x1Pos;
x2Pos=handles.x2Pos;
x3Pos=handles.x3Pos;
x4Pos=handles.x4Pos;
y1Pos=handles.y1Pos;
y2Pos=handles.y2Pos;
y3Pos=handles.y3Pos;
y4Pos=handles.y4Pos;
z1Pos=handles.z1Pos;
z2Pos=handles.z2Pos;
z3Pos=handles.z3Pos;
z4Pos=handles.z4Pos;

% set all plate positions based on four corner positions
handles.manualPlatePositions=cell(handles.NyPlates,handles.NxPlates);

Ny=handles.NyPlates; % number of plates in y direction
Nx=handles.NxPlates; % number of plates in x direction

xDist= abs(x1Pos-x2Pos)/(Nx-1);
yDist= abs(y1Pos-y3Pos)/(Ny-1);

if exist('x1Pos')==1 && exist('x2Pos')==1 && exist('x3Pos')==1 && exist('x4Pos')==1
    savename = (inputdlg({sprintf('Input Calibration File Name')},'Calibration File Name',1,{'Calibration1'}));
    save([handles.homeDirectory '\' savename{1}],'x1Pos','x2Pos','x3Pos','x4Pos','y1Pos','y2Pos','y3Pos','y4Pos','z1Pos','z2Pos','z3Pos','z4Pos');
    set(handles.InstructionText1,'string','Robot calibration file saved.')
else
    set(handles.InstructionText1,'string','Positions of all four plates must be set before calibration can be saved.')
end

guidata(hObject,handles);

% --- Executes on button press in xPlatePlus.
function xPlatePlus_Callback(hObject, eventdata, handles)
% hObject    handle to xPlatePlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard

try
    r=jogCNC('X',handles.xSpacing,2000);
    
    if r(1)=='o'
        set(handles.InstructionText1,'string',['Jogging robot to next plate in X+ Direction'])
    elseif r(1)=='e'
        set(handles.InstructionText1,'string',['Jog distance exceeds robot boundary'])
    end
catch
    set(handles.InstructionText1,'string','Please set X spacing with the "Set Parameters" button before attempting to jog robot to next plate.')
end
set(handles.imagingButton,'Enable','off')
guidata(hObject,handles);

% --- Executes on button press in nextPlateXMinus.
function nextPlateXMinus_Callback(hObject, eventdata, handles)
% hObject    handle to nextPlateXMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard

try
    r=jogCNC('X',-handles.xSpacing,2000);
    
    if r(1)=='o'
        set(handles.InstructionText1,'string',['Jogging robot to next plate in X- Direction'])
    elseif r(1)=='e'
        set(handles.InstructionText1,'string',['Jog distance exceeds robot boundary'])
    end
catch
    set(handles.InstructionText1,'string','Please set X spacing with the "Set Parameters" button before attempting to jog robot to next plate.')
end
set(handles.imagingButton,'Enable','off')
guidata(hObject,handles);

% --- Executes on button press in nextPlateYMinus.
function nextPlateYMinus_Callback(hObject, eventdata, handles)
% hObject    handle to nextPlateYMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard

try
    r=jogCNC('Y',handles.ySpacing,2000);
    
    if r(1)=='o'
        set(handles.InstructionText1,'string',['Jogging robot to next plate in Y- Direction'])
    elseif r(1)=='e'
        set(handles.InstructionText1,'string',['Jog distance exceeds robot boundary'])
    end
catch
    set(handles.InstructionText1,'string','Please set Y spacing with the "Set Parameters" button before attempting to jog robot to next plate.')
end
set(handles.imagingButton,'Enable','off')
guidata(hObject,handles);

% --- Executes on button press in nextPlateYPlus.
function nextPlateYPlus_Callback(hObject, eventdata, handles)
% hObject    handle to nextPlateYPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard

try
    r=jogCNC('Y',-handles.ySpacing,2000);
    
    if r(1)=='o'
        set(handles.InstructionText1,'string',['Jogging robot to next plate in Y+ Direction'])
    elseif r(1)=='e'
        set(handles.InstructionText1,'string',['Jog distance exceeds robot boundary'])
    end
catch
    set(handles.InstructionText1,'string','Please set Y spacing with the "Set Parameters" button before attempting to jog robot to next plate.')
end
set(handles.imagingButton,'Enable','off')
guidata(hObject,handles);

% --- Executes on button press in testBlueLight.
function testBlueLight_Callback(hObject, eventdata, handles)
% hObject    handle to testBlueLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of testBlueLight
global myNidaq

try
    outputSingleScan(myNidaq,4)
    set(handles.InstructionText1,'string','Blue light turning on for 3 seconds')
    pause(3)
    outputSingleScan(myNidaq,0)
    set(handles.InstructionText1,'string','Blue light turned off.  Nidaq is working.')
catch
    set(handles.InstructionText1,'string','Please make sure Nidaq is connected and initialized')
end
guidata(hObject,handles);


% --- Executes on button press in initializeImaging.
function initializeImaging_Callback(hObject, eventdata, handles)
% hObject    handle to initializeImaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grblBoard
global myRedLed
global cam1
%try
    cd(handles.homeDirectory)
    platesToImage=find((handles.currPlates').*(handles.plateLocs')~=0);
    currp=handles.currPlates';
    
    if length(platesToImage)~=0
        
        if handles.nextPlateToImage==0
            handles.nextPlateToImage=platesToImage(1);
        elseif currp(handles.nextPlateToImage)==0
            handles.nextPlateToImage=platesToImage(1);
        else
        end
        set(handles.imagingButton,'Enable','on')
         
        % move to next plate
        manualPlatePositions=handles.manualPlatePositions';
       
        newcoords=manualPlatePositions{handles.nextPlateToImage};
        
        try
            response=moveAbsoluteCNC_MinTravelHeight(newcoords(1), newcoords(2), newcoords(3), newcoords(3));
            %response=moveAbsoluteCNC(newcoords(1), newcoords(2), newcoords(3));
        catch
            display(['GRBL disconnected.  Attempting to reconnect GRBL.'])
            
            % disconnect grbl
            disconnectGrbl_Callback(handles.disconnectGrbl, eventdata, handles)
            
            % reconnect grbl
            reconnectToGrblAndNidaq_Callback(handles.reconnectToGrblAndNidaq, eventdata, handles)
            
            % home grbl
            homeRobotManual_Callback(handles.homeRobotManual, eventdata, handles)
            
            % pause to give enough time for robot to home
            pause(60)
            display(['GRBL successfully reconnected!'])
            
            % move to next plate
            response=moveAbsoluteCNC_MinTravelHeight(newcoords(1), newcoords(2), newcoords(3), newcoords(3));
            %response=moveAbsoluteCNC(newcoords(1), newcoords(2), newcoords(3));
        end
        
        set(handles.InstructionText1,'string',['Imaging initialized. Moving camera to plate number ' num2str(handles.nextPlateToImage) '.  Press "Begin Imaging" to start.'])
    else
        set(handles.InstructionText1,'string',['There are no plates to image!'])
    end
    outputSingleScan(myRedLed,0)
%catch
%    set(handles.InstructionText1,'string',['Please set home directory and set parameters before trying to initialize imaging.'])
%end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function robotCalibrationPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to robotCalibrationPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function cameraExposureTime_Callback(hObject, eventdata, handles)
% hObject    handle to cameraExposureTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cameraExposureTime as text
%        str2double(get(hObject,'String')) returns contents of cameraExposureTime as a double
global cam1
release(cam1);
expTime=str2double(get(hObject,'String'));
cam1.DeviceProperties.Exposure = expTime;

handles.cameraExposureTime=expTime;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function cameraExposureTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraExposureTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in manualPlateCalibration.
function manualPlateCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to manualPlateCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%try
    cd(handles.homeDirectory)
    xdraw=handles.xGrid;
    ydraw=handles.yGrid;
    
    hold off
    imshow(handles.currPlates,'Parent',handles.axes1)
    hold on
    for k=1:(length(xdraw)/2)
        plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
    end
    for i=1:handles.NxPlates
        for j=1:handles.NyPlates
            if handles.currPlates(j,i)==1
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)]);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)]);
                end
                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))]);
            end
            if isempty(handles.manualPlatePositions{j,i})==0
              plot(i+.3,j,'m*','LineWidth',2,'MarkerSize',10)  
            end
        end
    end

    set(handles.InstructionText1,'string',['Please select plate whose position you would like to set.'])
    
    [newy newx]=ginput(1);
    newx=round(newx);
    newy=round(newy);
    
    [newxPos, newyPos, newzPos]=getCurrentPosition();
    handles.manualPlatePositions{newx,newy}=[newxPos, newyPos, newzPos];
  
    hold off
    imshow(handles.currPlates,'Parent',handles.axes1)
    hold on
    for k=1:(length(xdraw)/2)
        plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
    end
    for i=1:handles.NxPlates
        for j=1:handles.NyPlates
            if handles.currPlates(j,i)==1
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)]);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)]);
                end
                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))]);
            end
            if isempty(handles.manualPlatePositions{j,i})==0
              plot(i+.3,j,'m*','LineWidth',2,'MarkerSize',10)  
            end
        end
    end
    set(handles.InstructionText1,'string',['Plate #' num2str(handles.plateLocs(newx,newy)) ' position set to x = ' num2str(newxPos) ', y = ' num2str(newyPos) ', z = ' num2str(newzPos) '.'])

% catch
%     set(handles.InstructionText1,'string',['Please set home directory and set parameters before trying to move to a specific plate.'])
% end

guidata(hObject,handles);

% --- Executes on button press in manualMoveToPlate.
function manualMoveToPlate_Callback(hObject, eventdata, handles)
% hObject    handle to manualMoveToPlate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global grblBoard

cd(handles.homeDirectory)
xdraw=handles.xGrid;
ydraw=handles.yGrid;

hold off
imshow(handles.currPlates,'Parent',handles.axes1)
hold on
for k=1:(length(xdraw)/2)
    plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
end
for i=1:handles.NxPlates
    for j=1:handles.NyPlates
        if handles.currPlates(j,i)==1
            try
                text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)]);
            catch
                text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)]);
            end
            text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))]);
        end
        if isempty(handles.manualPlatePositions{j,i})==0
            plot(i+.3,j,'m*','LineWidth',2,'MarkerSize',10)
        end
    end
end

set(handles.InstructionText1,'string',['Please select the plate you would like to move to.'])

[newy newx]=ginput(1);
newx=round(newx);
newy=round(newy);

[newxPos, newyPos, newzPos]=getCurrentPosition();
if isempty(handles.manualPlatePositions{newx,newy})==0
    newcoords=handles.manualPlatePositions{newx,newy}
    
    % Move robot with travel height of current z
    % travelHeight can be modified if necessary
    response=moveAbsoluteCNC_MinTravelHeight(newcoords(1), newcoords(2), newcoords(3), newcoords(3));
    %response=moveAbsoluteCNC(newcoords(1), newcoords(2), newcoords(3));
    set(handles.InstructionText1,'string',['Camera moved to plate #' num2str(handles.plateLocs(newx,newy))])
else
    set(handles.InstructionText1,'string',['A position has not been set for plate #' num2str(handles.plateLocs(newx,newy))])
end
set(handles.imagingButton,'Enable','off')
[currX, currY, currZ]=getCurrentPosition();
guidata(hObject,handles);

% --- Executes on button press in newManualCalibration.
function newManualCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to newManualCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    cd(handles.homeDirectory)
    
    handles.manualPlatePositions=cell(handles.NyPlates,handles.NxPlates);
    set(handles.InstructionText1,'string',['New manual calibration initialized.  Jog the robot to the first plate position you would like to set.'])
    
catch
    set(handles.InstructionText1,'string',['Please set home directory and set parameters before trying to begin a new manual calibration.'])
end

guidata(hObject,handles);


% --- Executes on button press in loadManualCalibration.
function loadManualCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to loadManualCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    cd(handles.homeDirectory)
    uiopen('load')    
    handles.manualPlatePositions=manualPlatePositions;
    savehandles=handles;
    save([handles.homeDirectory '\' handles.currentStateName '.mat'], 'savehandles');
    set(handles.InstructionText1,'string','Manual robot calibration successfully loaded.')
catch
    set(handles.InstructionText1,'string','Please set a home directory before attempting to load a previous robot calibration.')
end

guidata(hObject,handles);

% --- Executes on button press in saveManualCalibration.
function saveManualCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to saveManualCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


try
    manualPlatePositions=handles.manualPlatePositions;
catch
end


try
        savename = (inputdlg({sprintf('Input Calibration File Name')},'Calibration File Name',1,{'ManualCalibration_1'}));
        save([handles.homeDirectory '\' savename{1}],'manualPlatePositions');
        set(handles.InstructionText1,'string','Manual robot calibration file saved.')
catch
    set(handles.InstructionText1,'string','Please set a home directory before attempting to save robot calibration.')
end
guidata(hObject,handles);


% --- Executes on button press in exportData.
function exportData_Callback(hObject, eventdata, handles)
% hObject    handle to exportData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function finds all available pdata files for the selected plate and
% saves them in order in a single .mat file in the plate's directory for
% further analysis

answer=inputdlg({'Are you trying to export data from a plate that is still on the robot?  (Y/N):'},'Current or old plate',1,{'Y'});
noplate=0;
if answer{1}=='Y'
    xdraw=handles.xGrid;
    ydraw=handles.yGrid;
    
    hold off
    imshow(handles.currPlates,'Parent',handles.axes1)
    hold on
    for k=1:(length(xdraw)/2)
        plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
    end
    for i=1:handles.NxPlates
        for j=1:handles.NyPlates
            if handles.currPlates(j,i)==1
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)]);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)]);
                end
                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))]);
            end
        end
    end
    set(handles.InstructionText1,'string',['Please select plate whose data you want to consolidate'])
    
    [newy newx]=ginput(1);
    newx=round(newx);
    newy=round(newy);
    
    if handles.currPlates(newx,newy)==0
        set(handles.InstructionText1,'string',['No plate is present there.'])
        noplate=1;
    else
         plot(newy,newx,'bs','LineWidth',2,'MarkerSize',35)
         dname=[handles.plateSaveDirectory{newx,newy} '\' handles.plateIDs{newx,newy}];
         fileSaveName=(inputdlg({'Enter the name for the consolidated data file'},'File save name: ',1,{[handles.plateIDs{newx,newy} '_Consolidated.mat']}));
    end  
    
elseif answer{1}=='N'
    set(handles.InstructionText1,'string',['Please select the directory of the plate whose data you want to consolidate.'])
    dname=uigetdir();
    fileSaveName=(inputdlg({'Enter the name for the consolidated data file'},'File save name: ',1,{['Consolidated.mat']}));
else
    noplate=1;
end

if noplate==0
    fname=fileSaveName{1};
    
    mySuccess=consolidatePdata(dname,fname);
    
    if mySuccess==1
        if answer{1}=='Y'
            set(handles.InstructionText1,'string',['Data successfully consolidated for plate #' num2str(handles.plateLocs(newx,newy)) '.'])
        else
            set(handles.InstructionText1,'string',['Data successfully consolidated for chosen folder.'])
        end
    elseif mySuccess==0
        if answer{1}=='Y'
            set(handles.InstructionText1,'string',['No pdata yet for plate #' num2str(handles.plateLocs(newx,newy)) '.'])
        else
            set(handles.InstructionText1,'string',['No pdata yet for chosen folder.'])
        end
    elseif mySuccess==2
        set(handles.InstructionText1,'string',['Something went wrong.  Check the directory.'])
    end
end

guidata(hObject,handles);


% --- Executes on button press in testRedLed.
function testRedLed_Callback(hObject, eventdata, handles)
% hObject    handle to testRedLed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of testRedLed
global myRedLed
while get(hObject,'Value') % this code runs only when toggle button is pressed
    set(handles.getPlateInfo, 'Enable','off')
    set(handles.addPlate, 'Enable','off')
    set(handles.removePlate, 'Enable','off')
    set(handles.manualPlateCalibration, 'Enable','off')
    set(handles.initializeImaging,'Enable','off')
    
    set(handles. testRedLed,'string','Turn off Red LED')
    outputSingleScan(myRedLed,4)
    pause(0.1)
end

outputSingleScan(myRedLed,0)
set(handles. testRedLed,'string','Turn on Red LED')
set(handles.getPlateInfo, 'Enable','on')
set(handles.addPlate, 'Enable','on')
set(handles.removePlate, 'Enable','on')
set(handles.manualPlateCalibration, 'Enable','on')
set(handles.initializeImaging,'Enable','on')

guidata(hObject,handles);

% --- Executes on button press in analyzePdata.
function analyzePdata_Callback(hObject, eventdata, handles)
% hObject    handle to analyzePdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


answer=inputdlg({'Are you trying to analyze data from a plate that is still on the robot?  (Y/N):'},'Current or old plate',1,{'Y'});
noplate=0;
if answer{1}=='Y'
    xdraw=handles.xGrid;
    ydraw=handles.yGrid;
    
    hold off
    imshow(handles.currPlates,'Parent',handles.axes1)
    hold on
    for k=1:(length(xdraw)/2)
        plot(xdraw((2*k-1):2*k),ydraw((2*k-1):2*k),'r','LineWidth',2,'Clipping','off')
    end
    for i=1:handles.NxPlates
        for j=1:handles.NyPlates
            if handles.currPlates(j,i)==1
                try
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:5)]);
                catch
                    text(i-0.4,j-0.25,[handles.plateIDs{j,i}(1:end)]);
                end
                text(i-0.4,j+0.25,['P#: ' num2str(handles.plateLocs(j,i))]);
            end
        end
    end
    set(handles.InstructionText1,'string',['Please select plate whose data you want to analyze'])
    
    [newy newx]=ginput(1);
    newx=round(newx);
    newy=round(newy);
    
    if handles.currPlates(newx,newy)==0
        set(handles.InstructionText1,'string',['No plate is present there.'])
        noplate=1;
    else
         plot(newy,newx,'bs','LineWidth',2,'MarkerSize',35)
         dname=[handles.plateSaveDirectory{newx,newy} '\' handles.plateIDs{newx,newy}];
         fileSaveName=(inputdlg({'Enter a save name for the analyzed data file'},'File save name: ',1,{[handles.plateIDs{newx,newy} '_Analyzed.mat']}));
    end  
    
elseif answer{1}=='N'
    set(handles.InstructionText1,'string',['Please select the directory of the plate whose data you want to analyze.'])
    dname=uigetdir();
    fileSaveName=(inputdlg({'Enter a save name for the analyzed data file'},'File save name: ',1,{['myAnalyzedData.mat']}));
else
    noplate=1;
end

if noplate==0
    sname=fileSaveName{1};
    loadfile=uigetfile(dname,'Select consolidated pdata file');
    answerM=inputdlg({'Enter aggregate lifespan threshold:'},'Threshold',1,{num2str(handles.LSMetric)});
    answerHinputdlg({'Enter aggregate healthspan threshold:'},'Threshold',1,{num2str(handles.HSMetric)});
    metricp=str2num(answerM{1});
    metrich=str2num(answerH{1});
    
    [stimulated, spontaneous, t, AggLS, CDFsum, mySuccess] = processPdata24WellPlate(dname,loadfile,metricp,metrich,sname);
    
    if mySuccess==1
        if answer{1}=='Y'
            set(handles.InstructionText1,'string',['Data successfully analyzed for plate #' num2str(handles.plateLocs(newx,newy)) '.'])
        else
            set(handles.InstructionText1,'string',['Data successfully analyzed for chosen folder.'])
        end
        
    elseif mySuccess==0
        set(handles.InstructionText1,'string',['Something went wrong.  Check the directory and ensure data has been consolidated before trying to analyze it.'])
    end
end

guidata(hObject,handles);

% --- Executes on button press in plotMyData.
function plotMyData_Callback(hObject, eventdata, handles)
% hObject    handle to plotMyData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    [loadfile loadpath]=uigetfile('Select analyzed pdata file');
    currdata=load([loadpath '\' loadfile]);
    
    AggLS=currdata.AggLS;
    set(handles.InstructionText1,'string',['Successfully loaded analyzed data.  Plotting aggregated lifespan score for each well.'])
    
    % plot aggregate lifespan score
    hold off
    plot(1:24,AggLS,'o','LineWidth',2,'MarkerSize',15,'Parent',handles.axes1)
    xlabel('Well #')
    ylabel('Aggregate Lifespan-Activity Score')
    set(handles.axes1,'FontSize',15)
catch
    set(handles.InstructionText1,'string',['Something went wrong.  Please make sure you select a file that ends in "_Analyzed.mat".'])
end
guidata(hObject,handles);

% --- Executes on button press in identifyPlateHits.
function identifyPlateHits_Callback(hObject, eventdata, handles)
% hObject    handle to identifyPlateHits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer=inputdlg({'Enter empty vector well numbers separated by commas:'},'Well #s',1,{'1, 5, 10'});


% --- Executes on button press in reconnectToGrblAndNidaq.
function reconnectToGrblAndNidaq_Callback(hObject, eventdata, handles)
% hObject    handle to reconnectToGrblAndNidaq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


grblConnected=0;
nidaqConnected=0;

global grblBoard
grblBoard=serial([handles.grblComPort{1}],'BaudRate',115200);
try
    fopen(grblBoard);
    grblBoard.ReadAsyncMode='continuous';
    grblConnected=1;
    set(handles.InstructionText1,'string','GRBL Connection Successful.')
    
    global myNidaq % blue light channel
    global myRedLed % red light channel
    devices=daq.getDevices;
    myNidaq=daq.createSession('ni');
    myRedLed=daq.createSession('ni');
    blueCh=str2num(handles.nidaqCh{1}); % blue channel
    redCh = 1-blueCh; % red channel
    addAnalogOutputChannel(myNidaq,handles.nidaqName{1},blueCh,'Voltage');
    addAnalogOutputChannel(myRedLed,handles.nidaqName{1},redCh,'Voltage');
    nidaqConnected=1;
    set(handles.InstructionText1,'string','Nidaq Connection Successful.')
    pause(2)
    set(handles.InstructionText1,'string','GRBL and Nidaq Connection Successful. Please home the robot before continuing.')
    
catch
    if grblConnected==0
        set(handles.InstructionText1,'string','Failed to connect to GRBL Board.  If you are having trouble, try restarting Matlab and/or the GRBL Board.')
    else
        set(handles.InstructionText1,'string','Failed to connect to Nidaq.  Check connection and device number.')
    end
end

guidata(hObject,handles);


% --- Executes on button press in plotRawActivity.
function plotRawActivity_Callback(hObject, eventdata, handles)
% hObject    handle to plotRawActivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    [loadfile loadpath]=uigetfile('Select analyzed pdata file');
    currdata=load([loadpath '\' loadfile]);
    
    stim=currdata.stimulated;
    spon=currdata.spontaneous;
    t=currdata.t;
    set(handles.InstructionText1,'string',['Successfully loaded analyzed data.  Plotting aggregated lifespan score for each well.'])
    
    % plot aggregate lifespan score
    
    try
        i=handles.wellToPlot;
        hold off
        set(handles.InstructionText1,'string',['Currently showing raw activity data for well #' num2str(i) '.  Press Enter to proceed to data for next well.'])
        plot(t,spon(i,:),'b','LineWidth',3,'Parent',handles.axes1)
        hold on
        plot(t,stim(i,:),'r','LineWidth',3,'Parent',handles.axes1)
        xlabel('Time (Days)')
        ylabel('Raw Activity')
        legend(['Well #' num2str(i) ' Spontaneous behavior'],['Well #' num2str(i) ' Stimulated behavior'])
        legend boxoff
        set(handles.axes1,'FontSize',15)
    catch
        set(handles.InstructionText1,'string',['Set well to plot.'])
    end
catch
    set(handles.InstructionText1,'string',['Something went wrong.  Please make sure you select a file that ends in "_Analyzed.mat".'])
end
guidata(hObject,handles);



function wellToPlot_Callback(hObject, eventdata, handles)
% hObject    handle to wellToPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wellToPlot as text
%        str2double(get(hObject,'String')) returns contents of wellToPlot as a double

wellToPlot=str2double(get(hObject,'String'));
handles.wellToPlot=wellToPlot;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function wellToPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wellToPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in extractDataForMultiplePlates.
function extractDataForMultiplePlates_Callback(hObject, eventdata, handles)
% hObject    handle to extractDataForMultiplePlates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dname=uigetdir();
set(handles.InstructionText1,'string',['Select the directory containing folders whose analyzed data you want to extract into a new folder.'])
folders=dir(dname);
folderSaveName=(inputdlg({'Enter a save name for the extracted data folder'},'File save name: ',1,{['extractedData']}));
currt=clock;
folderSaveNameDate=[folderSaveName{1} '_' num2str(currt(1)) num2str(currt(2),'%02d') num2str(currt(3),'%02d') ];
mkdir([dname '\' folderSaveNameDate]) 
for i=3:length(folders)
    if exist([dname '\' folders(i).name '\' folders(i).name '_Analyzed.mat'])
       copyfile([dname '\' folders(i).name '\' folders(i).name '_Analyzed.mat'],[dname '\' folderSaveNameDate '\' folders(i).name '_Analyzed.mat'])
       copyfile([dname '\' folders(i).name '\' folders(i).name '_Consolidated.mat'],[dname '\' folderSaveNameDate '\' folders(i).name '_Consolidated.mat'])
    end
end
set(handles.InstructionText1,'string',['Data successfully extracted from folder: ' dname ' to folder: ' dname '\' folderSaveNameDate])


% --- Executes during object creation, after setting all properties.
function testRedLed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testRedLed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in resetImaging.
function resetImaging_Callback(hObject, eventdata, handles)
% hObject    handle to resetImaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer=inputdlg({'Set next plate to image to first plate available?  (Y/N):'},'Confirm Imaging Loop Reset',1,{'N'});

if answer{1}=='Y'
    % update next plate to image to first available plate
    platesToImage=find((handles.currPlates').*(handles.plateLocs')~=0);
    nextPlateToImage=platesToImage(1);
    set(handles.InstructionText1,'string',['Imaging reset.  Next plate to image is plate ' num2str(nextPlateToImage) '.  Press Stop imaging, press Initialize imaging, and finally press Begin Imaging.'])
else
    % update next plate to image to next available plate
    platesToImage=find((handles.currPlates').*(handles.plateLocs')~=0);
    currentPlate=find(platesToImage==handles.nextPlateToImage);
    if currentPlate==length(platesToImage)
        nextPlateToImage=platesToImage(1);
    else
        nextPlateToImage=platesToImage(currentPlate+1);
    end

     set(handles.InstructionText1,'string',['Imaging reset.  Next plate to image is plate #' num2str(nextPlateToImage) '.  Press Stop imaging, press Initialize imaging, and finally press Begin Imaging.'])
end

handles.nextPlateToImage=nextPlateToImage;

% save handles
savehandles=handles;
save([handles.homeDirectory '\' handles.currentStateName '.mat'], 'savehandles');

pause(1)

% Require user to always press initialize imaging before re-starting
% imaging
set(handles.imagingButton,'Enable','off')

% Re-enable these buttons
set(handles.getPlateInfo, 'Enable','on')
set(handles.addPlate, 'Enable','on')
set(handles.removePlate, 'Enable','on')
set(handles.manualPlateCalibration, 'Enable','on')
set(handles.initializeImaging,'Enable','on')
set(handles.testCamera,'Enable','on')
set(handles.testRedLed,'Enable','on')
set(handles.testBlueLight,'Enable','on')
set(handles.manualMoveToPlate,'Enable','on')

guidata(hObject,handles);
