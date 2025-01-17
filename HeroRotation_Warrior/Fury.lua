--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL         = HeroLib
local Cache      = HeroCache
local Unit       = HL.Unit
local Player     = Unit.Player
local Target     = Unit.Target
local Pet        = Unit.Pet
local Spell      = HL.Spell
local MultiSpell = HL.MultiSpell
local Item       = HL.Item
-- HeroRotation
local HR         = HeroRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Warrior then Spell.Warrior = {} end
Spell.Warrior.Fury = {
  RecklessnessBuff                      = Spell(1719),
  Recklessness                          = Spell(1719),
  FuriousSlashBuff                      = Spell(202539),
  FuriousSlash                          = Spell(100130),
  RecklessAbandon                       = Spell(202751),
  HeroicLeap                            = Spell(6544),
  Siegebreaker                          = Spell(280772),
  Rampage                               = Spell(184367),
  FrothingBerserker                     = Spell(215571),
  Carnage                               = Spell(202922),
  EnrageBuff                            = Spell(184362),
  Massacre                              = Spell(206315),
  Execute                               = MultiSpell(5308, 280735),
  Bloodthirst                           = Spell(23881),
  RagingBlow                            = Spell(85288),
  Bladestorm                            = Spell(46924),
  SiegebreakerDebuff                    = Spell(280773),
  DragonRoar                            = Spell(118000),
  Whirlwind                             = Spell(190411),
  Charge                                = Spell(100),
  FujiedasFuryBuff                      = Spell(207775),
  MeatCleaverBuff                       = Spell(85739),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Pummel                                = Spell(6552),
  IntimidatingShout                     = Spell(5246),
  ColdSteelHotBlood                     = Spell(288080),
  BloodoftheEnemy                       = MultiSpell(297108, 298273, 298277),
  MemoryofLucidDreams                   = MultiSpell(298357, 299372, 299374),
  PurifyingBlast                        = MultiSpell(295337, 299345, 299347),
  RippleInSpace                         = MultiSpell(302731, 302982, 302983),
  ConcentratedFlame                     = MultiSpell(295373, 299349, 299353),
  TheUnboundForce                       = MultiSpell(298452, 299376, 299378),
  WorldveinResonance                    = MultiSpell(295186, 298628, 299334),
  FocusedAzeriteBeam                    = MultiSpell(295258, 299336, 299338),
  GuardianofAzeroth                     = MultiSpell(295840, 299355, 299358),
  CondensedLifeforce                    = MultiSpell(295834, 299354, 299357),
  ConcentratedFlameBurn                 = Spell(295368),
  RecklessForceBuff                     = Spell(302932),
  RazorCoralDebuff                      = Spell(303568),
  ConductiveInkDebuff                   = Spell(302565)
};
local S = Spell.Warrior.Fury;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Fury = {
  PotionofUnbridledFury            = Item(169299),
  AshvanesRazorCoral               = Item(169311),
  AzsharasFontofPower              = Item(169314)
};
local I = Item.Warrior.Fury;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Warrior.Commons,
  Fury = HR.GUISettings.APL.Warrior.Fury
};

-- Stuns
local StunInterrupts = {
  {S.IntimidatingShout, "Cast Intimidating Shout (Interrupt)", function () return true; end},
};

local EnemyRanges = {8}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--S.ExecuteDefault    = Spell(5308)
--S.ExecuteMassacre   = Spell(280735)

--local function UpdateExecuteID()
  --S.Execute = S.Massacre:IsAvailable() and S.ExecuteMassacre or S.ExecuteDefault
