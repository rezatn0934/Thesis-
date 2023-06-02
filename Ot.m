function LL = Ot(data,angEL,angAZ,PD,hmax,prec)
F=[];
LL={};
for i2 = 1:length(data.snrmat.info.observedsats)
    satprn = data.snrmat.info.observedsats{i2};
    for i3 = 1:length(data.snrmat.info.typesofsnr)
        dSNRdata = create_dSNRdata(data.snrmat,data.snrmat.info.observedsats(i2), data.snrmat.info.typesofsnr(i3), angEL,angAZ,PD);
        if  ~isempty(dSNRdata)
            if ~isnan(find_WL(find_sat_index(data.snrmat.info.observedsats{i2}),data.snrmat.info.typesofsnr{i3}))
                wL = find_WL(find_sat_index(data.snrmat.info.observedsats{i2}),data.snrmat.info.typesofsnr{i3});
                for i4 = 1:size(dSNRdata,2)
                    if size(dSNRdata{1,i4},1) > 1
                        p1=[];
                        F1=[];
                        sat_index =find_sat_index(data.snrmat.info.observedsats{i2});
                        CS= [data.cs{sat_index}];
                        for i5=1:size(CS,1)
                            st=CS(i5,1);
                            en = CS(i5,2);
                            [P1,f1,pha1] = lombGIRAS(dSNRdata{1,i4}(st:en,6),dSNRdata{1,i4}(st:en,2),wL,hmax,prec);
                            if length(f1(P1==max(P1))) == 1; f_dom1 = f1(P1==max(P1)); else; f_dom1 = NaN; end            % Dominant frequency
                            if length(max(P1)) == 1; amp_dom1 = max(P1); else; amp_dom1 = NaN; end                    % Dominant amplitude
                            if length(pha1(P1==max(P1))) == 1; pha_dom1 = pha1(P1==max(P1)); else; pha_dom1 = NaN; end    % Dominant phase
                            F1=[F1;f_dom1];
                            p1=[p1;max(P1)];
                        end
                        %                     [maxRH, maxRHAmp,ij,pknoise] = lombGIRAS1(dSNRdata{1,i4}(i5,6),dSNRdata{1,i4}(i5,2),wL,hmax,prec);
                        [P,f,pha] = lombGIRAS(dSNRdata{1,i4}(:,6),dSNRdata{1,i4}(:,2),wL,hmax,prec);
                        if length(f(P==max(P))) == 1; f_dom = f(P==max(P)); else; f_dom = NaN; end            % Dominant frequency
                        if length(max(P)) == 1; amp_dom = max(P); else; amp_dom = NaN; end                    % Dominant amplitude
                        if length(pha(P==max(P))) == 1; pha_dom = pha(P==max(P)); else; pha_dom = NaN; end    % Dominant phase
                        LL=[LL;data.snrmat.info.DoY(1),data.snrmat.info.observedsats{i2},data.snrmat.info.typesofsnr{i3},i4,dSNRdata{2,i4},...
                            f_dom,F1,amp_dom,pha_dom,min(dSNRdata{1,i4}(:,1)),max(dSNRdata{1,i4}(:,1)),size(dSNRdata{1,i4},1),min(dSNRdata{1,i4}(:,2)),max(dSNRdata{1,i4}(:,2)),...
                            min(dSNRdata{1,i4}(:,3)),max(dSNRdata{1,i4}(:,3)),wL,max(P),p1,sum(P(~isnan(P)))/(length(P(~isnan(P))-1))];
                        %                     F =[F;maxRH, maxRHAmp,ij,pknoise ];
                    end
                end
            end
        end
    end
end

