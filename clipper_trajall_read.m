% clipper_trajall_read.m
% For finding minima of altitude=spctraj(:,3) to find closest-approach points;
% These points then used in clipper_trajorbs_calc.f to grab +/-30min around
% each closest-approach point.

N=8.2033431e6;  % # data points
dt=10;  % # seconds betw data points
datadir='clipper_traj_data';
fid=fopen([datadir '/clipper.trajall.dat'],'r');
% Note little-vs-big endian specifier via 'l' or 'b' in fread()'s below:
% 'l' for Intel-based procs, 'b' for powerpc-based old Macs.
numbytes=fread(fid,1,'int32',0,'l');
spctraj=fread(fid,[N,3],'double',0,'l');  % each row = [long(deg),lat(deg),radius(m)]
fclose(fid);
% convert long convention :
spctraj(:,1)=spctraj(:,1)+360.0;


% Now find the altitude minima to find times of closest approach in each flyby:
%t0 = datenum('MAR-25-2029 16:44:49.401');  % works in matlab but not octave
t0 = datenum(2029, 03, 25, 16, 44, 49.401);  % works in both matlab and octave
t = t0 + ((1:dt:N*dt-1)')/24/3600;  % t is in datenum format
peaklist = SimplePeakFind ( 1000, -spctraj(:,3),  -3e8);
plot(t,spctraj(:,3),'-',t(peaklist), spctraj(peaklist,3),'o',...
     'linewidth',2,'markersize',5,'markerfacecolor',[1,0,0]);
axis tight; datetick;
xlabel('date (year)');
ylabel('altitude over Europa (m)');
title({'Europa Clipper mission altitudes timeseries';...
       '(with times of closest approach marked)'});
print -dpdf clipper_trajall_plot.pdf

% list those CA times out to implement in clipper_trajorbs_calc.f subroutine:
datestr(t(peaklist))
% (This list which is output to stdout is then cut&pasted and reformatted by hand
% to form the subroutine at end of clipper_trajorbs_calc.f)
