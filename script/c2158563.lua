-- Bursting Tornado
-- raider
local s,id=GetID()
function s.initial_effect(c)
	-- Destroy S/T
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetCost(s.adcost)
	e1:SetTarget(s.adtg)
	e1:SetOperation(s.adop)
	c:RegisterEffect(e1)
end

function s.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
	local tc = Duel.GetFirstTarget()

    if tc and tc:IsRelateToEffect(e) then
        if Duel.Destroy(tc,REASON_EFFECT) ~= 0 then
            local g = Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)

            if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
                Duel.ShuffleHand(tp)
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
                local sg=g:Select(tp,1,1,nil)
                Duel.SSet(tp,sg:GetFirst(),tp,false)
            end
        end
    end
end