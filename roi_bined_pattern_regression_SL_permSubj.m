function roi_tr_bined_pattern_regression_SL_permSubj(perm)

loc='cluster';
set_parameters;
timeUnit='tr' ;
froidir='mor';
binSize_tested=[10 15 30]; % tr;
lags_tested={-3:3,0,-10:10 -10:-4, -20:-4, -30:-4, -10:-1};

load([expdir '/roi_mask/' froidir '/roi_id_region.mat'],'roi_table');
rnames=table2array(roi_table(:,3));

for ei= 1:4;
    exp=experiments{ei};
    
    load([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/zscore_listenerAll_' rnames{1} '.mat' ],'gdata');
    [~,tn,listenerN]=size(gdata);
    
    if perm<=listenerN;
        
        for binSizei=1%:length(binSize_tested);
            binSize=binSize_tested(binSizei);
            
            for lagi=1;%1:length(lags_tested);
                lags=lags_tested{lagi};
                
                b=nan([length(rnames),tn,length(lags)+1]);
                r2=nan([length(rnames) tn]);
                F=nan([length(rnames) tn]);
                p=nan([length(rnames) tn]);
                
                for ri=1:length(rnames);
                    rname=rnames{ri};
                    
                    if exist([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/zscore_listenerAll_' rname '.mat' ]);
                        load([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/zscore_listenerAll_' rname '.mat' ],'gdata');
                        load([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/zscore_speaker_' rname '.mat'],'data');
                        
                        roi_voxn=size(gdata,1);
                        
                        data_perm=gdata(:,:,perm);
                        gdata_perm=gdata;
                        gdata_perm(:,:,perm)=data;
                        
                        g=nanmean(gdata_perm(:,:,:),3);
                        
                        for t=1:tn;
                            t_bin=t:(t+binSize-1);
                            
                            if min(t_bin)+min(lags)>=1 & t_bin+max(lags)<=tn & max(t_bin)<=tn;
                                % substract the global mean pattern
                                y=g(:,t_bin);
                                y=y(:);
                                
                                
                                for li=1:length(lags);
                                    X(:,:,li)=data_perm(:,t_bin+lags(li));
                                end
                                
                                X=reshape(X,roi_voxn*length(t_bin),length(lags));
                                
                                % centralized X
                                X=X-mean(X);
                                
                                % add an constant
                                
                                [b(ri,t,:),~,~,~,stats]=regress(y,[ones(size(X,1),1) X]);
                                
                                r2(ri,t)=stats(1);
                                F(ri,t)=stats(2);
                                p(ri,t)=stats(3);
                                
                                clear X
                            end
                        end
                    end
                end
                save([expdir '/' exp '/fmri/pattern_regression_bined/' timeUnit '/roi/' froidir '/SLg/perm/regression_SL_binSize' num2str(binSize) '_lag' num2str(min(lags)) '-' num2str(max(lags)) '_permSL' num2str(perm)],'b','F','r2','p','lags','rnames','binSize');

                clear b F p r2 coupling r
            end
        end
    end
end
