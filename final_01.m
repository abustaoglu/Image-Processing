clc; clear all; close all;
%% read image 

img = imread('test.png');
img = rgb2gray(img);
img1 = img;
img = imnoise(img,'salt & pepper',0.01);

[h,w] = size(img);
img = imgaussfilt(img);
%% median filter for small image
med = zeros(h,w);
med = medfilt2(img);
med = double(med);
%% Pre processing / smoothing
dime = 3; 
ws=dime; hs=dime; % block size 

block_1 = zeros(hs,ws);% 3x3 blocks

smooth = zeros(h,w); % average image
smooth(1:h,1) = img(1:h,1); % left side borderline
smooth(1,1:w) = img(1,1:w); % top side borderline
smooth(1:h,w) = img(1:h,w); % right side borderline
smooth(h,1:w) = img(h,1:w); % bottom side borderline 

for i = ceil(ws/2) : 1 : h - floor(hs/2)
    
    for j = ceil(ws/2) : 1 : w - floor(hs/2)
        
        block_1 = double(img(i-floor(ws/2):i+floor(ws/2),j-floor(hs/2):j+floor(hs/2)));  
       
        %% optimal pixel value to better algorithm 
        
        ver = ( block_1(1,2) + block_1(3,2) ) / 2 ; hor = ( block_1(2,1) + block_1(2,3) ) / 2;
        
        cor = ( block_1(1,1) + block_1(1,3) + block_1(3,1) + block_1(3,3)) / 4;
        
        side = ( block_1(2,1) + block_1(1,2) + block_1(2,3) + block_1(3,2)) / 4;
        
        al = ( cor + side ) / 2;
        
        res = ( ver + cor + side + al + hor + med(i,j) ) / 6;

        smooth(i,j) = res;
        
    end
end
%% membership function // fuzzy image representation

smooth = floor(smooth);
smooth = uint8(smooth);
smooth = imnoise(smooth,'salt & pepper', 0.01);
block_2 = zeros(hs,ws);% 3x3 blocks
med1 = zeros(h,w);
med1 = medfilt2(uint8(smooth));
med1 = double(med1);
mem_res = zeros(h,w); % pixel density image
mem_res(1:h,1) = 1; % left side borderline
mem_res(1,1:w) = 1; % top side borderline
mem_res(1:h,w) = 1; % right side borderline
mem_res(h,1:w) = 1; % bottom side borderline

rs2 = zeros(h,w); % average image
rs2(1:h,1) = img(1:h,1); % left side borderline
rs2(1,1:w) = img(1,1:w); % top side borderline
rs2(1:h,w) = img(1:h,w); % right side borderline
rs2(h,1:w) = img(h,1:w); % bottom side borderline 

for i = ceil(ws/2)  : 1 : h - floor(hs/2)
    
    for j = ceil(ws/2) : 1 : w - floor(hs/2)
        
        block_2 = double(smooth(i-floor(ws/2):i+floor(ws/2),j-floor(hs/2):j+floor(hs/2)));  
       %% optimal pixel value to better algorithm 
        ver = ( block_2(1,2) + block_2(3,2) ) / 2 ; hor = ( block_2(2,1) + block_2(2,3) ) / 2;
        
        cor = ( block_2(1,1) + block_2(1,3) + block_2(3,1) + block_2(3,3)) / 4;
        
        side = ( block_2(2,1) + block_2(1,2) + block_2(2,3) + block_2(3,2)) / 4;
        
        al = ( cor + side ) / 2;
        
        res = ( ver + cor + side + al + hor + med(i,j) ) / 6; % Ir = (Ih + Iv + I4 + I8 + Id + Med) / 6
        
        rs2(i,j) = res;
       %% membership function 
        px = mem_fn3(block_2,res,3);
        
        mem_res(i,j) = px(2,2);
    end
end
%% trusted im process

tr = double(smooth);
tr = floor(tr);
cnt4 = 0; cnt3 = 0; cnt1 = 0; cnt2 = 0; % number of fuzzy points

for ii = 1 : 1 : h
    
    for jj = 1 : 1 : w
        
        temp = double(mem_res(ii,jj)); 
        temp2 = double(smooth(ii,jj));
        
        if temp > 0.99
            cnt4 = cnt4 +1;
            tr(ii,jj) = temp2;
            
        else
                        cnt3 = cnt3 + 1;
                        av = double(rs2(ii,jj));
                              if av < ceil(255/2) %Lmax or Lmin 
                                              tr(ii,jj) = -1;
                                              cnt1 = cnt1 + 1;
                              else
                                              tr(ii,jj) = 256;
                                              cnt2 = cnt2 + 1;
                              end
           
       
        end
    end
end


%% our method histogram
[hist,hist_shaved] = histogram_h(tr,smooth);
thr = otsuthresh(hist_shaved);
bin1 = imbinarize(uint8(tr),thr);
bin1 = 255*bin1;

%% otsu method histogram
[otsuhist] = imhist(uint8(img));
thr1 =  otsuthresh(otsuhist);
bin2 = imbinarize(uint8(img),thr1);
bin2 = 255*bin2;

%% matlab default binarization
%thr2 = graythresh(img);
%matbin = imbinarize(img,thr2);
%matbin = matbin*255;

%% plotting part
figure; imshow((uint8(img)));title('Source');
%figure; imshow((uint8(img1)));title('clear source');
%figure; imshow((uint8(img1)));title('source noise');
%figure; imshow(uint8(tr));title('trusted im ');
figure; imshow((uint8(bin1)));title('Our Method');
figure; imshow((uint8(bin2)));title('Otsu Method');
% figure; imshow((uint8(matbin)));title('matlab');
%% plot histogram
%subplot(2,1,1);bar(hist_shaved);title('Filtered Histogram');ylim([0 2500]);
%subplot(2,1,2);bar(otsuhist);title('Original Histogram ');ylim([0 2500]);

