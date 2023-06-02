function [data] = cs_detect_mw(data,N)

[arc]  = arc_dtr(data.obs);

sn = size(data.obs.st,2);

c  = 299792458; % m/s
[freq,~] = frequencies;
cs=cell(1,155);
G=[];
for k=1:sn
    b=[];
    f1 = freq(k,1); f2 = freq(k,2);
    lamwl = c/(f1-f2);
    lwl = (data.obs.l1(:,k).*f1 - data.obs.l2(:,k).*f2)./(f1-f2);
    pnl = (data.obs.p1(:,k).*f1 + data.obs.p2(:,k).*f2)./(f1+f2);
    nwl = (lwl - pnl)./(lamwl);
    gfl = data.obs.l1(:,k) - data.obs.l2(:,k); %meter
    ark = arc{k};
    for t=1:size(ark,1)
        st = ark(t,1);
        fn = ark(t,2);

        for i=(ark(t,1)+1):ark(t,2)
            dmwc = 0;
            if (i-2<st)
                mmw = mean(nwl(st:i-1,1));
                smw =  std(nwl(st:i,1));
            elseif (i-N<st)
                mmw = mean(nwl(st:i-1,1));
                smw =  std(nwl(st:i-1,1));
            else
                mmw = mean(nwl(i-N:i-1,1));
                smw =  std(nwl(i-N:i-1,1));
            end
            dmw = mmw - nwl(i,1);
            if abs(dmw)>(5*smw)
                dmwc = 1;
                b=[b;st, i];
                st=i;
            end
            if i == fn
                b=[b;st, i];
            end
            %             if (dmwc==1 && std(nwl(st:fn,1))>0.6)
            %                 one  = nwl(i-1,1) - nwl(i,1);
            %                 two  = gfl(i-1,1) - gfl(i,1);
            %                 A = [1 -1;wavl(k,1) -wavl(k,1)];
            %                 L = [one;two];
            %                 Dn = pinv(A)*L;
            %                 Dn1 = round(Dn(1));
            %                 Dn2 = round(Dn(2));
            %                 if (Dn1~=0) && (Dn2~=0)
            %                    G=[G; k, i];
            %                     data.obs.l1(i:fn,k) = data.obs.l1(i:fn,k) + Dn1.*wavl(k,1);
            %                     data.obs.l2(i:fn,k) = data.obs.l2(i:fn,k) + Dn2.*wavl(k,2);
            %                 end
            %                 st = i;
            %             end
        end
    end
    data.cs{k}=b;
end




for k=1:size(data.cs,2)
    cs=[data.cs{k}];
    CS=[];
    if ~isempty(cs)
        for i1=1:size(cs,1)
            if cs(i1,2) - cs(i1,1)>100
              CS=[CS;cs(i1,:)];
            end
        end
        data.cs{k}=CS;
    end
end

% for i= 1:size(b,1)
%     xmin=b(i,1);
%     ymin=gfl(b(i,1))-1;
%     w= b(i,2)-b(i,1);
%     h=2;
%     rectangle('position',[xmin ymin w h])
% end
