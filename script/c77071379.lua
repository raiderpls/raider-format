-- Hexorceress Spawn Puppeteers
-- raider

local s, id = GetID()
function s.initial_effect(c)
	-- Special Summon
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- On summon effect
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1, id+1)
	e2:SetCondition(s.oscon)
	e2:SetTarget(s.ostg)
	e2:SetOperation(s.osop)
	c:RegisterEffect(e2)
end

s.listed_names = {id}
s.listed_series = {0x1}

function s.spfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(4) and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end

	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.osfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0xe01) and c:IsAttribute(e:GetAttribute()) and c ~= e
end

function s.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.oscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.osfilter, tp, LOCATION_MZONE, 0, 1, nil, e:GetHandler()) and Duel.IsExistingTarget(s.stfilter, tp, 0, LOCATION_ONFIELD, 1, e:GetHandler())
end

function s.ostg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsType(TYPE_SPELL+TYPE_TRAP) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk == 0 then return Duel.IsExistingTarget(s.stfilter, tp, 0, LOCATION_ONFIELD, 1, e:GetHandler()) end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local group = Duel.SelectTarget(tp, s.stfilter, tp, 0, LOCATION_ONFIELD, 1, 1, e:GetHandler())
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, group, #group, 0, 0)
end

function s.osop(e,tp,eg,ep,ev,re,r,rp)
	local tc = Duel.GetFirstTarget()

	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc, REASON_EFFECT)
	end
end