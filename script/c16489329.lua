-- True Crystron Selenrirax
-- raider
-- this took longer than it should have and im not even sure if abides by everything it should but whatever
-- crystrons best archetype btw
local s,id=GetID()
function s.initial_effect(c)
    -- Can only special summon once per turn
    c:SetSPSummonOnce(id)

    -- Must be ritual summoned before it can be pendulum or special summoned
	c:EnableReviveLimit()

    -- Pendulum Summoning
    Pendulum.AddProcedure(c)

    -- Pendulum Effect 1
    -- Activate 1 Crystron trap the turn it was set
    local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_PZONE)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xea))
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

    -- Monster Effect 1
    -- Pay 1000 LP to draw
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.drcost)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)

    -- Monster Effect 2
    -- Special summon when returned to extra deck
	local e3 = Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1, id+1)
	e3:SetCondition(s.condition3)
	e3:SetTarget(s.target3)
	e3:SetOperation(s.operation3)
	c:RegisterEffect(e3)

    -- Pendulum Effect 2
    -- Destroy monsters / banish crystron tuners that equal 5 to ritual summon
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end

s.listed_series={0xea}
s.listed_names={id}

function s.rescon(sg,e,tp,mg,c)
	local sum=sg:GetSum(Card.GetLevel)
	return aux.ChkfMMZ(1)(sg,nil,tp) and sum==5,sum>5
end

function s.cfilter(c)
	return (c:IsLocation(LOCATION_MZONE)) or (c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0xea) and c:IsType(TYPE_TUNER) and c:IsAbleToRemove())
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c = e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.cfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)

	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,0) end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.cfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)

	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,0) end
    local rg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon,nil,false)

    for tc in aux.Next(g) do
        if tc:IsLocation(LOCATION_ONFIELD) then
            Duel.Destroy(tc,REASON_EFFECT)

        elseif tc:IsLocation(LOCATION_GRAVE) then
	        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        end
    end

    c:SetMaterial(g)
    Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
    c:CompleteProcedure()
end

function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end

    Duel.PayLPCost(tp,1000)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)

    if Duel.Draw(p,d,REASON_EFFECT) ~= 0 then
		local tc=Duel.GetOperatedGroup():GetFirst()

		Duel.ConfirmCards(1-tp,tc)

		if tc:IsType(TYPE_TUNER) and Duel.IsPlayerCanDraw(tp,1) then
			local g = Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)

			Duel.SetTargetPlayer(tp)
            Duel.SetTargetParam(1)
            Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
            Duel.Draw(p,d,REASON_EFFECT)
		end

		Duel.ShuffleHand(tp)
	end
end

function s.condition3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP_ATTACK)
end

function s.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c = e:GetHandler()

    if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,nil,c) > 0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.operation3(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()

	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE) ~= 0 then
        if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) > 0 then
            local p = tp
            local g = Duel.SelectMatchingCard(p,nil,p,LOCATION_HAND,0,1,1,nil,nil)

            local tg = g:GetFirst()
            if tg then
                Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
            end
        end

        if Duel.GetFieldGroupCount(1-tp,0,LOCATION_HAND) > 0 then
            local p = 1-tp
            local g = Duel.SelectMatchingCard(p,nil,p,LOCATION_HAND,0,1,1,nil,nil)

            local tg = g:GetFirst()
            if tg then
                Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
            end
        end
    end
end