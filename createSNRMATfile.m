function [data] = createSNRMATfile(data,ephfiletype,XYZ)
%--------------------------------------------------------------------------
% CREATESNRMATFILE
% This function creates SNRMAT file.
%
% INPUTS : OBSMAT file, ephemeris mat file, ephfiletype (1:Nav, 2:SP3), XYZ (optional)
% OUTPUT : SNRMAT file
%
% FUNCTIONS CALLED: lagrangeint.m, lagrangeloop.m, xyz2ell.m, refell.m,
%                   xyz2NEU.m, compGPScoord.m
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
load('satellite_list.mat')

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
if nargin < 3
    snrmat.info.sitepos = data.inf.rec.pos;
else
    snrmat.info.sitepos = XYZ;
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
snrmat.info.DoY = data.inf.time.doy;
snrmat.info.typesofsnr = data.obs.snr(2,:)';
snrmat.info.interval = data.inf.time.int;
snrmat.info.timeoffirstobs = data.inf.time.first;
snrmat.info.timeoflastobs = data.inf.time.last;
snrmat.snrdata = cell(1,155);
snrmat.ELAZ = cell(1,155);
snrmat.rho = cell(1,155);
outeph = NaN(length(data.obs.ep),1);
snrmat.info.epochs = [];
obsmat.obs=data.obs.snr;
ephmat=data.ephmat;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
for i = 1:155
    key = 0;
    snrmat.snrdata{1,i} = NaN(length(data.obs.ep),length(snrmat.info.typesofsnr));
    for j = 1:size(obsmat.obs,2)
        if ~isempty(obsmat.obs{1,j}(~isnan(obsmat.obs{1,j}(:,i)),i))
            key = 1;
            snrmat.snrdata{1,i}(:,j) = obsmat.obs{1,j}(:,i);
            if isempty(snrmat.info.epochs)
                snrmat.info.epochs = data.obs.ep;
            end
        end
    end
    if key == 0
        snrmat.snrdata{1,i} = [];
    end
end
if ephfiletype == 1
    navData=data.psat;
    for i = 1:155
        if ~isempty(navData{1,i})
            outeph=NaN(size(navData,1),3);
            out = cell2mat(navData(:,i));
            outeph(1:size(out,1),1:3)=out;
            [lat_site,lon_site,~] = xyz2ell(snrmat.info.sitepos(1),snrmat.info.sitepos(2),...
                snrmat.info.sitepos(3));
            num = size(outeph,1);
            rec = repmat(snrmat.info.sitepos,num,1);
            rho = sqrt((rec(:,1)-outeph(:,1)).^2+(rec(:,2)-outeph(:,2)).^2+(rec(:,3)-outeph(:,3)).^2);
            for k = 1:size(outeph,1)
                NEU = xyz2NEU([outeph(k,1)-snrmat.info.sitepos(1) ...
                    outeph(k,2)-snrmat.info.sitepos(2) ...
                    outeph(k,3)-snrmat.info.sitepos(3)],lat_site,lon_site);
                EL = atan(NEU(3)/sqrt(NEU(1)^2+NEU(2)^2));
                EL(EL<0) = NaN;
                AZ = mod(atan2(NEU(2),NEU(1)),2*pi);
                snrmat.ELAZ{i}(k,:) = 180/pi*[EL AZ];
            end
            snrmat.rho{i}=rho;
        end
    end
else
    for i = 1:155
        if ~isempty(cell2mat(ephmat.products(:,i)))
            inpeph = 1000*cell2mat(ephmat.products(:,i));
            for j = 1:3
                outeph(:,j) = lagrangeint(cell2mat(ephmat.products(:,156)),...
                    inpeph(:,j),data.obs.ep);
            end
            [lat_site,lon_site,~] = xyz2ell(snrmat.info.sitepos(1),snrmat.info.sitepos(2),...
                snrmat.info.sitepos(3));
            num = size(outeph,1);
            rec = repmat(snrmat.info.sitepos,num,1);
            rho = sqrt((rec(:,1)-outeph(:,1)).^2+(rec(:,2)-outeph(:,2)).^2+(rec(:,3)-outeph(:,3)).^2);
            for k = 1:size(outeph,1)
                NEU = xyz2NEU([outeph(k,1)-snrmat.info.sitepos(1) ...
                    outeph(k,2)-snrmat.info.sitepos(2) ...
                    outeph(k,3)-snrmat.info.sitepos(3)],lat_site,lon_site);
                EL = atan(NEU(3)/sqrt(NEU(1)^2+NEU(2)^2));
                EL(EL<0) = NaN;
                AZ = mod(atan2(NEU(2),NEU(1)),2*pi);
                snrmat.ELAZ{i}(k,:) = 180/pi*[EL AZ];
            end
            snrmat.rho{i}=rho;
        end
    end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
cnt1 = 0;
for i = 1:size(snrmat.snrdata,2)
    if ~isempty(snrmat.snrdata{1,i}) && ~isempty(snrmat.ELAZ{1,i})
        cnt1 = cnt1 + 1;
        snrmat.info.observedsats{cnt1,1} = satellite_list{i};
    end
end
%--------------------------------------------------------------------------
data.snrmat=snrmat;
end