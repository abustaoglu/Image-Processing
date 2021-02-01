function [mem] = mem_fn3(block_img, Ic, dime)

mem=zeros(dime,dime);

for i = 1 : 1 : dime
    
    for j = 1 : 1 : dime
        
        temp = double(block_img(i,j)); %real intensity level
        
        c = double(Ic); % average Ir
        b = (4/5)*c;

        if temp <= c
                    
                    l = temp; % constant
                    
                    a = c - b;  b = c - (b/2); % depended parameters
                    
                    if l <= a
                        
                        mem(i,j) = 0 ;
                        
                    elseif ( l >= a ) && ( l <= b )
                        
                        mem(i,j) = 2 * ( (l - a) / (c - a) )^2 ;
                        
                        
                    elseif  ( l >= b ) && ( l <= c )    
                    
                        mem(i,j) = 1 - (2 * (( l - c ) / ( c - a ) )^2) ;
                
        
                    else
                        
                        mem(i,j) = 1;
                    end
                    
                else 
                    
                    l = temp;    % constant
                    
                    a = c;  b = c + (b/2); c = c + b; % s function parameters
                    
                    if l <= a
                        
                        mem(i,j) = 1 ;
                        
                    elseif ( l >= a ) && ( l <= b )
                        
                        mem(i,j) = 1 - (2 * ( (l - a) / (c - a) )^2) ;
                        
                    elseif  ( l >= b ) && ( l <= c )    
                    
                        mem(i,j) = 1 - (1 - (2 * (( l - c ) / ( c - a ) )^2)) ;
                    else
                        
                        mem(i,j) = 1 - 1;
                    end
                    
                end
            end
        end
    end