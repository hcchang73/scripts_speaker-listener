%�@���ۡH
clear all;
tic
% loc='cluster';
set_parameters;
timeUnit='tr' ;

froidir='mor';
rnames=dir([expdir '/roi_mask/'  froidir '/mat/*.mat']);
rnames=strrep({rnames.name},'.mat','');

binSize=20;% tr;
binStep=1;

type='euclidean';
col_speaker='r'; %'r'

for ei=3%1:2;
    exp=experiments{ei};
    
    ris=find(ismember(rnames,{'dPCC'}));
    % [~,ri]=max(herdm);
    
    for rii=1:length(ris);
        ri=ris(rii);
        rname=rnames{ri};
        
        load([expdir '/' exp '/fmri/' rname '_tr_pattern_binSize' num2str(binSize) '_cmds_' type '_' col_speaker '.mat'],'speaker_cord','listener_cord','binN','binSize','binStep','rname');
        
        lmax=max(squeeze(max([listener_cord  ]))');
        lmin=min(squeeze(min([listener_cord  ]))');
        clear F
        fn=1;
        
        for ti=1:1:binN;
            
            fsize=[10 10];
            f=figure('unit','centimeter','position',[0 0 fsize],'paperposition',[0 0 fsize],'papersize',fsize);
            
            % choose the dimension
            scatter(listener_cord(ti,3,:),listener_cord(ti,4,:),40,'k','filled');
            hold on
            scatter(speaker_cord(ti,1),speaker_cord(ti,2),40,col_speaker,'filled');
            hold off
            
            xlim([lmin(1) lmax(1)]);
            ylim([lmin(2) lmax(2)]);
            axis off
            
            F(fn) = getframe(f);
            fn=fn+1
            
            close gcf
        end
        beep

        myVideo = VideoWriter([expdir '/' exp '/fmri/' rname '_tr_pattern_binSize' num2str(binSize) '_cmds_' type '_' col_speaker '.avi']);
        myVideo.FrameRate = binSize/2;  % Default 30
        open(myVideo);
        writeVideo(myVideo,F);
        close(myVideo)
        
        clear data data2 labels labels3
        %  close all
    end
end

