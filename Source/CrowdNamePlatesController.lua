---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by markg.
--- DateTime: 14/06/2021 15:15
---
local _Class, super = Class:create("CrowdEnemyNamePlatesController")
CrowdEnemyNamePlatesController = _Class

function CrowdEnemyNamePlatesController:Init()
    self = super.Init(self)
    self.enemyUnitsCastingSpell = {}
    return self
end

function CrowdEnemyNamePlatesController:OnEvent(event, arg1)
    if event == EVENT.PLAYER_TARGET_CHANGED then
        self:_OnPlayerTargetChanged()
        return
    end

    if event == EVENT.NAME_PLATE_UNIT_ADDED then
        self:_OnUnitNamePlateAdded(arg1)
        return
    end

    if event == EVENT.COMBAT_LOG_EVENT_UNFILTERED then
        self:_OnCombatLogEventUnfiltered()
        return
    end
end

function CrowdEnemyNamePlatesController:_OnPlayerTargetChanged()
    if self.lastPlayerTargetNamePlate and self.lastPlayerTargetNamePlate.namePlateUnitToken then
        local unitGUID = UnitGUID(self.lastPlayerTargetNamePlate.namePlateUnitToken)
        if self:_IsAnyEnemyUnitCastingSpell() and self.enemyUnitsCastingSpell[unitGUID] == nil then
            self.lastPlayerTargetNamePlate.UnitFrame:Hide()
        end
    end

    if not UnitCanAttack(UNIT.PLAYER, UNIT.TARGET) then
        return
    end

    local namePlate = C_NamePlate.GetNamePlateForUnit("target")
    if namePlate then
        self.lastPlayerTargetNamePlate = namePlate
    end
end

function CrowdEnemyNamePlatesController:_OnUnitNamePlateAdded(unit)
    local unitGUID = UnitGUID(unit)
    local targetNamePlate = C_NamePlate.GetNamePlateForUnit("target")
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)

    if self:_IsAnyEnemyUnitCastingSpell() and self.enemyUnitsCastingSpell[unitGUID] == nil and targetNamePlate ~= namePlate then
        namePlate.UnitFrame:Hide()
    end
end

function CrowdEnemyNamePlatesController:_OnCombatLogEventUnfiltered()
    local timestamp, eventType, hideCaster,
    srcGUID, srcName, srcFlags, srcFlags2,
    dstGUID, dstName, dstFlags, dstFlags2,
    spellID, spellName, arg3, arg4, arg5 = CombatLogGetCurrentEventInfo()

    local isSrcPlayer = bit.band(srcFlags, COMBATLOG_OBJECT_TYPE_PLAYER + COMBATLOG_OBJECT_TYPE_PET) > 0

    if eventType == COMBAT_LOG_EVENT.SPELL_CAST_START then
        if isSrcPlayer then
            return
        end
        self.enemyUnitsCastingSpell[srcGUID] = true
        local playerTargetNamePlate = C_NamePlate.GetNamePlateForUnit(UNIT.TARGET)
        for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
            local unitGUID = UnitGUID(frame.namePlateUnitToken)
            if unitGUID == srcGUID then
                frame.UnitFrame:Show()
            else

                -- Ignore hidding name plate which is current targeted by player
                -- or belongs to a enemy unit which also casting spell
                if self.enemyUnitsCastingSpell[unitGUID] == nil and playerTargetNamePlate ~= frame then
                    frame.UnitFrame:Hide()
                end
            end
        end
    end

    if eventType == COMBAT_LOG_EVENT.SPELL_CAST_FAILED
            or eventType == COMBAT_LOG_EVENT.SPELL_CAST_SUCCESS
            or eventType == COMBAT_LOG_EVENT.SPELL_INTERRUPT then
        if isSrcPlayer and eventType ~= COMBAT_LOG_EVENT.SPELL_INTERRUPT then
          return
        end

        local gUID = srcGUID
        if eventType == COMBAT_LOG_EVENT.SPELL_INTERRUPT then
            gUID = dstGUID
        end

        self.enemyUnitsCastingSpell[gUID] = nil
        local playerTargetNamePlate = C_NamePlate.GetNamePlateForUnit(UNIT.TARGET)

        for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
            local unitGUID = UnitGUID(frame.namePlateUnitToken)

            -- Hide the name plate which just finishes casting
            if unitGUID == gUID and self:_IsAnyEnemyUnitCastingSpell() and frame ~= playerTargetNamePlate then
                frame.UnitFrame:Hide()
            end

            -- Show all name plate when there are no enemy unit casts spell
            if not self:_IsAnyEnemyUnitCastingSpell() then
                frame.UnitFrame:Show()
            end
        end
    end
end

function CrowdEnemyNamePlatesController:_IsAnyEnemyUnitCastingSpell()
    local count = 0
    for _ in pairs(self.enemyUnitsCastingSpell) do count = count + 1 end
    return count > 0
end
