%reading our database picture.
database = imread('database_Ariel20_pic.docx.png');

databaseBW=imbinarize(database); %making pic binary.
databaseBW=databaseBW(:,:,1);     %making pic one dimentional.
databaseBWinv=1.-databaseBW;      %inverting black and white.
databaseBWlabel=bwlabel(databaseBWinv); %labeling all letters
databaseBWlabel=comb(databaseBWlabel);  %calling our function that manually combines
%2 parts of the same letter.

%running dictionary
dictionary;


%Datacell will hold matrix of each letter.
bboxes = regionprops(databaseBWlabel,'BoundingBox');
databaseBWlabel=int64(databaseBWlabel);
Datacell=cell([70 3]);

for k=1 : length(bboxes)
    currBB = bboxes(k).BoundingBox;
    %extracting matrix of a letter from the big picture of all letters.
    A=databaseBWlabel(int64(currBB(2)):int64(currBB(2)+currBB(4)) ,int64(currBB(1)):int64(currBB(1)+currBB(3)));
    
    
    % resizing and cleaning noise
    A = A*100;
    A = imresize(int32(A), [100,100]);
    A = medfilt2(A);
    for i=1:100
        for j=1:100
             if A(i,j) >= k*50
              A(i,j) = 1;
            else
               A(i,j) = 0;
            end
        end
     end

    B=DictionaryCell(k, :);
    Datacell(k,:)={A,size(A),B(2)};
end
    
        
%Excell will hold matrix of each letter from input image.
bboxes = regionprops(exBWlabel,'BoundingBox');
centers= regionprops(exBWlabel,'Centroid');
exBWlabel=int64(exBWlabel);
Excell=cell([length(bboxes) 4]);

%finding range of line by using first letter height.
currBB = bboxes(1).BoundingBox;
cent= centers(1).Centroid;
range= currBB(4);

%now we find where each letter is positioned in each line.
firstYpos=round(cent);
nextYpos=[0 0];
outOfRange=0;

for k=1 : length(bboxes)
    currBB = bboxes(k).BoundingBox;
    currCenter=centers(k).Centroid;
    %extracting matrix of a letter from the big input image.
    A=exBWlabel(int64(currBB(2)):int64(currBB(2)+currBB(4)) ,int64(currBB(1)):int64(currBB(1)+currBB(3)));
   
    % resizing and cleaning noise
    A = A*100;
    A = imresize(int32(A), [100,100]);
    A = medfilt2(A);
    for i=1:100
        for j=1:100
            if A(i,j) > 0
                A(i,j) = 1;
            else
                A(i,j) = 0;
            end
        end
    end
   
    %cheking to see in each iterarion if the y position is in range of the
    %line if so we fix the y position to be that of the line.
    %else we keep the last position that is out of the line to make a new
    %line standart.
    if currCenter(2)-range < firstYpos(2) && currCenter(2)+range > firstYpos(2)
    Excell(k,:)={A,size(A),round(currCenter(1)),firstYpos(2)};
    else
        Excell(k,:)={A,size(A),round(currCenter(1)),round(currCenter(2))};
        outOfRange= outOfRange+1;  
        nextYpos=round(currCenter);
    end       
end

%pastY will hold all the lines that we found and will find.
pastY = firstYpos;

%finding all the lines and fixing the characters positions.
while (outOfRange >1)
    
    outOfRange = 0;
    firstYpos= nextYpos;
    addToPastY=0;
    for k=1 : length(bboxes)

       currCenter(1)=Excell{k,3};
       currCenter(2)=Excell{k,4};
        
        goIn=1;
    
        %checking to see the value is not already a legitimate line value.
    for i=1 : length(pastY(:,1))
        if (round(currCenter(2)) == pastY(i,2))
            goIn = 0;
        end
    end
    
    
    %if there is a line in which we can fix the char position to
     if goIn == 1
            if currCenter(2)-range < firstYpos(2) && currCenter(2)+range > firstYpos(2) 
              Excell(k,3)={round(currCenter(1))};
              Excell(k,4)={round(firstYpos(2))};
       %else add a new line standart.       
            else
                
                addToPastY = 1;
                nextYpos=round(currCenter);
                outOfRange= outOfRange+1;    
            end    
    end
    end
    %adding the new line position to all the lines.
    if addToPastY == 1
        pastY = [pastY; nextYpos];
        addToPastY=0;
    end
end

%sorting by lines and x position
Excell_sorted = sortrows(Excell,[4 3]);

%finding spaceLength by finding the average range between letters.
sum=0;
divide_by=1;

for k=1 : length(Excell_sorted)-1
    if Excell_sorted{k,3}<Excell_sorted{k+1,3}
        sum=sum+ Excell_sorted{k+1,3} - Excell_sorted{k,3};
        divide_by=divide_by+1;
    end
    
end
spaceLength=sum/divide_by;
spaceLength=spaceLength*1.3;

%the main check, checking pixelwise which letter fits the most.
indexToWrite=1;

for k=1 : length(Excell_sorted)
    curLetterToWrite = Datacell(1,3);
    max=0;
    for j=1 : length(Datacell)
       tempMax = 0;
       letterFromInput = cell2mat( Excell_sorted(k,1));
       letterFromDataBase = cell2mat( Datacell(j,1));
        
       for r=1 : 100
           for c=1 : 100
             numFromInput = letterFromInput(r,c);
             numFromOutput = letterFromDataBase(r,c);
             
                 if (numFromInput == 0 && numFromOutput == 0) || (numFromInput ~= 0 && numFromOutput ~= 0)
                      if (numFromInput == 0 && numFromOutput == 0)
                          tempMax = tempMax + 2;
                      else
                     tempMax = tempMax + 1;
                      end
                 end
             
            end
       end
      
       
       if tempMax > max
           max = tempMax;
           curLetterToWrite = Datacell(j,3);
           
       end
    end
    
    %creating our final string, the printing takes place at imtext2notpad.m
    str(indexToWrite)=curLetterToWrite(1);           
    indexToWrite = indexToWrite+1;
    
    %adding space if necassery
    if k < length(Excell_sorted)
        if Excell_sorted{k,3} > Excell_sorted{k+1,3}
             str(indexToWrite)={' '};           
         indexToWrite = indexToWrite+1;
        end
      if Excell_sorted{k,3}+spaceLength < Excell_sorted{k+1,3}
         str(indexToWrite)={' '};           
         indexToWrite = indexToWrite+1;
      end
    end
end




% a function that combines 2 part letter together like in "i"
% combines the dot with the line.
function database = comb(database)
[row, col] = size(database);
for r=1:row
    for c=1:col
        if database(r,c)==15
            database(r,c)=16;
        end
        if database(r,c)==19
            database(r,c)=17;
        end
    
        if database(r,c)==58
            database(r,c)=57;
        end
         
        if database(r,c)==61
            database(r,c)=60;
        end
    end
end
end