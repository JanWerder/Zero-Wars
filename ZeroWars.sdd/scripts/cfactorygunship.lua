include "constants.lua"

local beam1, beam2 = piece("beam1", "beam2")
local post1, post2 = piece("post1", "post2")
local nano1, nano2 = piece("nano1", "nano2")
local base, pad = piece("base", "pad")

local nanoPieces = {beam1, beam2}
local smokePiece = {base}

local function Open()
    Signal(1)
    SetSignalMask(1)

    Move(post1, y_axis, 7, 21)
    Move(post1, y_axis, 7, 21)
    WaitForMove(post1, y_axis)

    Turn(nano1, z_axis, math.rad(-100), math.rad(175))
    Turn(nano2, z_axis, math.rad(100), math.rad(175))
    WaitForTurn(nano1, z_axis)

    Spin(pad, y_axis, math.rad(30), math.rad(1))

    SetUnitValue(COB.YARD_OPEN, 1)
    SetUnitValue(COB.INBUILDSTANCE, 1)
    SetUnitValue(COB.BUGGER_OFF, 1)
end

function script.Create()
    StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
    Spring.SetUnitNanoPieces(unitID, nanoPieces)
    Open()
end

local lastNanopiece = 1
function script.QueryNanoPiece()
    Spring.Echo("called at all? noice")
    lastNanopiece = 3 - lastNanopiece
    local nanoemit = nanoPieces[lastNanopiece]
    GG.LUPS.QueryNanoPiece(unitID, unitDefID, Spring.GetUnitTeam(unitID), nanoemit)
    return nanoemit
end

function script.QueryBuildInfo()
    return pad
end

local explodables = {nano1, nano2, post1, post2}
function script.Killed(recentDamage, maxHealth)
    local severity = recentDamage / maxHealth
    local brutal = (severity > 0.5)
    local sfx = SFX

    local effect = sfx.FALL + (brutal and (sfx.SMOKE + sfx.FIRE) or 0)
    for i = 1, #explodables do
        if math.random() < severity then
            Explode(explodables[i], effect)
        end
    end

    if not brutal then
        return 1
    else
        Explode(pad, sfx.SHATTER)
        Explode(base, sfx.SHATTER)
        return 2
    end
end