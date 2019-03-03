database = imread('database_Ariel20_pic.docx.png');
databaseBW=imbinarize(database); %making pic binary.
databaseBW=databaseBW(:,:,1);     %making pic one dimentional.
databaseBWinv=1.-databaseBW;      %inverting black and white.
databaseBWlabel=bwlabel(databaseBWinv); %labeling all letters
databaseBWlabel=comb(databaseBWlabel);  %calling our function that combines
%2 parts of the same letter.

%running dictionary
dictionary;


%Datacell will hold matrix of each letter.
bboxes = regionprops(databaseBWlabel,'BoundingBox');
databaseBWlabel=int64(databaseBWlabel);
Datacell=cell([70 3]);

for k=1 : length(bboxes)
    currBB = bboxes(k).BoundingBox;
    A=databaseBWlabel(int64(currBB(2)):int64(currBB(2)+currBB(4)) ,int64(currBB(1)):int64(currBB(1)+currBB(3)));
    B=DictionaryCell(k, :);
    Datacell(k,:)={A,size(A),B(2)};
end

%now reading our example
[1:8,7:9]




%Excell will hold matrix of each letter.
bboxes = regionprops(exBWlabel,'BoundingBox');
exBWlabel=int64(exBWlabel);
Excell=cell([length(bboxes) 2]);

for k=1 : length(bboxes)
    currBB = bboxes(k).BoundingBox;
    A=exBWlabel(int64(currBB(2)):int64(currBB(2)+currBB(4)) ,int64(currBB(1)):int64(currBB(1)+currBB(3)));
    Excell(k,:)={A,size(A)};
end

%the main check

str=cell(length(Excell(1)));
index=1;
for k=1 : length(Excell)
    for j=1 : length(Datacell)
        C=cell2mat( Excell(k,2))== cell2mat( Datacell(j,2));
        if (C(1,1)+C(1,2)==2) 
            s=Datacell(j,3);
            
           str(index)=s(1);
           
           index=index+1;
        end      
       
    end
end
% a function that combines 2 part letter together like in "i"
% combines the dot with the line
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