function [navData] = r_nav(f_nav)
format long;

[fid,errmsg] = fopen(f_nav);

if any(errmsg)
    errordlg('NAV file can not be opened.','NAV file error');
    return;
end

line = fgetl(fid);
nav_ver=str2double(line(1:10));
while 1
    line = fgetl(fid);
    
    if ~ischar(line)                                   
        continue
    end
    % every single line has 80 chars
    if length(line)<80                                 
        line(length(line)+1:80)=' ';
    end
    
    if strfind(line,'END OF HEADER       ')
        break
    else
        continue
    end
end

navData.GNum = 0;
navData.RNum = 0;
navData.CNum = 0;
navData.ENum = 0;
navData.GNavData = struct([]);
navData.RNavData = struct([]);
navData.CNavData = struct([]);
navData.ENavData = struct([]);

while ~feof(fid)
    
    line = fgetl(fid);
    if ~ischar(line)        
        continue          
    end
    
    if length(line)<80                 
        line(length(line)+1:80)=' ';
    end
    
    if strcmp(line(1),'G')
        navData.GNum = navData.GNum+1;                                  %% read the firt line
        navData.GNavData(navData.GNum).prn = str2double(line(2:3));
        navData.GNavData(navData.GNum).year = str2double(line(5:8));
        navData.GNavData(navData.GNum).month = str2double(line(10:11));
        navData.GNavData(navData.GNum).day = str2double(line(13:14));
        navData.GNavData(navData.GNum).hour = str2double(line(16:17));
        navData.GNavData(navData.GNum).min = str2double(line(19:20));
        navData.GNavData(navData.GNum).sec = str2double(line(22:23));
        time=[navData.GNavData(1).year navData.GNavData(1).month navData.GNavData(1).day];
        navData.GNavData(navData.GNum).SVClkBias = str2double(line(24:42));
        navData.GNavData(navData.GNum).SVClkDrift = str2double(line(43:61));
        navData.GNavData(navData.GNum).SVClkDDrift = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the second line
        navData.GNavData(navData.GNum).IODE = str2double(line(5:23));
        navData.GNavData(navData.GNum).Crs = str2double(line(24:42));
        navData.GNavData(navData.GNum).DeltN = str2double(line(43:61));
        navData.GNavData(navData.GNum).M0 = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the third line
        navData.GNavData(navData.GNum).Cuc = str2double(line(5:23));
        navData.GNavData(navData.GNum).e = str2double(line(24:42));
        navData.GNavData(navData.GNum).Cus = str2double(line(43:61));
        navData.GNavData(navData.GNum).sqrtA = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the forth line
        navData.GNavData(navData.GNum).Toe = str2double(line(5:23));
        navData.GNavData(navData.GNum).Cic = str2double(line(24:42));
        navData.GNavData(navData.GNum).OMEGA0 = str2double(line(43:61));
        navData.GNavData(navData.GNum).Cis = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the fifth line
        navData.GNavData(navData.GNum).i0 = str2double(line(5:23));
        navData.GNavData(navData.GNum).Crc = str2double(line(24:42));
        navData.GNavData(navData.GNum).omega = str2double(line(43:61));
        navData.GNavData(navData.GNum).OMEGADOT = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the sixth line
        navData.GNavData(navData.GNum).IDOT = str2double(line(5:23));
        navData.GNavData(navData.GNum).CodesOnL2 = str2double(line(24:42));
        navData.GNavData(navData.GNum).GPSWeek = str2double(line(43:61));
        navData.GNavData(navData.GNum).L2PDataFlag = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the seventh line
        navData.GNavData(navData.GNum).SVAccuracy = str2double(line(5:23));
        navData.GNavData(navData.GNum).SVHealth = str2double(line(24:42));
        navData.GNavData(navData.GNum).TGD = str2double(line(43:61));
        navData.GNavData(navData.GNum).IODC = str2double(line(62:80));  %% Issue of Data, Clock
        
        line = fgetl(fid);                              %% read the eighth line
        navData.GNavData(navData.GNum).TTOM = str2double(line(5:23)); 
        navData.GNavData(navData.GNum).FitInterval = str2double(line(24:42));
        navData.GNavData(navData.GNum).Spare1 = str2double(line(43:61));
        navData.GNavData(navData.GNum).Spare2 = str2double(line(62:80));
                        
    elseif strcmp(line(1),'R')
        navData.RNum = navData.RNum+1;                                  %% read the firt line
        navData.RNavData(navData.RNum).prn = str2double(line(2:3))+32;
        navData.RNavData(navData.RNum).year = str2double(line(5:8));
        navData.RNavData(navData.RNum).month = str2double(line(10:11));
        navData.RNavData(navData.RNum).day = str2double(line(13:14));
        navData.RNavData(navData.RNum).hour = str2double(line(16:17));
        navData.RNavData(navData.RNum).min = str2double(line(19:20));
        navData.RNavData(navData.RNum).sec = str2double(line(22:23));
        time=[navData.RNavData(1).year navData.RNavData(1).month navData.RNavData(1).day];
        
        navData.RNavData(navData.RNum).SVClkBias = str2double(line(24:42));
        navData.RNavData(navData.RNum).SVRFB = str2double(line(43:61)); %% SV relative frequency bias
        navData.RNavData(navData.RNum).MFT = str2double(line(62:80));   %% Message frame time
        
        tline = fgetl(fid);                              %% read the second line
        navData.RNavData(navData.RNum).SatPosX = str2double(tline(5:23));
        navData.RNavData(navData.RNum).velXDot = str2double(tline(24:42));
        navData.RNavData(navData.RNum).XAcceleration = str2double(tline(43:61));
        navData.RNavData(navData.RNum).health = str2double(tline(62:80));
        
        tline = fgetl(fid);                              %% read the third line
        navData.RNavData(navData.RNum).SatPosY = str2double(tline(5:23));
        navData.RNavData(navData.RNum).velYDot = str2double(tline(24:42));
        navData.RNavData(navData.RNum).YAcceleration = str2double(tline(43:61));
        navData.RNavData(navData.RNum).freNum = str2double(tline(62:80));%% frequency number
        
        tline = fgetl(fid);                              %% read the forth line
        navData.RNavData(navData.RNum).SatPosZ = str2double(tline(5:23));
        navData.RNavData(navData.RNum).velZDot = str2double(tline(24:42));
        navData.RNavData(navData.RNum).ZAcceleration = str2double(tline(43:61));
        navData.RNavData(navData.RNum).AOO = str2double(tline(62:80));   %% Age of oper
    elseif strcmp(line(1),'C')
        navData.CNum = navData.CNum+1;                                  %% read the firt line
        navData.CNavData(navData.CNum).prn = str2double(line(2:3))+95;
        navData.CNavData(navData.CNum).year = str2double(line(5:8));
        navData.CNavData(navData.CNum).month = str2double(line(10:11));
        navData.CNavData(navData.CNum).day = str2double(line(13:14));
        navData.CNavData(navData.CNum).hour = str2double(line(16:17));
        navData.CNavData(navData.CNum).min = str2double(line(19:20));
        navData.CNavData(navData.CNum).sec = str2double(line(22:23));
        time=[navData.CNavData(1).year navData.CNavData(1).month navData.CNavData(1).day];
        navData.CNavData(navData.CNum).SVClkBias = str2double(line(24:42));
        navData.CNavData(navData.CNum).SVClkDrift = str2double(line(43:61));
        navData.CNavData(navData.CNum).SVClkDDrift = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the second line
        navData.CNavData(navData.CNum).IODE = str2double(line(5:23));
        navData.CNavData(navData.CNum).Crs = str2double(line(24:42));
        navData.CNavData(navData.CNum).DeltN = str2double(line(43:61));
        navData.CNavData(navData.CNum).M0 = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the third line
        navData.CNavData(navData.CNum).Cuc = str2double(line(5:23));
        navData.CNavData(navData.CNum).e = str2double(line(24:42));
        navData.CNavData(navData.CNum).Cus = str2double(line(43:61));
        navData.CNavData(navData.CNum).sqrtA = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the forth line
        navData.CNavData(navData.CNum).Toe = str2double(line(5:23));
        navData.CNavData(navData.CNum).Cic = str2double(line(24:42));
        navData.CNavData(navData.CNum).OMEGA0 = str2double(line(43:61));
        navData.CNavData(navData.CNum).Cis = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the fifth line
        navData.CNavData(navData.CNum).i0 = str2double(line(5:23));
        navData.CNavData(navData.CNum).Crc = str2double(line(24:42));
        navData.CNavData(navData.CNum).omega = str2double(line(43:61));
        navData.CNavData(navData.CNum).OMEGADOT = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the sixth line
        navData.CNavData(navData.CNum).IDOT = str2double(line(5:23));
        navData.CNavData(navData.CNum).Spare1 = str2double(line(24:42));
        navData.CNavData(navData.CNum).BDTWeek = str2double(line(43:61));
        navData.CNavData(navData.CNum).Spare2 = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the seventh line
        navData.CNavData(navData.CNum).SVAccuracy = str2double(line(5:23));
        navData.CNavData(navData.CNum).SatH1 = str2double(line(24:42));
        navData.CNavData(navData.CNum).TGD1 = str2double(line(43:61));  %% B1/B3
        navData.CNavData(navData.CNum).TGD2 = str2double(line(62:80));  %% B2/B3
        
        line = fgetl(fid);                              %% read the eighth line
        navData.CNavData(navData.CNum).TTOM = str2double(line(5:23));   %% Transmission time of message
        navData.CNavData(navData.CNum).IODC = str2double(line(24:42));  %% Issue of Data Clock
        navData.CNavData(navData.CNum).Spare3 = str2double(line(43:61));
        navData.CNavData(navData.CNum).Spare4 = str2double(line(62:80));
        
    elseif strcmp(line(1),'E')
        navData.ENum = navData.ENum+1;                                  %% read the firt line
        navData.ENavData(navData.ENum).prn = str2double(line(2:3))+59;
        navData.ENavData(navData.ENum).year = str2double(line(5:8));
        navData.ENavData(navData.ENum).month = str2double(line(10:11));
        navData.ENavData(navData.ENum).day = str2double(line(13:14));
        navData.ENavData(navData.ENum).hour = str2double(line(16:17));
        navData.ENavData(navData.ENum).min = str2double(line(19:20));
        navData.ENavData(navData.ENum).sec = str2double(line(22:23));
        time=[navData.ENavData(1).year navData.ENavData(1).month navData.ENavData(1).day];
        navData.ENavData(navData.ENum).SVClkBias = str2double(line(24:42));
        navData.ENavData(navData.ENum).SVClkDrift = str2double(line(43:61));
        navData.ENavData(navData.ENum).SVClkDDrift = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the second line
        navData.ENavData(navData.ENum).IODN = str2double(line(5:23));   %% IODnav Ossue of Date of the nav batch
        navData.ENavData(navData.ENum).Crs = str2double(line(24:42));
        navData.ENavData(navData.ENum).DeltN = str2double(line(43:61));
        navData.ENavData(navData.ENum).M0 = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the third line
        navData.ENavData(navData.ENum).Cuc = str2double(line(5:23));
        navData.ENavData(navData.ENum).e = str2double(line(24:42));
        navData.ENavData(navData.ENum).Cus = str2double(line(43:61));
        navData.ENavData(navData.ENum).sqrtA = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the forth line
        navData.ENavData(navData.ENum).Toe = str2double(line(5:23));
        navData.ENavData(navData.ENum).Cic = str2double(line(24:42));
        navData.ENavData(navData.ENum).OMEGA0 = str2double(line(43:61));
        navData.ENavData(navData.ENum).Cis = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the fifth line
        navData.ENavData(navData.ENum).i0 = str2double(line(5:23));
        navData.ENavData(navData.ENum).Crc = str2double(line(24:42));
        navData.ENavData(navData.ENum).omega = str2double(line(43:61));
        navData.ENavData(navData.ENum).OMEGADOT = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the sixth line
        navData.ENavData(navData.ENum).IDOT = str2double(line(5:23));
        navData.ENavData(navData.ENum).DataSources = str2double(line(24:42));
        navData.ENavData(navData.ENum).GALWeek = str2double(line(43:61));
        navData.ENavData(navData.ENum).spare1 = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the seventh line
        navData.ENavData(navData.ENum).SISA = str2double(line(5:23));   %% Signal in space accuracy
        navData.ENavData(navData.ENum).SVHealth = str2double(line(24:42));
        navData.ENavData(navData.ENum).BGDE5aE1 = str2double(line(43:61));
        navData.ENavData(navData.ENum).BGDE5bE1 = str2double(line(62:80));
        
        line = fgetl(fid);                              %% read the eighth line
        navData.ENavData(navData.ENum).TTOM = str2double(line(5:23));   %% Transmission time of message
        navData.ENavData(navData.ENum).spare2 = str2double(line(24:42));
        navData.ENavData(navData.ENum).spare3 = str2double(line(43:61));
        navData.ENavData(navData.ENum).spare4 = str2double(line(62:80));
    elseif nav_ver<3 && ~isnan(str2double(line(1:2)))
        [PRN, Y, M, D, H, min, sec,af0,af1,af2] = parsef(line, {'I2' 'I3' 'I3' 'I3' 'I3' 'I3' ...
            'F5.1','D19.12','D19.12','D19.12'});
        navData.GNum = navData.GNum+1;
        navData.GNavData(navData.GNum).prn = PRN;
        navData.GNavData(navData.GNum).year = Y+2000;
        navData.GNavData(navData.GNum).month = M;
        navData.GNavData(navData.GNum).day = D;
        navData.GNavData(navData.GNum).hour =  H;
        navData.GNavData(navData.GNum).min = min;
        navData.GNavData(navData.GNum).sec = sec;
        time=[navData.GNavData(1).year navData.GNavData(1).month navData.GNavData(1).day];
        navData.GNavData(navData.GNum).SVClkBias = af0;
        navData.GNavData(navData.GNum).SVClkDrift = af1;
        navData.GNavData(navData.GNum).SVClkDDrift = af2;
        line = fgetl(fid);%% read the second line
        [IODE Crs delta_n M0] = parsef(line, {'D22.12' 'D19.12' 'D19.12' 'D19.12'});
        navData.GNavData(navData.GNum).IODE = IODE;
        navData.GNavData(navData.GNum).Crs =  Crs;
        navData.GNavData(navData.GNum).DeltN = delta_n;
        navData.GNavData(navData.GNum).M0 = M0;
        line = fgetl(fid);%% read the third line
        [Cuc e Cus sqrtA] = parsef(line, {'D22.12' 'D19.12' 'D19.12' 'D19.12'});
        navData.GNavData(navData.GNum).Cuc = Cuc;
        navData.GNavData(navData.GNum).e = e;
        navData.GNavData(navData.GNum).Cus = Cus;
        navData.GNavData(navData.GNum).sqrtA = sqrtA;
        line = fgetl(fid);%% read the forth line
        [toe Cic OMEGA Cis] = parsef(line, {'D22.12' 'D19.12' 'D19.12' 'D19.12'});
        navData.GNavData(navData.GNum).Toe = toe;
        navData.GNavData(navData.GNum).Cic = Cic;
        navData.GNavData(navData.GNum).OMEGA0 = OMEGA;
        navData.GNavData(navData.GNum).Cis = Cis;
        line = fgetl(fid);%% read the fifth line
        [i0 Crc omega OMEGA_dot] = parsef(line, {'D22.12' 'D19.12' 'D19.12' 'D19.12'});
        navData.GNavData(navData.GNum).i0 = i0;
        navData.GNavData(navData.GNum).Crc = Crc;
        navData.GNavData(navData.GNum).omega = omega;
        navData.GNavData(navData.GNum).OMEGADOT = OMEGA_dot;
        line = fgetl(fid);%% read the sixth line
        [i_dot L2_codes GPS_wk L2_dataflag ] = parsef(line, {'D22.12' 'D19.12' 'D19.12' 'D19.12'});
        navData.GNavData(navData.GNum).IDOT = i_dot;
        navData.GNavData(navData.GNum).CodesOnL2 = L2_codes;
        navData.GNavData(navData.GNum).GPSWeek = GPS_wk;
        navData.GNavData(navData.GNum).L2PDataFlag =L2_dataflag;
        line = fgetl(fid);%% read the seventh line
        [SV_acc SV_health TGD IODC] = parsef(line, {'D22.12' 'D19.12' 'D19.12' 'D19.12'});
        navData.GNavData(navData.GNum).SVAccuracy = SV_acc;
        navData.GNavData(navData.GNum).SVHealth = SV_health;
        navData.GNavData(navData.GNum).TGD = TGD;
        navData.GNavData(navData.GNum).IODC = IODC;
        line = fgetl(fid);%% read the eighth line
        [msg_trans_t fit_int Spare1 Spare2] = parsef(line, {'D22.12' 'D19.12' 'D19.12' 'D19.12'});
        navData.GNavData(navData.GNum).TTOM = msg_trans_t;
        navData.GNavData(navData.GNum).FitInterval = fit_int;
        navData.GNavData(navData.GNum).Spare1 = Spare1;
        navData.GNavData(navData.GNum).Spare2 = Spare2;
    else
        continue
    end
end
navData.time=time;
fclose(fid);
end