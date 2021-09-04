-- Cosmic Space
-- raider
local s,id=GetID()
function s.initial_effect(c)
	-- Initial activation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Increase level on summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(s.val1)
	c:RegisterEffect(e2)

	-- Decrease levels in End Phase
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(EFFECT_UPDATE_LEVEL+EFFECT_UPDATE_RANK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetOperation(s.lvop2)
	c:RegisterEffect(e3)
end

function s.lvfilter(c)
	return c:IsFaceup() and (c:HasLevel() or c:GetRank() > 0)
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg and eg:IsExists(s.lvfilter,1,nil) end
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not eg then return end

	local g=eg:Filter(s.lvfilter,nil)

	if #g>0 then
		for tc in aux.Next(g) do
			local lv=2
			local e1=Effect.CreateEffect(c)

			if tc:HasLevel() then
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_LEVEL)
				e1:SetValue(lv)
				--e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)

			elseif tc:GetRank() > 0 then
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_RANK)
				e1:SetValue(lv)
				--e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end

function s.val1(e,c)
	local level = 0

	if c:HasLevel() then
		level = c:GetLevel()

	elseif c:GetRank() > 0 then
		level = c:GetRank()
	end

	return level * 200
end

function s.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)

	if #sg > 0 then
		for tc in aux.Next(sg) do
			local lv=-2
			local e1=Effect.CreateEffect(tc)

			if tc:HasLevel() then
				if tc:GetLevel() > 3 then
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_LEVEL)
					e1:SetValue(lv)
					--e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e1)

					if tc:GetLevel() <= 1 then
						Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
					end
				end

			elseif tc:GetRank() > 0 then
				if tc:GetRank() > 3 then
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_RANK)
					e1:SetValue(lv)
					--e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e1)

					if tc:GetRank() <= 1 then
						Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
					end
				end
			end
		end
	end
end