Config = {}

Config.UseOxtarget = true
Config.UseOxinventory = true
Config.Debug = true

Config.Meterprops = {
    'prop_parknmeter_02',
    'prop_parknmeter_01'
}

Config.searchtime = 10 -- seconds
Config.searchcooldown = 300 -- seconds

Config.SearchAnim = {
    dict = 'mini@repair',
    clip = 'fixing_a_ped'
}

Config.RewardItem = 'markedbills'
-- Config.RewardItem = 'water' -- example if you want an ox_inventory item instead

Config.Reward = {
    RewardMin = 500,
    RewardMax = 10
}