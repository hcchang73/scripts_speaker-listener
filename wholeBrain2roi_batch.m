clear all;

loc='cluster';
set_parameters;
timeUnit='tr' ;

froidir='mor';
rnames=dir([expdir '/roi_mask/'  froidir '/mat/*.mat']);
rnames=strrep({rnames.name},'.mat','');

tic % 15 min


for ei=1:2;%1:4;
    exp=experiments{ei};
    
    f= sprintf('%s/%s/fmri/timeseries/%s/wholeBrain/zscore_listenerAll.mat',expdir,exp,timeUnit);
    load(f,'gdata','keptvox');
    gdata_listener=gdata;
    
    clear gdata
    f= sprintf('%s/%s/fmri/timeseries/%s/wholeBrain/zscore_speaker.mat',expdir,exp,timeUnit);
    load(f,'data','keptvox');
    data_speaker=data;
    
    clear data
    
    for ri=1:length(rnames);
        rname=rnames{ri};
        fr = sprintf('%s/roi_mask/%s/mat/%s',expdir,froidir,rname);
        load(fr,'roimask');
        
        if sum(roimask(keptvox))>10;
            gdata(:,:,:)=gdata_listener(logical(roimask(keptvox)),:,:);
            if ~isempty(gdata);
                save([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/zscore_listenerAll_' rname ],'gdata');
            end
            
            clear gdata
            data(:,:,:)=data_speaker(logical(roimask(keptvox)),:,:);
            if ~isempty(data);
                save([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/zscore_speaker_' rname ],'data');
            end
            
            clear data
        end
    end
end

for ei=1:2;%1:4;
    exp=experiments{ei};
    
    f= sprintf('%s/%s/fmri/timeseries/%s/wholeBrain/listenerAll.mat',expdir,exp,timeUnit);
    load(f,'gdata','keptvox');
    gdata_listener=gdata;
    
    clear gdata
    f= sprintf('%s/%s/fmri/timeseries/%s/wholeBrain/speaker.mat',expdir,exp,timeUnit);
    load(f,'data','keptvox');
    data_speaker=data;
    
    clear data
    
    for ri=1:length(rnames);
        rname=rnames{ri};
        fr = sprintf('%s/roi_mask/%s/mat/%s',expdir,froidir,rname);
        load(fr,'roimask');
        
        if sum(roimask(keptvox))>10;
            gdata(:,:,:)=gdata_listener(logical(roimask(keptvox)),:,:);
            if ~isempty(gdata);
                save([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/listenerAll_' rname ],'gdata');
            end
            
            clear gdata
            data(:,:,:)=data_speaker(logical(roimask(keptvox)),:,:);
            if ~isempty(data);
                save([expdir '/' exp '/fmri/timeseries/' timeUnit '/roi/' froidir '/speaker_' rname ],'data');
            end
            
            clear data
        end
    end
end
toc
beep;