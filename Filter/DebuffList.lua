--[[
    oUF_RaidDebuffs List
    A table of spellIDs to create icons for.
    To add spellIDs, look up a spell on www.wowhead.com and look at the URL:
    https://www.wowhead.com/wotlk/spell=SPELLID
    https://www.wowhead.com/wotlk/cn/spell=SPELLID
--]]

local _, ns = ...

-- oUF_Nihlathak
local N = ns.N
local ORD = N.oUF_RaidDebuffs

local function List(priority)
	return {
		enable = true,
		priority = priority or 0,
		stackThreshold = 0
	}
end

local DebuffList = {
-- Global
    [1604]  = List(),  -- Dazed                 -- 眩晕
    [8326]  = List(),  -- Ghost                 -- 鬼魂
    [15007] = List(),  -- Resurrection Sickness -- 复活虚弱
    [25771] = List(),  -- Forbearance           -- 自律
    [66233] = List(1), -- Ardent Defender       -- 炽热防御者

-- Naxxramas 纳克萨玛斯
    -- Anub'Rekhan
    [54022] = List(), -- Locust Swarm
    [56098] = List(), -- Acid Spit
    -- Grand Widow Faerlina
    [54099] = List(), -- Rain of Fire
    [54098] = List(), -- Poison Bolt Volley
    -- Maexxna
    [54121] = List(), -- Necrotic Poison 1
    [28776] = List(), -- Necrotic Poison 2
    [28622] = List(), -- Web Wrap
    [54125] = List(), -- Web Spray
    -- Noth the Plaguebringer
    [54835] = List(), -- Curse of the Plaguebringer
    [54814] = List(), -- Cripple 1
    [29212] = List(), -- Cripple 2
    -- Heigan the Unclean
    [55011] = List(), -- Decrepit Fever
    -- Loatheb
    [29232] = List(), -- Fungal Creep
    [55052] = List(), -- Inevitable Doom
    [55053] = List(), -- Deathbloom
    -- Instructor Razuvious
    [55550] = List(), -- Jagged Knife
    [55470] = List(), -- Unbalancing Strike
    -- Gothik the Harvester
    [55646] = List(), -- Drain Life
    [55645] = List(), -- Death Plague
    [28679] = List(), -- Harvest Soul
    -- The Four Horsemen
    [57369] = List(), -- Unholy Shadow
    [28832] = List(), -- Mark of Korth'azz
    [28835] = List(), -- Mark of Zeliek
    [28833] = List(), -- Mark of Blaumeux
    [28834] = List(), -- Mark of Rivendare
    -- Patchwerk
    [28801] = List(), -- Slime / Not really Encounter related
    -- Grobbulus
    [28169] = List(), -- Mutating Injection
    -- Gluth
    [54378] = List(), -- Mortal Wound
    [29306] = List(), -- Infected Wound
    -- Thaddius
    [28084] = List(), -- Negative Charge (-)
    [28059] = List(), -- Positive Charge (+)
    -- Sapphiron
    [28522] = List(), -- Icebolt
    [55665] = List(), -- Life Drain
    [28547] = List(), -- Chill 1
    [55699] = List(), -- Chill 2
    -- Kel'Thuzad
    [55807] = List(), -- Frostbolt 1
    [55802] = List(), -- Frostbolt 2
    [27808] = List(), -- Frost Blast
    [28410] = List(), -- Chains of Kel'Thuzad

-- The Eye of Eternity
    -- Malygos
    [56272] = List(), -- Arcane Breath
    [55853] = List(), -- Vortex 1
    [56263] = List(), -- Vortex 2
    [57407] = List(), -- Surge of Power
    [57429] = List(), -- Static Field

-- The Obsidian Sanctum
    -- Sartharion
    [60708] = List(4), -- Fade Armor
    [56910] = List(5), -- Tail Lash
    [57874] = List(5), -- Twilight Shift
    [57491] = List(6), -- Flame Tsunami

-- Ulduar
    -- Flame Leviathan
    [62376] = List(3), -- Battering Ram
    [62374] = List(4), -- Pursued
    -- Ignis the Furnace Master
    [64706] = List(3), -- Flame Buffet
    [62717] = List(4), -- Slag Pot
    -- Razorscale
    [64771] = List(5), -- Fuse Armor
    [64757] = List(3), -- Stormstrike
    -- XT-002 Deconstructor
    [63018] = List(4), -- Searing Light
    [63024] = List(5), -- Gravity Bomb
    -- Assembly of Iron
    [61886] = List(3), -- Lightning Tendrils
    [61878] = List(4), -- Overload
    [62269] = List(3), -- Rune of Death
    [61903] = List(5), -- Fusion Punch
    [61888] = List(4), -- Overwhelming Power
    [44008] = List(3), -- Static Disruption
    -- Kologarn
    [63355] = List(4), -- Crunch Armor
    [64290] = List(5), -- Stone Grip
    [63978] = List(3), -- Stone Nova
    -- Auriaya
    [64669] = List(5), -- Feral Pounce
    [64496] = List(3), -- Feral Rush
    [64396] = List(5), -- Guardian Swarm
    [64667] = List(3), -- Rip Flesh
    [64666] = List(4), -- Savage Pounce
    [64389] = List(3), -- Sentinel Blast
    -- Freya
    [62243] = List(3), -- Unstable Sun Beam
    [62310] = List(3), -- Impale
    [62438] = List(4), -- Iron Roots
    [62283] = List(4), -- Iron Roots
    [62930] = List(3), -- Iron Roots
    [62354] = List(4), -- Broken Bones
    [63571] = List(3), -- Nature's Fury
    -- Hodir
    [62039] = List(3), -- Biting Cold
    [61969] = List(5), -- Flash Freeze
    [62469] = List(4), -- Freeze
    -- Mimiron
    [63666] = List(3), -- Napalm Shell
    [65026] = List(3), -- Napalm Shell
    [64616] = List(3), -- Deafening Siren
    [64668] = List(4), -- Magnetic Field
    -- Thorim
    [62415] = List(3), -- Acid Breath
    [62318] = List(3), -- Barbed Shot
    [62576] = List(3), -- Blizzard
    [32323] = List(3), -- Charge
    [64971] = List(3), -- Electro Shock
    [62605] = List(3), -- Frost Nova
    [64970] = List(3), -- Fuse Lightning
    [62418] = List(5), -- Impale
    [35054] = List(3), -- Mortal Strike
    [62420] = List(4), -- Shield Smash
    [62042] = List(4), -- Stormhammer
    [57807] = List(3), -- Sunder Armor
    [62417] = List(3), -- Sweep
    [62130] = List(5), -- Unbalancing Strike
    [64151] = List(4), -- Whirling Trip
    [40652] = List(3), -- Wing Clip
    -- General Vezax
    [63276] = List(4), -- Mark of the Faceless
    [63420] = List(3), -- Profound Darkness
    -- Yogg-Saron
    [63120] = List(4), -- Insane
    [63802] = List(4), -- Brain Link
    [64157] = List(4), -- Curse of Doom
    [63830] = List(3), -- Malady of the Mind
    [63138] = List(4), -- Sara's Fervor
    [63134] = List(5), -- Sara's Blessing
    [64126] = List(5), -- Squeeze
    -- Algalon the Observer
    [64412] = List(3), -- Phase Punch

-- Trial of the Grand Crusader
    -- Northrend Beasts
    [66331] = List(3), -- Impale
    [66406] = List(3), -- Snobolled!
    [66407] = List(3), -- Head Crack
    [66823] = List(3), -- Paralytic Toxin
    [66830] = List(4), -- Paralysis
    [66869] = List(3), -- Burning Bile
    [66689] = List(3), -- Arctic Breath
    [66758] = List(3), -- Staggered Daze
    [66770] = List(4), -- Ferocious Butt
    -- Lord Jaraxxus
    [66334] = List(3), -- Mistress' Kiss
    [66532] = List(3), -- Fel Fireball
    [66197] = List(4), -- Legion Flame
    [66199] = List(4), -- Legion Flame
    [66237] = List(5), -- Incinerate Flesh
    -- Faction Champions
    [65812] = List(3), -- Unstable Affliction
    [65813] = List(4), -- Unstable Affliction
    [65866] = List(3), -- Explosive Shot
    [66017] = List(3), -- Death Grip
    -- Twin Val'kyr
    [65950] = List(3), -- Touch of Light
    [66001] = List(3), -- Touch of Darkness
    -- Anub'arak
    [66012] = List(3), -- Freezing Slash
    [67721] = List(3), -- Expose Weakness
    [65775] = List(3), -- Acid-Drenched Mandibles
    [66013] = List(4), -- Penetrating Cold
    [67574] = List(5), -- Pursued by Anub'arak
-- PvP --
    -- Warrior
    [5246]  = List(4), -- Intimidating Shout    -- 破胆怒吼
    [25212] = List(2), -- Hamstring             -- 断筋 (Rank 4)
    [23694] = List(3), -- Improved Hamstring    -- 强化断筋
    [12323] = List(2), -- Piercing Howl         -- 刺耳怒吼
    [25275] = List(3), -- Intercept             -- 拦截 (Rank 5)
    [30330] = List(2), -- Mortal Strike         -- 致死打击 (Rank 6)
    [12809] = List(3), -- Concussion Blow       -- 震荡猛击
    -- Warlock
    [5782]  = List(3), -- Fear                  -- 恐惧术 (Rank 1)
    [6213]  = List(3), -- Fear                  -- 恐惧术 (Rank 2)
    [6215]  = List(3), -- Fear                  -- 恐惧术 (Rank 3)
    [710]	= List(2), -- Banish                -- 放逐术 (Rank 1)
	[18647]	= List(2), -- Banish                -- 放逐术 (Rank 2)
    [6358]  = List(3), -- Seduction             -- 魅惑
    [11719] = List(3), -- Curse of Tongues      -- 语言诅咒
    [17928] = List(3), -- Howl of Terror        -- 恐惧嚎叫 (Rank 2)
    [24259] = List(3), -- Spell Lock            -- 法术锁定
    [27223] = List(5), -- Death Coil            -- 死亡缠绕 (Rank 4)
    [30108] = List(5), -- Unstable Affliction   -- 痛苦无常 (Rank 3)
    [31117] = List(5), -- U&A Silenced          -- 痛苦无常 (沉默)
    [30414] = List(2), -- Shadowfury            -- 暗影之怒 (Rank 4)
    [27215] = List(2), -- Immolate              -- 献祭 (Rank 9)
    [27216] = List(2), -- Corruption            -- 腐蚀术 (Rank 7)
    -- Priest
    [10890] = List(3), -- Psychic Scream        -- 心灵尖啸 (Rank 4)
    [605]   = List(5), -- Mind Control          -- 精神控制
    [15487] = List(3), -- Silence               -- 沉默
    [15269] = List(1), -- Blackout              -- 昏阙
    [25368] = List(2), -- Shadow Word: Pain     -- 暗言术：痛 (Rank 10)
    [34917] = List(2), -- Vampiric Touch        -- 吸血鬼之触 (Rank 3)
    -- Rogue
    [1833]  = List(3), -- Cheap Shot            -- 偷袭
    [2094]  = List(5), -- Blind                 -- 致盲
    [8643]  = List(4), -- Kidney Shot           -- 肾击 (Rank 2)
    [11297] = List(4), -- Sap                   -- 闷棍 (Rank 3)
    [38764] = List(2), -- Gouge                 -- 凿击 (Rank 6)
    [1330]  = List(3), -- Garrote - Silence     -- 锁喉沉默
    [18425] = List(3), -- Kick - Silenced       -- 脚踢 - 沉默
    -- Mage
    [116]	= List(2), -- Frostbolt             -- 寒冰箭 (Rank 1)
    [38697]	= List(2), -- Frostbolt             -- 寒冰箭 (Rank 14)
    [12826] = List(3), -- Polymorph             -- 变形术
    [28271] = List(3), -- Polymorph: Turtle     -- 变形术:龟
    [28272] = List(3), -- Polymorph: Pig        -- 变形术:猪
    [27087] = List(4), -- Cone of Cold          -- 冰锥术 (Rank 6)
    [122]   = List(4), -- Frost Nova            -- 冰霜新星 (Rank 1)
    [865]   = List(4), -- Frost Nova            -- 冰霜新星 (Rank 2)
    [6131]  = List(4), -- Frost Nova            -- 冰霜新星 (Rank 3)
    [10230] = List(4), -- Frost Nova            -- 冰霜新星 (Rank 4)
    [27088] = List(4), -- Frost Nova            -- 冰霜新星 (Rank 5)
    [33395] = List(4), -- W&E Freeze            -- 冰冻术 (水元素)
    [12494] = List(4), -- Frostbite             -- 霜寒刺骨
    [18469] = List(3), -- Counterspell Silenced -- 法术反制 -沉默
    [31589] = List(3), -- Slow                  -- 减速
    [33043] = List(3), -- Dragon's Breath       -- 龙息术
    -- Hunter
    [1543]  = List(2), -- Flare                 -- 照明弹
    [5116]  = List(2), -- Concussive Shot       -- 震荡射击
    [14325] = List(2), -- Hunter's Mark         -- 猎人印记 (Rank 4)
    [14309] = List(3), -- Freezing Trap         -- 冰冻陷阱 (Rank 3)
    [19185] = List(3), -- Entrapment            -- 诱捕
    [19503] = List(3), -- Scatter Shot          -- 驱散射击
    [27018] = List(2), -- Viper Sting           -- 蝰蛇钉刺 (Rank 4)
    [24133]	= List(2), -- Wyvern Sting          -- 翼龙钉刺 (Rank 3)
    [27065] = List(2), -- Aimed Shot            -- 瞄准射击 (Rank 7)
    [27067] = List(3), -- Counterattack         -- 反击 (Rank 4)
    [27016] = List(2), -- Serpent Sting         -- 毒蛇钉刺 (Rank 10)
    -- Druid
    [26993] = List(5), -- Faerie Fire           -- 精灵之火 (Rank 5)
    [27011] = List(5), -- Faerie Fire (Feral)   -- 精灵之火 (野性) (Rank 5)
    [9853]  = List(2), -- Entangling Roots      -- 纠缠根须
    [8983]  = List(4), -- Bash                  -- 重击 (Rank 3)
    [16922] = List(2), -- Starfire Stun         -- 星火昏迷
    [22570] = List(2), -- Maim                  -- 割碎
    [27006] = List(3), -- Pounce                -- 突袭 (Rank 4)
    [33786] = List(5), -- Cyclone               -- 飓风术
    [45334] = List(3), -- Feral Charge Effect   -- 野性冲锋效果
    -- Paladin
    [10308] = List(4), -- Hammer of Justice     -- 制裁之锤 (Rank 4)
    [20066] = List(3), -- Repentance            -- 忏悔
    -- Death Knight
	[55741]	= List(1), -- Desecration           -- 亵渎
	[47481]	= List(2), -- Gnaw (Ghoul)          -- 撕扯 (食尸鬼)
	[49203]	= List(3), -- Hungering Cold        -- 饥饿之寒
	[47476]	= List(2), -- Strangulate           -- 绞袭
	[53534]	= List(2), -- Chains of Ice         -- 寒冰锁链
    -- Shaman
    [2484]  = List(1), -- Earthbind Totem       -- 地缚图腾
    [25464] = List(1), -- Frost Shock           -- 冰霜震击 (Rank 5)
}

ORD:RegisterDebuffs(DebuffList)     -- don't touch this ...