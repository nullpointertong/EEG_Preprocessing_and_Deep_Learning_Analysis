function start()
% %     parpool(3);
%     %1 Representing the first ID and the last
%     for i=1:37
%         %This represents number of sessions
%         for j=1:3
%             if(i<10)
%                 stringID = append('0',int2str(i),'_',int2str(j));
%             elseif(i >= 10)
%                 stringID = append(int2str(i),'_',int2str(j));
%             end
%              try
%                 fprintf(stringID + "\n");
%                 eegPreprop(stringID);
%                 %genStudy(stringID);
%              catch
%                  continue
%              end
%         end
%     end
eegPreprop('22_1');
end

function eegPreprop(dataSetName)
    %Path to raw unprocessed files
    rawFilePath = 'C:\\Users\\auzri\\Desktop\\UTS\\UTS\\Research\\Data\\Raw\\';
    %Path to Channel Location Files
    channelLocationPath = 'C:\\Users\\auzri\\Desktop\\UTS\\UTS\\Research\\Data\\Channel Location\\AdultAverageNet256_v1.sfp';
    %Path to output the processed EEG data to
    processedFilePath = 'C:\\Users\\auzri\\Desktop\\UTS\\UTS\\Research\\Data\\Processed\\';
    %Path of output the eeg data as a CSV so that it can be processed into
    %a model
    csvFilePath = 'C:\\Users\\auzri\\Desktop\\Repo\\ML\\EEG\\';
    
    %Outer, Ear and Cheek electrodes that get removed 
    prechannels_removed = {'E1','E10','E18','E25','E31','E32','E37','E46','E54','E61','E62','E63','E67','E68','E69','E70','E73','E74','E75','E82','E83','E84','E91','E92','E93','E94','E95','E102','E103','E104','E105','E111','E112','E113','E120','E121','E122','E133','E134','E135','E145','E146','E147','E156','E157','E165','E166','E167','E174','E175','E176','E177','E178','E179','E180','E187','E188','E189','E190','E191','E192','E193','E199','E200','E201','E202','E203','E208','E209','E210','E211','E216','E217','E218','E219','E220','E225','E226','E227','E228','E229','E230','E231','E232','E233','E234','E235','E236','E237','E238','E239','E240','E241','E242','E243','E244','E245','E246','E247','E248','E249','E250','E251','E252','E253','E254','E255','E256'};
    postchannels_removed = {'E2','E3','E4','E5','E6','E7','E8','E9','E11','E12','E13','E14','E15','E16','E17','E19','E20','E21','E22','E23','E24','E26','E27','E28','E29','E30','E33','E34','E35','E36','E38','E39','E40','E41','E42','E43','E44','E45','E47','E48','E49','E50','E51','E52','E53','E55','E56','E57','E58','E59','E60','E64','E65','E66','E71','E72','E76','E77','E78','E79','E80','E81','E85','E87','E88','E89','E90','E98','E99','E100','E101','E106','E107','E108','E110','E114','E115','E117','E118','E123','E124','E125','E127','E128','E129','E130','E131','E132','E136','E137','E138','E139','E141','E142','E143','E144','E148','E149','E151','E152','E153','E154','E155','E158','E159','E160','E163','E164','E168','E169','E171','E172','E173','E181','E182','E183','E184','E185','E186','E194','E195','E196','E197','E198','E204','E205','E206','E207','E212','E213','E214','E215','E221','E222','E223','E224'}
    
    unaware = {'03','04','08','14','17','22','24','25','26','29','30','32','37'};
    awareTag = 'Aware';
    lastData = 3;
    
     if(contains(append(dataSetName(1),dataSetName(2)), unaware ))
         awareTag = 'Unaware';
     end
    
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
    EEG = pop_fileio(append(rawFilePath, dataSetName, '.raw'), 'dataformat','auto');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',dataSetName,'gui','off'); 
    EEG=pop_chanedit(EEG, 'lookup',channelLocationPath);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
