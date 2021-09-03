-- Darklord Scorns of Sanctity
-- raider
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={0xef}

function s.filter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)

	if Duel.SendtoGrave(sg,REASON_EFFECT) ~= 0 then
		local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)

		if ct>0 then
			local level = sg:GetFirst():GetLevel()
			Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,level*200)
			Duel.Recover(tp,level*200,REASON_EFFECT)
		end
	end
end