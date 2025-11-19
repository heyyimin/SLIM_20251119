%% SLIM for TCSPC B&H data format *.sdt
%   Package name:     SLIM
%   Package version:  2025-11-18
%   File version:     2025-11-18

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
addpath(genpath('./bfmatlab/'));
% load the data from *.sdt format file
[filename, path] = uigetfile( ...
{'*.sdt','Backer file format (*.sdt)'}, ...
   'Select an SLIM data file');
data = bfopen([path, filename]);
seriesCount = size(data, 1);
series1 = data{1,1};
metadataList = data{1,2};
% dimensions of the image
[x_dim_roi, y_dim_roi] = size(series1{1});
% lifetime channel count
tp_cot = size(series1, 1); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transfor the data cells from into matrix form
photons_matrix = zeros(x_dim_roi,y_dim_roi,tp_cot);
pho_mat_bin = zeros(x_dim_roi,y_dim_roi,tp_cot);
for i = 1:tp_cot
    % transform the data from cell to matrix
    photons_matrix(:,:,i) = series1{i,1};
end

%% %%%%%%%%%%%%%%%%% Obtain the intermediate images %%%%%%%%%%%%%%%%%% 
%% Obtain 8bit image
th = 71;  % Time-gated threshold
conf = sum(photons_matrix(:,:,1:th),3);  %  Confcoal image, double format
sted = sum(photons_matrix(:,:,th+1:end),3);  % STED image, double format

% Increase contrast and convert to uin8 format
Confcal = im2uint8(mat2gray(conf));
STED = im2uint8(mat2gray(sted));
Donut = Confcal-STED;  % Donut image

% Save Confcal and STED images
imwrite(Confcal,'Confcal.tif');
imwrite(STED,'STED.tif');

%% Perform low-pass filtering on the Donut image
s = fftshift(fft2(double(Donut))); 
[a,b] = size(s);
h = zeros(a,b); 
LP_Donut = zeros(a,b); 
a0 = round(a/2);
b0 = round(b/2);
d = 55;  % The cutoff radius of the ideal low-pass filter

% Identification filtering range
figure(1), imshow(log(abs(s)+1),[]); hold on
title('The Fourier spectrum that indicates the filtering range'); 
circle_x = b0 - d; 
circle_y = a0 - d; 
circle_width = 2*d; 
circle_height = 2*d; 
rectangle('Position', [circle_x, circle_y, circle_width, circle_height], ...
          'Curvature', [1, 1], ... 
          'EdgeColor', 'r', ...    
          'LineWidth', 2);         
hold off; 

% Obtain the low-pass filtered image
for i = 1:a
    for j = 1:b
        distance = sqrt((i-a0)^2 + (j-b0)^2);
        if distance > d
            h(i,j) = 0;
        else
            h(i,j) = 1;
        end
    end
end
LP_Donut = s .* h;
LP_Donut = real(ifft2(ifftshift(LP_Donut)));

figure(2),imshow(LP_Donut,[0 255]);
title('Low-pass filtered donut');
LP8_Donut = uint8(LP_Donut);

% Save Low-pass filtered donut images
imwrite(LP8_Donut,'Low-pass filtered donut.tif');

%% %%%%%%%%%%%%%%%%% Obtain the secondary computational depletion (SCD) image %%%%%%%%%%%%%%%%%% 
% Set the differential coefficient, such as 1.5
beta = 1.5;
% obtain the SCD intensity image
II = STED - beta.*LP8_Donut;

%% Obtain the SLIM image
data = double(II);
DATA = (data-min(min(data)))/(max(max(data))-min(min(data)));   

% load confocal-equivalent lifetime(*.asc) obatained from TCSPC B&H data
file =sprintf('./6 710nm 2ns z16 atto647n STED 5mW 0 6000ps_color coded value.asc');
tao = double(load(file));
%  Fluorescence lifetime normalization
tao_min = 0;
tao_max = 6000;  % Fluorescence lifetime display threshold
tao(tao > tao_max) = tao_max;
tao(tao < tao_min) = tao_min; 
T = (tao-tao_min)/(tao_max-tao_min); 

% Allocate the HSV color channels
hsv_img = zeros(x_dim_roi,y_dim_roi,3);
hsv_img(:, :, 1) = T*2/3;    % Hue
hsv_img(:, :, 2) = 1;        % Saturation
hsv_img(:, :, 3) = DATA(:,:);  % Value

% Convert the HSV color space to the RGB color space
rgb_img = hsv2rgb(hsv_img);

% Display the SLIM image(RGB image)
figure(3)
imshow(rgb_img,[],'border','tight');
%  save the SLIM image
imwrite(rgb_img,'SLIM_image.tif');  

%% Save lifetime map
original_jet = jet(256);
reversed_jet = flipud(original_jet);
overlap_scaled = uint8(T * 255);
% Map the data to an RGB image.
lifetime_map = ind2rgb(overlap_scaled + 1, reversed_jet); 
imwrite(lifetime_map, 'lifetime_map.tif');



