-- Hexorceress Sage
-- raider

local s, id = GetID()
function s.initial_effect(c)
	-- On summon effect
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2 = e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3 = e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

	-- Discard to search
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1, id+1)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

s.listed_series = {0xe01, 0x1e01}
s.listed_names = {id}

function s.filter(c,e,tp)
	return c:IsSetCard(0x1e01) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and c:IsAttribute(e:GetHandler():GetAttribute())
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil, e, tp) end

	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)

	local group = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, 1, nil, e, tp)
	if #group > 0 then
		Duel.SpecialSummon(group, 0, tp, tp, false, false, POS_FACEUP)
	end
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end

	Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST+REASON_DISCARD)
end

function s.thfilter(c)
	return c:IsSetCard(0xe01) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end

	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)

	local group = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #group > 0 then
		Duel.SendtoHand(group, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, group)
	end
end