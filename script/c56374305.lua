-- Hexorceress Kingdom
-- raider
-- there is probably a better way to do this but whatever

local s, id = GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	-- Normal Summon 1 "Hexorceress" monster from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)

	-- Attribute change
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetCode(EFFECT_ADD_ATTRIBUTE)
	e3:SetValue(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK|ATTRIBUTE_FIRE)
	e3:SetTarget(s.atrtg)
	c:RegisterEffect(e3)

	-- Apply attribute based effects
	-- LIGHT --
	-- Boost DEF
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.lighttg)
	e4:SetValue(s.atkdefval)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(s.lighttg)
	e5:SetValue(s.valcon)
	e5:SetCountLimit(1)
	c:RegisterEffect(e5)

	-- DARK --
	-- Unaffected by traps
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTarget(s.darktg)
	e6:SetValue(s.immfilter)
	c:RegisterEffect(e6)

	-- FIRE --
	-- Boost ATK
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e7:SetTarget(s.firetg)
	e7:SetValue(s.atkdefval)
	c:RegisterEffect(e7)

	-- Piercing battle damage
	-- changed this cause idk how to get it to work for both players
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_PIERCE)
	e8:SetRange(LOCATION_FZONE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(s.firetg)
	c:RegisterEffect(e8)
end

s.listed_series={0xe01}

function s.nsfilter(c)
	return c:IsSetCard(0xe01) and c:IsSummonable(true,nil)
end

function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end

	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end

function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g = Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc = g:GetFirst()

	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end

function s.atrtg(e,c)
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		local eff
		if c:IsLocation(LOCATION_MZONE) then
			eff={Duel.GetPlayerEffect(c:GetControler(),EFFECT_NECRO_VALLEY)}
		else
			eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		end
		c:ResetFlagEffect(1)
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return true
end

-- light
function s.lighttg(e,c)
	return c:GetOriginalAttribute() == ATTRIBUTE_LIGHT
end

function s.atkdefval(e,c)
	if c:HasLevel() then
		return c:GetLevel()*100
	end

	return 0
end

function s.valcon(e,re,r,rp)
	return r == REASON_BATTLE
end

-- dark

function s.darktg(e,c)
	return c:GetOriginalAttribute() == ATTRIBUTE_DARK
end

function s.immfilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end

-- fire
function s.firetg(e,c)
	return c:GetOriginalAttribute() == ATTRIBUTE_FIRE
end