--end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Movement, SingleTarget
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  --UpdateExecuteID()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    if Everyone.TargetIsValid() then
      -- use_item,name=azsharas_font_of_power
      if I.AzsharasFontofPower:IsEquipped() and I.AzsharasFontofPower:IsReady() then
        if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power"; end
      end
      -- memory_of_lucid_dreams
      if S.MemoryofLucidDreams:IsCastableP() then
        if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams"; end
      end
      -- guardian_of_azeroth
      if S.GuardianofAzeroth:IsCastableP() then
        if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth"; end
      end
      -- recklessness
      if S.Recklessness:IsCastableP() then
        if HR.Cast(S.Recklessness) then return "recklessness precombat"; end
      end
      -- potion
      if I.PotionofUnbridledFury:IsReady() and Settings.Commons.UsePotions then
        if HR.CastSuggested(I.PotionofUnbridledFury) then return "battle_potion_of_strength 4"; end
      end
    end
  end
  Movement = function()
    -- heroic_leap
    if S.HeroicLeap:IsCastableP() then
      if HR.Cast(S.HeroicLeap, Settings.Fury.GCDasOffGCD.HeroicLeap) then return "heroic_leap 16"; end
    end
  end
  SingleTarget = function()
    -- siegebreaker
    if S.Siegebreaker:IsCastableP("Melee") and HR.CDsON() then
      if HR.Cast(S.Siegebreaker, Settings.Fury.GCDasOffGCD.Siegebreaker) then return "siegebreaker 18"; end
    end
    -- rampage,if=(buff.recklessness.up|buff.memory_of_lucid_dreams.up)|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
    if S.Rampage:IsReadyP("Melee") and ((Player:BuffP(S.RecklessnessBuff) or Player:BuffP(S.MemoryofLucidDreams)) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90))) then
      if HR.Cast(S.Rampage) then return "rampage 20"; end
    end
    -- execute
    if S.Execute:IsReady("Melee") then
      if HR.Cast(S.Execute) then return "execute 34"; end
    end
    -- furious_slash,if=!buff.bloodlust.up&buff.furious_slash.remains<3
    if S.FuriousSlash:IsCastableP() and (not Player:HasHeroism() and Player:BuffRemainsP(S.FuriousSlashBuff) < 3) then
      if HR.Cast(S.FuriousSlash) then return "furious_slash 36"; end
    end
    -- bladestorm,if=prev_gcd.1.rampage
    if S.Bladestorm:IsCastableP("Melee") and HR.CDsON() and (Player:PrevGCDP(1, S.Rampage)) then
      if HR.Cast(S.Bladestorm) then return "bladestorm 37"; end
    end
    -- bloodthirst,if=buff.enrage.down|azerite.cold_steel_hot_blood.rank>1
    if S.Bloodthirst:IsCastableP("Melee") and (Player:BuffDownP(S.EnrageBuff) or S.ColdSteelHotBlood:AzeriteRank() > 1) then
      if HR.Cast(S.Bloodthirst) then return "bloodthirst 38"; end
    end
    -- dragon_roar,if=buff.enrage.up
    if S.DragonRoar:IsCastableP(12) and HR.CDsON() and (Player:BuffP(S.EnrageBuff)) then
      if HR.Cast(S.DragonRoar) then return "dragon_roar 39"; end
    end
    -- raging_blow,if=charges=2
    if S.RagingBlow:IsCastableP("Melee") and (S.RagingBlow:ChargesP() == 2) then
      if HR.Cast(S.RagingBlow) then return "raging_blow 42"; end
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP("Melee") then
      if HR.Cast(S.Bloodthirst) then return "bloodthirst 48"; end
    end
    -- raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
    if S.RagingBlow:IsCastableP("Melee") and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
      if HR.Cast(S.RagingBlow) then return "raging_blow 62"; end
    end
    -- furious_slash,if=talent.furious_slash.enabled
    if S.FuriousSlash:IsCastableP("Melee") and (S.FuriousSlash:IsAvailable()) then
      if HR.Cast(S.FuriousSlash) then return "furious_slash 70"; end
    end
    -- whirlwind
    if S.Whirlwind:IsCastableP("Melee") then
      if HR.Cast(S.Whirlwind) then return "whirlwind 74"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- charge
    if S.Charge:IsReadyP() and S.Charge:ChargesP() >= 1 then
      if HR.Cast(S.Charge, Settings.Fury.GCDasOffGCD.Charge) then return "charge 78"; end
    end
    -- Interrupts
    Everyone.Interrupt(5, S.Pummel, Settings.Commons.OffGCDasOffGCD.Pummel, StunInterrupts);
    -- run_action_list,name=movement,if=movement.distance>5
    -- heroic_leap,if=(raid_event.movement.distance>25&raid_event.movement.in>45)
    if ((not Target:IsInRange("Melee")) and Target:IsInRange(40)) then
      return Movement();
    end
    -- potion
    if I.PotionofUnbridledFury:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.PotionofUnbridledFury) then return "battle_potion_of_strength 84"; end
    end
    -- rampage,if=cooldown.recklessness.remains<3
    if S.Rampage:IsReadyP("Melee") and (S.Recklessness:CooldownRemainsP() < 3) then
      if HR.Cast(S.Rampage) then return "rampage 108"; end
    end
    -- blood_of_the_enemy,if=buff.recklessness.up
    if S.BloodoftheEnemy:IsCastableP() and (Player:BuffP(S.RecklessnessBuff)) then
      if HR.Cast(S.BloodoftheEnemy, Settings.Fury.GCDasOffGCD.Essences) then return "blood_of_the_enemy"; end
    end
    -- purifying_blast,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.PurifyingBlast:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      if HR.Cast(S.PurifyingBlast, Settings.Fury.GCDasOffGCD.Essences) then return "purifying_blast"; end
    end
    -- ripple_in_space,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.RippleInSpace:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      if HR.Cast(S.RippleInSpace, Settings.Fury.GCDasOffGCD.Essences) then return "ripple_in_space"; end
    end
    -- worldvein_resonance,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.WorldveinResonance:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      if HR.Cast(S.WorldveinResonance, Settings.Fury.GCDasOffGCD.Essences) then return "worldvein_resonance"; end
    end
    -- focused_azerite_beam,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.FocusedAzeriteBeam:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      if HR.Cast(S.FocusedAzeriteBeam, Settings.Fury.GCDasOffGCD.Essences) then return "focused_azerite_beam"; end
    end
    -- concentrated_flame,if=!buff.recklessness.up&!buff.siegebreaker.up&dot.concentrated_flame_burn.remains=0
    if S.ConcentratedFlame:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff) and Target:DebuffDownP(S.ConcentratedFlameBurn)) then
      if HR.Cast(S.ConcentratedFlame, Settings.Fury.GCDasOffGCD.Essences) then return "concentrated_flame"; end
    end
    -- the_unbound_force,if=buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff)) then
      if HR.Cast(S.TheUnboundForce, Settings.Fury.GCDasOffGCD.Essences) then return "the_unbound_force"; end
    end
    -- guardian_of_azeroth,if=!buff.recklessness.up
    if S.GuardianofAzeroth:IsCastableP() and (Player:BuffDownP(S.RecklessnessBuff)) then
      if HR.Cast(S.GuardianofAzeroth, Settings.Fury.GCDasOffGCD.Essences) then return "guardian_of_azeroth"; end
    end
    -- memory_of_lucid_dreams,if=!buff.recklessness.up
    if S.MemoryofLucidDreams:IsCastableP() and (Player:BuffDownP(S.RecklessnessBuff)) then
      if HR.Cast(S.MemoryofLucidDreams, Settings.Fury.GCDasOffGCD.Essences) then return "memory_of_lucid_dreams"; end
    end
    -- recklessness,if=!essence.condensed_lifeforce.major&!essence.blood_of_the_enemy.major|cooldown.guardian_of_azeroth.remains>20|buff.guardian_of_azeroth.up|cooldown.blood_of_the_enemy.remains<gcd
    if S.Recklessness:IsCastableP() and HR.CDsON() and (not S.CondensedLifeforce:IsAvailable() and not S.BloodoftheEnemy:IsAvailable() or S.GuardianofAzeroth:CooldownRemainsP() > 20 or Player:BuffP(S.GuardianofAzeroth) or S.BloodoftheEnemy:CooldownRemainsP() < Player:GCD()) then
      if HR.Cast(S.Recklessness, Settings.Fury.GCDasOffGCD.Recklessness) then return "recklessness 112"; end
    end
    -- whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
    if S.Whirlwind:IsCastableP("Melee") and (Cache.EnemiesCount[8] > 1 and not Player:BuffP(S.MeatCleaverBuff)) then
      if HR.Cast(S.Whirlwind) then return "whirlwind 114"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=!debuff.razor_coral_debuff.up|(target.health.pct<30.1&debuff.conductive_ink_debuff.up)|(!debuff.conductive_ink_debuff.up&buff.memory_of_lucid_dreams.up|prev_gcd.2.guardian_of_azeroth|prev_gcd.2.recklessness&(buff.guardian_of_azeroth.up|!essence.memory_of_lucid_dreams.major&!essence.condensed_lifeforce.major))
    if I.AshvanesRazorCoral:IsEquipped() and I.AshvanesRazorCoral:IsReady() and (Target:DebuffDownP(S.RazorCoralDebuff) or (Target:HealthPercentage() < 30 and Target:DebuffP(S.ConductiveInkDebuff)) or (Target:DebuffDownP(S.ConductiveInkDebuff) and Player:BuffP(S.MemoryofLucidDreams) or Player:PrevGCDP(2, S.GuardianofAzeroth) or Player:PrevGCDP(2, S.Recklessness) and (Player:BuffP(S.GuardianofAzeroth) or not S.MemoryofLucidDreams:IsAvailable() and not S.GuardianofAzeroth:IsAvailable()))) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 115"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 118"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 122"; end
    end
    -- lights_judgment,if=buff.recklessness.down
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Player:BuffDownP(S.RecklessnessBuff)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 126"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 130"; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 134"; end
    end
    -- run_action_list,name=single_target
    if (true) then
      return SingleTarget();
    end
  end
end

local function Init ()
  HL.RegisterNucleusAbility(46924, 8, 6)               -- Bladestorm
  HL.RegisterNucleusAbility(118000, 12, 6)             -- Dragon Roar
  HL.RegisterNucleusAbility(190411, 8, 6)              -- Whirlwind
end

HR.SetAPL(72, APL, Init)
