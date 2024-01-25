local _, RP = ...

-- Register Libs
local LCG = LibStub('LibCustomGlow-1.0')

-- CustomGlow
function RP:StartGlow(frame, glowType, ...)
	if (glowType == 'Pixel') then
		LCG.PixelGlow_Start(frame, ...)
	elseif (glowType == 'AutoCast') then
		LCG.AutoCastGlow_Start(frame, ...)
	end
end

function RP:StopGlow(frame, glowType)
	if (glowType == 'Pixel') then
		LCG.PixelGlow_Stop(frame)
	elseif (glowType == 'AutoCast') then
		LCG.AutoCastGlow_Stop(frame)
	end
end

-- Animation methods
function RP:CreateFlashAnimation(frame)
	local Flash = frame:CreateAnimationGroup()
	Flash:SetLooping('BOUNCE')

    local Anim = Flash:CreateAnimation('Alpha')
	Anim:SetFromAlpha(1)
	Anim:SetToAlpha(0.5)
	Anim:SetDuration(0.75)
	Anim:SetSmoothing('IN_OUT')

    frame.Flash = Flash
end

function RP:StartFlashAnim(frame)
	if not frame.Flash:IsPlaying() then
		frame.Flash:Play()
	end
end

function RP:StopFlashAnim(frame)
	if frame.Flash:IsPlaying() then
		frame.Flash:Stop()
	end
end

function RP:CreateTransAnimation(frame)
	local Trans = frame:CreateAnimationGroup()
    Trans:SetLooping('REPEAT')

    local Anim1 = Trans:CreateAnimation('Alpha')
    Anim1:SetTarget(frame)
    Anim1:SetOrder(1)
	Anim1:SetFromAlpha(0)
	Anim1:SetToAlpha(1)
	Anim1:SetDuration(0.25)
	Anim1:SetSmoothing('IN')

    local Anim2 = Trans:CreateAnimation('Translation')
    Anim2:SetTarget(frame)
    Anim2:SetOrder(2)
    Anim2:SetOffset(0, 6)
    Anim2:SetStartDelay(0.25)
    Anim2:SetDuration(0.75)
    Anim2:SetSmoothing('IN_OUT')

    local Anim3 = Trans:CreateAnimation('Alpha')
    Anim3:SetTarget(frame)
    Anim3:SetOrder(3)
	Anim3:SetFromAlpha(1)
	Anim3:SetToAlpha(0)
	Anim3:SetDuration(0.25)
	Anim3:SetSmoothing('OUT')

    frame.Trans = Trans
end

function RP:StartTransAnim(frame)
	if not frame.Trans:IsPlaying() then
		frame.Trans:Play()
	end
end

function RP:StopTransAnim(frame)
	if frame.Trans:IsPlaying() then
		frame.Trans:Stop()
	end
end