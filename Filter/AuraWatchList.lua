--[[
    AuraWatch List
    A table of spellIDs to create icons for.
    To add spellIDs, look up a spell on www.wowhead.com and look at the URL:
    https://www.wowhead.com/wotlk/spell=SPELLID
    https://www.wowhead.com/wotlk/cn/spell=SPELLID
--]]

local _, ns = ...

-- oUF_Nihlathak
local C = ns.C

local AuraWatchList = {
    ['ALL'] = {
        {   498,    'CENTER',   0,  0,  true,   1   },  -- Divine Protection            -- 圣佑术
        {   871,    'CENTER',   0,  0,  true,   1   },  -- Shield Wall                  -- 盾墙
        {   22812,  'CENTER',   0,  0,  true,   1   },  -- Barkskin                     -- 树皮术
        {   33206,  'CENTER',   0,  0,  true,   1   },  -- Pain Suppression             -- 痛苦压制
        {   48792,  'CENTER',   0,  0,  true,   1   },  -- Icebound Fortitude           -- 冰封之韧
        {   6940,   'CENTER',   0,  0,  true,   1   },  -- Blessing Sacrifice           -- 牺牲之手
        {   10278,  'CENTER',   0,  0,  true,   1   },  -- Blessing of Protection       -- 保护祝福 (Rank 3)
        {   45438,  'CENTER',   0,  0,  true,   1   },  -- Ice Block                    -- 寒冰屏障
        {   19263,  'CENTER',   0,  0,  true,   1   },  -- Deterrence                   -- 威慑
        {   53563,  'CENTER',   0,  0,  true,   1   },  -- Divine Intervention          -- 圣光道标
        {   301089, 'TOPRIGHT', 0,  0,  true,   1   },  -- Horde Flag                   -- 部落旗帜
        {   301091, 'TOPRIGHT', 0,  0,  true,   1   },  -- Alliance Flag                -- 联盟旗帜
        {   34976,  'TOPRIGHT', 0,  0,  true,   1   },  -- Netherstorm Flag             -- 虚空风暴旗帜
        {   65123,  'CENTER',   0,  0,  true,   1   },  -- Storm Cloud                  -- 风暴雷云
        {   63711,  'CENTER',   0,  0,  true,   1   },  -- Storm Power                  -- 风暴之力
        {   65133,  'CENTER',   0,  0,  true,   1   },  -- Storm Cloud                  -- 风暴雷云
        {   65134,  'CENTER',   0,  0,  true,   1   },  -- Storm Power                  -- 风暴之力
    },
    ['WARRIOR'] = {
        {   3411,     'TOPRIGHT'                    },  -- Intervene                    -- 援护
    },
    ['PRIEST'] = {
        {   48066,    'CENTER'	                    }, -- Power Word: Shield            -- 真言术：盾 (Rank 14)
        {   10060,    'TOP'	                        }, -- Power Infusion                -- 能量灌注
        {   48068,    'TOPRIGHT'                    }, -- Renew                         -- 恢复 (Rank 14)
    },
    ['DRUID'] = {
        {   29166,    'CENTER'                      }, -- Innervate                     -- 激活
        {   2893,     'TOP'                         }, -- Abolish Poison                -- 驱毒术
        {   48451,    'TOP'                         }, -- Lifebloom                     -- 生命绽放 (Rank 3)
        {   48441,    'TOPRIGHT'                    }, -- Rejuvenation                  -- 回春术 (Rank 15)
        {   48443,    'TOPRIGHT',       -15,    0   }, -- Regrowth                      -- 愈合 (Rank 12)
    },
    ['PALADIN'] = {
        {   19753,    'CENTER'   		            }, -- Divine Intervention	        -- 神圣干涉
        --{   53563,    'CENTER'   		            }, -- Blessing of Light		        -- 圣光道标
        {   1044,     'TOP'                         }, -- Blessing of Freedom	        -- 自由祝福
        {   19752,    'TOP'                         }, -- Divine Intervention	        -- 神圣干涉
        {   53601,    'BOTTOMRIGHT'                 }, -- Sacred Shield                 -- 圣洁护盾
    },
    ['SHAMAN'] = {
        {   16237,    'TOPRIGHT'                    }, -- Ancestral Fortitude           -- 先祖坚韧 (Rank 3)
        {   49284,    'CENTER'                      }, -- Earth Shield                  -- 大地之盾 (Rank 5)
        {   61301,    'TOP'                         }, -- Tidal Waves	                -- 波涛汹涌 (Rank 4)
        {   52000,    'TOPRIGHT',       -15,    0   }, -- Earthliving                   -- 大地生命 (Rank 6)
    },
    ['MAGE'] = {
        {   130,      'CENTER'                      }, -- Slow Fall                     -- 缓落术
        {   54646,    'TOPRIGHT',       -15,    0   }, -- Focus Magic                   -- 专注魔法
    },
    ['WARLOCK'] = {
        {   47883,    'CENTER'    	                }, -- Soulstone Resurrection        -- 灵魂石复活 (Rank 7)
    },
    ['HUNTER'] = {
        {   34477,    'CENTER'                      }, -- Misdirection                  -- 误导
    },
    ['ROGUE'] = {
        {   57933,    'CENTER'                      }, -- Tricks of the Trade           -- 嫁祸诀窍 (目标)
    }
}

C.AuraWatchList = AuraWatchList      -- don't touch this ...