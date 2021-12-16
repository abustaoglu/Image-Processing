function [histogram1,histogram2] = histogram_h(I1,source)

    histogram1 = zeros(1,258);  
    [w,h] = size(source);
    
for i=1:1:w-1
   
    for j=1:1:h-1
       
        histogram1(I1(i,j)+2) = histogram1(I1(i,j)+2)+1;
    
    end
    
end
    
histogram2 = zeros(1,256);

for z = 1 : 256
    
    histogram2(z) = histogram1(z+1);
end

 
