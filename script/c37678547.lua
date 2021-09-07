-- Nemesis Sanctuary Dragon
-- raider
local s,id=GetID()
function s.initial_effect(c)
	-- Xyz summon
	Xyz.AddProcedure(c,nil,5,3,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()

	-- Gain Attack on summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Detach to pop
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end

s.listed_series={0xd01}

function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(0xd01,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0) * 800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local exc=nil
    if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
    if #g>0 then
        Duel.HintSelection(g)
        Duel.Destroy(g,REASON_EFFECT)
    end
end
