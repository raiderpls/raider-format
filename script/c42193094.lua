-- Banisher of the Shining
-- raider
local s,id=GetID()
function s.initial_effect(c)
	-- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2)

    -- Banish cards
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0xff,0xff)
    e1:SetTarget(s.rmtarget)
    e1:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e1)
end

function s.matfilter(c,lc,st,tp)
	return not c:IsType(TYPE_LINK,lc,st,tp)
end

function s.rmtarget(e,c)
    return Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end