%      EEG = eeg_checkset( EEG );
%      EEG = pop_rmbase( EEG, [],[]);
%      [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
    
 
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.5305164,'plotfreqz',0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
    
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'hicutoff',30,'plotfreqz',0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
    
    EEG = eeg_checkset( EEG );
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-100 100] );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
     
    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:256] ,'computepower',1,'linefreqs',60,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',4,'winstep',1);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
    
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG, 'nochannel',prechannels_removed); 
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
    
    EEG = eeg_checkset( EEG );
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-100 100] );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
    
    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:156] ,'computepower',1,'linefreqs',60,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',4,'winstep',1);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
    
    %EEG = eeg_checkset( EEG );
    %EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
    %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',append('C:\\Users\\auzri\\Desktop\\UTS\\UTS\\Research\\Data\\Processed\\', dataSetName,'.set'),'overwrite','on','gui','off'); 
    %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off')
    
    EEG = eeg_checkset( EEG );
    EEG = pop_epoch( EEG, {  '2'  '4'  '8'  }, [-0.1         0.6], 'newname', append(dataSetName, ' Square'), 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
    
    [EEG, comrej]    = pop_eegmaxmin(EEG,[1:148],[-100  596],100,696,50,0);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG, 'nochannel',postchannels_removed);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'overwrite','on','gui','off');
    
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-100 0] ,[]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'overwrite','on','gui','off');
    
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, []);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'savenew',append(processedFilePath, dataSetName ,' Square.set'),'overwrite','on','gui','off'); 
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'retrieve',1,'study',0); 
    
    EEG = eeg_checkset( EEG );
    EEG = pop_epoch( EEG, {  '2'  '8'  }, [-0.1         0.6], 'newname', append(dataSetName, ' Random'), 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
    
    [EEG, comrej]    = pop_eegmaxmin(EEG,[1:148],[-100  596],100,696,50,0);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG, 'nochannel',postchannels_removed);    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'overwrite','on','gui','off'); 
    
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-100 0] ,[]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'overwrite','on','gui','off');
    
     EEG = eeg_checkset( EEG );
     EEG = pop_reref( EEG, []);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'savenew',append(processedFilePath,dataSetName,' Random.set'),'overwrite','on','gui','off'); 
     
    if(dataSetName(4) == '3')
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'retrieve',1,'study',0); 
        EEG = eeg_checkset( EEG );
        EEG = pop_epoch( EEG, {  '1'  '8'  }, [-0.1         0.6], 'newname', append(dataSetName, ' Diamond'), 'epochinfo', 'yes');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
        
        EEG = eeg_checkset( EEG );
        EEG = pop_rmbase( EEG, [-100 0] ,[]);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'overwrite','on','gui','off'); 
        
        %Remove all channels not in the 10-10 GSN document.
        EEG = eeg_checkset( EEG );
        EEG = pop_select( EEG, 'nochannel',unidentified_channels);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'savenew',append(processedFilePath, dataSetName,' Diamond.set'),'overwrite','on','gui','off'); 
        lastData = 4;
    end
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, lastData,'retrieve',1,'study',0); 
    
    EEG = eeg_checkset( EEG );
    EEG = pop_epoch( EEG, {  }, [-0.1         0.6], 'newname', dataSetName, 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
    
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, []);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
  
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-100 0],[]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
    
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG, 'nochannel',postchannels_removed);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',append(processedFilePath, dataSetName,'.set'),'overwrite','on','gui','off'); 
    
    pop_export(EEG, append(csvFilePath, dataSetName, '_', awareTag, '.csv'),'transpose','on','separator',',','precision',1);
end

% function helperFunction(EEG, ALLEEG EEG CURRENTSET, events, postchannels_removed, prechannels_removed, dataSetName, dataSetNumber)
%     EEG = pop_epoch( EEG, events, [-0.1         0.6], 'newname', append(dataSetName, ' Square'), 'epochinfo', 'yes');
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
%     
%     EEG = eeg_checkset( EEG );
%     EEG = pop_select( EEG, 'nochannel',prechannels_removed);
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'overwrite','on','gui','off');
%     
%     EEG = eeg_checkset( EEG );
%     EEG = pop_reref( EEG, []);
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'overwrite','on','gui','off');
%     
%     EEG = eeg_checkset( EEG );
%     EEG = pop_rmbase( EEG, [-100 0] ,[]);
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'overwrite','on','gui','off');
%     
%      EEG = eeg_checkset( EEG );
%      EEG = pop_select( EEG, 'nochannel',postchannels_removed);
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'savenew',append('C:\\Users\\auzri\\Desktop\\UTS\\UTS\\Research\\Data\\Processed\\', dataSetName ,' Square.set'),'overwrite','on','gui','off'); 
%     
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'retrieve',1,'study',0); 
% end
