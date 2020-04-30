function point = save_point(cam)

% Function: detect the crossing point of the chess took from camera
% Argument:
%   Input: the 2-D rgb picture of a chess
%       ps1. cannot include any other straight line (even the outline of the chess!)
%       ps2. avoid shade
%       ps3. keep the lines as horizontal and vertical as possible
%   Output: the NxNx2 array, storing (x,y) for every point in the chess

% binarize
gray_cam = rgb2gray(cam);
bw_cam = imbinarize(gray_cam, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.4);
% figure, imshow(bw_cam), title('binarize');
[height, width] = size(bw_cam);

% detect lines
bw_cam = 1 - bw_cam;
sigma = 2; % 方差，图像比较清晰、噪音不大时可以设置小一点
window = double(uint8(3*sigma)*2+1);
H = fspecial('gaussian', window, sigma);
% figure,imshow(bw_cam);
bw_cam = imfilter(bw_cam, H, 'replicate');

[H, theta, rho] = hough(bw_cam);
% figure, imshow(bw_cam);
P = findNmaxH(H);

% P = houghpeaks(H, 1000); % 好像不太行
lines = houghlines(bw_cam, theta, rho, P);

figure, imshow(cam), hold on
[x_intercept, y_intercept] = findLinePoint(lines, height, width);
for k = 1:length(x_intercept)
    if x_intercept(k) ~= -1
        plot([x_intercept(k); x_intercept(k)], [0; height], 'LineWidth', 2, 'Color', 'red');
    end
end
for k = 1:length(y_intercept)
    if y_intercept(k) ~= -1
        plot([0, width], [y_intercept(k); y_intercept(k)], 'LineWidth', 2, 'Color', 'red');
    end
end
figure, imshow(cam), hold on
for i = 1:length(x_intercept)
    for j = 1:length(y_intercept)
        if x_intercept(i) ~= -1 && y_intercept(j) ~= -1
            plot(x_intercept(i), y_intercept(j), '*b');
        end
    end
end
end

function modP = findNmaxH(H)
% 找到H中前n个最大的值（每5x5里最多出一个）←gave up
[height, width] = size(H);
tmpH = H;

% 下面这段代码好像帮倒忙
% for i = 1:height
%     for j = 1:width
%         for dh = -0:0
%             for dw = -0:0
%                 tmpH(i,j) = tmpH(i,j) + H(mod(i+dh+height-1,height)+1, mod(j+dw+width-1,width)+1);
%             end
%         end
%     end
% end

% 发现横线和竖线分开聚类好像比较好
P1 = []; % 竖线
P2 = []; % 横线

for k = 1:500
    max = [1, 1];
    for i = 1:height
        for j = 1:width
            if tmpH(i, j) > tmpH(max(1), max(2))
                max = [i, j];
            end
        end
    end
    
    if (max(2)>=0 && max(2)<=5) || (max(2)>=175 && max(2)<=180)
        P1 = [P1; max];
    elseif max(2)>=85 && max(2)<= 95
        P2 = [P2; max];
    end
%     for dh = -0:0
%         for dw = -0:0
%             tmpH(mod(max(1)+dh+height-1,height)+1, mod(max(2)+dw+width-1,width)+1) = -1;
%         end
%     end

    tmpH(max(1), max(2)) = -1;
     
end

num = 45;
label = kmeans(P1, num, 'MaxIter',1000);
modP1 = zeros(num, 2);
for i = 1:length(label)
    if modP1(label(i),:) ~= [0, 0]
        modP1(label(i), :) = (P1(i, :)+modP1(label(i),:)) / 2;
    else
        modP1(label(i),:) = P1(i,:);
    end
end
modP1 = round(modP1);

label = kmeans(P2, num, 'MaxIter', 1000);
modP2 = zeros(num, 2);
for i = 1:length(label)
    if modP2(label(i),:) ~= [0, 0]
        modP2(label(i), :) = (P2(i, :)+modP2(label(i),:)) / 2;
    else
        modP2(label(i),:) = P2(i,:);
    end
end
modP2 = round(modP2);

modP = [modP1; modP2];

end

function [x_intercept, y_intercept] = findLinePoint(lines, height, width)
% 根据过直线的两点找到该直线与边框的交点
x_intercept = []; % 横向截距
y_intercept = []; % 纵向截距
for i = 1:length(lines)
    p1 = lines(i).point1;
    p2 = lines(i).point2;
    if p1(1) ~= p2(1)
        k = (p1(2)-p2(2)) / (p1(1)-p2(1));
        if k > -0.05 && k < 0.05 % 横线，近似水平，提取纵向截距b 
            y_intercept = [y_intercept, p1(2)];
        elseif 1/k > -0.05 && 1/k < 0.05 % 竖线，近似竖直，提取横向截距
            x_intercept = [x_intercept, p1(1)];
        end
    else % 绝对竖直的竖线
        x_intercept = [x_intercept, p1(1)]; 
    end
end

dw_thresh = width / 100; 
dh_thresh = height / 100;
% 这个是因为这里用的照片是19x19的棋盘。如果用7x7的可以将阈值改为20。
%（依赖于摄像精度、棋盘水平竖直程度和外界噪声大小）
for i = 1:length(x_intercept)-1
    for j = i+1:length(x_intercept)
        dw = abs(x_intercept(i) - x_intercept(j));
        if dw < dw_thresh
            x_intercept(j) = round( (x_intercept(i)+x_intercept(j)) / 2 );
            x_intercept(i) = -1;
        end
    end
end
for i = 1:length(y_intercept)-1
    for j = i+1:length(y_intercept)
        dh = abs(y_intercept(i) - y_intercept(j));
        if dh < dh_thresh
            y_intercept(j) = round( (y_intercept(i)+y_intercept(j)) / 2 );
            y_intercept(j) = -1;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%分别对x和y去除重复或相近的截距

        %end
        
%         % 对这些直线再“聚类”
%         
%         
%         % 根据k, b作直线
%         np1 = [0, b]; % np1~4代表四个可能的交点（实际只有两个）
%         np2 = [-b/k, 0];
%         np3 = [width, k*width+b];
%         np4 = [(height-b)/k, height];
%         if np1(2)<=height && np1(2)>0 % 检测是否在框内，如果是则储存
%             lp = [lp, np1];
%         end
%         if np2(1)<=width && np2(1)>0
%             lp = [lp, np2];
%         end
%         if np3(2)<=height && np3(2)>0
%             lp = [lp, np3];
%         end
%         if np4(1)<=width && np4(1)>0
%             lp = [lp, np4];
%         end
%     else
%         lp = [p1(1), 0, p1(1), height];
%     end
    
%     LinePoint = [LinePoint; lp];

end