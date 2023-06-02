function [obs] = r_rnxobsv3(f_obs,inf)
[fid,errmsg] = fopen(f_obs);
if any(errmsg)
    errordlg('OBSERVATION file can not be opened !','Observation file error');
    error   ('OBSERVATION file error');
end
sno = 155;
snrno=size(inf.snrtype,2);
if inf.time.last == 86400
    fi = inf.time.first(4,1)*3600 + inf.time.first(5,1)*60 + inf.time.first(6,1);
    la = inf.time.last;
    max = (la-fi)/inf.time.int + 1;
else
    fi = inf.time.first(4,1)*3600 + inf.time.first(5,1)*60 + inf.time.first(6,1);
    la = inf.time.last (4,1)*3600 + inf.time.last (5,1)*60 + inf.time.last (6,1);
    max = (la-fi)/inf.time.int + 1;
end
p1s  = NaN(max,sno);
p2s  = NaN(max,sno);
l1s  = NaN(max,sno);
l2s  = NaN(max,sno);

snr  =   cell(2,snrno);
for in=1:snrno
    snr{2,in}=cellstr(inf.snrtype(in));
    snr{1,in}=NaN(max,sno);
end
eps  = NaN(max, 1);
st   = zeros(max,sno);
[~,wavl] = frequencies;
epno = 0; % epoch no
lno  = 0; % line no
while ~feof(fid)

    tline = fgetl(fid);
    lno   = lno + 1;
    if ~isempty(tline) && strcmp(tline(1),'>')
        nep  = sscanf(tline(3:end),'%f');
        epno = epno + 1;
        eps(epno,1) = nep(4)*3600 + nep(5)*60 + nep(6);
        for i=1:nep(8)

            tline = fgetl(fid);
            lno   = lno + 1;
            % GPS
            if strcmp(tline(1),'G')
                k   = sscanf(tline(2:3),'%d');
                if k>32
                    continue
                end
                ono = inf.nob.gps;
                lso = NaN(ono,1);
                nu  = 0;
                for u=4:16:size(tline,2)
                    nu = nu + 1;
                    tls = sscanf(tline(u:u+13),'%f');
                    if ~isempty(tls)
                        lso(nu,1) = tls;
                    end
                end
                p1s(epno,k) = lso(inf.seq.gps(1));
                p2s(epno,k) = lso(inf.seq.gps(2));
                l1s(epno,k) = lso(inf.seq.gps(3))*wavl(k,1);
                l2s(epno,k) = lso(inf.seq.gps(4))*wavl(k,2);
                for in=1:size(inf.gps.snrtype,2)
                    if inf.seq.gps(in+4)<=length(lso)
                        L=find(inf.gps.snrtype(in)==inf.snrtype(:));
                        snr{1,L}(epno,k)=lso(inf.seq.gps(in+4));
                    end
                end
                % GLONASS
            elseif strcmp(tline(1),'R')
                k   = 32 + sscanf(tline(2:3),'%d'); % satellite prn number
                if k>59
                    continue
                end
                ono = inf.nob.glo;               % observation number
                lso = NaN(ono,1);
                nu  = 0;
                for u=4:16:size(tline,2)
                    nu = nu + 1;
                    tls = sscanf(tline(u:u+13),'%f');
                    if ~isempty(tls)
                        lso(nu,1) = tls;
                    end
                end
                % store the data
                p1s(epno,k) = lso(inf.seq.glo(1));
                l1s(epno,k) = lso(inf.seq.glo(3))*wavl(k,1);

                if inf.seq.glo(2) ~= 0
                    p2s(epno,k) = lso(inf.seq.glo(2));
                    l2s(epno,k) = lso(inf.seq.glo(4))*wavl(k,2);
                end
                for in=1:size(inf.glo.snrtype,2)
                    if inf.seq.glo(in+4)<=length(lso)
                        L=find(inf.glo.snrtype(in)==inf.snrtype(:));
                        snr{1,L}(epno,k)=lso(inf.seq.glo(in+4));
                    end
                end
                % GALILEO
            elseif strcmp(tline(1),'E')
                k   = 59 + sscanf(tline(2:3),'%d'); % satellite prn number
                if k>95
                    continue
                end
                ono = inf.nob.gal;               % observation number
                lso = NaN(ono,1);
                nu  = 0;
                for u=4:16:size(tline,2)
                    nu = nu + 1;
                    tls = sscanf(tline(u:u+13),'%f');
                    if ~isempty(tls)
                        lso(nu,1) = tls;
                    end
                end
                % store the data
                p1s(epno,k) = lso(inf.seq.gal(1));
                p2s(epno,k) = lso(inf.seq.gal(2));
                l1s(epno,k) = lso(inf.seq.gal(3))*wavl(k,1);
                l2s(epno,k) = lso(inf.seq.gal(4))*wavl(k,2);
                for in=1:size(inf.gal.snrtype,2)
                    if inf.seq.gal(in+4)<=length(lso)
                        L=find(inf.gal.snrtype(in)==inf.snrtype(:));
                        snr{1,L}(epno,k)=lso(inf.seq.gal(in+4));
                    end
                end
                % BEIDOU
            elseif strcmp(tline(1),'C')
                k   = 95 + sscanf(tline(2:3),'%d'); % satellite prn number
                if k>155
                    continue
                end
                ono = inf.nob.bds;               % observation number
                lso = NaN(ono,1);
                nu  = 0;
                for u=4:16:size(tline,2)
                    nu = nu + 1;
                    tls = sscanf(tline(u:u+13),'%f');
                    if ~isempty(tls)
                        lso(nu,1) = tls;
                    end
                end
                % store the data
                p1s(epno,k) = lso(inf.seq.bds(1));
                l1s(epno,k) = lso(inf.seq.bds(3))*wavl(k,1);
                if inf.seq.bds(2) ~= 0
                    p2s(epno,k) = lso(inf.seq.bds(2));
                    l2s(epno,k) = lso(inf.seq.bds(4))*wavl(k,2);
                end
                for in=1:size(inf.bds.snrtype,2)
                    if inf.seq.bds(in+4)<=length(lso)
                        L=find(inf.bds.snrtype(in)==inf.snrtype(:));
                        snr{1,L}(epno,k)=lso(inf.seq.bds(in+4));
                    end
                end
            end
        end
    end
end

all = p1s + p2s + l1s + l2s;
st(~isnan(all)) = 1;

if max>epno
    p1s(epno+1:max,:) = [];
    p2s(epno+1:max,:) = [];
    l1s(epno+1:max,:) = [];
    l2s(epno+1:max,:) = [];
    eps(epno+1:max,:) = [];
    st(epno+1:max,:)  = [];
    for in=1:size(snr,2)
        snr{1,in}= snr{1,in}(1:epno,:);
    end
end

obs.p1 = p1s;
obs.p2 = p2s;
obs.l1 = l1s;
obs.l2 = l2s;
obs.ep = eps;
obs.st = st;
obs.snr=snr;
fclose('all');


