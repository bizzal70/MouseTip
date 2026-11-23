local addonName, ns = ...

-- The game puts tooltips for things in the world (creatures, players,
-- objects) in the bottom-right corner of the screen. This moves them to the
-- mouse cursor. Tooltips for buttons and items already sit beside what they
-- describe, and are left alone.

-- Where the tooltip sits relative to the cursor. x and y nudge it clear of
-- the pointer; the "above" anchor is centred by the game and takes none.
ns.POSITIONS = {
    { key = "above", label = "Above the cursor", anchor = "ANCHOR_CURSOR" },
    { key = "right", label = "To the right of the cursor", anchor = "ANCHOR_CURSOR_RIGHT", x = 24, y = 0 },
    { key = "left", label = "To the left of the cursor", anchor = "ANCHOR_CURSOR_LEFT", x = -24, y = 0 },
}

local defaults = {
    enabled = true,
    -- Whether tooltips also follow the mouse during combat.
    inCombat = true,
    position = "above",
    -- While a controller is what is being used: the lower right corner.
    padCorner = true,
}

-- Whether a controller is the input being used right now. The game says
-- so (GAME_PAD_ACTIVE_CHANGED) whenever it switches between the controller
-- and the mouse and keyboard; until then, the mouse is assumed.
ns.padActive = false

function ns.Print(msg)
    print("|cffd9a066MouseTip|r: " .. tostring(msg))
end

function ns.Position()
    for _, position in ipairs(ns.POSITIONS) do
        if position.key == ns.db.position then return position end
    end
    return ns.POSITIONS[1]
end

-- Runs after the game has given a tooltip its default place, and gives it a
-- place at the cursor instead.
local function MoveToCursor(tooltip, parent)
    local db = ns.db
    if not db or not db.enabled then return end
    if not db.inCombat and InCombatLockdown() then return end
    if tooltip.IsForbidden and tooltip:IsForbidden() then return end
    if db.padCorner and ns.padActive then
        -- Playing with a controller: there is no mouse pointer to follow,
        -- so the lower right corner of the screen, out of the way.
        pcall(function()
            tooltip:SetOwner(parent or UIParent, "ANCHOR_NONE")
            tooltip:ClearAllPoints()
            tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -(CONTAINER_OFFSET_X or 0) - 13, CONTAINER_OFFSET_Y or 0)
        end)
        return
    end
    local position = ns.Position()
    -- If the client refuses (it restricts some things in combat), the
    -- tooltip simply stays where the game put it.
    pcall(tooltip.SetOwner, tooltip, parent or UIParent, position.anchor, position.x or 0, position.y or 0)
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", MoveToCursor)

local function Describe()
    if not ns.db.enabled then
        return "Tooltips are in the game's usual place."
    end
    return ("Tooltips appear %s%s%s."):format(ns.Position().label:lower(),
        ns.db.inCombat and "" or ", except in combat",
        ns.db.padCorner and "; with a controller, in the lower right corner" or "")
end

SLASH_MOUSETIP1 = "/mousetip"
SLASH_MOUSETIP2 = "/mtip"
SlashCmdList.MOUSETIP = function(msg)
    local command = (msg or ""):lower():match("^%s*(%S*)")
    if command == "" or command == "options" then
        ns.ToggleOptions()
        return
    elseif command == "on" then
        ns.db.enabled = true
    elseif command == "off" then
        ns.db.enabled = false
    elseif command == "toggle" then
        ns.db.enabled = not ns.db.enabled
    elseif command == "combat" then
        ns.db.inCombat = not ns.db.inCombat
    elseif command == "pad" or command == "controller" or command == "gamepad" then
        ns.db.padCorner = not ns.db.padCorner
    elseif command == "above" or command == "right" or command == "left" then
        ns.db.position = command
    else
        ns.Print("/mousetip - open the options")
        ns.Print("/mousetip on, off or toggle - tooltips at the mouse, or in the game's usual place")
        ns.Print("/mousetip above, right or left - where the tooltip sits beside the cursor")
        ns.Print("/mousetip combat - whether tooltips also follow the mouse in combat")
        ns.Print("/mousetip pad - with a controller, tooltips in the lower right corner (on) or at the cursor")
        return
    end
    ns.Print(Describe())
    ns.RefreshOptions()
end

-- Entry in the minimap's addon list.
function MouseTip_OnAddonCompartmentClick()
    ns.ToggleOptions()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
pcall(frame.RegisterEvent, frame, "GAME_PAD_ACTIVE_CHANGED")
frame:SetScript("OnEvent", function(self, event, loaded)
    if event == "GAME_PAD_ACTIVE_CHANGED" then
        ns.padActive = loaded and true or false
        return
    end
    if loaded ~= addonName then return end
    MouseTipDB = MouseTipDB or {}
    for key, value in pairs(defaults) do
        if MouseTipDB[key] == nil then
            MouseTipDB[key] = value
        end
    end
    ns.db = MouseTipDB
    self:UnregisterEvent("ADDON_LOADED")
end)
