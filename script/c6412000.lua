-- Traptrix Forest
-- raider
local s,id=GetID()
function s.initial_effect(c)
	-- Search on activation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    -- Traptrix non-Xyzs are indestructable
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.target)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    c:RegisterEffect(e4)

    -- Pop a monster when a S/T leaves field
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_LEAVE_FIELD)
    e5:SetRange(LOCATION_SZONE)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCondition(s.condition)
    e5:SetTarget(s.target2)
    e5:SetOperation(s.operation)
    c:RegisterEffect(e5)
end

s.listed_series={0x108a}

function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x108a) and c:IsAbleToHand()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.target(e,c)
    return c:IsSetCard(0x108a) and c:GetRank() == 0
end

function s.cfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.filter(c,e,tp)
    return c:IsType(TYPE_MONSTER)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end