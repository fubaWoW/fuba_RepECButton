local addonName = ...
if not ReputationFrame then return end -- do not load addon if there is no ReputationFrame
local numFactions = 0

-- reduce global shown faction by 1 because it is relplaced by our button
NUM_FACTIONS_DISPLAYED = 14

-- MAYBE later in settings
local CollapsOnShow = false

-- Button
local ButtonName = "ReputationExpandOrCollapseAllButton"

-- function to check if Value is Numeric Value
local function IsNumeric(value)
  if type(value) == "number" then
    return true
  elseif type(value) ~= "string" then
    return false
  end
  value = strtrim(value)
  local x, y = string.find(value, "[%d+][%.?][%d*]")
  if x and x == 1 and y == strlen(value) then
    return true
  end
  return false
end

-- Check if ALL Faction Headers are Collapsed or not for Repheler "SortByStanding"
function CheckAllCollapsed_RPH()
  if RPH_Data and RPH_Data.SortByStanding then
    if RPH_Entries and RPH_Collapsed then
      for i=1, #RPH_Entries, 1 do
        if RPH_Entries[i] and (RPH_Entries[i].header) then
          local isCollapsed = RPH_Collapsed[RPH_Entries[i].i]
          if not isCollapsed then
            return false
          end
        end
      end
    end
  end
  return true
end

-- Check if ALL Faction Headers are Collapsed or not
local function CheckAllCollapsed()
  for i=1, NUM_FACTIONS_DISPLAYED, 1 do
    --local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(i)
    local isHeader, isCollapsed = select(9, GetFactionInfo(i))
    if isHeader then
      if not isCollapsed then
        return false
      end
    end
  end
  return true
end

-- Update Texture from ExpandOrCollapseButtonAll Button
local function UpdateIconTexture()
  local button = _G[ButtonName]
  if not button then return end

  if RPH_Data and RPH_Data.SortByStanding then
    collapsed = CheckAllCollapsed_RPH()
  else
    collapsed = CheckAllCollapsed()
  end
  if collapsed then
    if ElvUI then
      button:SetNormalTexture(ElvUI[1].Media.Textures.PlusButton)
    else
      button:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
    end
  else
    if ElvUI then
      button:SetNormalTexture(ElvUI[1].Media.Textures.MinusButton)
    else
      button:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
    end
  end
end

-- OnClick function for our Button
local function btnOnClick(self)
  numFactions = GetNumFactions()
  if RPH_Data and RPH_Data.SortByStanding then
    collapsed = CheckAllCollapsed_RPH()
    for i=1, numFactions, 1 do
      if RPH_Entries[i] and (RPH_Entries[i].header == true) then
        if collapsed then
          RPH_Collapsed[RPH_Entries[i].i] = nil
          RPH_ReputationFrame_Update()
        else
          RPH_Collapsed[RPH_Entries[i].i] = true
          RPH_ReputationFrame_Update()
        end
      end
    end
  else
    collapsed = CheckAllCollapsed()
    for i=1, numFactions, 1 do
      local ExpandOrCollapseButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
      local isHeader = select(9, GetFactionInfo(i))
      if ExpandOrCollapseButton then
        local index = ExpandOrCollapseButton:GetParent().index
        local isCollapsed = ExpandOrCollapseButton:GetParent().isCollapsed
        if (isCollapsed ~= nil) and IsNumeric(index) then
          if (collapsed) then
            ExpandFactionHeader(index)
          else
            CollapseFactionHeader(index)
          end
        end
      end
    end
  end
  UpdateIconTexture()
end

--hook the "RPH_OrderByStandingCheckBox" becasue it is possible there are no Repuations visible in "SortByStanding"
local f = CreateFrame("FRAME")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon, ...)
  if event == "ADDON_LOADED" and addon == "RepHelper"then
    if RPH_OrderByStandingCheckBox then
      RPH_OrderByStandingCheckBox:HookScript("OnClick", function (self)
        local button = _G[ButtonName]
        if not button then return end
        UpdateIconTexture()
        if RPH_Data.SortByStanding then
          if RPH_Entries and (#RPH_Entries == 0) then
            button:Hide()
          else
            button:Show()
          end
        else
          button:Show()
        end
      end)
    end
  end
end)

-- Hook OnClick of ReputationBar ExpandOrCollapseButtons if they are Headers
for i=1, NUM_FACTIONS_DISPLAYED, 1 do
  local ExpandOrCollapseButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
  local isHeader = select(9, GetFactionInfo(i))
  if ExpandOrCollapseButton and isHeader then
    ExpandOrCollapseButton:HookScript("OnClick", function(self)
      UpdateIconTexture()
    end)
  end
end

-- local variables to check later on
local collapsed = CheckAllCollapsed() or false

-- Move ReputationBar1 -23 in Y (default is -68)
-- the -23 come from "ReputationBarTemplate" Height (20) + Bar spacing (3) like all other bars have
ReputationListScrollFrame:HookScript("OnShow", function(self)
  ReputationBar1:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -50, -91)
end)

ReputationListScrollFrame:HookScript("OnHide", function(self)
  ReputationBar1:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -26, -91)
end)

ReputationBar15:HookScript("OnShow", function(self)
  self:Hide()
end)

-- Hook OnShow of the ReputationFrame for your MAIN function
ReputationFrame:HookScript("OnShow", function(self)
  local button = _G[ButtonName] or CreateFrame("Button", ButtonName, self)
  if not button then return end
  local buttonText = _G[ButtonName.."Text"] or button:CreateFontString(_G[ButtonName.."Text"], "OVERLAY", "GameFontNormal")
  buttonText:ClearAllPoints()
  buttonText:SetPoint("LEFT", button, "RIGHT", 3, 0)
  buttonText:SetText(_G.ALL)
  button.text = buttonText

  if CollapsOnShow then -- Collapse ALL Factions on login?
    numFactions = GetNumFactions()
    for i=1, numFactions, 1 do
      local ExpandOrCollapseButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
      if (ExpandOrCollapseButton) then
        local index = ExpandOrCollapseButton:GetParent().index
        if IsNumeric(index) then
          CollapseFactionHeader(index)
        end
      end
    end
  end

  button:ClearAllPoints()
  button:SetPoint("TOPLEFT", self, "TOPLEFT", 16, -71)

  button:SetWidth(16)
  button:SetHeight(16)
  button:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
  button:SetScript("OnClick", btnOnClick)

  UpdateIconTexture()
end)