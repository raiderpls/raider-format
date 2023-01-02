-- Hexorceress Spawn Elephental
-- raider

local s, id = GetID()
function s.initial_effect(c)
	-- Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcFun2(c, s.matfilter, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x1e01), true)

	-- Boost during damage step
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetCondition(s.condition)
	e1:SetValue(500)
	c:RegisterEffect(e1)

	-- Attack magnet
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0, LOCATION_MZONE)
	e2:SetValue(s.attg)
	c:RegisterEffect(e2)
end

function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4)
end

function s.condition(e)
    local ph = Duel.GetCurrentPhase()

    if not (ph == PHASE_DAMAGE or ph == PHASE_DAMAGE_CAL) then return false end

    local a = Duel.GetAttacker()
    local d = Duel.GetAttackTarget()

    return (a == e:GetHandler() and d and d:IsFaceup()) or (d == e:GetHandler())
end

function s.attg(e,c)
	return c:IsCode(id)
end