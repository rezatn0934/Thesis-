function [data]=cal_sat_nav(data)

en = size(data.obs.st,1);
sn = size(data.obs.st,2);
psat = cell(en,sn+1);
c=299792458;

navData=data.navData;
[~, gpsOSow, ~] = date2gps([data.inf.time.first(1),data.inf.time.first(2),data.inf.time.first(3),0,0,0]);

for i=1:en
    gpsOSow1=gpsOSow+data.obs.ep(i);
    oData(i).TOE=gpsOSow1;
    valid_sat=unique([find(~isnan(data.obs.p1(i,:))) find(~isnan(data.obs.p2(i,:)))]);
    oData(i).satNum =length(valid_sat);
    k = [];
    for j = 1:oData(i).satNum
        oData(i).satList(j,:) = valid_sat(j);
        if ~isnan(data.obs.p1(i,valid_sat(j)))
            oData(i).obsValue(j,:) =data.obs.p1(i,valid_sat(j));
        else
            oData(i).obsValue(j,:) =data.obs.p2(i,valid_sat(j));
        end
        %check data
        if oData(i).obsValue(j,:) < 0
            k = [k j];
        end
    end
    oData(i).satNum = oData(i).satNum - length(k);
    oData(i).satList(k,:) = [];
    oData(i).obsValue(k,:) = [];
end

eph=[reshape(cell2mat(struct2cell(navData.GNavData)),[38 navData.GNum]) reshape(cell2mat(struct2cell(navData.ENavData)),[38 navData.ENum]) reshape(cell2mat(struct2cell(navData.CNavData)),[38 navData.CNum])]';
ephGLO=reshape(cell2mat(struct2cell(navData.RNavData)),[22 navData.RNum])';
data_GPS=utc2gps(datenum(ephGLO(:,2:7)));
[~,ephGLO(:,10)]=date2gps(datevec(data_GPS));
x0 = data.inf.rec.pos(1);
y0 = data.inf.rec.pos(2);
z0 = data.inf.rec.pos(3);

