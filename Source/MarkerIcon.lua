---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by markg.
--- DateTime: 14/06/2021 14:43
---

local MARKER_ICON_TYPE = {
    ATTACK = 1,
    CROSSHAIRS = 2
}

local _Class, super = Class:create("MarkerIcon")
MarkerIcon = _Class

function MarkerIcon:Init(owner, size, point)
    self = super.Init(self)

    local texture = owner:CreateTexture(nil, "ARTWORK")
    texture:SetSize(size, size)
    texture:SetPoint(unpack(point))

    self.texture = texture

    return self
end

function MarkerIcon:Show()
    local type = self:_GetType()

    self.texture:Show()
    if type == MARKER_ICON_TYPE.CROSSHAIRS then
        self.texture:SetTexture("Interface\\CURSOR\\Crosshairs")
    end

    if type == MARKER_ICON_TYPE.ATTACK then
        self.texture:SetTexture("Interface\\CURSOR\\Attack")
    end
end

function MarkerIcon:Hide()
    self.texture:Hide()
end

function MarkerIcon:_GetType()
    if IsPlayerAttacking("target") then
        return MARKER_ICON_TYPE.ATTACK
    else
        return MARKER_ICON_TYPE.CROSSHAIRS
    end
end