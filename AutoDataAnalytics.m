function start()
    %Representing the first ID and the last
    %Setting workers to 2 because I have a 6 core laptop and like to
    %Multi-Task
    parfor (i=1:37,3)
            %This represents number of sessions
            for j=3:3
                if(i<10)
                    stringID = append('0',int2str(i),'_',int2str(j));
                elseif(i >= 10)
                    stringID = append(int2str(i),'_',int2str(j));
                end
                 try
                    fprintf(stringID + "\n");
                    preprocessingWithoutArtifactRejection(stringID, false);
                 catch
                     continue
                 end
            end
    end

%%eegPreprop('22_1');
%preprocessingWithoutArtifactRejection('15_3',false);
% %replaceEvents('02_1');

%Manually exporting the handpicked data to csv for .fif conversion

%     exportEpochtoCsv('09_1 Square','Aware');
%     exportEpochtoCsv('10_1 Square','Aware');
%     exportEpochtoCsv('18_1 Square','Aware');
%     exportEpochtoCsv('02_1 Square','Aware');
%     exportEpochtoCsv('03_1 Square','Aware');
%     exportEpochtoCsv('14_1 Square','Unaware');
%     exportEpochtoCsv('24_1 Square','Unaware');
%     exportEpochtoCsv('32_1 Square','Unaware');
%     exportEpochtoCsv('37_1 Square','Unaware');
%     
%     exportEpochtoCsv('09_1 Random','Aware');
%     exportEpochtoCsv('10_1 Random','Aware');
%     exportEpochtoCsv('18_1 Random','Aware');
%     exportEpochtoCsv('02_1 Random','Aware');
%     exportEpochtoCsv('03_1 Random','Aware');
%     exportEpochtoCsv('14_1 Random','Unaware');
%     exportEpochtoCsv('24_1 Random','Unaware');
%     exportEpochtoCsv('32_1 Random','Unaware');
%     exportEpochtoCsv('37_1 Random','Unaware');
    
end

function preprocessingWithoutArtifactRejection(datasetName,exportToCsv)
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
    postchannels_removed = {'E2','E3','E4','E5','E6','E7','E8','E9','E11','E12','E13','E14','E15','E16','E17','E19','E20','E21','E22','E23','E24','E26','E27','E28','E29','E30','E33','E34','E35','E36','E38','E39','E40','E41','E42','E43','E44','E45','E47','E48','E49','E50','E51','E52','E53','E55','E56','E57','E58','E59','E60','E64','E65','E66','E71','E72','E76','E77','E78','E79','E80','E81','E85','E87','E88','E89','E90','E98','E99','E100','E106','E107','E108','E110','E114','E115','E117','E118','E123','E124','E125','E127','E128','E129','E130','E131','E132','E136','E137','E138','E139','E141','E142','E143','E144','E148','E149','E151','E152','E153','E154','E155','E158','E159','E160','E163','E164','E168','E169','E171','E172','E173','E181','E182','E183','E184','E185','E186','E194','E195','E196','E197','E198','E204','E205','E206','E207','E212','E213','E214','E215','E221','E222','E223','E224'}
    lastData = 3;
    
    unaware = {'03','04','08','14','17','22','24','25','26','29','30','32','37'};
    awareTag = 'Aware';

     if(contains(append(datasetName(1),datasetName(2)), unaware ))
         awareTag = 'Unaware';
     end
    
    %Create unique Events by combining all event codes on the same latency
    %i.e 2,4,8 turns into 248
    replaceEvents(datasetName);
    
    %Start EEGLab
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
     
    %Load Files from replaceEvents
    EEG = pop_loadset('filename', append(datasetName, '.set'),'filepath',processedFilePath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

    %Add Channel Locations
    EEG=pop_chanedit(EEG, 'lookup',channelLocationPath);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    %Lowpass Filtering at 30hz
    EEG = eeg_checkset( EEG );
    EEG = pop_firma(EEG, 'forder', 2);
    EEG = pop_eegfiltnew(EEG, 'hicutoff',30,'plotfreqz',0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
    
    %Pre-processing
%     EEG = eeg_checkset( EEG );
%     EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-100 100] );
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
%      
%     EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:256] ,'computepower',1,'linefreqs',50,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',4,'winstep',1);
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
%     
    %Custom Epoch Extraction which Removes Baseline and References data
    %Epoch extraction is based on the events in the event table.
    [ALLEEG EEG CURRENTSET] = extractEpochs(EEG, ALLEEG, CURRENTSET, datasetName, '248', 2, 'Square',processedFilePath);
   
    [ALLEEG EEG CURRENTSET] = extractEpochs(EEG, ALLEEG, CURRENTSET, datasetName, '28', 3 , 'Random',processedFilePath);
    
    if(datasetName(4) == '3')
        [ALLEEG EEG CURRENTSET] = extractEpochs(EEG, ALLEEG, CURRENTSET, datasetName, '18', 4, 'Diamond', processedFilePath);
        
        if(exportToCsv)
            exportEpochtoCsv( append(datasetName,' ' , 'Diamond' ,'.set') ,awareTag);
        end
    end
    
    if(exportToCsv)
        exportEpochtoCsv( append(datasetName,' ' , 'Square' ,'.set') ,awareTag);
        exportEpochtoCsv( append(datasetName,' ' , 'Random' ,'.set') ,awareTag);
    end
    
    %pop_export(EEG, append(csvFilePath, datasetName,'.csv'),'transpose','on','separator',',','precision',1);
