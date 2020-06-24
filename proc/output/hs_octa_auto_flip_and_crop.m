%% Constants
CROP_Z = [50, 512]; % DC & AC to system rolloff
CROP_X = 24; % sync error in custom system
SKIP_FRAME = 1; % galvo recoil destroys frame 1

%% Get files
[avi_fnames, avi_path] = uigetfile('*.avi', 'Select HS-OCT-A processed scans', ...
	'multiselect', 'on');
if isnumeric(avi_fnames)
	return;
end
if ~iscell(avi_fnames)
	avi_fnames = {avi_fnames};
end
avi_fnames = avi_fnames';

%% Read, flip, crop
for ii=1:numel(avi_fnames)
	new_name = strrep(avi_fnames{ii}, '.avi', '_crop.avi');
	
	% Create reader and writer
	vr = VideoReader(fullfile(avi_path, avi_fnames{ii})); %#ok<TNMLP>
	vw = VideoWriter(fullfile(avi_path, new_name), 'motion jpeg avi'); %#ok<TNMLP>
	vw.open;
	try
		for jj = 1:vr.NumFrames
			frame = vr.readFrame;
			if jj == SKIP_FRAME
				continue;
			end
			frame = frame(CROP_Z(1):CROP_Z(2), CROP_X:end, :);
			frame = flip(frame, 2);
			vw.writeVideo(frame);
		end
	catch me
		vw.close;
	end
	vw.close;
end