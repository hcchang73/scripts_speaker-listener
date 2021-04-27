%% ttest across subject
clear all
% loc='cluster';
set_parameters;
timeUnit='tr' ;
froidir='mor';
load([expdir '/roi_mask/' froidir '/roi_id_region.mat'],'roi_table');
rnames=table2array(roi_table(:,3));
roi_ids=cell2mat(roi_table.id);
lags_tested={-10:10,  -40:40};
seeds={'HG_L','vPCUN','pANG_L'};
permN=1000;

for ei=1:4;
    exp=experiments{ei};
    
    for lagi=1:length(lags_tested);
        lags=lags_tested{lagi};
        
        for sdi=1:length(seeds);
            seed=seeds{sdi};
            
            load([expdir '/' exp '/fmri/temporal/circularlagcorr/' timeUnit '/roi2rois/' froidir '/LL_gg/perm/' seed '_lag' num2str(min(lags)) '-' num2str(max(lags)) '_permPhase' ],'rnames','r','lags','keptT');
            rz_perm=atanh(r);
            
            load([expdir '/' exp '/fmri/temporal/circularlagcorr/' timeUnit '/roi2rois/' froidir '/LL_gg/' seed '_lag' num2str(min(lags)) '-' num2str(max(lags)) ],'rnames','r','lags','keptT');
            rz=atanh(r);

            p=min(mean(rz_perm>rz,3) , mean(rz_perm<rz,3));
            p(isnan(rz))=NaN;
            pfwe=p*(sum(~isnan(p(:))));
            
            pfdr=nan(size(p(:)));
            [ ~,~,pfdr(~isnan(p(:)))]=fdr(p(~isnan(p(:))));
            pfdr=reshape(pfdr,size(p));
            
            ris=find(sum(~isnan(rz),2)~=0);
            peak=nan([length(rnames) 1 ]);
            peakLags=peak;
            peaks_pfwe=nan([length(rnames) 1 ]);
            peakLags_pfwe=peaks_pfwe;
            peaks_pfdr=nan([length(rnames) 1 ]);
            peakLags_pfdr=peaks_pfdr;
            
            rz_tempfwe=rz;
            rz_tempfwe(pfwe>.025)=NaN;
            rz_tempfdr=rz;
            rz_tempfdr(pfdr>.05)=NaN;
            for i=1:length(ris);
                ri=ris(i);
                [~, peakLagi]=max(abs(rz(ri,:)),[],2);
                peakLags(ri,1)=(lags(peakLagi));
                peak(ri,1)=rz(ri,peakLagi);
                
                if min(pfdr(ri,:))<.025;
                    [~, peakLagi]=max(abs(rz_tempfdr(ri,:)),[],2);
                    peakLags_pfdr(ri,1)=(lags(peakLagi));
                    peaks_pfdr(ri,1)=rz_tempfdr(ri,peakLagi);
                end
                
                if min(pfwe(ri,:))<.025;
                    [~, peakLagi]=max(abs(rz_tempfwe(ri,:)),[],2);
                    peakLags_pfwe(ri,1)=(lags(peakLagi));
                    peaks_pfwe(ri,1)=rz_tempfwe(ri,peakLagi);
                end
            end
            
            nii=roiTable2wholeBrainNii_mor([roi_ids(~isnan( peakLags_pfwe) & peaks_pfwe>0),   peakLags_pfwe(~isnan( peaks_pfwe) & peaks_pfwe>0)+0.00000001]);
            nii.img(1,1,1)=1;
            save_nii(nii,[expdir '/' exp '/fmri/temporal/circularlagcorr/' timeUnit '/roi2rois/'  froidir '/LL_gg/' seed '_lag' num2str(min(lags)) '-' num2str(max(lags))  '_posPeakLags_pfwe.nii']);
            
            nii=roiTable2wholeBrainNii_mor([roi_ids(~isnan( peakLags_pfdr) & peaks_pfdr>0),   peakLags_pfdr(~isnan( peaks_pfdr) & peaks_pfdr>0)+0.00000001]);
            nii.img(1,1,1)=1;
            save_nii(nii,[expdir '/' exp '/fmri/temporal/circularlagcorr/' timeUnit '/roi2rois/'  froidir '/LL_gg/' seed '_lag' num2str(min(lags)) '-' num2str(max(lags))  '_posPeakLags_pfdr.nii']);
            
            save([expdir '/' exp '/fmri/temporal/circularlagcorr/' timeUnit '/roi2rois/' froidir '/LL_gg/' seed '_lag' num2str(min(lags)) '-' num2str(max(lags)) '_peaks' ],...
                'rnames','rz','r','rz','lags','keptT','p','pfwe','peaks_pfwe','peakLags_pfwe','pfdr','peaks_pfdr','peakLags_pfdr');
        end
    end
end

