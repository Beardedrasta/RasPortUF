--[[
    Aura List
    A table of spellIDs to create icons for.
    To add spellIDs, look up a spell on www.wowhead.com and look at the URL:
    https://www.wowhead.com/wotlk/spell=SPELLID
    https://www.wowhead.com/wotlk/cn/spell=SPELLID
--]]

local _, RP = ...

-- oUF_Nihlathak
local C = RP.C

local AuraList = {
    ['ALL'] = {
    -- Racial
        [2825]  = true, -- Bloodlust               -- 嗜血
        [32182] = true, -- Heroism                 -- 英勇
        [7744]  = true, -- Will of the Forsaken    -- 亡灵意志
        [26297] = true, -- Berserking (Mana)       -- 狂暴
        [20572] = true, -- Blood Fury              -- 血性狂怒
        [33697] = true, -- Blood Fury (Shaman)     -- 血性狂怒 (萨满)
        [33702] = true, -- Blood Fury (Warlock)    -- 血性狂怒 (术士)
        [20594] = true, -- Stoneform               -- 石像形态
        [20600] = true, -- Perception              -- 感知
        [65123] = true, -- Storm Cloud             -- 风暴雷云
        [63711] = true, -- Storm Power             -- 风暴之力
        [65133] = true, -- Storm Cloud             -- 风暴雷云
        [65134] = true, -- Storm Power             -- 风暴之力
    -- Items
        [2379]  = true, -- Speed                   -- 迅捷药水
        [53762] = true, -- Indestructible          -- 不灭 (药水)
        [53908] = true, -- Speed                   -- 加速 (药水)
        [53909] = true, -- Wild Magic              -- 狂野魔法 (药水)
        [59620] = true, -- Berserk                 -- 狂暴
        [54758] = true, -- Hyperspeed Acceleration -- 超级加速器
        [54861] = true, -- Nitro Boosts            -- 硝化甘油推进器
        [55637] = true, -- Lightweave              -- 光纹刺绣
        [60494] = true, -- Dying Curse             -- 垂死詛咒
    -- Warrior
        [871]   = true, -- Shield Wall             -- 盾墙
        [1719]  = true, -- Recklessness            -- 鲁莽
        [3411]  = true, -- Intervene               -- 援护
        [12292] = true, -- Death Wish              -- 死亡之愿
        [12976] = true, -- Last Stand              -- 破釜沉舟
        [18499] = true, -- Berserker Rage          -- 狂暴之怒
        [20230] = true, -- Retaliation             -- 反击风暴
        [23920] = true, -- Spell Reflection        -- 法术反射
        [46924] = true, -- Bladestorm              -- 利刃风暴
        [55694] = true, -- Enraged Regeneration    -- 狂怒回复
        [29842] = true, -- Second Wind             -- 复苏之风 (Rank 2)
    -- Warlock
        [47241] = true, -- Metamorphosis           -- 恶魔变形
    -- Priest
        [6346]  = true, -- Fear Ward               -- 防护恐惧结界
        [15487] = true, -- Silence                 -- 沉默
        [10060] = true, -- Power Infusion          -- 能量灌注
        [33206] = true, -- Pain Suppression        -- 痛苦压制
        [47585] = true, -- Dispersion              -- 消散
        [47788] = true, -- Guardian Spirit         -- 守护之魂
        [64844] = true, -- Divine Hymn             -- 神圣赞美诗
        [64904] = true, -- Hymn of Hope            -- 希望圣歌
        [48066] = true, -- Power Word: Shield      -- 真言术：盾 (Rank 14)
    -- Rogue
        [1833]  = true, -- Cheap Shot              -- 偷袭
        [2094]  = true, -- Blind                   -- 致盲
        [8643]  = true, -- Kidney Shot             -- 肾击 (Rank 2)
        [26669] = true, -- Evasion                 -- 闪避 (Rank 2)
        [11297] = true, -- Sap                     -- 闷棍 (Rank 3)
        [11305] = true, -- Sprint                  -- 疾跑 (Rank 3)
        [14177] = true, -- Cold Blood              -- 冷血
        [31224] = true, -- Cloak of Shadows        -- 暗影斗篷
        [57933] = true, -- Tricks of the Trade     -- 嫁祸诀窍 (目标)
        [45182] = true, -- Cheating Death          -- 装死
    -- MAGE
        [12826] = true, -- Polymorph               -- 变形术
        [28271] = true, -- Polymorph: Turtle       -- 变形术:龟
        [28272] = true, -- Polymorph: Pig          -- 变形术:猪
        [66]    = true, -- Invisibility            -- 隐形术
        [130]   = true, -- Slow Fall               -- 缓落术
        [45438] = true, -- Ice Block               -- 寒冰屏障
        [12494] = true, -- Frostbite               -- 霜寒刺骨
        [12042] = true, -- Arcane Power            -- 奥术强化
        [12043] = true, -- Presence of Mind        -- 气定神闲
        [31589] = true, -- Slow                    -- 减速
        [44572] = true, -- Deep Freeze             -- 深度冻结
        [55021] = true, -- Counterspell - Silenced -- 法术反制 - 沉默 (Rank 2)
        [43039] = true, -- Ice Barrier             -- 寒冰护体 (Rank 8)
    -- Hunter
        [14309] = true, -- Freezing Trap Effect    -- 冰冻陷阱效果
        [19503] = true, -- Scatter Shot            -- 驱散射击
        [34490] = true, -- Silencing Shot          -- 沉默射击
        [5384]  = true, -- Feign Death             -- 假死
        [19263] = true, -- Deterrence              -- 威慑
        [19574] = true, -- Bestial Wrath           -- 狂野怒火
        [34471] = true, -- The Beast Within        -- 野兽之心
        [34477] = true, -- Misdirection            -- 误导
    -- Druid
        [17116] = true, -- Nature's Swiftness      -- 自然迅捷
        [22812] = true, -- Barkskin                -- 树皮术
        [22842] = true, -- Frenzied Regeneration   -- 狂暴回复
        [29166] = true, -- Innervate               -- 激活
        [50334] = true, -- Berserk                 -- 狂暴
        [61336] = true, -- Survival Instincts      -- 生存本能
        [33357] = true, -- Dash                    -- 急奔 (Rank 3)
    -- Paladin
        [10308] = true, -- Hammer of Justice       -- 制裁之锤 (Rank 4)
        [498]   = true, -- Divine Protection       -- 圣佑术
        [642]   = true, -- Divine Shield           -- 圣盾术
        [1038]  = true, -- Blessing of Salvation   -- 拯救之手
        [1044]  = true, -- Blessing of Freedom     -- 自由祝福
        [6940]  = true, -- Blessing of Sacrifice   -- 牺牲之手
        [20066] = true, -- Repentance              -- 忏悔
        [19753] = true, -- Divine Intervention     -- 神圣干涉
        [31821] = true, -- Aura Mastery            -- 光环掌握
        [31884] = true, -- Avenging Wrath          -- 复仇之怒
        [20216] = true, -- Divine Favor            -- 神恩术
        [53563] = true, -- Blessing of Light       -- 圣光道标
        [53601] = true, -- Sacred Shield           -- 圣洁护盾
        [54428] = true, -- Divine Plea             -- 神圣恳求
        [64205] = true, -- Divine Sacrifice        -- 神圣牺牲
        [70940] = true, -- Divine Guardian         -- 神圣护卫者
        [10278] = true, -- Blessing of Protection  -- 保护之手 (Rank 3)
    -- Shaman
        [8178]  = true, -- Grounding Totem Effect  -- 根基图腾效果
        [16166] = true, -- Elemental Mastery       -- 元素掌握
        [16188] = true, -- Nature's Swiftness      -- 自然迅捷
        [30823] = true, -- Shamanistic Rage        -- 萨满之怒
        [58875] = true, -- Spirit Walk             -- 幽魂步
        [16237] = true, -- Ancestral Fortitude     -- 先祖坚韧 (Rank 3)
        [61301] = true, -- Riptide                 -- 激流 (Rank 4)
    -- Death Knight
        [48707]  = true, -- Anti-Magic Shell       -- 反魔法护罩
        [48792]  = true, -- Icebound Fortitude     -- 冰封之韧
        [49039]  = true, -- Lichborne              -- 巫妖之躯
        [49222]  = true, -- Bone Shield            -- 白骨之盾
        [50461]  = true, -- Anti-Magic Zone        -- 反魔法领域
        [55233]  = true, -- Vampiric Blood         -- 吸血鬼之血
    },
    ['WARRIOR'] = {
		[58567] = true, -- Sunder Armor            -- 破甲攻击
        [2565]  = true, -- Shield Block            -- 盾牌格挡
        [12328] = true, -- Sweeping Strikes        -- 横扫攻击
        [52437] = true, -- Sudden Death            -- 猝死
        [60503] = true, -- Taste for Blood         -- 血之气息
        [47465] = true, -- Rend                    -- 撕裂 (Rank 10)
        [47437] = true, -- Demoralizing Shout      -- 挫志怒吼 (Rank 8)
        [47502] = true, -- Thunder Clap            -- 雷霆一击 (Rank 9)
        [47486] = true, -- Mortal Strike           -- 致死打击 (Rank 8)
        [47436] = true, -- Battle Shout            -- 战斗怒吼 (Rank 9)
        [47440] = true, -- Commanding Shout        -- 命令怒吼 (Rank 3)
	},
    ['WARLOCK'] = {
        [17941] = true, -- Shadow Trance           -- 夜幕降临
        [18708] = true, -- Fel Domination          -- 恶魔支配
        [54370] = true, -- Nether Protection       -- 虚空防护 (神圣)
        [54371] = true, -- Nether Protection       -- 虚空防护 (火焰)
        [54372] = true, -- Nether Protection       -- 虚空防护 (冰霜)
        [54373] = true, -- Nether Protection       -- 虚空防护 (奥术)
        [54374] = true, -- Nether Protection       -- 虚空防护 (暗影)
        [54375] = true, -- Nether Protection       -- 虚空防护 (自然)
        [34936] = true, -- Backlash                -- 反冲
        [47283] = true, -- Empowered Imp           -- 小鬼增效
        [54277] = true, -- Backdraft               -- 爆燃
        [63244] = true, -- Pyroclasm               -- 火焰冲撞
        [63167] = true, -- Decimation              -- 灭杀
        [64371] = true, -- Eradication             -- 根除
        [71165] = true, -- Molten Core             -- 熔火之心
        [48090] = true, -- Demonic Pact            -- 恶魔契约
        [50589] = true, -- Immolation Aura         -- 献祭光环
        [47813] = true, -- Corruption              -- 腐蚀术 (Rank 10)
        [47891] = true, -- Shadow Ward             -- 暗影防护结界 (Rank 6)
        [47986] = true, -- Sacrifice               -- 牺牲 (Rank 9)
        [63321] = true, -- Life Tap                -- 生命分流雕纹
	},
    ['PRIEST'] = {
        [586]   = true, -- Fade                    -- 渐隐术
        [10890] = true, -- Psychic Scream          -- 心灵尖啸 (Rank 4)
        [48068] = true, -- Renew                   -- 恢复 (Rank 14)
    },
    ['ROGUE'] = {
        [1330]  = true, -- Garrote - Silence       -- 锁喉沉默
        [18425] = true, -- Kick - Silenced         -- 脚踢 - 沉默
        [1856]  = true, -- Vanish                  -- 消失
        [6774]  = true, -- Slice and Dice          -- 切割 (Rank 2)
        [26889] = true, -- Vanish                  -- 消失 (Rank 3)
        [13750] = true, -- Adrenaline Rush         -- 冲动
        [13877] = true, -- Blade Flurry            -- 剑刃乱舞
    },
    ['MAGE'] = {
        [12472] = true, -- Icy Veins               -- 冰冷血脉
        [12536] = true, -- Clearcasting            -- 节能施法
        [28682] = true, -- Combustion              -- 燃烧
        [43010] = true, -- Fire Ward               -- 火焰防护结界 (Rank 7)
        [43012] = true, -- Frost Ward              -- 冰霜防护结界 (Rank 7)
        [43020] = true, -- Mana Shield             -- 法力护盾 (Rank 9)
    },
    ['HUNTER'] = {
        [3045]  = true, -- Rapid Fire              -- 急速射击
        [35099] = true, -- Rapid Killing           -- 疾速杀戮
    },
    ['DRUID'] = {
        [2893]  = true, -- Abolish Poison          -- 驱毒术
        [5229]  = true, -- Enrage                  -- 激怒
        [16886] = true, -- Nature's Grace          -- 自然之赐
        [48443] = true, -- Regrowth                -- 愈合 (Rank 12)
        [48441] = true, -- Rejuvenation            -- 回春术 (Rank 15)
        [48451] = true, -- Lifebloom               -- 生命绽放 (Rank 3)
    },
    ['PALADIN'] = {
        [31842] = true, -- Divine Illumination     -- 神启
        [59578] = true, -- The Art of War          -- 战争艺术 (Rank 2)
        [48952] = true, -- Holy Shield             -- 神圣之盾 (Rank 6)
    },
    ['SHAMAN'] = {
        [53817] = true, -- Maelstrom Weapon        -- 漩涡武器
        [55166] = true, -- Tidal Force             -- 潮汐之力
        [17364] = true, -- Stormstrike             -- 风暴打击
        [53390] = true, -- Tidal Waves             -- 波涛汹涌
        [49233] = true, -- Flame Shock             -- 烈焰震击 (Rank 9)
        [49281] = true, -- Lightning Shield        -- 闪电之盾 (Rank 11)
        [49284] = true, -- Earth Shield            -- 大地之盾 (Rank 5)
        [57960] = true, -- Water Shield            -- 水之护盾 (Rank 10)
    },
    ['DEATHKNIGHT'] = {
        [49028]  = true, -- Dancing Rune Weapon    -- 符文刃舞
        [49796]  = true, -- Deathchill             -- 黑锋冰寒
        [51271]  = true, -- Unbreakable Armor      -- 铜墙铁壁
        [61777]  = true, -- Summon Gargoyle        -- 召唤石像鬼
    }
}

C.AuraList = AuraList      -- don't touch this ...