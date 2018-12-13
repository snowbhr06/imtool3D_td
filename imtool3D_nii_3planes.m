function tool = imtool3D_nii_3planes(filename,maskfname)
if ~exist('maskfname','var'), maskfname=[]; end

tool = imtool3D_nii(filename,'axial', maskfname);
range = tool.getClimits;
tool(2) = imtool3D_nii(filename,'sagittal', maskfname,tool.getHandles.fig,range);
tool(3) = imtool3D_nii(filename,'coronal', maskfname,tool(1).getHandles.fig,range);

tool(1).setPosition([0 0 0.33 1])
tool(2).setPosition([0.33 0 0.33 1])
tool(3).setPosition([0.66 0 0.33 1])

for ii=1:3
set(tool(ii).getHandles.Panels.ROItools,'Visible','off')
set(tool(ii).getHandles.Tools.Save,'Visible','off')
set(tool(ii).getHandles.Tools.SaveOptions,'Visible','off')
end

h = tool(1).getHandles.fig;
set(h,'WindowScrollWheelFcn',@(src, evnt) scrollWheel(src, evnt, tool) )
set(h,'Windowkeypressfcn', @(hobject, event) shortcutCallback(hobject, event,tool))
set(h,'Units','Pixels');
pos = get(tool(1).getHandles.fig,'Position');
pos(3)=3*pos(3);
screensize = get(0,'ScreenSize');
pos(3) = min(pos(3),screensize(3));
pos(1) = ceil((screensize(3)-pos(3))/2);
pos(2) = ceil((screensize(4)-pos(4))/2);
set(h,'Position',pos)
set(h,'Units','normalized');


function scrollWheel(src, evnt, tool)
currentobj = hittest;
for ii=1:length(tool)
    if isequal(currentobj,tool(ii).getHandles.mask)
        newSlice=tool(ii).getCurrentSlice-evnt.VerticalScrollCount;
        dim = tool(ii).getImageSize;
        if newSlice>=1 && newSlice <=dim(3)
            tool(ii).setCurrentSlice(newSlice);
        end
        
    end
end


function shortcutCallback(hobject, event,tool)
switch event.Key
    case 'x'
        currentobj = hittest;
        for ii=1:length(tool)
            if isequal(currentobj,tool(ii).getHandles.mask)
                movetools = setdiff(1:length(tool),ii);
                [xi,yi,zi] = tool(ii).getCurrentMouseLocation;
                if ii==1
                    tool(movetools(1)).setCurrentSlice(yi);
                    tool(movetools(2)).setCurrentSlice(xi);
                else
                    tool(movetools(1)).setCurrentSlice(xi);
                    tool(movetools(2)).setCurrentSlice(yi);
                end
            end
        end
    case {'leftarrow', 'rightarrow', 'uparrow', 'downarrow', 'space'}
        for ii=1:length(tool)
            tool(ii).shortcutCallback(event)
        end
        
    otherwise
        tool(end).shortcutCallback(event)
end


