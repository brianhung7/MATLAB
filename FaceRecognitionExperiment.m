clear; close all;
%Script creates images that are randomly inverted then tests if the user
%recognizes the image and records their response.
AssertOpenGL; % check for some basic Psychtoolbox functionality; good to do early on in code
KbName('UnifyKeyNames'); % have same name for keyboard buttons across operating systems

%Loading in images
myDir = 'faces/*.jpg';
myDir2 = 'faces/';
images = dir(myDir);
image_num_list = [1:20];

%Making new variables for each image
for index=1:numel(images)
    eval(['image_' num2str(index)  '= imread([myDir2, images(index).name]);']);
    image_set{index} = eval(['image_' num2str(index);]);
end;

%Randomly select 10 images for learning set
for i = 1:10
    %Choose an image number first
    image_num = image_num_list(1+floor(rand*length(image_num_list)));
    %After choosing a number, remove it so it doesn't select it again
    image_num_list(image_num_list==image_num) = [];
    %Store into learning set
    learning_set{i,1} = eval(['image_' num2str(image_num);]);
    if i<=5
        learning_set{i,2} = 0;
    else
        learning_set{i,2} = 180;
    end
end

%Shuffling/randomizing learning set and entire image set
rand_order_learning = randperm(length(learning_set));
learning_set = learning_set(rand_order_learning,:);
rand_order_images = randperm(length(image_set));
image_set = image_set(rand_order_images);

data.key_pressed = cell(length(image_set),1);
data.response_time = zeros(length(image_set));

try
    %Parameters
    white = [255 255 255];
    black = [0 0 0];
    orientation = {'upright', 'inverted'};
    num_orientations = length(orientation);
    
    % open a window
    scrnNum = max(Screen('Screens'));
    [win, rect] = Screen('OpenWindow',scrnNum,white);
    Screen('Flip',win);
    % get properties of the screen window
    [cx, cy] = RectCenter(rect);
    [width, height] = RectSize(rect);
    HideCursor;
    
    % Learning test
    for i = 1:length(learning_set)
        learning_image = Screen('MakeTexture',win,learning_set{i});
        Screen('DrawTexture',win,learning_image,[],[cx-100 cy-100 cx+100 cy+100],learning_set{i,2});
        Screen('Flip',win);
        KbWait;
        KbReleaseWait;
    end
    
    %% DISTRACTOR TASK
    % tell participant that studying is over
    Screen('DrawText',win,'The learning set is over. Now do math.',50,50,black);
    Screen('DrawText',win,'Press any key to begin',50,100,black);
    Screen('Flip',win);
    KbWait;
    KbReleaseWait;
    
    % solve a math problem before continuing
    n1 = randi(9);
    n2 = randi(9);
    mathProb = [num2str(n1) ' + ' num2str(n2) ' = '];
    correctAnswer = n1 + n2;
    badAnswer = true;
    while badAnswer
        answer = GetEchoNumber(win,mathProb,cx-50,cy,black);
        Screen('Flip',win);
        
        if answer == correctAnswer
            badAnswer = false;
        else
            DrawFormattedText(win,'WRONG DUMMY! try again','center','center',black);
            Screen('Flip',win);
            WaitSecs(1);
        end
    end % checking for correct answer
    
    % tell participant that distractor is over
    Screen('DrawText',win,'The math is over. Now remember stuff.',50,50,black);
    Screen('DrawText',win,'Press y/n if you remember an image or not',50,100,black);
    Screen('DrawText',win,'Press any key to begin',50,150,black);
    Screen('Flip',win);
    KbWait;
    KbReleaseWait;
    
    %%Recognition Task, image matrix already randomized earlier.
    for i = 1:length(image_set)
        recog_image = Screen('MakeTexture',win,image_set{i});
        Screen('DrawTexture',win,recog_image,[],[cx-100 cy-100 cx+100 cy+100],0);
        Screen('Flip',win);
        
        %Timer for response time
        start_time = GetSecs;
        
        %Making sure a valid key is pressed: y/n
        no_good_key = 1;
        while no_good_key
            [secs,keyCode,deltaSecs] = KbWait;
            this_key = KbName(keyCode);
            KbReleaseWait;
            
            if any(strcmpi(this_key,'y'))
                no_good_key = 0;
            end
            
            if any(strcmpi(this_key,'n'))
                no_good_key = 0;
            end
        end
        %Store key press and response time
        res.key_pressed{i} = this_key;
        res.response_time{i} = secs - start_time;
    end
    
    %% CLEANUP
    % close the window
    ShowCursor;
    Screen('Close',win);
catch
    % if there's an error, close the window
    % and show error
    ShowCursor;
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end
