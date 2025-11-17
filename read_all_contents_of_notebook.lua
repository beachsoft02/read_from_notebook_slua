-- Read all lines from a notecard in SLua
-- Adapted from the LSL at http://wiki.secondlife.com/wiki/Category:LSL_Notecard
-- Author blackcanadian02 Resident
-- Company: Beach Software
-- License : MIT 
-- Date : Nov 16, 2025
-- Notes: Please submit a pull request with corrections and improvements
-- Current bugs in SLua: 1)Arguments to main function via coroutine.resume is ignored?
--    2)To check  for "EOF" check for all spaces and control characters in returned value in dataserver

--- change notecard_name
local notecard_name = "Questions and Answers"

-- ordered lines in notecard get stored in this array
local notecard_lines = {}

local kQuery = nil
local iLine = 1
local next_line = iLine
local eof_seen = 0
local loop_counter = 1
local key notecard_key = nil;
local DEBUG_CHANNEL  = 0

local function snc(notecard)
    local num_lines = #notecard
    ll.OwnerSay("numlines" .. tostring(num_lines))
    local i = 1
    while (i <= num_lines) do
        ll.OwnerSay("line " .. tostring(i) .. " : " .. notecard[i])
        i +=1
    end
end



local function main( 
    -- eof_seen,next_line, loop_counter
)
   max_loops = 5000
    while true do
        --max loops prevent inifinite loop: set to max number of lines for notecard
        if (loop_counter > max_loops) then
            ll.Say(DEBUG_CHANNEL, "max iterations reached: increase max_loops")
            return
        end
 
        --eof seen, communicated from dataserver event processor via coroutines.resume
        -- means we have the contents of the notecard and we can go ahead with rest of program
        if (eof_seen == 1) then
            snc(notecard_lines)
            -- rest of script ....
            return
        end
        
        -- first time
        if ( 1 ==next_line ) then
            local nc_key = ll.GetInventoryKey(notecard_name)
            notecard_key  = nc_key
        end
        -- first one initiated here, subsequent ones are initiated after event processing of previous
        kQuery = ll.GetNotecardLine(notecard_name, next_line);
        coroutine.yield()
    end
end



local function processDataserver(query_id, data)
    if (data == nil or string.find(data,"^[%c ]+$")  ) then
        eof_seen = 1
        coroutine.resume(main_co
          --,1,iLine,loop_counter
        )
    else
        notecard_lines[next_line] = data
        next_line += 1
        loop_counter += 1
        coroutine.resume(main_co
        --,0,iLine,loop_counter
        )
    end
end

LLEvents:on("dataserver",processDataserver)

main_co  = coroutine.create(main)
coroutine.resume(main_co
--,0,iLine,loop_counter
)
