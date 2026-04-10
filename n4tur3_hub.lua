-- N4tur3 Hub Lua Script
local N4tur3Hub = {}

function N4tur3Hub:new()
    local newObj = {name = "N4tur3 Hub"}
    self.__index = self
    return setmetatable(newObj, self)
end

function N4tur3Hub:initialize()
    print(self.name .. " is initializing...")
    -- Initialization code here
end

function N4tur3Hub:run()
    print(self.name .. " is now running!")
    -- Main run loop here
end

return N4tur3Hub