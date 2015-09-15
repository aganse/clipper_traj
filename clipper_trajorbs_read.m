% Plot map of surface projections of flybys, with dots at points of closest approach

N=1801;  % num data pts, set in clipper_traj_calc.f
maxlon=360; minlon=0;  % set in clipper_traj_calc.f
endian='l';  % little ('l') vs big ('b') endian data (generally 'l' on Intel procs)

datadir='clipper_traj_data';
orbs=1:45;
col=hsv(55);

for j=1:length(orbs)
  orb=num2str(orbs(j),'%02d');
  disp(['loading data for orbit ' orb '...']);
  fid=fopen([datadir '/clipper.orb' orb '.traj.dat'],'r');
  numbytes=fread(fid,1,'int32',0,endian);
  spctraj=fread(fid,[N,3],'double',0,endian);  % each row = [long(deg),lat(deg),radius(m)]
  fclose(fid);

  % convert long convention :
  i=find(spctraj(:,1)<0);
  spctraj(i,1)=spctraj(i,1)+360;

  % find closest approach point :
  iCA=find(spctraj(:,3)==min(spctraj(:,3)));  % note only works for one flyby at a time!

  % the 360-lon is used to get W lon (common Europa mapping convention)
  plot(360-spctraj(:,1),spctraj(:,2),'.','color',col(j,:),'linewidth',2);
  hold on;
  calon(j)=360-spctraj(iCA,1);
  calat(j)=spctraj(iCA,2);
end

plot(calon,calat,'k*','linewidth',2);
axis xy;
set(gca,'XDir','Reverse');
axis([minlon maxlon -90 90]);
xlabel('Europa W Longitude (deg)');
ylabel('Europa Latitude (deg)');
title({'Europa Clipper flyby path extents (CA \pm 30min).';...
       'Black dots are lat/lon of closest approach for each flyby;';...
       '(rainbow color order in chronological order of flybys).'});
grid on;
hold off;
print -dpdf clipper_trajorbs_plot.pdf
