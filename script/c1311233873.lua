-- Traptrix Darlingtonia
-- raider

local s,id=GetID()
function s.initial_effect(c)
	-- Must be properly summoned before reviving
	c:EnableReviveLimit()

	-- Link summon procedure
	Link.AddProcedure(c,s.matfilter,2,2)

	-- Unaffected by trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.immcon)
	e1:SetValue(s.efilter)

	-- Summon or set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, id)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Add when leaves the field
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1, id+1)
	e3:SetCondition(s.condition3)
	e3:SetTarget(s.target3)
	e3:SetOperation(s.operation3)
	c:RegisterEffect(e3)
end

-- Lists "Traptrix" and "Hole" archetypes
s.listed_series={0x108a,0x4c,0x89}

function s.matfilter(c,sc,st,tp)
	return c:IsRace(RACE_PLANT+RACE_INSECT,sc,st,tp)
end

-- If this card was link summoned
function s.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Unaffected by trap effects
function s.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end

-- Check for a "Traptrix" monster
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x108a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

-- Check for a "Hole" normal trap
function s.setfilter(c)
	return (c:IsSetCard(0x4c) or c:IsSetCard(0x89)) and c:GetType()==TYPE_TRAP and c:IsSSetable()
end

-- Check for either of the above
function s.trapfilter(c)
	return (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x108a) and c:IsAbleToHand()) or (c:GetType()==TYPE_TRAP and (c:IsSetCard(0x4c) or c:IsSetCard(0x89)) and c:IsAbleToHand())
end

-- Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local options = {}

	if chk == 0 then
		return true -- mandatory effect, must activate even if no valid targets
	end

	if Duel.GetLocationCount(tp,LOCATION_MZONE) > 0	and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) then table.insert(options, aux.Stringid(id,0)) end
	if Duel.GetLocationCount(tp,LOCATION_SZONE) > 0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) then table.insert(options, aux.Stringid(id,1)) end

	if #options == 0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sel = Duel.SelectOption(tp,table.unpack(options))+1
	local opt = options[sel]-aux.Stringid(id,0)

	if opt == 0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end

	e:SetLabel(opt)
end

-- Special Summon 1 "Traptrix" monster from Deck/GY
-- or Set 1 Trap Hole from Deck/GY
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local opt = e:GetLabel()

	if opt == 0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g = Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)

		if #g > 0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end

	elseif opt == 1 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g = Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)

		if #g > 0 then
			Duel.SSet(tp,g:GetFirst())
		end
	end
end

-- Activation legality
function s.condition3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)-- and not c:IsLocation(LOCATION_DECK)
end

function s.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- Add one traptrix or trap hole to hand
function s.operation3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.trapfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end