function snake_game_serial()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     PRESS 'Q' TO EXIT GAME         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all

%OPTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

difficulty=6;            %difficulty:  1-10
bounds=1;         %bounds? 1-yes 0-no
axis_limit= 15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555555555

d=0;
x =round(axis_limit/2); %starting point round
y =round(axis_limit/2); %starting point
d = 3; % Start with initial direction to the right
a =randi([1 axis_limit-1],1);%generates random x coordinate for food
b =randi([1 axis_limit-1],1);%generates random y coordinate for food
snake(1,1:2)=[x y];%defines the snake for x and y coordinates
size_snake=1;
ate=1;   %snake ate food
ex=0;    % used to exit game
food=[a b];%defines food for a and b coordinates
score = 0; % Initialize score counter

% Open serial port
s = serial('COM9','BaudRate',9600);
fopen(s);

fig = figure('CloseRequestFcn', @close_game);
score_text = uicontrol('Style', 'text', 'Position', [20 20 100 20], 'String', ['Score: ', num2str(score)]);
draw_snake(snake,food,size_snake,axis_limit)

    function close_game(~,~)
        ex = 1;
        delete(fig);
        fclose(s); % Close serial port
    end

while (ex~=1)%runs the snake as long as q is not pressed
    % Read data from serial port
    if s.BytesAvailable > 0
        data = fscanf(s, '%s');
        switch data
            case 'left'
                d = mod(d - 1, 4); % rotate left 90 degrees
            case 'right'
                d = mod(d + 1, 4); % rotate right 90 degrees
        end
    end
    
    size_snake=size(snake);
    size_snake=size_snake(1);
    for l=size_snake+ate:-1:2
        snake(l,:)=snake(l-1,:);
    end
    switch d         %calling callback function
        case 1
            snake(1,2)=snake(1,2)+1;%add value of 1 to y position
        case 2
            snake(1,1)=snake(1,1)-1;%subtract value of 1 to x position
        case 3
            snake(1,2)=snake(1,2)-1;%subtract value of 1 to y position
        case 0
            snake(1,1)=snake(1,1)+1;%add value of 1 to x position
    end
    
    % Check if the snake hits the boundary
    if bounds == 1 && (snake(1,1) == 0 || snake(1,2) == 0 || snake(1,1) == axis_limit+1 || snake(1,2) == axis_limit+1)
        msgbox('YOU LOST!');
        ex = 1;
        break;
    end
    
    draw_snake(snake,food,size_snake,axis_limit);%draws the snake

    pause(max([(105-difficulty*10)/(10*axis_limit) .001])) %difficulty makes game faster;

    if snake(1,1)==food(1) && snake(1,2)==food(2)%if the snake and food are in the same position
        ate=1;
        score = score + 1; % Increment score when snake eats food
        set(score_text, 'String', ['Score: ', num2str(score)]); % Update score display
        food(1) = randi([1 axis_limit-1]);%creates a new x position for the food
        food(2) = randi([1 axis_limit-1]);%creates a new y position for the food
    else
        ate=0;
    end

    if bounds==1
        snake=snake-((snake>axis_limit).*(axis_limit+1));
        snake=snake+((snake<0).*(axis_limit+1));
    end
    
    if (sum(snake(:, 1) ==snake(1, 1)   & snake(:, 2) == snake(1, 2) )>1) %if snake hits itself
        msgbox('YOU LOST!');
        break;
    end
end
fclose(s); % Close serial port
close all;
end

function draw_snake(snake,food,size_snake,axis_limit)

    num_interp_points = 100; % Number of interpolated points between each pair of consecutive snake points
    
    for p = 1:size_snake-1
        % Interpolate between snake points
        interpolated_x = linspace(snake(p,1), snake(p+1,1), num_interp_points);
        interpolated_y = linspace(snake(p,2), snake(p+1,2), num_interp_points);
        
        % Plot interpolated points
        plot(interpolated_x, interpolated_y, 'ws'); %wo
        hold on;
    end
    
    % Plot last snake point
    plot(snake(end,1), snake(end,2), 'ws'); %wo
    
    % Plot food
    plot(food(1), food(2), 'rs');
    
    whitebg([0 0 0]); % Create black background
    axis([0, axis_limit, 0, axis_limit]); % Set axis limits
    hold off;
end
