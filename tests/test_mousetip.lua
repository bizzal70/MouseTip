-- The game's own function: it gives a tooltip its default place in the
-- corner of the screen. It must exist before the addon loads and hooks it.
function GameTooltip_SetDefaultAnchor(tooltip, parent)
    tooltip:SetOwner(parent, "ANCHOR_NONE")
end

local ns = LoadAddon(ADDON_DIR, "MouseTip")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function hover() GameTooltip_SetDefaultAnchor(GameTooltip, UIParent); return GameTooltip.__owner end

check(hover()[2] == "ANCHOR_NONE", "before its settings load, the addon leaves tooltips alone")

Fire("ADDON_LOADED", "SomeOtherAddon")
check(MouseTipDB == nil, "another addon loading does not set it up")
Fire("ADDON_LOADED", "MouseTip")
check(MouseTipDB and ns.db == MouseTipDB and ns.db.enabled and ns.db.inCombat and ns.db.position == "above", "settings start with their defaults")

local owner = hover()
check(owner[1] == UIParent and owner[2] == "ANCHOR_CURSOR", "a world tooltip is moved to the cursor")

SlashCmdList.MOUSETIP("right")
owner = hover()
check(owner[2] == "ANCHOR_CURSOR_RIGHT" and owner[3] == 24, "it can sit to the right of the cursor, nudged clear of the pointer")
SlashCmdList.MOUSETIP("left")
check(hover()[2] == "ANCHOR_CURSOR_LEFT", "or to the left")
SlashCmdList.MOUSETIP("above")

SlashCmdList.MOUSETIP("off")
check(hover()[2] == "ANCHOR_NONE" and not ns.db.enabled, "/mousetip off puts tooltips back in the game's place")
SlashCmdList.MOUSETIP("toggle")
check(hover()[2] == "ANCHOR_CURSOR" and ns.db.enabled, "/mousetip toggle turns it back on")

SlashCmdList.MOUSETIP("combat")
IN_COMBAT = true
check(hover()[2] == "ANCHOR_NONE", "with combat turned off, tooltips stay put during a fight")
IN_COMBAT = false
check(hover()[2] == "ANCHOR_CURSOR", "and follow the mouse again afterwards")
SlashCmdList.MOUSETIP("combat")
IN_COMBAT = true
check(hover()[2] == "ANCHOR_CURSOR", "with combat turned on, they follow the mouse in a fight too")
IN_COMBAT = false

-- a tooltip the client will not let addons touch
local forbidden = { IsForbidden = function() return true end }
function forbidden:SetOwner(...) self.__owner = { ... } end
GameTooltip_SetDefaultAnchor(forbidden, UIParent)
check(forbidden.__owner[2] == "ANCHOR_NONE", "a tooltip the client protects is left alone")

-- a tooltip that errors when moved must not break the game's own call
local fragile = {}
function fragile:SetOwner(_, anchor) if anchor ~= "ANCHOR_NONE" then error("refused") end; self.placed = true end
GameTooltip_SetDefaultAnchor(fragile, UIParent)
check(fragile.placed, "if the client refuses the move, nothing breaks")

