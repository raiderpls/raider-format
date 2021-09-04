-- Drytron Contrails
-- raider
local s,id=GetID()
function s.initial_effect(c)
	-- Search Drytron lv1 when a monster is tributed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_RELEASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.scon)
	e1:SetTarget(s.stg)
	e1:SetOperation(s.sop)
	c:RegisterEffect(e1)
end

s.listed_series={0x151}
s.listed_names={id}

function s.sconfilter(c)
	return c:IsType(TYPE_MONSTER) or c:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER
end

function s.scon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sconfilter,1,nil)
end

function s.searchfilter(c)
	return c:IsSetCard(0x151) and c:IsType(TYPE_MONSTER) and c:HasLevel() and c:IsLevel(1)
end

function s.stg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.searchfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.sop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.searchfilter,tp,LOCATION_DECK,0,1,1,nil)

	if #g>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT) ~= 0 then
			Duel.ConfirmCards(1-tp,g)

			if Duel.GetLocationCount(tp,LOCATION_SZONE) > 0 and Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
				local g2 = Duel.GetMatchingGroup(s.acfilter,tp,LOCATION_HAND,0,nil)

				if #g2 > 0 then
					-- Activate Ritual Spell from hand
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
					local rs=g2:Select(tp,1,1,nil):GetFirst()
					local te,ceg,cep,cev,cre,cr,crp=rs:CheckActivateEffect(false,true,true)
					local op=te:GetOperation()
					Duel.MoveToField(rs,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
					if op then op(e,tp,eg,ep,ev,re,r,rp) end
					Duel.SendtoGrave(rs,REASON_RULE)
				end
			end
		end
	end

	-- Halve all damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,1-tp,1,0,aux.Stringid(id,1),nil)
end

function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end

function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.acfilter(c)
	local tp=c:GetControler()
	local te=c:GetActivateEffect()
	if c:IsHasEffect(EFFECT_CANNOT_TRIGGER) then return false end
	local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
	if pre[1] then
		for i,eff in ipairs(pre) do
			local prev=eff:GetValue()
			if type(prev)~='function' or prev(eff,te,tp) then return false end
		end
	end
	return c:IsRitualSpell() and c:CheckActivateEffect(false,false,false)~=nil
end

function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end

function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	local tpe=tc:GetType()
	local te=tc:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	local loc=LOCATION_SZONE
	if tpe&TYPE_FIELD~=0 then
		loc=LOCATION_FZONE
		local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if Duel.IsDuelType(DUEL_1_FIELD) then
			if fc then Duel.Destroy(fc,REASON_RULE) end
			fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		else
			fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		end
	end
	Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
	Duel.Hint(HINT_CARD,0,tc:GetCode())
	tc:CreateEffectRelation(te)
	if tpe&(TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
		tc:CancelToGrave(false)
	end
	if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
	if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
	Duel.BreakEffect()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g then
		local etc=g:GetFirst()
		while etc do
			etc:CreateEffectRelation(te)
			etc=g:GetNext()
		end
	end
	if op then op(te,tp,eg,ep,ev,re,r,rp) end
	tc:ReleaseEffectRelation(te)
	if etc then
		etc=g:GetFirst()
		while etc do
			etc:ReleaseEffectRelation(te)
			etc=g:GetNext()
		end
	end
end