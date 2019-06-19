htmlEntities = module("vrp", "lib/htmlEntities")


local lcfg = module("vrp", "cfg/base")
Luang = module("vrp", "lib/Luang")
Lang = Luang()


Lang:loadLocale(lcfg.lang, module("vrp", "cfg/lang/"..lcfg.lang) or {})

Lang:loadLocale(lcfg.lang, module("loot", "lang/"..lcfg.lang) or {})
lang = Lang.lang[lcfg.lang]



local Loot = class("Loot", vRP.Extension)


local function menu_loot(self)
  local function choice_loot(menu)
    local user = menu.user
	local choice_loot = {function(player,choice)
	  local user = self.users({player})
	  if user_id ~= nil then
		vRP.EXT.Base.remote.getNearestPlayer(player,{10},function(nplayer)
		  local nuser = self.users({nplayer})
		  if nuser_id ~= nil then
			Survival.isInComa(nplayer,{}, function(in_coma)
			  if in_coma then
				local revive_seq = {
				  {"amb@medic@standing@kneel@enter","enter",1},
				  {"amb@medic@standing@kneel@idle_a","idle_a",1},
				  {"amb@medic@standing@kneel@exit","exit",1}
				}
				vRP.EXT.Base:playAnim(player,{false,revive_seq,false}) -- anim
				SetTimeout(15000, function()
				  local ndata = vRP:getUData({nuser})
				  if ndata ~= nil then
					if ndata.inventory ~= nil then -- gives inventory items
					  User:clearInventory({nuser})
					  for k,v in pairs(ndata.inventory) do 
						vRP.giveInventoryItem({user_id,k,v.amount,true})
					  end
					end
				  end
				  local nmoney = User:getWallet({nuser})
				  if User:tryPayment({nuser,nmoney}) then
					User:getWallet({user_id,nmoney})
				  end
				end)
				vRP.EXT.Base:stopAnim(player,{false})
			  else
				vRP.EXT.Base.remote._notify(player,{lang.emergency.menu.revive.not_in_coma()})
			  end
			end)
		  else
			vRP.EXT.Base.remote._notify(player,{lang.common.no_player_near()})
		  end
		end)
	  end
	end,"Loot nearby corpse"}
	end
end

	
function Loot:__construct()
  vRP.Extension.__construct(self)
  
  menu_loot(self)

  local function choice_loot(menu)
    menu.user:openMenu("Loot")
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    if menu.user:hasPermission("player.loot") then
      menu:addOption("Loot", choice_loot)
    end
  end)
end

vRP:registerExtension(Loot)	