-- options window
SlashCmdList.MOUSETIP("")
check(MouseTipOptions:IsShown(), "/mousetip opens the options")
local before = { ns.db.enabled, ns.db.inCombat, ns.db.position }
local rows = {}
for _, f in ipairs(Frames()) do
    if rawget(f, "Refresh") and f.__scripts.OnClick then rows[#rows + 1] = f end
end
check(#rows == 4, "the options have four controls")
rows[1].__scripts.OnClick(rows[1]); check(ns.db.enabled ~= before[1], "the first switches the addon off and on")
rows[1].__scripts.OnClick(rows[1])
rows[2].__scripts.OnClick(rows[2]); check(ns.db.inCombat ~= before[2], "the second switches combat")
rows[2].__scripts.OnClick(rows[2])
rows[3].__scripts.OnClick(rows[3]); check(ns.db.padCorner == false, "the third switches the controller corner")
rows[3].__scripts.OnClick(rows[3])
rows[4].__scripts.OnClick(rows[4]); check(ns.db.position == "right", "the fourth steps to the next position")
rows[4].__scripts.OnClick(rows[4]); rows[4].__scripts.OnClick(rows[4])
check(ns.db.position == "above", "and comes back round to the first")
MouseTip_OnAddonCompartmentClick()
check(not MouseTipOptions:IsShown(), "the minimap addon list entry toggles the options")
SlashCmdList.MOUSETIP("help")

-- saved settings are kept, and missing ones filled in
MouseTipDB = nil
local ns2 = LoadAddon(ADDON_DIR, "MouseTip")
MouseTipDB = { enabled = false }
Fire("ADDON_LOADED", "MouseTip")
check(ns2.db.enabled == false and ns2.db.position == "above", "saved choices are kept and new settings get defaults")

-- The controller's B button closes the addon's windows while they are shown.
do
    local bound = {}
    SetOverrideBinding = function(owner, _, key, command) bound[owner] = { key = key, command = command } end
    ClearOverrideBindings = function(owner) bound[owner] = nil end
    local w = CreateFrame("Frame", "PadCloseTestWindow", UIParent)
    w.HookScript = function(self, event, fn)
        local previous = self.__scripts[event]
        self.__scripts[event] = previous and function(...) previous(...); fn(...) end or fn
    end
    w:Hide()
    ns.CloseWithPadB(w, "PadCloseTestWindow")
    w:Show(); w.__scripts.OnShow(w)
    check(bound[w] and bound[w].key == "PAD2" and bound[w].command == "CLICK PadCloseTestWindowPadClose:LeftButton",
        "while a window is shown, the controller's B button is set to close it")
    w.padClose.__scripts.OnClick(w.padClose)
    check(not w:IsShown(), "pressing B closes it")
    w.__scripts.OnHide(w)
    check(bound[w] == nil, "and B gets its usual job back once it is closed")
end

-- When a fight starts, B is handed back at once, even with the window open.
do
    local bound = {}
    SetOverrideBinding = function(owner, _, key) bound[owner] = key end
    ClearOverrideBindings = function(owner) bound[owner] = nil end
    local w = CreateFrame("Frame", "PadFightTestWindow", UIParent)
    w.HookScript = function(self, event, fn)
        local previous = self.__scripts[event]
        self.__scripts[event] = previous and function(...) previous(...); fn(...) end or fn
    end
    w.GetName = function() return "PadFightTestWindow" end
    w:Hide()
    ns.CloseWithPadB(w, "PadFightTestWindow")
    w:Show(); w.__scripts.OnShow(w)
    check(bound[w] == "PAD2", "with the window open, B closes it")
    Fire("PLAYER_REGEN_DISABLED")
    check(bound[w] == nil, "when a fight starts, B is handed back at once")
    Fire("PLAYER_REGEN_ENABLED")
    check(bound[w] == "PAD2", "and borrowed again once the fight is over")
    w:Hide(); w.__scripts.OnHide(w)
end

-- With a controller, tooltips go to the lower right corner by default.
do
    local ns3 = ns2
    check(ns3.db.padCorner == true, "the controller corner is on by default")
    ns3.db.enabled = true
    Fire("GAME_PAD_ACTIVE_CHANGED", true)
    local placed
    local tip = { SetOwner = function(self, ...) self.__owner = { ... } end, ClearAllPoints = function() end,
        SetPoint = function(_, ...) placed = { ... } end }
    GameTooltip_SetDefaultAnchor(tip, UIParent)
    check(tip.__owner[2] == "ANCHOR_NONE" and placed and placed[1] == "BOTTOMRIGHT" and placed[3] == "BOTTOMRIGHT",
        "using a controller puts world tooltips in the lower right corner")
    Fire("GAME_PAD_ACTIVE_CHANGED", false)
    GameTooltip_SetDefaultAnchor(tip, UIParent)
    check(tip.__owner[2] == "ANCHOR_CURSOR", "back on the mouse, they follow the cursor again")
    SlashCmdList.MOUSETIP("pad")
    Fire("GAME_PAD_ACTIVE_CHANGED", true)
    GameTooltip_SetDefaultAnchor(tip, UIParent)
    check(ns3.db.padCorner == false and tip.__owner[2] == "ANCHOR_CURSOR", "/mousetip pad turns the corner off: the cursor even with a controller")
    Fire("GAME_PAD_ACTIVE_CHANGED", false)
end
