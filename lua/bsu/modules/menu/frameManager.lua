-- menu/frameManager.lua by Bonyoze
-- Creates and manages showing the menu frames

function bsuMenu.create()
  -- main menu frame
  bsuMenu.frame = vgui.Create("DFrame")
	bsuMenu.frame:SetSize(ScrW() / 1.25, ScrH() / 1.25)
	bsuMenu.frame:SetPos(ScrW() / 2 - bsuMenu.frame:GetWide() / 2, ScrH() / 2 - bsuMenu.frame:GetTall() / 2)
	bsuMenu.frame:SetTitle("")
  bsuMenu.frame:SetDraggable(false)
	bsuMenu.frame:ShowCloseButton(false)

  bsuMenu.frame.Paint = function() end

  -- pages container
  bsuMenu.sheet = vgui.Create("DPropertySheet", bsuMenu.frame)
  bsuMenu.sheet:SetSize(bsuMenu.frame:GetWide(), bsuMenu.frame:GetTall())
  bsuMenu.sheet:SetPos(0, 0)

  bsuMenu.sheet.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 20, w, h - 20, Color(40, 40, 40))
    local padding = bsuMenu.sheet:GetPadding()
    draw.RoundedBox(0, padding, 20 + padding, w - padding * 2, h - 20 - padding * 2, Color(50, 50, 50))
  end
  bsuMenu.sheet.oldPaint = bsuMenu.sheet.Paint

  local tabOnPaint = function(self, w, h)
    draw.RoundedBoxEx(5, 0, 0, w, h, Color(40, 40, 40), true, true)
  end
  local tabOffPaint = function(self, w, h)
    draw.RoundedBoxEx(5, 0, 0, w, h, Color(10, 10, 10), true, true)
  end

  local pagesData = {} -- temp table

  function bsuMenu.addPage(index, name, pnl, icon)
    table.insert(pagesData, index, {
      name = name,
      pnl = pnl,
      icon = icon
    })
  end

  -- get the pages
  for _, file in ipairs(bsuMenu.pageFiles) do
    include(MENU_PAGES .. file)
  end

  -- add the pages
  for _, page in ipairs(pagesData) do
    page.pnl:SetParent(bsuMenu.sheet)
    local tab = bsuMenu.sheet:AddSheet(page.name, page.pnl, page.icon).Tab
    tab.Paint = tab:IsActive() and tabOnPaint or tabOffPaint
    tab.OnReleased = function(self)
      for _, v in ipairs(bsuMenu.sheet:GetItems()) do
        v.Tab.Paint = v.Tab == self and tabOnPaint or tabOffPaint
      end
    end
  end

  bsuMenu.hide()

  hook.Add("OnTextEntryGetFocus", "BSU_MenuFocus", function(pnl)
    if pnl:HasParent(bsuMenu.sheet) then
      bsuMenu.frame:SetKeyboardInputEnabled(true)
      pnl:RequestFocus()
    end
  end)

  hook.Add("OnTextEntryLoseFocus", "BSU_MenuUnfocus", function(pnl)
    if pnl:HasParent(bsuMenu.sheet) then
      bsuMenu.frame:SetKeyboardInputEnabled(false)
    end
  end)

  hook.Add("VGUIMousePressed", "BSU_BSU_MenuMouse", function(pnl, code)
    if not pnl:HasParent(bsuMenu.sheet) then
      bsuMenu.hide()
    elseif code == MOUSE_4 or code == MOUSE_5 then
      local active, items = bsuMenu.sheet:GetActiveTab(), bsuMenu.sheet:GetItems()
      for i = 1, #items do
        if items[i].Tab == active then
          local index = i + (code == MOUSE_4 and -1 or 1)
          if index >= 1 and index <= #items then
            local new = items[index].Tab
            bsuMenu.sheet:SetActiveTab(new)
            new:OnReleased()
          end
          break
        end
      end
    end
  end)
end

local blur = Material("pp/blurscreen")
function bsuMenu.blur(panel, layers, density, alpha)
	local x, y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (i / layers) * density)
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
	end
end

function bsuMenu.hide()
  local children = bsuMenu.frame:GetChildren()
	for _, pnl in pairs(children) do
		if pnl == bsuMenu.frame.btnMaxim or pnl == bsuMenu.frame.btnClose or pnl == bsuMenu.frame.btnMinim then continue end
		pnl:SetVisible(false)
	end

  bsuMenu.frame:SetMouseInputEnabled(false)
	bsuMenu.frame:SetKeyboardInputEnabled(false)
end

function bsuMenu.show()
  local children = bsuMenu.frame:GetChildren()
	for _, pnl in pairs(children) do
		if pnl == bsuMenu.frame.btnMaxim or pnl == bsuMenu.frame.btnClose or pnl == bsuMenu.frame.btnMinim then continue end
		pnl:SetVisible(true)
	end

  bsuMenu.frame:MakePopup()
  bsuMenu.frame:SetKeyboardInputEnabled(false)
end