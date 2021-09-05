-- Xekhinaga, El Shaddoll Krawlery
-- raider
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Send 1 Flip monster to Special Summon a Flip monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.sscost)
	e2:SetTarget(s.sstg)
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)

	-- Banish a Flip monster to negate a monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.ncost)
	e3:SetTarget(s.ntg)
	e3:SetOperation(s.nop)
	c:RegisterEffect(e3)
end

function s.sendfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_MZONE))
end

function s.banishfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsAbleToRemoveAsCost() and c:IsLocation(LOCATION_GRAVE)
end

local canSendFromHandField = function(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg = Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,e:GetHandler())

	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > -2 and #rg > 1 and aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),0) end

	local g = aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(g,REASON_COST)
end

local canBanishFromGrave = function(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg = Duel.GetMatchingGroup(s.banishfilter,tp,LOCATION_GRAVE,0,e:GetHandler())

	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and #rg > 1 end

	local g = aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then
		return canSendFromHandField(e,tp,eg,ep,ev,re,r,rp,chk) or canBanishFromGrave(e,tp,eg,ep,ev,re,r,rp,chk)
	end

	local options = {}
	if canSendFromHandField(e,tp,eg,ep,ev,re,r,rp,0) then table.insert(options, aux.Stringid(id, 0)) end
	if canBanishFromGrave(e,tp,eg,ep,ev,re,r,rp,0) then table.insert(options, aux.Stringid(id, 1)) end

	local chosenOption = 0
	if #options > 1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local sel = Duel.SelectOption(tp,table.unpack(options))+1
		chosenOption = options[sel]-aux.Stringid(id,0)

	else
		chosenOption = options[1]-aux.Stringid(id,0)
	end

	if chosenOption == 0 then canSendFromHandField(e,tp,eg,ep,ev,re,r,rp,chk) end
	if chosenOption == 1 then canBanishFromGrave(e,tp,eg,ep,ev,re,r,rp,chk) end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.sscfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsAbleToGraveAsCost()
end

function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sscfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.sscfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.ssfilter(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end

function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_DEFENSE) ~= 0 and Duel.IsPlayerCanDraw(tp,1) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

function s.nfilter(c)
	return c:IsFaceup() and not c:IsDisabled() and c:IsType(TYPE_EFFECT)
end

function s.ncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.banishfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.ntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.nfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.flfilter(c)
	return c:IsFacedown()
end

function s.nop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        -- Negate effects
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_DISABLE_EFFECT)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		if tc ~= c and Duel.IsExistingMatchingCard(s.flfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			local g2=Duel.SelectMatchingCard(tp,s.flfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,exc)
			if #g2>0 then
				local tc2 = g2:GetFirst()
				Duel.ChangePosition(tc2,POS_FACEUP_ATTACK)
			end
		end
	end
end