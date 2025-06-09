gg.setVisible(false)
gg.alert("────୨ৎ────────୨ৎ────\nScript By: CheatCode Revolution\nTelegram: @BadLuck_69\nYouTube: CheatCode Revolution\n────୨ৎ────────୨ৎ────")

local gg = gg
local ti = gg.getTargetInfo()
local arch = ti.x64
local p_size = arch and 8 or 4
local p_type = arch and 32 or 4

local count = function()
    return gg.getResultsCount()
end

local getvalue = function(address, flags)
    return gg.getValues({{address = address, flags = flags}})[1].value
end

local ptr = function(address)
    return getvalue(address, p_type)
end

local CString = function(address, str)
    local bytes = gg.bytes(str)
    for i = 1, #bytes do
        if (getvalue(address + (i - 1), 1) & 0xFF ~= bytes[i]) then
            return false
        end
    end
    return getvalue(address + #bytes, 1) == 0
end

Meow = function(clazz, method)
    gg.setVisible(false)
    local original_hex = {}
    gg.setRanges(-2080835)
    gg.clearResults()
    gg.searchNumber(string.format("Q 00 '%s' 00", method))
    if (count() == 0) then 
        print("No results found for method: " .. method)
        gg.setVisible(true)
        return false 
    end
    gg.refineNumber(method:byte(), 1)
    gg.searchPointer(0, p_type)
    local pointer_results = gg.getResults(count(), nil, nil, nil, nil, nil, p_type, nil, gg.POINTER_EXECUTABLE | gg.POINTER_EXECUTABLE_WRITABLE | gg.POINTER_WRITABLE | gg.POINTER_READ_ONLY)
    gg.clearResults()
    if (#pointer_results == 0) then 
        print("No pointer results found for method: " .. method)
        gg.setVisible(true)
        return false 
    end
    for i, v in ipairs(pointer_results) do
        if (CString(ptr(ptr(v.address + p_size) + (p_size * 2)), clazz)) then
            local base_address = ptr(v.address - (p_size * 2))
            local hex_values = ""
            for j = 1, 48 do
                local value = getvalue(base_address + (j - 1), 1)
                hex_values = hex_values .. string.format("%02X ", value & 0xFF)
            end
            table.insert(original_hex, {address = base_address, hex = hex_values, class = clazz, method = method})
        end
    end
    if (#original_hex == 0) then
        print("No matches found for class: " .. clazz .. " and method: " .. method)
        gg.setVisible(true)
        return false
    end
    for i, v in ipairs(original_hex) do
        print(string.format("{\nClass: %s\nMethod: %s\nAddress: 0x%X\nSearch Hex: %s\n}", 
            v.class, v.method, v.address, v.hex))
    end
    gg.setVisible(true)
    os.exit() -- Exit script after printing results
    return true
end

gg.clearResults()

-- Initialize variables to store previous inputs
local last_class = ""
local last_method = ""

function main()
    local input = gg.prompt(
        {"Class Name:", "Method Name:", "Exit Script"},
        {last_class, last_method, false},
        {"text", "text", "checkbox"}
    )
    
    if input == nil then
        gg.toast("Input cancelled")
        return
    end
    
    -- Check if exit checkbox is selected
    if input[3] then
        gg.toast("Exiting script")
        os.exit()
    end
    
    local class_name = input[1]
    local method_name = input[2]
    
    -- Update last inputs
    last_class = class_name
    last_method = method_name
    
    if class_name == "" or method_name == "" then
        gg.toast("Both class and method names must be provided")
        return
    end
    
    Meow(class_name, method_name)
end

while true do
    while gg.isVisible(true) do
        gg.setVisible(false)
        main()
    end
end