end

function [ALLEEG EEG CURRENTSET] = extractEpochs(EEG, ALLEEG, CURRENTSET, datasetName, eventCode, datasetNumber, type, processedFilePath)
    prechannels_removed = {'E1','E10','E18','E25','E31','E32','E37','E46','E54','E61','E62','E63','E67','E68','E69','E70','E73','E74','E75','E82','E83','E84','E91','E92','E93','E94','E95','E102','E103','E104','E105','E111','E112','E113','E120','E121','E122','E133','E134','E135','E145','E146','E147','E156','E157','E165','E166','E167','E174','E175','E176','E177','E178','E179','E180','E187','E188','E189','E190','E191','E192','E193','E199','E200','E201','E202','E203','E208','E209','E210','E211','E216','E217','E218','E219','E220','E225','E226','E227','E228','E229','E230','E231','E232','E233','E234','E235','E236','E237','E238','E239','E240','E241','E242','E243','E244','E245','E246','E247','E248','E249','E250','E251','E252','E253','E254','E255','E256'};
    postchannels_removed = {'E2','E3','E4','E5','E6','E7','E8','E9','E11','E12','E13','E14','E15','E16','E17','E19','E20','E21','E22','E23','E24','E26','E27','E28','E29','E30','E33','E34','E35','E36','E38','E39','E40','E41','E42','E43','E44','E45','E47','E48','E49','E50','E51','E52','E53','E55','E56','E57','E58','E59','E60','E64','E65','E66','E71','E72','E76','E77','E78','E79','E80','E81','E85','E87','E88','E89','E90','E98','E99','E100','E106','E107','E108','E110','E114','E115','E117','E118','E123','E124','E125','E127','E128','E129','E130','E131','E132','E136','E137','E138','E139','E141','E142','E143','E144','E148','E149','E151','E152','E153','E154','E155','E158','E159','E160','E163','E164','E168','E169','E171','E172','E173','E181','E182','E183','E184','E185','E186','E194','E195','E196','E197','E198','E204','E205','E206','E207','E212','E213','E214','E215','E221','E222','E223','E224'}
    
    EEG = eeg_checkset( EEG );
    EEG = pop_epoch( EEG, {  eventCode  }, [-0.1         0.6], 'newname', append(datasetName, ' ',type), 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
    
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-100 0] ,[]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, datasetNumber,'overwrite','on','gui','off');
    
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, []);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, datasetNumber,'overwrite','on','gui','off');
    
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG, 'nochannel',prechannels_removed);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, datasetNumber,'overwrite','on','gui','off');
    
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG, 'nochannel',postchannels_removed);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, datasetNumber,'savenew',append(processedFilePath, datasetName, ' ' , type ,'.set'),'overwrite','on','gui','off'); 
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, datasetNumber,'retrieve',1,'study',0); 
end

