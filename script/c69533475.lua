-- Hexorceress Fusion
-- raider

local s, id = GetID()
function s.initial_effect(c)
	--Activate
	local e1 = Fusion.CreateSummonEff(c, nil, s.matfilter, s.fextra, s.extraop)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)

	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable, e1)
end

function s.fcheck(tp,sg,fc)
	if sg:IsExists(Card.IsLocation, 1, nil, LOCATION_GRAVE) then return sg:CheckSameProperty(Card.GetAttribute) end

	return true
end

function s.fextra(e,tp,mg)
	local eg = Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove), tp, LOCATION_GRAVE, 0, nil)

	if #eg > 0 --[[and (mg+eg):CheckSameProperty(Card.GetAttribute)]] then
		if #eg > 0 then
			return eg, s.fcheck
		end
	end

	return nil, s.fcheck
end

function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end