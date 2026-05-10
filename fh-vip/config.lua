Config = {}

Config.Locale = 'en' -- 'en' or 'lt'

Config.AdminGroup = 'admin' -- Admin group that can use /setvip command

-- VIP Level rewards
Config.Rewards = {
    [1] = { -- VIP level 1 
        money = 5000,
        items = {
            {name = 'burger', count = 2},
            {name = 'water', count = 2}
        }
    },
    [2] = { -- VIP level  2 
        money = 10000,
        items = {
            {name = 'burger', count = 5},
            {name = 'water', count = 5},
            {name = 'bandage', count = 2}
        }
    },
    [3] = { -- VIP level  3 
        money = 25000,
        items = {
            {name = 'burger', count = 10},
            {name = 'water', count = 10},
            {name = 'bandage', count = 5},
            {name = 'medikit', count = 1}
        }
    }
}