function replaceEvents(datasetName)
    %Path to raw unprocessed files
    rawFilePath = 'C:\\Users\\auzri\\Desktop\\UTS\\UTS\\Research\\Data\\Raw\\';
    %Path to output the processed EEG data to
    processedFilePath = 'C:\\Users\\auzri\\Desktop\\UTS\\UTS\\Research\\Data\\Processed\\';

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_fileio(append(rawFilePath, datasetName, '.raw'), 'dataformat','auto');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',datasetName,'gui','off'); 
    
    %For Square No Target
    for i = 1:length(EEG.event)-1
        
         if( i<=length(EEG.event) -3 )
            if(EEG.event(i).latency == EEG.event(i+1).latency && EEG.event(i+1).latency == EEG.event(i+2).latency && EEG.event(i+2).latency == EEG.event(i+3).latency)
                if (EEG.event(i).type == 1 && EEG.event(i+1).type == 2 && EEG.event(i+2).type == 4 && EEG.event(i+3).type == 8)
                    EEG.event(i).type = 1248;
                    EEG.event(i+1).type = 1248;
                    EEG.event(i+2).type = 1248;
                end
            end
         end
        
        if( i<=length(EEG.event) -2 )
             if(EEG.event(i).latency == EEG.event(i+1).latency && EEG.event(i+1).latency == EEG.event(i+2).latency)
                if (EEG.event(i).type == 1 && EEG.event(i+1).type == 2 && EEG.event(i+2).type == 8)
                    EEG.event(i).type = 128;
                    EEG.event(i+1).type = 128;
                    EEG.event(i+2).type = 128;
                end
             end
            
            if(EEG.event(i).latency == EEG.event(i+1).latency && EEG.event(i+1).latency == EEG.event(i+2).latency)
                if (EEG.event(i).type == 1 && EEG.event(i+1).type == 2 && EEG.event(i+2).type == 4)
                    EEG.event(i).type = 124;
                    EEG.event(i+1).type = 124;
                    EEG.event(i+2).type = 124;
               end
                
                if (EEG.event(i).type == 2 && EEG.event(i+1).type == 4 && EEG.event(i+2).type == 8)
                    EEG.event(i).type = 248;
                    EEG.event(i+1).type = 248;
                    EEG.event(i+2).type = 248;
               end
            end
        end
        
        if(i<=length(EEG.event) -1)
            if(EEG.event(i).latency == EEG.event(i+1).latency)
                
                if (EEG.event(i).type == 2 && EEG.event(i+1).type == 4)
                    EEG.event(i).type = 24;
                    EEG.event(i+1).type = 24;
                end
                
               if (EEG.event(i).type == 2 && EEG.event(i+1).type == 8)
                    EEG.event(i).type = 28;
                    EEG.event(i+1).type = 28;
               end
               
               if (EEG.event(i).type == 1 && EEG.event(i+1).type == 8)
                    EEG.event(i).type = 18;
                    EEG.event(i+1).type = 18;
               end
               
            end
        end     
    end
   [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
   [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',append(processedFilePath, datasetName ,'.set'),'overwrite','on','gui','off'); 
end

function exportEpochtoCsv(datasetName, awareTag)
    processedFilePath = 'C:\\Users\\auzri\\Desktop\\UTS\\UTS\\Research\\Data\\Processed\\';
    csvFilePath = 'C:\\Users\\auzri\\Desktop\\Repo\\ML\\EEG\\';
     
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
    EEG = pop_loadset('filename', append(datasetName, '.set'),'filepath',processedFilePath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    epochLength = length(EEG.epoch);
    
    for i=1:10:epochLength-10
        EEG = eeg_checkset( EEG );
        EEG = pop_selectevent( EEG, 'epoch',[i,i+10],'deleteevents','off','deleteepochs','on','invertepochs','off');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, i,'gui','off'); 
        pop_export(EEG, append(csvFilePath, datasetName,' epoch' , int2str(i) ,'_', awareTag, '.csv'),'transpose','on','separator',',','precision',1);
        
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, i+1,'retrieve',1,'study',0); 
    end
end