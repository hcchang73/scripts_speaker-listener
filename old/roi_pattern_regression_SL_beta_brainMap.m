clear all
close all
set_parameters;
timeUnit='tr' ;
froidir='mor';
load([expdir '/roi_mask/' froidir '/roi_id_region.mat'],'roi_table');
rnames=table2array(roi_table(:,3));
roi_ids=cell2mat(roi_table.id);
crop_start=10;
lags_tested={-10:10, -20:20, -30:30, -10:-4, -20:-4, -30:-4, -10:-1};

for ei=[1:4];;%
    exp=experiments{ei};
    
    for lagi=1%:length(lags_tested);
        lags=lags_tested{lagi};
        
        load([expdir '/' exp '/fmri/pattern_regression/' timeUnit '/roi/' froidir '/SLeach/regression_SLeach_lag' num2str(min(lags)) '-' num2str(max(lags)) '_classification' ],'rnames','acc','sig_fdr_withinSigSL','b_s','b_l','p','p_adj','foldN');
        sig_betaClass=sig_fdr_withinSigSL;
        
        bPeakLags=nan([length(rnames) 1]);
        for ri=1:length(rnames);
            rname=rnames{ri};
            
            % within roi showing signifcant difference in sl and ll beta
            % profiles.
            if sig_betaClass(ri)==1;
                
                b_s_temp=squeeze(b_s(ri,:,:))';
                b_l_temp=squeeze(b_l(ri,:,:))';
                
                % find the biggest peak within lag<=0
                   m_s=nanmean(b_s_temp);
                [pks,locs] = findpeaks(m_s);
                pks_sorted=sort(pks(ismember(locs,find(lags<=0))),'descend');
                bPeakLags(ri,1)=min(lags(locs(ismember(pks,pks_sorted(1:min(1,length(pks)))))));
           
            else
                bPeakLags(ri,1)=NaN;
            end
            
        end
    end
    save([expdir '/' exp '/fmri/pattern_regression/' timeUnit '/roi/' froidir '/SLeach/regression_SLeach_lag' num2str(min(lags)) '-' num2str(max(lags)) '_bPeakLags'  ],'rnames','bPeakLags');
    
    nii=roiTable2wholeBrainNii_mor([roi_ids(~isnan( bPeakLags)),  bPeakLags(~isnan( bPeakLags))]);
    save_nii(nii,[expdir '/' exp '/fmri/pattern_regression/' timeUnit '/roi/' froidir '/SLeach/regression_SL_lag' num2str(min(lags)) '-' num2str(max(lags))  '_bPeakLags.nii']);
end