for i = 1:en%all epoch
    for j = 1:oData(i).satNum
        if oData(i).satList(j,:)<33
            GM=3.986005e14;%G
            OMEGAe=7.2921151467e-5;
        elseif oData(i).satList(j,:)<60
            %GLONASS
            OMEGAe=7.292115e-5;%R
            col = find(ephGLO(:,1)==oData(i).satList(j,:));
            if isempty(col)
                continue;
            end
            ephtmp = ephGLO(col,:);
            [~,col] = min(abs(oData(i).TOE-ephtmp(:,10)));
            ephtmp = ephtmp(col,:);
            dTime = tSent - ephtmp(10);
            tSent=oData(i).TOE-oData(i).obsValue(j)/c-ephtmp(8);
            tSent=oData(i).TOE-oData(i).obsValue(j)/c-ephtmp(8)-ephtmp(9).*dTime;
            pos = [ephtmp(11) ephtmp(15) ephtmp(19)].*10^3;
            vel = [ephtmp(12) ephtmp(16) ephtmp(20)].*10^3;
            acc = [ephtmp(13) ephtmp(17) ephtmp(21)].*10^3;
            TSTEP = 60;
            if dTime>302400
                dTime = dTime-604800;
            elseif dTime<-302400
                dTime = dTime+604800;
            end
            n = floor(abs(dTime/TSTEP));
            tt = ones(n,1)*TSTEP*(dTime/abs(dTime));
            dTSTEP = rem(dTime,TSTEP);
            if (dTSTEP ~= 0)
                n = n + 1;
                tt = [tt; dTSTEP];
            end
            %Runge-Kutta numerical integration algorithm
            for ln = 1 : n
                %step 1
                pos1 = pos;
                vel1 = vel;
                [pos1_dot,vel1_dot] = diffeq(pos1,vel1,acc);
                %step 2
                pos2 = pos + pos1_dot*tt(ln)/2;
                vel2 = vel + vel1_dot*tt(ln)/2;
                [pos2_dot, vel2_dot] = diffeq(pos2,vel2,acc);
                %step 3
                pos3 = pos + pos2_dot*tt(ln)/2;
                vel3 = vel + vel2_dot*tt(ln)/2;
                [pos3_dot, vel3_dot] = diffeq(pos3,vel3,acc);
                %step 4
                pos4 = pos + pos3_dot*tt(ln);
                vel4 = vel + vel3_dot*tt(ln);
                [pos4_dot,vel4_dot] = diffeq(pos4,vel4,acc);
                %final position and velocity
                pos = pos + (pos1_dot + 2*pos2_dot + 2*pos3_dot + pos4_dot)*tt(ln)/6;
                vel = vel + (vel1_dot + 2*vel2_dot + 2*vel3_dot + vel4_dot)*tt(ln)/6;
            end
            xs = pos(1) - 0.36;ys = pos(2) + 0.08;zs= pos(3) + 0.18;
            [new_x,new_y,new_z] = rot_satpos(oData(i).TOE-tSent,xs,ys,zs,OMEGAe);
            psat{i,oData(i).satList(j,:)} = [new_x, new_y, new_z];
            continue;
        elseif oData(i).satList(j,:)<95
            GM=3.986004418e+14;%E
            OMEGAe=7.2921151467e-5;
        else
            GM=3.986004418e+14;%C
            OMEGAe=7.292115e-5;
        end
        col = find(eph(:,1)==oData(i).satList(j,:));
        if isempty(col)
            continue;
        end
        ephtmp = eph(col,:);
        [~,tow]=date2gps(ephtmp(:,2:7));
        if oData(i).satList(j,:)<96
            [~,col] = min(abs(oData(i).TOE-tow));
        else
            [~,col] = min(abs(oData(i).TOE-tow-14));
        end
        ephtmp = ephtmp(col,:);
        deltaT0 = oData(i).obsValue(j)/c;
        clkSat = 0;
        while 1
            tSent = oData(i).TOE-deltaT0-clkSat;
            if oData(i).satList(j,:)<96
                dTime = tSent-tow(col);
            else
                dTime = tSent-tow(col)-14;
            end
            if dTime>302400
                dTime = dTime-604800;
            elseif dTime<-302400
                dTime = dTime+604800;
            end
            n0 = sqrt(GM)/(ephtmp(18)^3);
            n = n0 + ephtmp(13);
            M = ephtmp(14)+n*dTime;
            E0 = M;
            while 1
                E = M+ephtmp(16)*sin(E0);
                if abs(E-E0)<1e-12
                    break
                else
                    E0 = E;
                end
            end

            f = atan2((sqrt(1-ephtmp(16)^2)*sin(E)),(cos(E)-ephtmp(16)));

            u0 = ephtmp(25) + f;

            delta_u = ephtmp(15)*cos(2*u0)+ephtmp(17)*sin(2*u0);
            delta_r = ephtmp(24)*cos(2*u0)+ephtmp(12)*sin(2*u0);
            delta_i = ephtmp(20)*cos(2*u0)+ephtmp(22)*sin(2*u0);

            u = u0+delta_u;
            r = ephtmp(18)^2*(1-ephtmp(16)*cos(E))+delta_r;
            w = ephtmp(23)+ephtmp(27)*dTime+delta_i;

            x = r*cos(u);
            y = r*sin(u);

            if oData(i).satList(j,:)>=96 && oData(i).satList(j,:)<=100
                L = ephtmp(21)+ephtmp(26)*dTime-OMEGAe*tow(col);
            else
                L = ephtmp(21)+(ephtmp(26)-OMEGAe)*dTime-OMEGAe*tow(col);
            end

            xs = x*cos(L)-y*cos(w)*sin(L);
            ys = x*sin(L)+y*cos(w)*cos(L);
            zs = y*sin(w);

            if oData(i).satList(j,:)>=96 && oData(i).satList(j,:)<=100
                xtemp = xs;
                ytemp = cosd(-5)*ys+sind(-5)*zs;
                ztemp = -sind(-5)*ys+cosd(-5)*zs;

                sigma = OMEGAe*dTime;
                xs = cos(sigma)*xtemp+sin(sigma)*ytemp;
                ys = -sin(sigma)*xtemp+cos(sigma)*ytemp;
                zs = ztemp;
            end

            rela = (-2*sqrt(GM)*ephtmp(16)*ephtmp(18)*sin(E))/c^2;
            clk = ephtmp(8)+ephtmp(9)*dTime+ephtmp(10)*dTime^2;
            clkSat = rela+clk;
            [xs,ys,zs] = rot_satpos(oData(i).TOE-tSent,xs,ys,zs,OMEGAe);

            deltaT = sqrt((xs-x0)^2+(ys-y0)^2+(zs-z0)^2)./c;
            if abs(deltaT-deltaT0)<1e-8
                break
            else
                deltaT0 = deltaT;
            end
        end
        time=ephtmp(5)*60*60 + ephtmp(6)*60 + ephtmp(7);
        psat{i,oData(i).satList(j,:)} = [xs, ys, zs];

    end
end
data.psat = psat;
end