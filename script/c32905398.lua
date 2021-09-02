-- Time Thief Nemesis
-- raider
local s,id=GetID()
function s.initial_effect(c)
	-- Setup Xyz summon
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()

	-- Attempt negate activation
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition1)
	--e1:SetCost(s.cost1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- Detach to reduce
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	--e2:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost2)
	--e2:SetTarget(s.tg)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end

function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer() ~= tp and rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

--[[
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x147,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x147,1,REASON_COST)
end
--]]

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end

	local thisCard = e:GetHandler()
	local activatedCard = re:GetHandler()

	Duel.ConfirmDecktop(tp,1)

	local g = Duel.GetDecktopGroup(tp,1)
	local tc = g:GetFirst()
	local opt = e:GetLabel()

	if thisCard:IsLocation(LOCATION_ONFIELD) then
		Duel.Overlay(thisCard, Group.FromCards(tc))

		if (activatedCard:IsType(TYPE_MONSTER) and tc:IsType(TYPE_MONSTER)) or (activatedCard:IsType(TYPE_SPELL) and tc:IsType(TYPE_SPELL)) or (activatedCard:IsType(TYPE_TRAP) and tc:IsType(TYPE_TRAP)) then
			Duel.NegateActivation(ev)
		end
	end
end

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c = e:GetHandler()
	local rt = math.min(c:GetOverlayCount(), 2)

	if chk==0 then return rt>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end

	c:RemoveOverlayCard(tp,1,rt,REASON_COST)

	local ct = Duel.GetOperatedGroup():GetCount()
	e:SetLabel(ct)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local g = Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc = g:GetFirst()

	local materialsDetached = e:GetLabel()

	for tc in aux.Next(g) do
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-materialsDetached * 400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2 = e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end

	if c:GetOverlayCount() == 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
		Duel.Remove(c, c:GetPosition(), REASON_EFFECT+REASON_TEMPORARY)
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END,2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END,2)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.returnToField)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.returnToField(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsLocation(LOCATION_REMOVED) and Duel.GetTurnPlayer() ~= tp then
		Duel.ReturnToField(e:GetLabelObject())
	end
end