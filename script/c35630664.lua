-- Crystal Gemini
-- raider

local s, id = GetID()
function s.initial_effect(c)
	-- Link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1034),2,2)

	-- Extra materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e0:SetTargetRange(LOCATION_SZONE,0)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)

	-- Cannot be used as link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	-- Attack boost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1034))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- Special summon a Crystal Beast from hand or GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetTarget(s.target1)
	e3:SetOperation(s.operation1)
	c:RegisterEffect(e3)

	-- Place a Crystal Beast from Deck to S/T Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e4:SetTarget(s.target2)
	e4:SetOperation(s.operation2)
	c:RegisterEffect(e4)
end

s.listed_series={0x1034}

--

function s.matfilter(c)
	return c:IsFaceup()
		and c:IsSetCard(0x1034)
		and c:GetSequence()<5
		and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
		and c:GetType()&(TYPE_SPELL+TYPE_CONTINUOUS)==TYPE_SPELL+TYPE_CONTINUOUS
end

function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_SZONE,0,nil)
		end
	end
end

--

function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*300
end

--

function s.filter1(c,e,tp,zone)
	return c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone = e:GetHandler():GetLinkedZone(tp)

	if chk == 0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
			and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp,zone)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local zone = e:GetHandler():GetLinkedZone(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp,zone)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end

--

function s.filter2(c)
	return c:IsSetCard(0x1034)
		and (not c:IsForbidden())
		and c:IsMonster()
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		Duel.RaiseEvent(tc,EVENT_CUSTOM+47408488,e,0,tp,0,0)
	end
end