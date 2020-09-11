local TermColors = {}
local Tokens = {
  -- Attributes:
  "None", "Bold", "Dim", "Italic", "Underline", "DobleU", "Blink", "Reverse", "Hidden", "Strike",
  -- Predefined colors (3/4 bits):
  "Black", "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White"
}

local function tokExists(val) for i=1, #Tokens do if val == Tokens[i] then return true end end; return false end
local function split(str, sep)
  local sep = sep or "%s"
  local t = {}
  for e in str:gmatch("([^" .. sep .. "]+)") do table.insert(t, e) end
  return t
end

TermColors.ESC = string.char(27)

TermColors.Attr = {
  None      = "0", Bold   = "1",
  Dim       = "2", Italic = "3",
  Underline = "4", Blink  = "5",
  Reverse   = "7", Hidden = "8",
  Strike    = "9", DobleU = "21" -- "Doble Underline"
}

TermColors.FG = {
  Black = "30", Red     = "31",
  Green = "32", Yellow  = "33",
  Blue  = "34", Magenta = "35",
  Cyan  = "36", White   = "37",
  FG    = "38"
}

TermColors.BG = {
  Black = "40", Red     = "41",
  Green = "42", Yellow  = "43",
  Blue  = "44", Magenta = "45",
  Cyan  = "46", White   = "47",
  BG    = "48"
}

function TermColors:compile(input)
  assert(
    type(input) == "string" or
    type(input) == "nil",
    "[TermColors] Error: wrong input to 'compile()', 'string' expected, got '" .. type(input) .. "'."
  )

  local gi = 0 -- "group index"
  local tn = 0 -- "token number"
  local esc = string.char(27)

  local str = input:gsub("(%#%{[%w%s%(%)%;%,]+%})", function (match)
    gi = gi + 1
    match = match:gsub("%s", "")

    match = match:gsub("([%w%s%(%)%;%,]+)", function (props)
      for _, val in pairs(split(props, ";")) do
        tn = tn + 1

        if val:match("%w%(.*%)") then
          local func, farg = val:match("(%w+)%((.*)%)")
          local rgb = nil

          if farg:find("RGB") and farg:match("RGB%((%d?%d?%d?,%d?%d?%d?,%d?%d?%d?)%)") then
            farg = farg:gsub("[%(%)]", ""):gsub("RGB", "2;"):gsub(",", ";")
            rgb  = true
          elseif farg:find("RGB") and not farg:match("RGB%((%d?%d?%d?,%d?%d?%d?,%d?%d?%d?)%)") then
            -- Error: bad call to RGB() function
            print("[TermColors] Error: bad call to RGB() function.")
            print("                ==> @ group #"..gi.." ("..match.."), token #"..tn.." ("..val..").")
            os.exit(1)
          end

          if func == "FG" or func == "BG" then
            if not rgb then
              if tokExists(farg) then props = props:gsub(func .. "%(?" .. farg .. "%)?", self[func][farg])
              elseif farg:match("^(%d+)$") and not farg:find(",") and not farg:find("%a+") then
                if tonumber(farg) >= 0 and tonumber(farg) <= 255 then
                  props = props:gsub(func .. "%(?" .. farg .. "%)?", self[func][func] .. ";5;" .. farg)
                else
                  -- Error: 8-bit color value out of range
                  print("[TermColors] Error: 8-bit color value (%s"..farg.."%s) out of range.")
                  print("                ==> @ group #"..gi.." (%s"..match.."%s), token #"..tn.." (%s"..val.."%s).")
                  os.exit(1)
                end
              else
                -- Error: unknown pre-defined color
                print("[TermColors] Error: wrong color '"..farg.."'.")
                print("                ==> @ group #"..gi.." ("..match.."), token #"..tn.." ("..val..").")
                os.exit(1)
              end
            elseif rgb then
              props = props:gsub(func, self[func][func]..";2;"):gsub("[%(%)]+", ""):gsub("RGB", ""):gsub(",", ";")
            else
              -- Error: idk...
              print("[TermColors] Error: something's wrong...")
              print("                ==> @ group #"..gi.." ("..match.."), token #"..tn.." ("..val..").")
              os.exit(1)
            end
          elseif func == "RGB" then
            -- Error: calling RGB() function outside FG() and BG() functions is not allowed
            print("[TermColors] Error: calling RGB() function outside FG() and BG() functions is not allowed.")
            print("                ==> @ group #"..gi.." ("..match.."), token #"..tn.." ("..val..").")
            os.exit(1)
          else
            -- Error: unknown function name
            print("[TermColors] Error: unknown function '"..func.."'.")
            print("                ==> @ group #"..gi.." ("..match.."), token #"..tn.." ("..val..").")
            os.exit(1)
          end
        elseif tokExists(val) and self.Attr[val] then props = props:gsub(val, self.Attr[val])
        elseif tokExists(val) and not self.Attr[val] then
          -- Error: trying to use a color value outside FG() and BG() functions is not allowed
          print("[TermColors] Error: trying to use a color value outside FG() and BG() functions is not allowed.")
          print("                ==> @ group #"..gi.." ("..match.."), token #"..tn.." ("..val..").")
          os.exit(1)
        else
          -- Error: unknown property
          print("[TermColors] Error: unknown property '" .. val .. "'.")
          print("                ==> @ group #"..gi.." ("..match.."), token #"..tn.." ("..val..").")
          os.exit(1)
        end
      end

      return props
    end)

    tn = 0
    match = match:gsub("^(%#%{)", string.char(27).."["):gsub(";*%}$", "m")
    return match
  end)

  return str
end

function TermColors:print(str) print(self:compile(str or "")) end

return TermColors