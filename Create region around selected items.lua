--Create region around selected items
--Lua script for Reaper
--Author : BioMannequin (Ashton Mills)
--Version: 1.2
--Version Date : 29.05.20

--Prompts for how much space in milliseconds you want to leave before the first and after the last items.
--If items are selected, creates a region that starts at the earlist start point of all selected regions, and ends and the latest point of
--all selected regions. In short, it creates a single region around all the items you have selected. 

--Global Vars
numSelectedItems = reaper.CountSelectedMediaItems(0);
startPositionsArray = {};
endPositionsArray = {};

--Functions
function fillArrays();
  for itemNumber = 0,numSelectedItems-1,1
  do
    item = reaper.GetSelectedMediaItem(0,itemNumber);
    itemStartPosition= reaper.GetMediaItemInfo_Value(item,"D_POSITION");
    itemEndPosition = reaper.GetMediaItemInfo_Value(item,"D_POSITION") + reaper.GetMediaItemInfo_Value(item,"D_LENGTH");
    table.insert(startPositionsArray,itemNumber+1,itemStartPosition);
    table.insert(endPositionsArray,itemNumber+1,itemEndPosition);
    if (itemNumber == 0)
    then
      track = reaper.GetMediaItemInfo_Value(item,"P_TRACK");
    end
  end
end

function getEarliestStartPoint()
  lowest = 100000;
  for i,v in pairs(startPositionsArray)do
    if v < lowest then
      lowest = v
    end
  end
  return lowest;
end

function getLatestEndPoint()
  highest = 0;
  for i,v in pairs(endPositionsArray)do
    if v > highest then
      highest = v
    end
  end
  return highest;
end

function createRegion(startPoint,endPoint)
  regionColour = reaper.GetTrackColor(track);
  myBool, regionName=  reaper.GetSetMediaTrackInfo_String(track,"P_NAME","",false);
  reaper.AddProjectMarker2(0,true,startPoint,endPoint,regionName,-1,regionColour);
end

--Main Body
fillArrays();
rv, rv_str = reaper.GetUserInputs("Head and tail length in milliseconds", 2, "Time before first item ,Time after last item","" );
bfr, aftr = rv_str:match("([^,]+),([^,]+)");

bfrValid = tonumber(bfr) ~= nil;

if (bfrValid==false)
then 
  bfr = 0;
else 
  bfr = bfr/1000;
end

aftrValid = tonumber(aftr) ~= nil;

if (aftrValid==false)
then 
  aftr = 0;
else 
  aftr = aftr/1000;
end


regStart = getEarliestStartPoint() - bfr;
if(regStart < 0)
then
  regStart=0;
end
regEnd = getLatestEndPoint() + aftr;

createRegion(regStart,regEnd);
