-- Hexorceress Spawn Marionette
-- raider

local s, id = GetID()
function s.initial_effect(c)
	-- Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcFun2(c, s.matfilter, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x1e01), true)

	-- Steal on summon
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	--e1:SetCountLimit(1, id)
	e1:SetCondition(s.con)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(4)
end

function s.con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return e:GetHandler():GetAttackAnnouncedCount() == 0 end

	local e1 = Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetLocation() == LOCATION_MZONE and chkc:GetControler() ~= tp and chkc:IsControlerCanBeChanged() end
	if chk == 0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged, tp, 0, LOCATION_MZONE, 1, nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local group = Duel.SelectTarget(tp, Card.IsControlerCanBeChanged, tp, 0, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_CONTROL, group, 1, 0, 0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc = Duel.GetFirstTarget()

	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc, tp)
	end
end
