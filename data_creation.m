function data=data_creation
[f_o,p_o]=uigetfile('*.**o');
files.rinex=strcat(p_o,f_o);
[f_o,p_o]=uigetfile('*.sp3');
f_orbit=strcat(p_o,f_o);
[f_n,p_n]=uigetfile('*.**n');
f_nav=strcat(p_n,f_n);
[ver] = r_rnxvers(files.rinex);
if ver>=3
    [inf] = r_rnxheadv3(files.rinex);
    inf.time.int=1;
    [obs] = r_rnxobsv3(files.rinex,inf);

elseif ver>=2
    [inf] = r_rnxheadv2(files.rinex);
    inf.time.int=1;
    [obs] = r_rnxobsv2(files.rinex,inf);
else
    errordlg('RINEX version is not valid !','RINEX version error');
    error('RINEX version is not valid !');
end
data.obs=obs;
data.inf=inf;
[ephmat] = sp3reader(f_orbit);
data.inf  = inf;
data.obs  = obs;
data.ephmat=ephmat;
[navData] = r_nav(f_nav);
data.navData=navData;
[data]=cal_sat_nav(data);
XYZ=[3235217.9316, 4051192.9811, 3704925.8384];
[data] = createSNRMATfile(data,2,XYZ);
[data] = cs_detect_mw(data,20);
