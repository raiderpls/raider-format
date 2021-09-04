-- Zoodiac Sheepherd
-- raider
local s,id=GetID()
function s.initial_effect(c)
	-- Xyz summon
	Xyz.AddProcedure(c,nil,4,4,s.ovfilter,aux.Stringid(id,0),99,s.xyzop)
	c:EnableReviveLimit()

	-- Boost ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.defval)
	c:RegisterEffect(e2)
	
	-- Reduce other monsters attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace, RACE_BEASTWARRIOR)))
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)

	-- Attach or set 1 Zoodiac S/T
	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.stg)
	e4:SetOperation(s.sop)
	c:RegisterEffect(e4)
end

s.listed_series={0xf1}

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(0xf1,lc,SUMMON_TYPE_XYZ,tp) and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end

function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end

function s.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end

function s.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(s.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end

function s.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end

function s.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(s.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end

function s.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.val(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(s.stfilter, nil)
	return g:GetCount() * -500
end

function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xf1)
end

function s.stg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end

function s.sop(e,tp,eg,ep,ev,re,r,rp)	
	local c=e:GetHandler()
	local tc=e:GetLabelObject()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()

	local options = {}
	if Duel.GetLocationCount(tp,LOCATION_SZONE) > 0 then table.insert(options, aux.Stringid(id,0)) end
	table.insert(options, aux.Stringid(id, 1))

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sel = Duel.SelectOption(tp,table.unpack(options))+1
	local opt = options[sel]-aux.Stringid(id,0)

	if opt == 0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE) > 0 then
			Duel.SSet(tp, g)
		end

	elseif opt == 1 then
		Duel.Overlay(c, Group.FromCards(g))
	end
end