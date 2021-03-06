function roi_tr_pattern_regression_SL_permSubj(perm)

loc='cluster';
set_parameters;
timeUnit='tr' ;
froidir='mor';
load([expdir '/roi_mask/' froidir '/roi_id_region.mat'],'roi_table');
rnames=table2array(roi_table(:,3));
crop_start=10;
lags_tested={-10:10, -20:20, -30:30, -10:-4, -20:-4, -30:-4, -10:-1};

for ei=1:2;
    exp=experiments{ei};
    
    for lagi=1:length(lags_tested);
        lags=lags_tested{lagi};
        
        load([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/zscore_speaker_' rnames{1} '.mat' ],'data')
        tn=size(data,2);
        
        b=nan([length(rnames) length(lags)+1 ]);
        r2=nan([length(rnames) 1 ]);
        F=nan([length(rnames) 1]);
        p=nan([length(rnames) 1]);
        r2_byTime=nan([length(rnames),tn]);
        
        for ri=1:size(rnames);
            rname=rnames{ri};
            
            if exist([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/zscore_listenerAll_' rname '.mat' ]);
                load([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/zscore_listenerAll_' rname '.mat' ],'gdata');
                load([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/zscore_speaker_' rname '.mat'],'data');
                
                roi_voxn=size(gdata,1);
                
                keptT_s=find(([1:tn]+min(lags))==1)+crop_start;
                keptT_e=min(tn,tn-max(lags));
                keptT=keptT_s:keptT_e;
                
                data_perm=gdata(:,:,perm);
                gdata_perm=gdata;
                gdata_perm(:,:,perm)=data;
                
                g=nanmean(gdata_perm,3);
                y=g;
                y=y(:,keptT);
                y=y(:);
                
                for li=1:length(lags);
                    X(:,:,li)=data_perm(:,keptT+lags(li));
                end
                
                X=reshape(X,roi_voxn*length(keptT),length(lags));
                
                % centralize X
                X=X-mean(X);
                
                [b(ri,:),~,r,~,stats]=regress(y,[ones(size(X,1),1) X]);
                
                r2(ri,1)=stats(1);
                F(ri,1)=stats(2);
                p(ri,1)=stats(3);
                
                ymat=reshape(y,roi_voxn,length(keptT));
                rmat=reshape(r,roi_voxn,length(keptT));
                ssr=sum(rmat.^2);
                sst=sum((ymat-mean(y)).^2);
                r2_byTime(ri,:)=nan(tn,1);
                r2_byTime(ri,keptT)=1-ssr./sst;
                
                clear X
                disp(ri)
                
            end
        end
        
        save(sprintf('%s/%s/fmri/pattern_regression/%s/roi/%s/SLg/perm/regression_SL_lag%d-%d_permSL%03d',expdir,exp,timeUnit,froidir,min(lags),max(lags),perm),'b','F','r2','r2_byTime','p','lags','rnames','keptT');
        clear b F p r2 r2_byTime
    end
end
toc
