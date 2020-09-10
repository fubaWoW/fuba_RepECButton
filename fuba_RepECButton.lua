local addonName = ...
if not ReputationFrame then return end -- do not load addon if there is no ReputationFrame
if NUM_FACTIONS_DISPLAYED < 2 then return end -- do not load addon if there are no Repuations (in case of... anything ^^)

-- MAYBE later in settings
local CollapsOnShow = false

-- Global Button Name
local ButtonName = "ReputationExpandOrCollapseButtonAll"

-- Backup Original Regions for ReputationBar1
local RB1_point, RB1_relativeTo, RB1_relativePoint, RB1_xOfs, RB1_yOfs = ReputationBar1:GetPoint()

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

-- Check if ALL Faction Headers are Collapsed or not
local function CheckAllCollapsed()
  for i=1, NUM_FACTIONS_DISPLAYED, 1 do
    local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(i);
    if isHeader then
      if not isCollapsed then
        return false
      end
    end
  end
  return true
end

-- local variables to check later on
local collapsed = CheckAllCollapsed()

-- Update Texture from ExpandOrCollapseButtonAll Button
local function UpdateIconTexture()
  local button = _G[ButtonName];
  if not button then return end
	collapsed = CheckAllCollapsed()
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

-- Hook OnClick of ReputationBar ExpandOrCollapseButtons if they are Headers
for i=1, NUM_FACTIONS_DISPLAYED, 1 do
  local ExpandOrCollapseButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"];
  local isHeader = select(9, GetFactionInfo(i));
  if ExpandOrCollapseButton and isHeader then
    ExpandOrCollapseButton:HookScript("OnClick", function(self)
      collapsed = CheckAllCollapsed()
      UpdateIconTexture()
    end)
  end
end

-- OnClick function for our Button
local function btnOnClick(self)
  for i=1, NUM_FACTIONS_DISPLAYED, 1 do
    local ExpandOrCollapseButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"];
		local isHeader = select(9, GetFactionInfo(i));
    if ExpandOrCollapseButton and isHeader then
      local index = ExpandOrCollapseButton:GetParent().index
      if IsNumeric(index) then
        if (collapsed) then
          ExpandFactionHeader(index);
        else
          CollapseFactionHeader(index);
        end
      end
    end
  end
  collapsed = CheckAllCollapsed()
  UpdateIconTexture()
end

-- Move ReputationBar1 -23 in Y (default is -68)
-- the -23 come from "ReputationBarTemplate" Height (20) + Bar spacing (3) like all other bars have
ReputationListScrollFrame:HookScript("OnShow", function(self)
  ReputationBar1:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -50, -91);
end)

ReputationListScrollFrame:HookScript("OnHide", function(self)
  ReputationBar1:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -26, -91);
end)

-- Hook OnShow of the ReputationFrame for your MAIN function
ReputationFrame:HookScript("OnShow", function(self)
  local btn = _G[ButtonName] or CreateFrame("Button", ButtonName, self)

  if CollapsOnShow then -- Collapse ALL Factions on
    for i=1, NUM_FACTIONS_DISPLAYED, 1 do
      local ExpandOrCollapseButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"];
      if (ExpandOrCollapseButton) then
        local index = ExpandOrCollapseButton:GetParent().index
        if IsNumeric(index) then
          CollapseFactionHeader(index);
        end
      end
  end
  collapsed = CheckAllCollapsed()
  end

  btn:SetWidth(16)
  btn:SetHeight(16)
  btn:ClearAllPoints()
  btn:SetPoint("LEFT", ReputationBar1, "LEFT", 6, 22);

  local btnText = _G[ButtonName.."Text"] or btn:CreateFontString(_G[ButtonName.."Text"], "OVERLAY", "GameFontNormal")
  btnText:ClearAllPoints()
  btnText:SetPoint("LEFT", btn, "RIGHT", 3, 0)
  btnText:SetText(_G.ALL)
  btn.text = btnText;

  UpdateIconTexture()
  btn:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD");
  btn:SetScript("OnClick", btnOnClick)
end)