clear all;
%Defining color codes
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];
yellow = [255 255 0];
orange = [255 102 0];
white = [255 255 255];
gray = round(white./2);
tasks = {'congruent','incongruent'};
colors = {'red','green','blue','yellow','orange','white'};
nTasks = length(tasks);
nColors = length(colors);
conditions = fullfact([nColors, nTasks]);
cond_names = [colors(conditions(:,1))' tasks(conditions(:,2))'];
KbName('UnifyKeyNames');

%Randomizing
rand_order = randperm(size(cond_names,1));
new_conditions = conditions(rand_order,:);
new_cond_names = cond_names(rand_order,:);

%User_index used for keeping location for user_data matrix
user_index = 1;
times_to_loop = 5; %How many times to repeat full trial

try
    scrnNum = max(Screen('Screens'));
    [win, rect] = Screen('OpenWindow',scrnNum, gray);
    Screen('TextSize', win, 24);
    
    %Loops through 5 times
    for j = 1:times_to_loop
        for i = 1:length(conditions)
            %Wrong_index used for displaying incongruent trial
            wrong_index = new_conditions(i,1);
            if wrong_index == 6
                wrong_index = 1;
            else
                wrong_index = wrong_index + 1;
            end
            
            %Get color to display
            this_color = new_cond_names{i,1};
            congruency = new_cond_names{i,2};
            word_color = eval(this_color);
            %Wrong color takes color from wrong index
            wrong_color = colors{wrong_index};
            wrong_word_color = eval(wrong_color);
            
            %Word to display
            this_word = upper(this_color);
            
            %Setting colors, if congruent, assign proper color. If not, assign
            %from shifted matrix
            if strcmp(congruency,'congruent')
                DrawFormattedText(win, this_word,'center','center',word_color);
                answer = 'c';
            elseif strcmp(congruency,'incongruent')
                DrawFormattedText(win, this_word,'center','center',wrong_word_color);
                answer = 'i';
            end
            
            Screen('Flip',win);
            %start timer
            start_time = GetSecs;
            
            %obtaining user input
            response = GetChar(win);
            if strcmp(response,answer)
                correctness = 'correct';
            else
                correctness = 'incorrect';
            end
            
            %Obtaining response time
            [secs] =  KbWait;
            response_time = secs - start_time;
            %Storing data
            user_data(user_index,:) = {response correctness response_time};
            KbReleaseWait;
            
            user_index = user_index +1;
        end
    end
    Screen('Close',win);
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

%Creating data 
replicated_trials = repmat(new_cond_names,times_to_loop,1);
exp_data = horzcat(replicated_trials,user_data);

%Performing calculations
for i = 1:length(colors)
    totalRT_congruent = 0;
    totalRT_incongruent = 0;
    for j = 1:length(exp_data)
        %If same color and congruent add to response time total
        if strcmp(exp_data(j,1),colors(i))
            if strcmp(exp_data(j,2),'congruent')
                totalRT_congruent = totalRT_congruent + cell2mat(exp_data(j,5));
                %Same but for incongruent
            elseif strcmp(exp_data(j,2),'incongruent')
                totalRT_incongruent = totalRT_incongruent + cell2mat(exp_data(j,5));
            end
        end
        avgRT_congruent = totalRT_congruent/times_to_loop;
        avgRT_incongruent = totalRT_incongruent/times_to_loop;
        meanRT(1,i) = avgRT_congruent;
        meanRT(2,i) = avgRT_incongruent;
    end
end

for i = 1:length(colors)
    total_correct_congruent = 0;
    total_correct_incongruent = 0;
    for j = 1:length(exp_data)
        %If same color and congruent add to correctness
        if strcmp(exp_data(j,1),colors(i))&& strcmp(exp_data(j,4),'correct')
            if strcmp(exp_data(j,2),'congruent') 
                total_correct_congruent = total_correct_congruent + 1;
                %Same but for incongruent
            elseif strcmp(exp_data(j,2),'incongruent')
                total_correct_incongruent = total_correct_incongruent + 1;
            end
        end
        avg_correct_congruent = total_correct_congruent/times_to_loop;
        avg_correct_incongruent = total_correct_incongruent/times_to_loop;
        meanCR(1,i) = avg_correct_congruent;
        meanCR(2,i) = avg_correct_incongruent;
    end
end