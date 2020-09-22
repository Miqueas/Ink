--[[
  Author: Miqueas Martinez (miqueas2020@yahoo.com)
  Date: 2020/09/10
  License: MIT (see it in the repository)
  Git Repository: https://github.com/M1que4s/TermColors
]]

local TermColors = {}
local Tokens = {
  -- Attributes
  "None", "Bold", "Dim", "Italic", "Underline", "DobleU", "Blink", "Reverse", "Hidden", "Strike",
  -- Predefined colors
  "Black", "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White"
}

local function tokExists(val) -- Check if the given value is a valid token
  for i=1, #Tokens do
    if val == Tokens[i] then return true end
  end
  return false
end

local function split(str, sep) -- Like 'split()' in JS
  local sep = sep or "%s"
  local t = {}
  for e in str:gmatch("([^" .. sep .. "]+)") do t[#t+1] = e end
  return t
end

TermColors.ESC = string.char(27)
TermColors.Attr = { -- Text attributes
  None      = "0", Bold   = "1",
  Dim       = "2", Italic = "3",
  Underline = "4", Blink  = "5",
  Reverse   = "7", Hidden = "8",
  Strike    = "9", DobleU = "21" -- "Doble Underline"
}

TermColors.FG = { -- Predefined colors for foreground
  Black = "30", Red     = "31",
  Green = "32", Yellow  = "33",
  Blue  = "34", Magenta = "35",
  Cyan  = "36", White   = "37",
  FG    = "38"
}

TermColors.BG = { -- Predefined colors for background
  Black = "40", Red     = "41",
  Green = "42", Yellow  = "43",
  Blue  = "44", Magenta = "45",
  Cyan  = "46", White   = "47",
  BG    = "48"
}

function TermColors:compile(input)
  assert(type(input) == "string", "wrong input to 'compile()', string expected, got '" .. type(input) .. "'.")

  local gi = 0 -- "group index": Used to count the number of "style" groups in the string
  local tn = 0 -- "token number": Like 'gi', but for count the number of "style properties" in a group
  local esc = string.char(27)
  local str = input:gsub("(%#%{(.-)%})", function (match) -- Caught "style" groups in the input
    gi = gi + 1
    match = match:gsub("%s", "")
    match = match:gsub("%#%{(.-)%}", function (props)
      for _, val in pairs(split(props, ";")) do -- Split down all properties in separated values
        tn = tn + 1

        if val:match("%w%(.*%)") then -- Check if 'val' is a function
          local func, farg = val:match("(%w+)%((.*)%)") -- Gets the function name an their arguments
          local rgb = nil

          if farg:find("RGB") and farg:match("RGB%((%d+,%d+,%d+)%)") then
            farg = farg
              :gsub("[%(%)]", "") -- Remove parentheses
              :gsub("RGB", "2;") -- Replace the 'RGB' function name by the correct needed value
              :gsub(",", ";") -- ...
            rgb  = true
          elseif farg:find("RGB") and not farg:match("RGB%((%d+,%d+,%d+)%)") then
            -- Error: bad call to RGB() function
            error(
              ("Bad call to RGB() function.\n\t→ in input: %s\n\t→ in group #%s: %s\n\t→ in token #%s: %s")
              :format(input, gi, match, tn, val)
            )
          end

          if func == "FG" or func == "BG" then
            if not rgb then
              if tokExists(farg) then props = props:gsub(func .. "%(?" .. farg .. "%)?", self[func][farg])
              elseif farg:match("^(%d+)$") and not farg:find(",") and not farg:find("%a+") then
                if tonumber(farg) >= 0 and tonumber(farg) <= 255 then
                  props = props:gsub(func .. "%(?" .. farg .. "%)?", self[func][func] .. ";5;" .. farg)
                else
                  -- Error: 8-bit color value out of range
                  error(
                    ("8-bit color value out of range: %s.\n\t→ in input: %s\n\t→ in group #%s: %s\n\t→ in token #%s: %s")
                    :format(farg, input, gi, match, tn, val)
                  )
                end
              else
                -- Error: unknown pre-defined color
                error(
                  ("wrong color '%s'.\n\t→ in input: %s\n\t→ in group #%s: %s\n\t→ in token #%s: %s")
                  :format(farg, input, gi, match, tn, val)
                )
              end
            elseif rgb then
              props = props:gsub(func, self[func][func]..";2;")
                :gsub("[%(%)]+", "")
                :gsub("RGB", "")
                :gsub(",", ";")
            else
              -- Error: idk...
              error(
                  ("something's wrong...\n\t→ in input: %s\n\t→ in group #%s: %s\n\t→ in token #%s: %s")
                  :format(input, gi, match, tn, val)
                )
            end
          elseif func == "RGB" then
            -- Error: calling RGB() function outside FG() and BG() functions is not allowed
            error(
              ("calling RGB() outside FG() and BG() is not allowed\n\t→ in input: %s\n\t→ in group #%s: %s\n\t→ in token #%s: %s")
              :format(input, gi, match, tn, val)
            )
          else
            -- Error: unknown function name
            error(
              ("unknown function '%s'.\n\t→ in input: %s\n\t→ in group #%s: %s\n\t→ in token #%s: %s")
              :format(func, input, gi, match, tn, val)
            )
          end
        elseif tokExists(val) and self.Attr[val] then props = props:gsub(val, self.Attr[val])
        elseif tokExists(val) and not self.Attr[val] then
          -- Error: trying to use a color value outside FG() and BG() functions is not allowed
          error(
            ("trying to use a color value outside FG() and BG() functions is not allowed.\n\t→ in input: %s\n\t→ in group #%s: %s\n\t→ in token #%s: %s")
            :format(input, gi, match, tn, val)
          )
        else
          -- Error: unknown property
          error(
            ("unknown property '%s'.\n\t→ in input: %s\n\t→ in group #%s: %s\n\t→ in token #%s: %s")
            :format(val, input, gi, match, tn, val)
          )
        end
      end

      return props
    end)

    match = esc.."["..match.."m"
    tn = 0

    return match
  end)

  return str
end

function TermColors:print(str) print(self:compile(str or "")) end

return setmetatable(TermColors, { __call = TermColors.print })