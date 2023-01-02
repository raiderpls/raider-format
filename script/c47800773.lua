-- Hexorceress Spawn Inferno Golem
-- raider

local s, id = GetID()
function s.initial_effect(c)
	-- Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcFun2(c, s.matfilter, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x1e01), true)

	-- Attack all
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	-- ATK increase
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end

function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevel(4)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()

	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end