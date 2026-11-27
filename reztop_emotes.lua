local ffi = require("ffi")
local tab = ui.tab("Emote wheel")
local playSelectedDance, stopSelectedDance, resetWheel, freezeWheelView
local musicEnabled, volume, cameraDistance, allowWalking, loopAnimation, readAsset, widePath
local resourceRoot, gameResourceDir, tickInstaller, closeInstaller
local function logError(message)
    print("[emotes] ", message)
end

do
    local emotes = {
        {1000, "Dance Moves", false, "DanceMoves", cycleMs = 6800, wav = "DanceMoves.wav", soundMs = 6745},
        {1001, "Electro Shuffle", false, "ElectroShuffle", cycleMs = 8433, wav = "ElectroShuffle.wav", soundMs = 7606},
        {1002, "Aerobic", false, "Emote_AerobicChamp", cycleMs = 6300, wav = "Emote_AerobicChamp.wav", soundMs = 12643},
        {1003, "Best Mates", true, "Emote_BandOfTheFort", cycleMs = 533, wav = "Emote_BandOfTheFort.wav", soundMs = 8934},
        {1004, "Bendy", true, "Emote_Bendy", cycleMs = 9100, wav = "Emote_Bendy.wav", soundMs = 9169},
        {1005, "Blow Kiss", true, "Emote_BlowKiss", cycleMs = 2600, endMs = 875, wav = "Emote_BlowKiss.wav"},
        {1006, "Come To Me", true, "Emote_Bring_It_On", cycleMs = 4433, endMs = 4463},
        {1007, "Calculated", true, "Emote_Calculated", cycleMs = 3500, endMs = 3511, wav = "Emote_Calculated.wav"},
        {1008, "Capoeira", false, "Emote_Capoeira", cycleMs = 4833, endMs = 4810, wav = "Emote_Capoeira.wav"},
        {1009, "Celebration", true, "Emote_Celebration_Loop", cycleMs = 2933, endMs = 3158, wav = "Emote_Celebration.wav"},
        {1010, "Flapper", false, "Emote_Charleston", cycleMs = 1833, wav = "Emote_Charleston.wav", soundMs = 7419},
        {1011, "Chicken", true, "Emote_Chicken", cycleMs = 3633, wav = "Emote_Chicken.wav", soundMs = 3709},
        {1012, "Chug", true, "Emote_Chug", cycleMs = 1200, endMs = 1200},
        {1013, "Confused", true, "Emote_Confused", cycleMs = 6967, endMs = 6863},
        {1014, "Cry", true, "Emote_Cry", cycleMs = 8967, endMs = 7834, wav = "Emote_Cry.wav"},
        {1015, "Dab", true, "Emote_Dab", cycleMs = 1867, endMs = 1748},
        {1016, "Break Dance", false, "Emote_Dance_Breakdance", cycleMs = 8567, endMs = 7311, wav = "Emote_Dance_Breakdance.wav"},
        {1017, "Disco Fever", false, "Emote_Dance_Disco_T3", cycleMs = 8800, wav = "Emote_Dance_Disco_T3.wav", soundMs = 8568},
        {1018, "Take The L", false, "Emote_Dance_Loser", cycleMs = 800, nextSequence = "Emote_Dance_Loser_CT", nextCycleMs = 800, transitionMs = 820, wav = "Emote_Dance_Loser.wav", soundMs = 12669},
        {1019, "Boneless", false, "Emote_Dance_NoBones", cycleMs = 3200, wav = "Emote_Dance_NoBones.wav", soundMs = 15386},
        {1020, "Pump", false, "Emote_Dance_Pump", cycleMs = 3533, wav = "Emote_Dance_Pump.wav", soundMs = 13897},
        {1021, "Ride The Pony", false, "Emote_Dance_RideThePony", cycleMs = 2667, wav = "Emote_Dance_RideThePony.wav", soundMs = 1750},
        {1022, "Hype", false, "Emote_Dance_Shoot", cycleMs = 3533, wav = "Emote_Dance_Shoot.wav", soundMs = 13479},
        {1023, "Swipe It", false, "Emote_Dance_SwipeIt", cycleMs = 3467, wav = "Emote_Dance_SwipeIt.wav", soundMs = 13270},
        {1024, "The Worm", false, "Emote_Dance_Worm", cycleMs = 4167, wav = "Emote_Dance_Worm.wav", soundMs = 6857},
        {1025, "Disco Fever 2", false, "Emote_DG_Disco", cycleMs = 7367, wav = "Emote_DG_Disco.wav", soundMs = 7387},
        {1026, "Dust Off Hands", true, "Emote_DustingOffHands", cycleMs = 3267, endMs = 3267, wav = "Emote_DustingOffHands.wav"},
        {1027, "Dust Off Shoulders", true, "Emote_DustOffShoulders", cycleMs = 3733, endMs = 20870, wav = "Emote_DustOffShoulders.wav"},
        {1028, "Eastern Bloc", false, "Emote_EasternBloc_Start", cycleMs = 2967, nextSequence = "Emote_EasternBloc", nextCycleMs = 11633, wav = "Emote_EasternBloc.wav", soundMs = 14367},
        {1029, "Facepalm", true, "Emote_Facepalm", cycleMs = 5300, endMs = 2276, wav = "Emote_Facepalm.wav"},
        {1030, "Dream Feet", false, "Emote_FancyFeet", cycleMs = 4233, nextSequence = "Emote_FancyFeet_CT", nextCycleMs = 4233, wav = "Emote_FancyFeet.wav", soundMs = 16875},
        {1031, "On the Hook", true, "Emote_Fishing", cycleMs = 7267, endMs = 3988, wav = "Emote_Fishing.wav"},
        {1032, "Flex", true, "Emote_Flex", cycleMs = 8100, endMs = 8100, wav = "Emote_Flex.wav"},
        {1033, "Flippin", true, "Emote_FlippnSexy", cycleMs = 3467, endMs = 3467, wav = "Emote_FlippnSexy.wav"},
        {1034, "Floss", false, "Emote_FlossDance", cycleMs = 1600, wav = "Emote_FlossDance.wav", soundMs = 8385},
        {1035, "Finger Guns", true, "Emote_Fonzie_Pistol", cycleMs = 3200, endMs = 3200},
        {1036, "Fresh", false, "Emote_Fresh", cycleMs = 10133, wav = "Emote_Fresh.wav", soundMs = 5094},
        {1037, "Golf Clap", true, "Emote_golfclap", cycleMs = 3800, endMs = 3800, wav = "Emote_golfclap.wav"},
        {1038, "Groove Jam", false, "Emote_GrooveJam", cycleMs = 9333, wav = "Emote_GrooveJam.wav", soundMs = 15151},
        {1039, "Guitar", false, "Emote_guitar", cycleMs = 10133, wav = "Emote_guitar.wav", soundMs = 10188},
        {1040, "Hand Signals", true, "Emote_HandSignals", cycleMs = 9600, endMs = 9543, wav = "Emote_HandSignals.wav"},
        {1041, "Shuffle", false, "Emote_Hillbilly_Shuffle_Intro", cycleMs = 967, nextSequence = "Emote_Hillbilly_Shuffle", nextCycleMs = 2500, transitionMs = 1050, wav = "Emote_Hillbilly_Shuffle.wav", soundMs = 7040},
        {1042, "Hip Hop", false, "Emote_Hiphop_01", cycleMs = 6267, nextSequence = "Emote_Hip_Hop", nextCycleMs = 7267, transitionMs = 6290, wav = "Emote_Hip_Hop.wav", soundMs = 14576},
        {1043, "Hot Stuff", true, "Emote_Hotstuff", cycleMs = 3367, endMs = 2970, wav = "Emote_Hotstuff.wav"},
        {1044, "Hula Hop", false, "Emote_Hula_Start", cycleMs = 2033, nextSequence = "Emote_Hula", nextCycleMs = 7200, transitionMs = 2060, wav = "Emote_Hula.wav", soundMs = 14158},
        {1045, "Breaking Point", true, "Emote_IBreakYou", cycleMs = 3567, endMs = 3524},
        {1046, "True Love", true, "Emote_IHeartYou", cycleMs = 2500, endMs = 2494},
        {1047, "Infinite Dab", false, "Emote_InfiniDab_Intro", cycleMs = 733, nextSequence = "Emote_InfiniDab_Loop", nextCycleMs = 1067, transitionMs = 803, wav = "Emote_InfiniDab.wav", soundMs = 15491},
        {1048, "Intensity", false, "Emote_Intensity_Start", cycleMs = 5500, nextSequence = "Emote_Intensity_Loop", nextCycleMs = 5333, transitionMs = 5510, wav = "Emote_Intensity.wav", soundMs = 35344},
        {1049, "Irish Jig", false, "Emote_IrishJig_Start", cycleMs = 567, nextSequence = "Emote_IrishJig", nextCycleMs = 6367, transitionMs = 389, wav = "Emote_IrishJig.wav", soundMs = 12095},
        {1050, "Eagle", false, "Emote_KoreanEagle", cycleMs = 4100, wav = "Emote_KoreanEagle.wav", soundMs = 18678},
        {1051, "True Heart", false, "Emote_Kpop_02", cycleMs = 7667, wav = "Emote_Kpop.wav", soundMs = 7706},
        {1052, "Laugh", false, "Emote_Laugh", cycleMs = 9067, nextSequence = "Emote_Laugh_CT", nextCycleMs = 9067, transitionMs = 9093, endMs = 9133, wav = "Emote_Laugh.wav"},
        {1053, "Living Large", false, "Emote_LivingLarge", cycleMs = 16533, wav = "Emote_LivingLarge.wav", soundMs = 16588},
        {1054, "Luchador", true, "Emote_Luchador", cycleMs = 6800, endMs = 6766, wav = "Emote_Luchador.wav"},
        {1055, "Make It Rain", true, "Emote_Make_It_Rain", cycleMs = 5000, endMs = 4606, wav = "Emote_Make_It_Rain.wav"},
        {1056, "Maracas", false, "Emote_Maracas", cycleMs = 8133, wav = "Emote_Maracas.wav", soundMs = 8176},
        {1057, "Orange Justice", false, "Emote_Mask_Off_Intro", cycleMs = 567, nextSequence = "Emote_Mask_Off_Loop", nextCycleMs = 6500, transitionMs = 468, wav = "Emote_Mask_Off.wav", soundMs = 18965},
        {1058, "Not Today", true, "Emote_NotToday", cycleMs = 3633, endMs = 3423},
        {1059, "Pop Lock", false, "Emote_PopLock", cycleMs = 8233, wav = "Emote_PopLock.wav", soundMs = 16666},
        {1060, "Star Power", false, "Emote_PopRock", cycleMs = 8000, wav = "Emote_PopRock.wav", soundMs = 16039},
        {1061, "Robot", false, "Emote_RobotDance", cycleMs = 9833, wav = "Emote_RobotDance.wav", soundMs = 19827},
        {1062, "Rock", true, "Emote_RockPaperScissor_Rock", cycleMs = 3500, endMs = 3424},
        {1063, "Paper", true, "Emote_RockPaperScissor_Paper", cycleMs = 3500, endMs = 3424},
        {1064, "Scissors", true, "Emote_RockPaperScissor_Scissor", cycleMs = 3500, endMs = 3424},
        {1065, "Salt", true, "Emote_Salt", cycleMs = 5467, endMs = 5341},
        {1066, "Salute", true, "Emote_Salute", cycleMs = 2600, endMs = 1944, wav = "Emote_Salute.wav"},
        {1067, "Drive Car", false, "Emote_SmoothDrive", cycleMs = 7800, endMs = 20898, wav = "Emote_SmoothDrive.wav"},
        {1068, "Snap", true, "Emote_Snap", cycleMs = 1867, endMs = 1881, wav = "Emote_Snap.wav"},
        {1069, "Stage Bow", true, "Emote_StageBow", cycleMs = 4000, endMs = 3353, wav = "Emote_StageBow.wav"},
        {1070, "Reanimated", false, "Emote_TechnoZombie", cycleMs = 4833, wav = "Emote_TechnoZombie.wav", soundMs = 9639},
        {1071, "Thumbs Down", true, "Emote_ThumbsDown", cycleMs = 4933, endMs = 4960},
        {1072, "Thumbs Up", true, "Emote_ThumbsUp", cycleMs = 4933, endMs = 4840},
        {1073, "Twist", false, "Emote_Twist", cycleMs = 11000, wav = "Emote_Twist.wav", soundMs = 11207},
        {1074, "Warehouse", false, "Emote_WarehouseDance_Start", cycleMs = 3933, nextSequence = "Emote_WarehouseDance_Loop", nextCycleMs = 8667, transitionMs = 4017, wav = "Emote_WarehouseDance.wav", soundMs = 31817},
        {1075, "Wave", true, "Emote_Wave2", cycleMs = 1833, endMs = 1834},
        {1076, "Wiggle", false, "Emote_Wiggle", cycleMs = 3200, wav = "Emote_Wiggle.wav", soundMs = 5198},
        {1077, "Yeet", true, "Emote_Yeet", cycleMs = 1667, endMs = 1754, wav = "Emote_Yeet.wav"},
        {1078, "You're Awesome", false, "Emote_Youre_Awesome", cycleMs = 5633, endMs = 4909, wav = "Emote_Youre_Awesome.wav"},
        {1079, "Rambunctious", false, "Emote_Zippy_Dance", cycleMs = 3667, wav = "Emote_Zippy_Dance.wav", soundMs = 7367},
        {1080, "Boogie Down", false, "Emote_Boogie_Down_Intro", cycleMs = 667, nextSequence = "Emote_Boogie_Down", nextCycleMs = 4333, transitionMs = 667, wav = "Emote_BoogieDown.wav", soundMs = 18352},
        {1081, "Heel Click", true, "Emote_HeelClick", cycleMs = 1834, endMs = 1834, wav = "Emote_HeelClick.wav"},
        {1082, "Respect", true, "Emote_KungFu_Salute", cycleMs = 2467, endMs = 2467},
        {1083, "T-Rex", false, "Emote_TRex", cycleMs = 12667, endMs = 12667, wav = "Emote_TRex.wav"},
        {1084, "Smooth Moves", false, "Emote_Smooth_Moves", cycleMs = 9600, wav = "Emote_Smooth_Moves.wav", soundMs = 19031},
        {1085, "California Gurls", false, "Emote_Friday13", cycleMs = 10267, wav = "Emote_Friday13.wav", soundMs = 15453},
        {1086, "Gangnam Style", false, "Emote_Gangnam_Style", cycleMs = 7267, wav = "Emote_Gangnam_Style.wav", soundMs = 28984},
        {1087, "In Da Party", false, "Emote_InDaGhetto", cycleMs = 7567, wav = "Emote_InDaGhetto.wav", soundMs = 15191},
        {1088, "Blinding Lights", false, "Emote_BlindingLights", cycleMs = 14067, wav = "Emote_BlindingLights.wav", soundMs = 14120},
        {1089, "Get Griddy", false, "Emote_Griddy", cycleMs = 6067, wav = "Emote_Griddy.wav", soundMs = 24465},
        {1090, "I Like To Move It", false, "Emote_ILikeToMoveIt", cycleMs = 7333, wav = "Emote_ILikeToMoveIt.wav", soundMs = 7381},
        {1091, "The Macarena", false, "Emote_Macarena", cycleMs = 9300, wav = "Emote_Macarena.wav", soundMs = 75090},
        {1092, "Never Gonna", false, "Emote_NeverGonna", cycleMs = 10000, wav = "Emote_NeverGonna.wav", soundMs = 33634},
        {1093, "Ninja Style", false, "Emote_NinjaStyle", cycleMs = 7467, wav = "Emote_NinjaStyle.wav", soundMs = 14982},
        {1094, "Pump It Up", false, "Emote_PumpkinDance", cycleMs = 12000, wav = "Emote_PumpkinDance.wav", soundMs = 12448},
        {1095, "Pump up the Jam", false, "Emote_PumpUpTheJam", cycleMs = 7633, wav = "Emote_PumpUpTheJam.wav", soundMs = 15322},
        {1096, "The Renegade", false, "Emote_Renegade", cycleMs = 12900, wav = "Emote_Renegade.wav", soundMs = 25849},
        {1097, "Rushin' Around", false, "Emote_RushinAround", cycleMs = 7533, wav = "Emote_RushinAround.wav", soundMs = 30186},
        {1098, "Say So", false, "Emote_SaySo", cycleMs = 8600, wav = "Emote_SaySo.wav", soundMs = 17255},
        {1099, "Stuck", false, "Emote_Stuck", cycleMs = 11467, wav = "Emote_Stuck.wav", soundMs = 22976},
        {1100, "Toosie Slide", false, "Emote_ToosieSlide", cycleMs = 5867, wav = "Emote_ToosieSlide.wav", soundMs = 35253},
        {1101, "Air Shredder", false, "Emote_AirShredder", cycleMs = 5333, wav = "Emote_AirShredder.wav", soundMs = 23446},
        {1102, "Crossbounce", false, "Emote_Crossbounce", cycleMs = 7500, wav = "Emote_Crossbounce.wav", soundMs = 15061},
        {1103, "Distraction Dance", false, "Emote_DistractionDance", cycleMs = 5500, wav = "Emote_DistractionDance.wav", soundMs = 7381},
        {1104, "Head Banger", false, "Emote_Headbanger", cycleMs = 3067, wav = "Emote_Headbanger.wav", soundMs = 27312},
        {1105, "Hitchhiker", false, "Emote_HitchHiker", cycleMs = 4000, wav = "Emote_HitchHiker.wav", soundMs = 16680},
        {1106, "It's Go Time!", false, "Emote_ItsGoTime", cycleMs = 6167, wav = "Emote_ItsGoTime.wav", soundMs = 15400},
        {1107, "Knee Slapper", false, "Emote_KneeSlapper", cycleMs = 10400, wav = "Emote_KneeSlapper.wav", soundMs = 31204},
        {1108, "Showstopper", false, "Emote_Showstopper", cycleMs = 7400, wav = "Emote_Showstopper.wav", soundMs = 14773},
        {1109, "Sprinkler", false, "Emote_Sprinkler", cycleMs = 3733, wav = "Emote_Sprinkler.wav", soundMs = 22558},
        {1110, "Ghostbusters", false, "Emote_Ghostbusters", cycleMs = 8333, wav = "Emote_Ghostbusters.wav", soundMs = 33399},
        {1111, "Marsh Walk", false, "Emote_Martian", cycleMs = 12933, wav = "Emote_Martian.wav", soundMs = 25980},
        {1112, "Forget me not", false, "Emote_RememberMe_Intro", cycleMs = 1467, nextSequence = "Emote_RememberMe_Loop", nextCycleMs = 10000, wav = "Emote_RememberMe.wav", soundMs = 39668},
        {1113, "Rollie", false, "Emote_Rollie", cycleMs = 13267, wav = "Emote_Rollie.wav", soundMs = 42306},
        {1114, "Scenario", false, "Emote_Scenario", cycleMs = 8133, wav = "Emote_Scenario.wav", soundMs = 32719},
        {1115, "John Cena", false, "Emote_Cena", cycleMs = 7233, wav = "Emote_Cena.wav", soundMs = 7407},
        {1116, "The Silencer", false, "Emote_Lebron", cycleMs = 6667, wav = "Emote_Lebron.wav", soundMs = 9053},
        {1117, "Walky Walk", false, "Emote_Walkywalk_Walk", cycleMs = 11800, wav = "Emote_Walkywalk_Walk.wav", soundMs = 28853},
    }




    local settings = tab:group("Колесо эмоций", "left")

    local slots = 6
    local pi = math.pi
    local step = 2 * pi / slots
    local top = -pi / 2
    local halfSector = math.rad(27.5)
    local openMs, closeMs, holdMs = 145, 95, 160
    local lastEmoteKey = "emote_wheel.last_emote"
    local pages = {}
    local function addPages(category, entries)
        local count = math.ceil(#entries / slots)
        for i = 1, count do
            local page = {category = category}
            for j = 1, slots do page[j] = entries[(i - 1) * slots + j] end
            pages[#pages + 1] = page
        end
    end

    local favorites, dances, gestures, byName, byId = {category = "Избранное"}, {}, {}, {}, {}
    for _, entry in ipairs(emotes) do
        local list = entry[3] and gestures or dances
        list[#list + 1] = entry
        byName[entry[2]] = entry
        byId[entry[1]] = entry
    end
    pages[1] = favorites
    addPages("Танцы", dances)
    addPages("Эмоции", gestures)

    local favoriteControls = {}
    local favoriteSettings = tab:group("Избранные эмоции", "right")
    for i = 1, slots do
        local default = emotes[i][2]
        local choices = {default, "Пусто"}
        for _, entry in ipairs(emotes) do
            if entry[2] ~= default then choices[#choices + 1] = entry[2] end
        end
        favoriteControls[i] = favoriteSettings:combo("Слот " .. i, choices)
    end

    local fixedNames = {
        [0x04] = "Средняя кнопка мыши", [0x05] = "Mouse 4", [0x06] = "Mouse 5",
        [0x08] = "Backspace", [0x09] = "Tab", [0x0d] = "Enter",
        [0x14] = "Caps Lock", [0x20] = "Space", [0x21] = "Page Up", [0x22] = "Page Down",
        [0x23] = "End", [0x24] = "Home", [0x25] = "Left", [0x26] = "Up", [0x27] = "Right",
        [0x28] = "Down", [0x2d] = "Insert", [0x2e] = "Delete",
        [0x6a] = "Num *", [0x6b] = "Num +", [0x6d] = "Num -", [0x6e] = "Num .", [0x6f] = "Num /",
        [0x90] = "Num Lock", [0x91] = "Scroll Lock",
        [0xa0] = "Left Shift", [0xa1] = "Right Shift", [0xa2] = "Left Ctrl", [0xa3] = "Right Ctrl",
        [0xa4] = "Left Alt", [0xa5] = "Right Alt",
        [0xba] = "; / Ж", [0xbb] = "= / +", [0xbc] = ", / Б", [0xbd] = "- / _", [0xbe] = ". / Ю",
        [0xbf] = "/ / ?", [0xc0] = "` / Ё", [0xdb] = "[ / Х", [0xdc] = "\\", [0xdd] = "] / Ъ", [0xde] = "' / Э",
        [0xe2] = "OEM 102",
    }
    local function keyName(vk)
        if fixedNames[vk] then return fixedNames[vk] end
        if vk >= 0x30 and vk <= 0x39 or vk >= 0x41 and vk <= 0x5a then return string.char(vk) end
        if vk >= 0x70 and vk <= 0x87 then return "F" .. (vk - 0x6f) end
        if vk >= 0x60 and vk <= 0x69 then return "Num " .. (vk - 0x60) end
    end

    local function keyIsSupported(vk)
        return type(vk) == "number" and vk == math.floor(vk) and keyName(vk) ~= nil
    end

    local captureKeys = {0x1b}
    for key = 4, 0xfe do
        if keyIsSupported(key) then captureKeys[#captureKeys + 1] = key end
    end
    local function makeBind(storage, title, fallback)
        local key = database[storage]
        return {storage = storage, title = title, key = keyIsSupported(key) and key or fallback}
    end
    local openBind = makeBind("emote_wheel.open_key", "Клавиша колеса", 0x77)
    local stopBind = makeBind("emote_wheel.stop_key", "Клавиша остановки", 0x78)
    if stopBind.key == openBind.key then stopBind.key = openBind.key == 0x78 and 0x79 or 0x78 end
    local captured
    local function showBind(bind)
        bind.button:name(bind.title .. ": " .. keyName(bind.key))
    end
    local function keyStates()
        return {hold = utils.key_state(openBind.key), stop = utils.key_state(stopBind.key),
            left = utils.key_state(1), right = utils.key_state(2), middle = utils.key_state(4),
            escape = utils.key_state(0x1b)}
    end
    local function favoritesUseRightClick()
        return openBind.key == 4 or stopBind.key == 4
    end

    local state = {
        open = false, progress = 0, page = 1, hot = nil,
        wheel = 0, wheelDelta = 0, nextScroll = 0,
        keys = keyStates(), icons = {},
    }

    ffi.cdef[[
        typedef struct { long x, y; } emote_wheel_point;
        typedef struct { long left, top, right, bottom; } emote_wheel_rect;
        typedef struct { void *hwnd; uint32_t message; uintptr_t wParam; } emote_wheel_msg;
        typedef intptr_t (__stdcall *emote_wheel_getmsg)(int, uintptr_t, intptr_t);
        void * __stdcall GetForegroundWindow(void);
        uint32_t __stdcall GetWindowThreadProcessId(void *, uint32_t *);
        void * __stdcall SetWindowsHookExW(int, emote_wheel_getmsg, void *, uint32_t);
        int __stdcall UnhookWindowsHookEx(void *);
        intptr_t __stdcall CallNextHookEx(void *, int, uintptr_t, intptr_t);
        uint32_t __stdcall GetCurrentThreadId(void);
        uint32_t __stdcall GetLastError(void);
        void * __stdcall LoadCursorW(void *, const unsigned short *);
        void * __stdcall SetCursor(void *);
        int __stdcall GetCursorPos(emote_wheel_point *);
        int __stdcall ScreenToClient(void *, emote_wheel_point *);
        int __stdcall GetClientRect(void *, emote_wheel_rect *);
        bool SDL_IsMainThread(void);
        void *SDL_GetKeyboardFocus(void);
        uint32_t SDL_GetWindowID(void *);
        void *SDL_GetWindowFromID(uint32_t);
        uint32_t SDL_GetWindowProperties(void *);
        void *SDL_GetPointerProperty(uint32_t, const char *, void *);
        bool SDL_GetWindowRelativeMouseMode(void *);
        bool SDL_SetWindowRelativeMouseMode(void *, bool);
        bool SDL_GetWindowMouseGrab(void *);
        bool SDL_SetWindowMouseGrab(void *, bool);
        bool SDL_SetCursor(void *);
        bool SDL_CursorVisible(void);
        bool SDL_ShowCursor(void);
        bool SDL_HideCursor(void);

    ]]
    local user32 = ffi.load("user32")
    local wheelWin = ffi.load("kernel32")
    local sdlOk, sdl = pcall(ffi.load, "SDL3")
    if not sdlOk then sdl = nil end
    local cursorPoint = ffi.new("emote_wheel_point[1]")
    local clientRect = ffi.new("emote_wheel_rect[1]")
    local cursorSession
    local wheelHook, wheelCallback
    local wheelDeltaPerStep = 120
    local wheelDeltaLimit = wheelDeltaPerStep * #pages

    local function wheelMessage(code, mode, address)
        local saved = cursorSession
        if code == 0 and mode == 1 and state.open and saved and address ~= 0 then
            local msg = ffi.cast("emote_wheel_msg *", address)[0]
            if msg.message == 0x020a and msg.hwnd == saved.hwnd then
                local word = math.floor(tonumber(ffi.cast("uint32_t", msg.wParam)) / 65536)
                local delta = word < 32768 and word or word - 65536
                state.wheelDelta = math.max(-wheelDeltaLimit, math.min(wheelDeltaLimit, state.wheelDelta + delta))
                msg.message = 0
            end
        end
        return user32.CallNextHookEx(nil, code, mode, address)
    end
    if jit and jit.off then jit.off(wheelMessage, true) end

    local function stopWheelHook()
        if not wheelHook then return true end
        if user32.UnhookWindowsHookEx(wheelHook) == 0 and wheelWin.GetLastError() ~= 1404 then
            return false
        end
        wheelHook = nil
        wheelCallback:free()
        wheelCallback = nil
        return true
    end

    local function startWheelHook(hwnd)
        if wheelHook then return false end
        local thread = user32.GetWindowThreadProcessId(hwnd, nil)
        if thread == 0 or thread ~= wheelWin.GetCurrentThreadId() then return false end
        local ok, callback = pcall(ffi.cast, "emote_wheel_getmsg", wheelMessage)
        if not ok then return false end
        local hook = user32.SetWindowsHookExW(3, callback, nil, thread)
        if hook == nil then
            callback:free()
            return false
        end
        wheelHook, wheelCallback = hook, callback
        return true
    end

    local function close()
        state.open, state.wheel, state.wheelDelta, state.hot = false, 0, 0, nil
        state.pendingPress, state.favoriteEntry = nil, nil
        stopWheelHook()
        local saved = cursorSession
        if saved then state.releaseInputUntil = (tonumber(utils.timestamp()) or 0) + 80 end
        cursorSession = nil
        if not saved or not sdl.SDL_IsMainThread() then return end
        if sdl.SDL_GetWindowFromID(saved.id) ~= saved.window then return end
        if saved.visible then sdl.SDL_ShowCursor() else sdl.SDL_HideCursor() end
        if sdl.SDL_GetWindowMouseGrab(saved.window) ~= saved.grab then
            sdl.SDL_SetWindowMouseGrab(saved.window, saved.grab)
        end
        if sdl.SDL_GetWindowRelativeMouseMode(saved.window) ~= saved.relative then
            sdl.SDL_SetWindowRelativeMouseMode(saved.window, saved.relative)
        end
        sdl.SDL_SetCursor(nil)
    end

    local function useSystemCursor(saved)
        if sdl.SDL_GetWindowRelativeMouseMode(saved.window)
            and not sdl.SDL_SetWindowRelativeMouseMode(saved.window, false) then return false end
        if sdl.SDL_GetWindowMouseGrab(saved.window)
            and not sdl.SDL_SetWindowMouseGrab(saved.window, false) then return false end
        if not sdl.SDL_CursorVisible() and not sdl.SDL_ShowCursor() then return false end
        user32.SetCursor(saved.arrow)
        return true
    end

    local function addBindButton(bind, label)
        bind.button = settings:button(label, function()
            close()
            if captured then showBind(captured.bind) end
            captured = {bind = bind, keys = {}}
            for _, key in ipairs(captureKeys) do captured.keys[key] = utils.key_state(key) end
            bind.button:name("Нажми клавишу · Esc отменяет")
        end)
        showBind(bind)
    end
    addBindButton(openBind, "Назначить клавишу колеса")
    addBindButton(stopBind, "Назначить клавишу остановки")
    local repeatOnTap = settings:toggle("Повтор по короткому нажатию", true)
    musicEnabled = settings:toggle("Музыка эмоций", true)
    volume = settings:slider("Громкость эмоций", 0, 100, 100, 1, "%")
    musicEnabled:set_callback(function(self) volume:disabled(not self:get()) end, true)
    cameraDistance = settings:slider("Дистанция третьего лица", 48, 256, 128)
    allowWalking = settings:toggle("Ходить во время танца", false)
    loopAnimation = settings:toggle("Зацикливать анимацию", false)

    local detailFont = render.load_font("Bahnschrift", 15, "outline")
    local smallFont = render.load_font("Verdana", 12, "outline")
    local pageFont = render.load_font("Bahnschrift", 17, "outline")

    local function tint(rgb, alpha)
        return color(rgb[1], rgb[2], rgb[3], math.floor(alpha + 0.5))
    end
    local function clamp(v, lo, hi)
        return math.max(lo, math.min(hi, v))
    end
    local function wheelLayout(screen)
        local amount = 1 - (1 - state.progress)^3
        local radius = math.min(screen.x, screen.y) * 0.23 * (0.88 + 0.12 * amount)
        return {x = screen.x * 0.5, y = screen.y * 0.5, inner = radius * 0.60, outer = radius}
    end

    local function gameWindow()
        if not sdl or not sdl.SDL_IsMainThread() then return end
        local window = sdl.SDL_GetKeyboardFocus()
        if window == nil then return end
        local id = sdl.SDL_GetWindowID(window)
        local properties = sdl.SDL_GetWindowProperties(window)
        if id == 0 or properties == 0 then return end
        local hwnd = sdl.SDL_GetPointerProperty(properties, "SDL.window.win32.hwnd", nil)
        if hwnd ~= nil and user32.GetForegroundWindow() == hwnd then return window, id, hwnd end
    end

    local function open()
        local window, id, hwnd = gameWindow()
        if not window then return end
        local arrow = user32.LoadCursorW(nil, ffi.cast("const unsigned short *", 32512))
        if arrow == nil then return end
        local look = render.camera_angles()
        state.look = look and angle(look:pitch(), look:yaw(), look:roll())
        for i, control in ipairs(favoriteControls) do favorites[i] = byName[control:get()] end
        state.page = 1
        state.open, state.hot, state.favoriteEntry = true, nil, nil
        state.wheel, state.wheelDelta, state.nextScroll = 0, 0, 0
        state.releaseInputUntil = nil
        cursorSession = {window = window, hwnd = hwnd, id = id, arrow = arrow,
            visible = sdl.SDL_CursorVisible(),
            grab = sdl.SDL_GetWindowMouseGrab(window), relative = sdl.SDL_GetWindowRelativeMouseMode(window)}
        if not useSystemCursor(cursorSession) then
            close()
            logError("Не удалось освободить курсор Windows")
            return
        end
        cursorSession.nativeWheel = startWheelHook(hwnd)
    end

    local function captureHotkey()
        local bind = captured.bind
        local other = bind == openBind and stopBind or openBind
        for _, key in ipairs(captureKeys) do
            local down = utils.key_state(key)
            local pressed = down and not captured.keys[key]
            captured.keys[key] = down
            if pressed then
                if key == other.key then
                    bind.button:name("Клавиша занята · выбери другую")
                    return
                end
                if key ~= 0x1b then
                    bind.key = key
                    database[bind.storage] = key
                end
                captured = nil
                state.keys = keyStates()
                showBind(bind)
                return
            end
        end
    end

    local function selectHovered()
        local entry = state.hot and pages[state.page][state.hot]
        close()
        if entry then
            database[lastEmoteKey] = entry[1]
            playSelectedDance(entry)
        end
    end

    local function updatePointer(layout, screen)
        state.hot = nil
        local saved = cursorSession
        if not saved or user32.GetForegroundWindow() ~= saved.hwnd
            or not sdl.SDL_IsMainThread() or sdl.SDL_GetWindowFromID(saved.id) ~= saved.window then
            close()
            return
        end
        if not useSystemCursor(saved) then close() return end
        if user32.GetCursorPos(cursorPoint) == 0
            or user32.ScreenToClient(saved.hwnd, cursorPoint) == 0
            or user32.GetClientRect(saved.hwnd, clientRect) == 0 then return end
        local rect, pos = clientRect[0], cursorPoint[0]
        local width, height = rect.right - rect.left, rect.bottom - rect.top
        if width <= 0 or height <= 0 then return end
        local screenX = (pos.x - rect.left) * screen.x / width
        local screenY = (pos.y - rect.top) * screen.y / height
        local x, y = screenX - layout.x, screenY - layout.y
        local length = math.sqrt(x * x + y * y)
        if length < layout.inner or length > layout.outer then return end
        local direction = (math.atan2(y, x) - top + step * 0.5) % (2 * pi)
        local slot = math.floor(direction / step) + 1
        local fromMiddle = direction % step - step * 0.5
        if math.abs(fromMiddle) <= halfSector and (state.favoriteEntry or pages[state.page][slot]) then
            state.hot = slot
        end
    end

    local function inputSuppressed()
        if state.open then return true end
        local deadline = state.releaseInputUntil
        return deadline and (tonumber(utils.timestamp()) or deadline) < deadline
    end

    events.mouse_input:set(function(mouse)
        if not inputSuppressed() then return end
        local delta = tonumber(mouse.wheel)
        if state.open and cursorSession and not cursorSession.nativeWheel and delta and delta ~= 0 then
            state.wheel = delta > 0 and -1 or 1
        end
        return false
    end)

    local gameplayButtons = {
        "IN_ATTACK", "IN_ATTACK2", "IN_ATTACK3", "IN_JUMP", "IN_DUCK", "IN_FORWARD", "IN_BACK",
        "IN_USE", "IN_CANCEL", "IN_LEFT", "IN_RIGHT", "IN_MOVELEFT", "IN_MOVERIGHT", "IN_RUN",
        "IN_RELOAD", "IN_ALT1", "IN_ALT2", "IN_SCORE", "IN_SPEED", "IN_WALK", "IN_ZOOM",
        "IN_WEAPON1", "IN_WEAPON2", "IN_BULLRUSH", "IN_GRENADE1", "IN_GRENADE2", "IN_LOOKSPIN",
        "IN_INSPECT",
    }
    local function suppressGameplay(cmd)
        if not inputSuppressed() then return end
        cmd.forwardmove, cmd.leftmove, cmd.upmove = 0, 0, 0
        cmd.mousedx, cmd.mousedy, cmd.weaponselect, cmd.impulse = 0, 0, 0, 0
        for _, key in ipairs(gameplayButtons) do
            if cmd[key] ~= nil and cmd[key] ~= 0 then cmd[key] = 0 end
        end
        if state.look then
            cmd.viewangles = state.look
            cmd.camera = true
        end
    end

    events.pre_movement:set(suppressGameplay)
    events.createmove:set(function(cmd)
        suppressGameplay(cmd)
        if not state.open then state.releaseInputUntil = nil end
    end)
    freezeWheelView = function(view)
        if inputSuppressed() and state.look then
            view.angles = state.look
        end
    end

    ffi.cdef[[
        void * __stdcall CreateFileW(const unsigned short *, unsigned long, unsigned long,
            void *, unsigned long, unsigned long, void *);
        int __stdcall GetFileSizeEx(void *, int64_t *);
        int __stdcall ReadFile(void *, void *, unsigned long, unsigned long *, void *);
        int __stdcall CloseHandle(void *);
    ]]
    local iconFiles = ffi.load("kernel32")
    local invalidFile = ffi.cast("void *", -1)
    local pngHeader = "\137PNG\r\n\26\n"

    widePath = function(path)
        if not path:match("^%a:\\") then return nil end
        local chars = iconFiles.MultiByteToWideChar(65001, 8, path, -1, nil, 0)
        if chars < 2 or chars > 32768 then return nil end
        local wide = ffi.new("unsigned short[?]", chars)
        if iconFiles.MultiByteToWideChar(65001, 8, path, -1, wide, chars) ~= chars then return nil end
        return wide
    end

    readAsset = function(path, minSize, maxSize)
        local wide = widePath(path)
        if not wide then return nil end
        local file = iconFiles.CreateFileW(wide, 0x80000000, 7, nil, 3, 0x80, nil)
        if file == nil or file == invalidFile then return nil end
        local size = ffi.new("int64_t[1]")
        local length = iconFiles.GetFileSizeEx(file, size) ~= 0 and tonumber(size[0])
        local buffer
        if length and length >= minSize and length <= maxSize then
            buffer = ffi.new("uint8_t[?]", length)
            local got = ffi.new("unsigned long[1]")
            if iconFiles.ReadFile(file, buffer, length, got, nil) == 0 or tonumber(got[0]) ~= length then
                buffer = nil
            end
        end
        iconFiles.CloseHandle(file)
        return buffer, length
    end

    local function validIcon(ok, texture)
        if not ok or not texture then return nil end
        local valid, size = pcall(function() return texture.size end)
        if valid and size and size.x > 0 and size.y > 0 then
            return {texture = texture, ratio = size.x / size.y}
        end
    end

    local function iconFor(stem)
        if not stem then return nil end
        local cached = state.icons[stem]
        if cached ~= nil then return cached or nil end
        if state.iconBudget <= 0 then return nil end
        state.iconBudget = state.iconBudget - 1
        if not resourceRoot then return end
        local path = resourceRoot .. "\\icons\\" .. stem .. ".png"
        local icon = validIcon(pcall(render.load_image_from_file, path))
        if not icon then
            local buffer, size = readAsset(path, #pngHeader, 512 * 1024)
            if buffer and ffi.string(buffer, #pngHeader) == pngHeader then
                icon = validIcon(pcall(render.load_image, ffi.string(buffer, size)))
            end
        end
        state.icons[stem] = icon or false
        return icon
    end

    local motionGlyph = {
        {-0.43,0.12, -0.18,-0.11, 0.11,0.01, 0.39,-0.33},
        {-0.18,-0.11, -0.05,0.20, -0.33,0.49},
        {-0.05,0.20, 0.30,0.49},
    }

    local function drawGlyph(x, y, size, ink)
        local width = math.max(1.4, size * 0.055)
        for _, path in ipairs(motionGlyph) do
            local points = {}
            for i = 1, #path, 2 do points[#points + 1] = vector2(x + path[i] * size, y + path[i + 1] * size) end
            render.polyline(points, ink, false, width)
        end
        render.circle_outline(vector2(x - size * 0.12, y - size * 0.40), ink, size * 0.13, 0, 1, width)
    end

    local function drawName(x, y, name, width, ink, font)
        local size = render.measure_text(font, nil, name)
        if size.x <= width then
            render.text(vector2(x, y), ink, font, "c", name)
            return
        end
        local split
        for position in name:gmatch("() ") do
            if not split or math.abs(position - #name * 0.5) < math.abs(split - #name * 0.5) then
                split = position
            end
        end
        if split then
            render.text(vector2(x, y - size.y * 0.5), ink, smallFont, "c", name:sub(1, split - 1))
            render.text(vector2(x, y + size.y * 0.5), ink, smallFont, "c", name:sub(split + 1))
        else
            render.text(vector2(x, y), ink, smallFont, "c", name)
        end
    end

    local function drawSector(layout, mid, fill, rim, rimWidth, selected)
        local segments = 16
        local first = mid - halfSector
        local span = 2 * halfSector / segments
        local inside, outside
        local rimPoints = {}
        for i = 0, segments do
            local a = first + i * span
            local dx, dy = math.cos(a), math.sin(a)
            local nextInside = vector2(layout.x + dx * layout.inner, layout.y + dy * layout.inner)
            local nextOutside = vector2(layout.x + dx * layout.outer, layout.y + dy * layout.outer)
            if inside then
                render.poly({inside, outside, nextOutside, nextInside}, fill)
            end
            inside, outside = nextInside, nextOutside
            if rim then
                local r = selected and layout.inner + rimWidth * 0.5 or layout.outer - rimWidth * 0.5
                rimPoints[#rimPoints + 1] = vector2(layout.x + dx * r, layout.y + dy * r)
            end
        end
        if rim then render.polyline(rimPoints, rim, false, rimWidth) end
    end

    local function drawPageWheel(layout, fade, category, favoriteEntry, hot)
        local center = vector2(layout.x, layout.y)
        local radius = clamp(layout.inner * 0.22, 15, 27)
        local width = clamp(radius * 0.13, 2, 3)
        local arcRadius = radius - width
        local quadrant = math.floor((state.page - 1) * 4 / #pages)
        render.circle(center, tint({31, 31, 31}, fade * 188), radius)
        for i = 0, 3 do
            local first = top + i * pi * 0.5 + 0.16
            local points = {}
            for j = 0, 7 do
                local a = first + j * (pi * 0.5 - 0.32) / 7
                points[#points + 1] = vector2(layout.x + math.cos(a) * arcRadius, layout.y + math.sin(a) * arcRadius)
            end
            local shade = i == quadrant and 233 or 118
            render.polyline(points, tint({shade, shade, shade}, fade * 225), false, width)
        end
        render.text(center, tint({244, 244, 244}, fade * 255), pageFont, "c",
            favoriteEntry and "+" or tostring(state.page))
        render.text(vector2(layout.x, layout.y - radius - 12),
            tint({231, 231, 231}, fade * 255), favoriteEntry and detailFont or smallFont, "c",
            favoriteEntry and "В избранное" or category)
        if favoriteEntry then
            local ink = tint({246, 246, 246}, fade * 255)
            drawName(layout.x, layout.y - radius - 30, favoriteEntry[2], layout.inner * 1.8, ink, smallFont)
            local action = hot and favorites[hot] and "ЛКМ — заменить · Esc — отмена"
                or "ЛКМ — выбрать слот · Esc — отмена"
            render.text(vector2(layout.x, layout.y + radius + 12), ink, smallFont, "c",
                action)
        elseif hot then
            local button = favoritesUseRightClick() and "ПКМ" or "СКМ"
            render.text(vector2(layout.x, layout.y + radius + 12),
                tint({231, 231, 231}, fade * 225), smallFont, "c", button .. " — в избранное")
        end
    end

    local function drawWheel(screen, layout)
        local fade = math.min(1, state.progress * 1.7)
        local cx, cy = layout.x, layout.y
        local thickness = layout.outer - layout.inner
        local middle = (layout.outer + layout.inner) * 0.5
        local page = pages[state.page]
        local hot = state.open and state.hot
        local favoriteEntry = state.favoriteEntry
        state.iconBudget = 2

        render.rect(vector2(0, 0), screen, tint({17, 17, 17}, fade * 34))
        for i = 1, slots do
            local entry = page[i]
            local selected = hot == i
            local mid = top + (i - 1) * step
            local dx, dy = math.cos(mid), math.sin(mid)
            local ink = tint({246, 246, 246}, fade * (selected and 255 or 220))
            local fillShade = selected and 116 or 39
            local rimShade = selected and 236 or 151
            local enabled = entry or favoriteEntry
            local fill = tint({fillShade, fillShade, fillShade}, fade * (enabled and 205 or 72))
            local rim = enabled and tint({rimShade, rimShade, rimShade}, fade * (selected and 255 or 132))
            drawSector(layout, mid, fill, rim, selected and 3 or 1.5, selected)
            local x, y = cx + dx * middle, cy + dy * middle
            if entry then
                local icon = iconFor(entry[4])
                if icon then
                    local side = thickness * (selected and 0.85 or 0.72)
                    local width = side * math.min(1, icon.ratio)
                    local height = side / math.max(1, icon.ratio)
                    render.image(icon.texture, vector2(x - width * 0.5, y - height * 0.5), vector2(width, height), ink)
                else
                    drawGlyph(x, y, thickness * 0.55, ink)
                end
            elseif favoriteEntry then
                render.text(vector2(x, y), ink, pageFont, "c", "+")
            end
            if enabled then
                local labelX = cx + dx * (layout.outer + 58)
                local labelY = cy + dy * (layout.outer + 22)
                local labelWidth = math.min(108, screen.x - math.abs(labelX - cx) * 2 - 12)
                labelX = clamp(labelX, labelWidth * 0.5 + 6, screen.x - labelWidth * 0.5 - 6)
                local name = entry and entry[2] or "Пусто"
                if favoriteEntry then name = tostring(i) .. " · " .. name end
                drawName(labelX, labelY, name, labelWidth, ink, selected and detailFont or smallFont)
            end
        end

        drawPageWheel(layout, fade, page.category, favoriteEntry, hot)
    end

    local function handleWheelBind(now, keys, previous)
        if state.open then return end
        local pending = state.pendingPress
        if pending then
            local _, _, hwnd = gameWindow()
            if hwnd ~= pending.hwnd or (keys.escape and not previous.escape) then
                state.pendingPress = nil
            elseif not keys.hold then
                state.pendingPress = nil
                local last = byId[database[lastEmoteKey]]
                if now - pending.started < holdMs and last then playSelectedDance(last) end
            elseif now - pending.started >= holdMs then
                state.pendingPress = nil
                open()
            end
        elseif keys.hold and not previous.hold then
            if not repeatOnTap:get() then
                open()
            else
                local _, _, hwnd = gameWindow()
                if hwnd ~= nil then state.pendingPress = {started = now, hwnd = hwnd} end
            end
        end
    end

    events.render:set(function()
        if tickInstaller then tickInstaller(state.icons) end
        if not state.open and wheelHook then stopWheelHook() end
        local now = tonumber(utils.timestamp())
        if not now then return end
        local elapsed = state.lastFrame and clamp(now - state.lastFrame, 0, 60) or 16
        state.lastFrame = now
        local previous = state.keys
        local keys = keyStates()
        state.keys = keys
        if captured then
            captureHotkey()
        elseif keys.stop and not previous.stop then
            close()
            stopSelectedDance()
        else
            handleWheelBind(now, keys, previous)
        end

        local screen = render.screen_size()
        if math.min(screen.x, screen.y) * 0.23 < 65 then close() return end
        state.progress = clamp(state.progress + elapsed * (state.open and 1 / openMs or -1 / closeMs), 0, 1)
        local layout = wheelLayout(screen)
        if state.open then
            local steps = state.wheelDelta / wheelDeltaPerStep
            steps = steps >= 0 and math.floor(steps) or math.ceil(steps)
            if state.favoriteEntry then
                state.wheelDelta = 0
            elseif steps ~= 0 then
                state.page = (state.page - 1 - steps) % #pages + 1
                state.wheelDelta = state.wheelDelta - steps * wheelDeltaPerStep
            elseif state.wheel ~= 0 and now >= state.nextScroll then
                state.page = (state.page - 1 + state.wheel) % #pages + 1
                state.nextScroll = now + 45
            end
            state.wheel = 0
            updatePointer(layout, screen)
            local right = keys.right and not previous.right
            local click = keys.left and not previous.left
            local useRightClick = favoritesUseRightClick()
            local addFavorite = useRightClick and right or not useRightClick and keys.middle and not previous.middle
            if keys.escape and not previous.escape then
                close()
            elseif state.favoriteEntry then
                if right then
                    close()
                elseif click and state.hot then
                    local slot, entry = state.hot, state.favoriteEntry
                    favoriteControls[slot]:set(entry[2])
                    favorites[slot] = entry
                    close()
                end
            elseif state.hot and addFavorite then
                state.favoriteEntry = pages[state.page][state.hot]
                state.page, state.hot = 1, nil
            elseif right then
                close()
            elseif (not keys.hold and previous.hold) or click then
                selectHovered()
            end
        end

        if state.progress > 0 then drawWheel(screen, layout) end
    end)

    resetWheel = function()
        close()
        if captured then
            showBind(captured.bind)
            captured = nil
        end
    end
end

do
    ffi.cdef[[
        void * __stdcall GetModuleHandleA(const char *);
        uint32_t __stdcall GetFileAttributesW(const uint16_t *);
        void * __stdcall GetCurrentProcess(void);
        int __stdcall ReadProcessMemory(void *, const void *, void *, size_t, size_t *);
    ]]

    ffi.cdef[[
        int __stdcall MultiByteToWideChar(unsigned int, unsigned long, const char *, int, unsigned short *, int);
        int __stdcall PlaySoundW(const unsigned short *, void *, unsigned int);
    ]]
    local win = ffi.load("kernel32")
    local soundOk, sound = pcall(ffi.load, "winmm")
    if not soundOk then sound = nil end

    local function waveData(buffer, length)
        if ffi.string(buffer, 4) ~= "RIFF" or ffi.string(buffer + 8, 4) ~= "WAVE" then return end
        local function word(at)
            return buffer[at] + buffer[at + 1] * 256
        end
        local function dword(at)
            return word(at) + word(at + 2) * 65536
        end
        local limit = dword(4) + 8
        if limit > length then return end
        local at, format, blockAlign, sampleRate = 12, nil, nil, nil
        while at + 8 <= limit do
            local name, size = ffi.string(buffer + at, 4), dword(at + 4)
            local dataAt = at + 8
            at = dataAt + size + size % 2
            if at > limit then return end
            if name == "fmt " then
                if size < 16 or word(dataAt) ~= 1 or word(dataAt + 14) ~= 16 then return end
                blockAlign = word(dataAt + 12)
                sampleRate = dword(dataAt + 4)
                if blockAlign == 0 or blockAlign ~= 2 * word(dataAt + 2)
                    or sampleRate == 0 or dword(dataAt + 8) ~= sampleRate * blockAlign then return end
                format = dataAt
            elseif name == "data" then
                if not format or size == 0 or size % blockAlign ~= 0 then return end
                return {format = format, start = dataAt, size = size, align = blockAlign, rate = sampleRate}
            end
        end
    end

    local function littleEndian32(value)
        return string.char(value % 256, math.floor(value / 256) % 256,
            math.floor(value / 65536) % 256, math.floor(value / 16777216) % 256)
    end

    local function playSound(file, level, startedAt)
        if not sound or not file or level == 0 then return nil end
        if not resourceRoot then return nil end
        local path = resourceRoot .. "\\music\\" .. file
        if not startedAt and level == 100 then
            local wide = widePath(path)
            if wide and sound.PlaySoundW(wide, nil, 0x20003) ~= 0 then return wide end
            return nil
        end
        local buffer, length = readAsset(path, 44, 32 * 1024 * 1024)
        local wave = buffer and waveData(buffer, length)
        if not wave then return nil end
        local elapsed = startedAt and math.max(0, tonumber(utils.timestamp()) - startedAt) or 0
        local skip = math.floor(elapsed * wave.rate / 1000) * wave.align
        if skip >= wave.size then return nil, true end
        local start, remaining = wave.start + skip, wave.size - skip
        local playback = buffer
        if skip > 0 then
            local header = "RIFF" .. littleEndian32(36 + remaining) .. "WAVEfmt " .. "\16\0\0\0"
                .. ffi.string(buffer + wave.format, 16) .. "data" .. littleEndian32(remaining)
            playback = buffer + (start - #header)
            ffi.copy(playback, header, #header)
        end
        if level ~= 100 then
            local gain = level / 100
            local samples = ffi.cast("int16_t *", buffer + start)
            for i = 0, remaining / 2 - 1 do
                local scaled = samples[i] * gain
                samples[i] = scaled < 0 and math.ceil(scaled - 0.5) or math.floor(scaled + 0.5)
            end
        end
        if sound.PlaySoundW(ffi.cast("const unsigned short *", playback), nil, 7) ~= 0 then
            return buffer
        end
    end
    local current = win.GetCurrentProcess()
    local function address(ptr)
        if ptr == nil then return 0 end
        return tonumber(ffi.cast("uintptr_t", ptr))
    end

    local function read(at, size)
        if at < 65536 or at + size >= 2^47 then return nil end
        local buffer = ffi.new("uint8_t[?]", size)
        local count = ffi.new("size_t[1]")
        if win.ReadProcessMemory(current, ffi.cast("const void *", at), buffer, size, count) == 0
            or tonumber(count[0]) ~= size then
            return nil
        end
        return buffer
    end

    local function number(at, ctype)
        local buffer = read(at, ffi.sizeof(ctype))
        return buffer and tonumber(ffi.cast("const " .. ctype .. " *", buffer)[0])
    end

    local function checkBytes(at, hex)
        local size = #hex / 2
        local buffer = read(at, size)
        if not buffer then return false end
        for i = 0, size - 1 do
            if buffer[i] ~= tonumber(hex:sub(i * 2 + 1, i * 2 + 2), 16) then return false end
        end
        return true
    end

    local modules = {
        client = {name = "client.dll", timestamp = 0x6b04b843, size = 0x2996000},
        engine = {name = "engine2.dll", timestamp = 0x6b04a8dd, size = 0xa0a000},
    }
    local manifestMethods = {
        {name = "create", slot = 27, rva = 0x1ae7b0, ctype = "void *(*)(void *, int, const char *const *, uint8_t, const char *, uint8_t)",
            bytes = "48895c241048896c241848897424205741544155415641574883ec704883795800450fb6f1498bd88bf2488bf9"},
        {name = "loaded", slot = 29, rva = 0x1af190, ctype = "bool (*)(void *, void *)",
            bytes = "4885d2740c4883baa0000000000f94c0c3b001c3"},
        {name = "destroy", slot = 31, rva = 0x1aee80, ctype = "void (*)(void *, void *)",
            bytes = "4885d2744d534883ec20488b8aa0000000488bda4885c974"},
    }
    local modelName = "characters/kolka/fortnite_dance.vmdl"
    local reasonRva = 0x5cca84
    local function verifyModule(build)
        local handle = win.GetModuleHandleA(build.name)
        local base = address(handle)
        if not checkBytes(base, "4d5a") then return nil end
        local pe = number(base + 0x3c, "uint32_t")
        if not pe or pe < 64 or pe > 4096 or not checkBytes(base + pe, "504500006486") then return nil end
        if number(base + pe + 8, "uint32_t") ~= build.timestamp
            or number(base + pe + 24, "uint16_t") ~= 0x20b
            or number(base + pe + 24 + 56, "uint32_t") ~= build.size then
            return nil
        end
        return base, handle
    end

    local function checkModelFile()
        local dir = gameResourceDir()
        if not dir then return nil end
        local path = dir .. "\\characters\\kolka\\fortnite_dance.vmdl_c"
        local wide = widePath(path)
        if not wide then return nil end
        local attributes = tonumber(win.GetFileAttributesW(wide))
        return attributes ~= 0xffffffff and math.floor(attributes / 16) % 2 == 0, path
    end

    local function resolve()
        local clientBase = verifyModule(modules.client)
        local engine = verifyModule(modules.engine)
        if not clientBase or not engine then return nil, "Бинарники отличаются от билда 26879581" end

        local exists, path = checkModelFile()
        if not exists then return nil, path and ("Модель отсутствует: " .. path) or "Путь к папке игры не определён" end

        local service = utils.interface("engine2.dll", "GameResourceServiceClientV001")
        local tableAt = number(address(service), "uintptr_t")
        if not tableAt then return nil, "Интерфейс ресурсов недоступен" end

        local methods = {service = service, clientBase = clientBase, engineBase = engine, serviceTable = tableAt}
        for _, method in ipairs(manifestMethods) do
            local entry = engine + method.rva
            if number(tableAt + method.slot * 8, "uintptr_t") ~= entry
                or not checkBytes(entry, method.bytes) then
                return nil, "Проверка функции ресурса не прошла: " .. method.name
            end
            methods[method.name] = ffi.cast(method.ctype, entry)
        end
        local reason = engine + reasonRva
        if not checkBytes(reason, "47414d4500") then return nil, "Строка ресурса не совпала" end
        methods.reason = ffi.cast("const char *", reason)
        return methods
    end

    ffi.cdef[[
        typedef struct { uint32_t hash; int32_t unknown; const char *name; } dance_probe_key;
        typedef struct { uintptr_t identity; uintptr_t kv; uint64_t flags; } dance_probe_spawn;
    ]]

    local clientFunctions = {
        ctor = {0x15c93d0, "void *(*)(void *, void *, uint8_t)", "48895c2408574883ec2033ff488bd9488979284889793044884125"},
        dtor = {0x15c94c0, "void (*)(void *)", "48895c240848896c24104889742418574883ec20488b7908488bd94885ff7427"},
        find = {0x15ca6a0, "void *(*)(void *, const dance_probe_key *)", "4883ec388b024533c0894424208b420489442424488b4208488d5424204889442428e8090000004883c438c3"},
        set = {0x15cb5b0, "void (*)(void *, void *, const char *)", "48895c241048896c2418564883ec2048833900498bf0488bea488bd9"},
        create = {0x15b32c0, "void *(*)(void *, uint32_t, const char *, int, int, int, bool)", "48895c240848896c2410488974241848897c242041564883ec50498bf8448bf233db"},
        queue = {0x15bef40, "void (*)(void *, void *, void *)", "40565741564883ec30f7423000080000498bf04c8bf2488bf9"},
        execute = {0x15b6580, "void (*)(void *)", "48895c2408574881ec00010000ff81480c0000488d442428"},
        remove = {0xa1b0c0, "void (*)(void *)", "4883ec284885c90f84a7000000488b51108b42300fbae00b"},
        group = {0x15b9270, "uint32_t (*)(void *)", "8b81c01f0000c3"},
        setAnimation = {0x9a7a30, "void (*)(void *, const char *, int)", "4885d20f8453020000555641564883ec50c6816e14000000458bf0803a00"},
        get = {0x9f6210, "void *(*)(void *, int)", "4c8d491081fafe7f000077478bcac1f9"},
    }
    local tier0Build = {name = "tier0.dll", timestamp = 0x6af4a3e4, size = 0x401000}
    local function resolveSpawner(resource)
        local f = {}
        local tier0 = verifyModule(tier0Build)
        if not tier0 or not checkBytes(tier0 + 0x12ddc0, "488bd1488b0d8ee62700488b0148ff6008")
            or not checkBytes(tier0 + 0x12de00, "488bd1488b0d4ee62700488b0148ff6018")
            or (number(tier0 + 0x3ac458, "uintptr_t") or 0) == 0 then
            return nil, "Аллокатор движка не прошёл проверку"
        end
        f.alloc = ffi.cast("void *(*)(size_t)", tier0 + 0x12ddc0)
        f.free = ffi.cast("void (*)(void *)", tier0 + 0x12de00)

        local precache = resource.engineBase + 0x1ae2b0
        if number(resource.serviceTable + 35 * 8, "uintptr_t") ~= precache
            or not checkBytes(precache, "48895c240848896c24104889742418574881ecf00000004883795800498bf1418bf88bea488bd9747b4585c074") then
            return nil, "Функция precache не прошла проверку"
        end
        f.precache = ffi.cast("void (*)(void *, uint32_t, int, const dance_probe_spawn *, const float *)", precache)

        for name, method in pairs(clientFunctions) do
            local entry = resource.clientBase + method[1]
            if not checkBytes(entry, method[3]) then return nil, "Функция пропа не совпала: " .. name end
            f[name] = ffi.cast(method[2], entry)
        end

        local system = number(address(resource.service) + 0x58, "uintptr_t")
        if not system or not read(system, 16) then return nil, "Система сущностей недоступна" end
        f.system = ffi.cast("void *", system)
        return f
    end

    local propClass = "prop_dynamic_override"
    local keys = {
        {0xc61b1c62, "classname"}, {0xc8bfbc06, "model"}, {0xe4200216, "origin"},
        {0xba98dacf, "angles"}, {0xcc9643e1, "solid"}, {0x87219ed5, "DefaultAnim"},
        {0xefa48bb8, "rendermode"},
    }
    local function identify(f, prop, clientOnly)
        local ptr = address(prop)
        if ptr == 0 then return nil end
        local identity = number(ptr + 0x10, "uintptr_t")
        if not identity or number(identity, "uintptr_t") ~= ptr then return nil end
        local handle = number(identity + 0x10, "uint32_t")
        if not handle or handle == 0xffffffff then return nil end
        local index = handle % 0x8000
        if index > 0x7ffe or (clientOnly and index < 0x4000) or address(f.get(f.system, index)) ~= ptr then return nil end
        return identity, handle, index
    end

    local function stillExists(f, prop)
        local ptr = address(f.get(f.system, prop.index))
        if ptr ~= address(prop.pointer) then return false end
        local identity = number(ptr + 0x10, "uintptr_t")
        return identity and number(identity + 0x10, "uint32_t") == prop.handle
    end

    local function validPosition(origin)
        return math.abs(origin.x) < 32768 and math.abs(origin.y) < 32768 and math.abs(origin.z) < 32768
    end

    local function spawn(resource, f, position, angles, model, clip, hideParent)
        local values = {propClass, model or modelName, position, angles, "0", clip}
        local keyCount = clip and 6 or 5
        if hideParent then
            keyCount = 7
            values[7] = "kRenderNone"
        end
        local input = ffi.new("dance_probe_key[?]", keyCount)
        local keyStrings = {}
        for i = 1, keyCount do
            local key = keys[i]
            local name = ffi.new("char[?]", #key[2] + 1)
            ffi.copy(name, key[2], #key[2])
            keyStrings[i] = name
            input[i - 1].hash, input[i - 1].unknown = key[1], -1
        end
        local info = ffi.new("dance_probe_spawn[1]")
        local matrixStorage = ffi.new("uint8_t[63]")

        local kv = f.alloc(56)
        if address(kv) == 0 then return nil, "Движок не выделил блок KV3" end
        f.ctor(kv, nil, 0)
        local references = ffi.cast("int16_t *", address(kv) + 0x20)
        references[0] = references[0] + 1

        local function dropKeyValues()
            references[0] = references[0] - 1
            if references[0] <= 0 then f.dtor(kv) f.free(kv) end
        end

        for i = 1, keyCount do
            local value = values[i]
            input[i - 1].name = keyStrings[i]
            local slot = f.find(kv, input + (i - 1))
            if address(slot) == 0 then
                dropKeyValues()
                return nil, "KV3 отклонил ключ " .. keys[i][2]
            end
            f.set(kv, slot, value)
        end

        local groupId = f.group(f.system)
        local pointer = f.create(f.system, groupId, propClass, 0, -1, -1, false)
        local identity, handle, index = identify(f, pointer, true)
        if not identity then
            dropKeyValues()
            return nil, "Движок не вернул подтверждённую клиентскую сущность"
        end

        info[0].identity, info[0].kv, info[0].flags = identity, address(kv), 0x1ffffffffffff
        local raw = address(matrixStorage)
        local matrix = ffi.cast("float *", raw + (16 - raw % 16) % 16)
        matrix[0], matrix[5], matrix[10] = 1, 1, 1
        f.precache(resource.service, groupId, 1, info, matrix)
        local prop = {pointer = pointer, handle = handle, index = index}
        local flags = stillExists(f, prop) and number(identity + 0x30, "uint32_t")
        if not flags or math.floor(flags / 0x200) % 2 ~= 0 then
            dropKeyValues()
            return nil, "Проп отклонён на этапе precache"
        end

        f.queue(f.system, ffi.cast("void *", identity), kv)
        f.execute(f.system)
        dropKeyValues()
        if not stillExists(f, prop) then return nil, "Проп исчез после спавна" end
        return prop
    end

    local followRva = 0x2190d0
    local followBytes = "48895c24084889742410574883ec2033db488bf2488bf94584c07452488b41104c8b004d85c07426488b4008486315dd38fa01488b88880000000fb70451b9ffff0000663bc174064a8b0c00eb03488bcb488b4908488b01ff50704885c0740e483998e00100007405bbe648971c"
    local boneMergeToken = 0x1c9748e6

    local renderComponentVtableRva = 0x1ad00a0
    local refreshTintRva = 0x96b6c0
    local refreshTintBytes = "48895c2408574883ec40488bb938030000488bd94885ff0f84d50000004883b940100000000f84c700000080b94c100000007462f30f1005601616010fb6814b100000660f6ee00fb6814a1000000f5be4660f6ed80fb681491000000f5bdb660f6ed00fb68148100000488d4c24300f5bd2660f6ec80f5bc9f30f5ee0f30f5ec8f30f5ed8f30f5ed0f30f11642420e85ce97effeb4ff30f100d96c71501488d4c24300f28d9f30f114c24200f28d1e83ce97eff488b03488d542430488bcbff9040070000488b83401000000fb64817660f6ec10f5bc0f30f5905bd081701f30f1144243c488d542430488bcfe88e3f87ff488b5c24504883c4405fc3"
    local noDraw = 0x20
    local animationFrameMs = 1000 / 30
    local c4Light = {
        vtableRva = 0x1bdbb88, setSlot = 0xd38, clearSlot = 0xd40,
        setRva = 0x805e90, clearRva = 0x808940,
        setBytes = "488bc4488958184889782055488d68a14881ecd00000008bfa488bd93991641f00000f841f01000048897008488b01ff90400d00008bcf33f6baffffffff8993601f000083e901741a83f9010f858c000000e829d11d00488bc8488d05676c3d01eb0fe818d11d00488bc8",
        clearBytes = "40534883ec2083b9601f0000ff488bd97434e8b9a61d008b93601f000041b101450fb6c1488bc8e8c4cf1c00c783601f0000ffffffffc783641f0000000000004883c4205bc3c781641f0000000000004883c4205bc3",
        owner = 0x520, particle = 0x1f60, effect = 0x1f64,
        none = 0, held = 2, invalidParticle = 0xffffffff,
    }


    local function offset(t, field)
        local n = t and t:offset(field)
        if type(n) == "number" and n >= 0 and n < 0x4000 and n == math.floor(n) then return n end
    end

    local moveOriginRva = 0xa108e0
    local moveOriginBytes = "48895c240848896c2410488974241848897c242041564883ec20488bd9488bf24883e980e8f743faff84c07533f30f10060f2e83e40000"
    local moveAnglesRva = 0xa10730
    local moveAnglesBytes = "48895c240848896c24104889742418574883ec40f20f1002488db9b80000008b4208488bf2488bd9f20f11442420488bcf894424"

    local function resolveMovement(clientBase)
        local origin, angles = clientBase + moveOriginRva, clientBase + moveAnglesRva
        if offset(class.CGameSceneNode, "m_angRotation") ~= 0xb8
            or not checkBytes(origin, moveOriginBytes) or not checkBytes(angles, moveAnglesBytes) then return end
        local signature = "void (*)(void *, const float *)"
        return {origin = ffi.cast(signature, origin), angles = ffi.cast(signature, angles)}
    end

    local function resolveC4Light(clientBase)
        if offset(class.C_C4, "m_activeLightParticleIndex") ~= c4Light.particle
            or offset(class.C_C4, "m_eActiveLightEffect") ~= c4Light.effect
            or offset(class.C_BaseEntity, "m_hOwnerEntity") ~= c4Light.owner then return end
        local vtable = clientBase + c4Light.vtableRva
        local set, clear = clientBase + c4Light.setRva, clientBase + c4Light.clearRva
        if number(vtable + c4Light.setSlot, "uintptr_t") ~= set
            or number(vtable + c4Light.clearSlot, "uintptr_t") ~= clear
            or not checkBytes(set, c4Light.setBytes) or not checkBytes(clear, c4Light.clearBytes) then return end
        return {vtable = vtable, set = ffi.cast("void (*)(void *, uint32_t)", set)}
    end

    local function resolveAgent(resource, f)
        local entry = resource.clientBase + followRva
        if not checkBytes(entry, followBytes) then return nil, "FollowEntity не прошёл проверку" end
        local node = offset(class.C_BaseEntity, "m_pGameSceneNode")
        local state = offset(class.CSkeletonInstance, "m_modelState")
        local name = offset(class.CModelState, "m_ModelName")
        local attachment = offset(class.CGameSceneNode, "m_hierarchyAttachName")
        local parent = offset(class.CGameSceneNode, "m_pParent")
        local owner = offset(class.CGameSceneNode, "m_pOwner")
        if not (node and state and name and attachment and parent and owner) then
            return nil, "В схеме не найдены поля модели агента"
        end
        local component = offset(class.C_BaseModelEntity, "m_CRenderComponent")
        local enabled = offset(class.CRenderComponent, "m_bEnableRendering")
        local effects = offset(class.C_BaseEntity, "m_fEffects")
        local renderInput = offset(class.C_BaseEntity, "m_pRenderComponent")
        local renderAlpha = offset(class.C_BaseModelEntity, "m_pClientAlphaProperty")
        local tint = offset(class.C_BaseModelEntity, "m_ClientOverrideTint")
        local useTint = offset(class.C_BaseModelEntity, "m_bUseClientOverrideTint")
        local refreshTint = resource.clientBase + refreshTintRva
        if component ~= 0xaf8 or enabled ~= 0x58 or effects ~= 0x52c
            or renderInput ~= 0x338 or renderAlpha ~= 0x1040 or tint ~= 0x1048 or useTint ~= 0x104c
            or not checkBytes(refreshTint, refreshTintBytes) then
            return nil, "Поля прозрачности модели не прошли проверку"
        end
        f.follow = ffi.cast("void (*)(void *, void *, bool)", entry)
        f.refreshTint = ffi.cast("void (*)(void *)", refreshTint)
        return {node = node, model = state + name, attachment = attachment, parent = parent, owner = owner,
            component = component, enabled = enabled, effects = effects, renderInput = renderInput,
            renderAlpha = renderAlpha, tint = tint, useTint = useTint,
            child = offset(class.CGameSceneNode, "m_pChild"),
            sibling = offset(class.CGameSceneNode, "m_pNextSibling"),
            arms = offset(class.C_CSPlayerPawn, "m_hHudModelArms"),
            weaponAttachment = offset(class.C_EconEntity, "m_hViewmodelAttachment"),
            c4Light = resolveC4Light(resource.clientBase), movement = resolveMovement(resource.clientBase)}
    end

    local function readModelName(at)
        if not at or at < 65536 then return nil, "Поле имени модели агента пустое" end
        local segments, remaining = {}, 261
        while remaining > 0 do
            local count = math.min(remaining, 64, 4096 - at % 4096)
            local buffer = read(at, count)
            if not buffer then return nil, "Строка модели агента недоступна" end
            local chunk = ffi.string(buffer, count)
            local zero = chunk:find("\0", 1, true)
            if zero then
                segments[#segments + 1] = chunk:sub(1, zero - 1)
                local path = table.concat(segments)
                local root = path:match("^([a-zA-Z]+)/")
                if (root == "agents" or root == "characters")
                    and path:match("^[a-zA-Z0-9_./%-]+%.vmdl$")
                    and not path:find("..", 1, true) and not path:find("//", 1, true) then
                    return path
                end
                return nil, "В поле модели агента нет допустимого пути VMDL"
            end
            segments[#segments + 1] = chunk
            at, remaining = at + count, remaining - count
        end
        return nil, "Путь модели агента длиннее 260 байт"
    end

    local function modelOf(player, schema)
        local ptr = address(player:data())
        if ptr == 0 then return nil, "Нет адреса локального агента" end
        local node = number(ptr + schema.node, "uintptr_t")
        if not node or node == 0 then return nil, "У агента нет узла сцены" end
        if number(node + schema.owner, "uintptr_t") ~= ptr then
            return nil, "Узел сцены принадлежит другой сущности"
        end
        return readModelName(number(node + schema.model, "uintptr_t"))
    end

    local function mergeAgent(f, schema, child, parent)
        if not stillExists(f, child) or not stillExists(f, parent) then return false end
        local childNode = number(address(child.pointer) + schema.node, "uintptr_t")
        local parentNode = number(address(parent.pointer) + schema.node, "uintptr_t")
        if not childNode or childNode == 0 or not parentNode or parentNode == 0 then return false end
        if number(childNode + schema.owner, "uintptr_t") ~= address(child.pointer)
            or number(parentNode + schema.owner, "uintptr_t") ~= address(parent.pointer) then return false end
        f.follow(child.pointer, parent.pointer, true)
        return stillExists(f, child) and stillExists(f, parent)
            and number(childNode + schema.parent, "uintptr_t") == parentNode
            and number(childNode + schema.attachment, "uint32_t") == boneMergeToken
    end

    local function followPlayer(job, origin, yaw)
        local schema = job.agentSchema
        if not schema.movement or not (math.abs(yaw) < 10000) then return false end
        local ptr = address(job.prop.pointer)
        local node = number(ptr + schema.node, "uintptr_t")
        if not node or number(node + schema.owner, "uintptr_t") ~= ptr
            or number(node + schema.parent, "uintptr_t") ~= 0 then return false end
        if not job.transform then job.transform = ffi.new("float[3]") end
        local transform = job.transform
        local previous = job.position
        if origin.x ~= previous.x or origin.y ~= previous.y or origin.z ~= previous.z then
            transform[0], transform[1], transform[2] = origin.x, origin.y, origin.z
            schema.movement.origin(ffi.cast("void *", node), transform)
            job.position = origin
        end
        if yaw ~= job.yaw then
            transform[0], transform[1], transform[2] = 0, yaw, 0
            schema.movement.angles(ffi.cast("void *", node), transform)
            job.yaw = yaw
        end
        return true
    end

    local function hasNoDraw(effects)
        return math.floor(effects / noDraw) % 2 ~= 0
    end

    local function renderComponent(resource, schema, ptr)
        local component = number(ptr + schema.component, "uintptr_t")
        if not component or number(component, "uintptr_t") ~= resource.clientBase + renderComponentVtableRva then
            return nil
        end
        return component
    end

    local function tintSnapshot(job, ptr)
        local schema = job.agentSchema
        local component = renderComponent(job.methods, schema, ptr)
        local alpha = number(ptr + schema.renderAlpha, "uintptr_t")
        if not component or number(ptr + schema.renderInput, "uintptr_t") ~= component
            or not alpha or not read(alpha, 24) then return nil end
        local rgba = number(ptr + schema.tint, "uint32_t")
        local enabled = number(ptr + schema.useTint, "uint8_t")
        if not rgba or (enabled ~= 0 and enabled ~= 1) then return nil end
        return {component = component, alpha = alpha, rgba = rgba, enabled = enabled,
            transparent = enabled == 1 and rgba % 0x1000000 or 0xffffff}
    end

    local function setModelTint(job, entityRecord, tintState, hidden)
        if not stillExists(job.spawner, entityRecord) then return false end
        local ptr = address(entityRecord.pointer)
        local schema = job.agentSchema
        if renderComponent(job.methods, schema, ptr) ~= tintState.component
            or number(ptr + schema.renderInput, "uintptr_t") ~= tintState.component
            or number(ptr + schema.renderAlpha, "uintptr_t") ~= tintState.alpha then return false end
        local oldRgba = number(ptr + schema.tint, "uint32_t")
        local oldEnabled = number(ptr + schema.useTint, "uint8_t")
        if not oldRgba or (oldEnabled ~= 0 and oldEnabled ~= 1) then return false end

        local rgba = hidden and tintState.transparent or tintState.rgba
        local enabled = hidden and 1 or tintState.enabled
        if oldRgba ~= rgba or oldEnabled ~= enabled then
            if oldRgba ~= rgba then ffi.cast("uint32_t *", ptr + schema.tint)[0] = rgba end
            if oldEnabled ~= enabled then ffi.cast("uint8_t *", ptr + schema.useTint)[0] = enabled end
            job.spawner.refreshTint(entityRecord.pointer)
        end
        return number(ptr + schema.tint, "uint32_t") == rgba
            and number(ptr + schema.useTint, "uint8_t") == enabled
    end

    local function modelVisibility(job, pointer, expectedHandle)
        local f, schema = job.spawner, job.agentSchema
        local _, handle, index = identify(f, pointer)
        if not handle or (expectedHandle and handle ~= expectedHandle) then return nil end
        local ptr = address(pointer)
        local component = renderComponent(job.methods, schema, ptr)
        if not component then return nil end
        local enabled = number(component + schema.enabled, "uint8_t")
        local effects = number(ptr + schema.effects, "uint32_t")
        if not effects or (enabled ~= 0 and enabled ~= 1) then return nil end
        return {pointer = pointer, handle = handle, index = index, component = component,
            enabled = enabled, noDraw = hasNoDraw(effects), tint = tintSnapshot(job, ptr)}
    end

    local function changeVisibility(job, original, hidden)
        local schema = job.agentSchema
        if not stillExists(job.spawner, original) then return false end
        local ptr = address(original.pointer)
        local component = renderComponent(job.methods, schema, ptr)
        local effects = number(ptr + schema.effects, "uint32_t")
        local currentEnabled = component == original.component and number(component + schema.enabled, "uint8_t")
        local componentValid = currentEnabled == 0 or currentEnabled == 1
        if not effects or (hidden and not componentValid) then return false end

        local wantNoDraw = hidden or original.noDraw
        if hasNoDraw(effects) ~= wantNoDraw then
            effects = effects + (wantNoDraw and noDraw or -noDraw)
            ffi.cast("uint32_t *", ptr + schema.effects)[0] = effects
        end

        local enabled = hidden and 0 or original.enabled
        if componentValid and currentEnabled ~= enabled then ffi.cast("uint8_t *", component + schema.enabled)[0] = enabled end
        local tintApplied = not original.tint or setModelTint(job, original, original.tint, hidden)
        return tintApplied and componentValid and number(ptr + schema.effects, "uint32_t") == effects
            and number(component + schema.enabled, "uint8_t") == enabled
    end

    local function heldC4Light(job, bomb)
        local ptr = address(bomb.pointer)
        if not stillExists(job.spawner, bomb) or number(ptr, "uintptr_t") ~= job.agentSchema.c4Light.vtable
            or number(ptr + c4Light.owner, "uint32_t") ~= job.playerHandle then return end
        return number(ptr + c4Light.effect, "uint32_t"), number(ptr + c4Light.particle, "uint32_t")
    end

    local function restoreC4Light(job)
        local bomb = job.hiddenC4
        if not bomb then return end
        job.hiddenC4 = nil
        local player = entity.local_pawn()
        if not player or not player:is_valid() or not player:is_alive() or player:handle() ~= job.playerHandle then return end
        local effect, particle = heldC4Light(job, bomb)
        if effect == c4Light.none and particle == c4Light.invalidParticle then
            job.agentSchema.c4Light.set(bomb.pointer, c4Light.held)
        end
    end

    local function suppressEquipment(job, player)
        local schema, f = job.agentSchema, job.spawner
        local pawn = address(job.original.pointer)
        local clone, prop = address(job.clone.pointer), address(job.prop.pointer)
        local targets, nodes, seenNodes = {}, {}, {}
        local function visit(ptr, expectedHandle)
            if ptr == 0 or ptr == clone or ptr == prop or targets[ptr] then return end
            local pointer = ffi.cast("void *", ptr)
            local _, handle = identify(f, pointer)
            if not handle or (expectedHandle and expectedHandle ~= handle) then return end
            targets[ptr] = handle
            local node = number(ptr + schema.node, "uintptr_t")
            if schema.child and schema.sibling and node and node ~= 0
                and number(node + schema.owner, "uintptr_t") == ptr and not seenNodes[node] and #nodes < 96 then
                nodes[#nodes + 1], seenNodes[node] = node, true
            end
        end
        local function visitHandle(ptr, field)
            if not field then return end
            local handle = number(ptr + field, "uint32_t")
            if not handle or handle == 0 or handle == 0xffffffff then return end
            visit(address(f.get(f.system, handle % 0x8000)), handle)
        end

        visit(pawn, job.original.handle)
        visitHandle(pawn, schema.arms)
        local bomb
        local function visitItems(collection, attachment, weapons)
            if not collection then return end
            for i = 0, math.min(#collection, 32) - 1 do
                local item = collection[i]
                if item and item:is_valid() then
                    local ptr = address(item:data())
                    visit(ptr, item:handle())
                    local handle = targets[ptr]
                    if handle then
                        visitHandle(ptr, attachment)
                        if weapons and schema.c4Light and number(ptr, "uintptr_t") == schema.c4Light.vtable then
                            bomb = {pointer = item:data(), handle = handle, index = handle % 0x8000}
                        end
                    end
                end
            end
        end
        local ok, err = pcall(function()
            visitItems(player:weapons(), schema.weaponAttachment, true)
            visitItems(player.m_hMyWearables, schema.weaponAttachment)
        end)
        if not ok and not job.equipmentReadReported then
            job.equipmentReadReported = true
            logError("Не удалось прочитать часть экипировки: " .. tostring(err))
        end

        local nextNode, visitedLinks = 1, 0
        while nextNode <= #nodes and visitedLinks < 96 do
            local parent = nodes[nextNode]
            local child = number(parent + schema.child, "uintptr_t")
            nextNode = nextNode + 1
            while child and child ~= 0 and visitedLinks < 96 do
                if number(child + schema.parent, "uintptr_t") ~= parent then break end
                local owner = number(child + schema.owner, "uintptr_t")
                if owner and owner ~= 0 and number(owner + schema.node, "uintptr_t") == child then visit(owner) end
                child = number(child + schema.sibling, "uintptr_t")
                visitedLinks = visitedLinks + 1
            end
        end

        local hidden = job.equipment
        for ptr, record in pairs(hidden) do
            local exists = stillExists(f, record)
            if not exists or targets[ptr] ~= record.handle
                or renderComponent(job.methods, schema, ptr) ~= record.component then
                if exists then changeVisibility(job, record, false) end
                hidden[ptr] = nil
            end
        end
        targets[pawn] = nil
        for ptr, handle in pairs(targets) do
            local record = hidden[ptr] or modelVisibility(job, ffi.cast("void *", ptr), handle)
            if record then
                hidden[ptr] = record
                changeVisibility(job, record, true)
            end
        end

        if job.hiddenC4 and (not bomb or bomb.handle ~= job.hiddenC4.handle or bomb.pointer ~= job.hiddenC4.pointer) then
            restoreC4Light(job)
        end
        if bomb then
            local effect, particle = heldC4Light(job, bomb)
            if effect == c4Light.held and particle and particle ~= c4Light.invalidParticle then
                schema.c4Light.set(bomb.pointer, c4Light.none)
                local updatedEffect, updatedParticle = heldC4Light(job, bomb)
                if updatedEffect == c4Light.none and updatedParticle == c4Light.invalidParticle then
                    job.hiddenC4 = bomb
                end
            end
        end
    end

    local function hideCrosshair(job)
        local crosshair = console and console.crosshair
        if crosshair and crosshair.is_valid and crosshair.value == true then
            job.restoreCrosshair = pcall(utils.console, "crosshair", 0)
        end
    end

    local function cameraOrigin(player, view, amount)
        local origin = view.origin
        local forward = view.angles:forward()
        local distance = cameraDistance:get()
        local wanted = origin - forward * distance
        local hit = trace.sphere(origin, wanted, 4, trace.filter(player))
        if not hit or hit.startsolid or type(hit.fraction) ~= "number"
            or not (hit.fraction > 0 and hit.fraction <= 1) then return nil end
        return origin - forward * (amount * math.max(0, hit.fraction * distance - 3.2))
    end

    local function currentSession()
        local level = globals.level_name
        if netchan.is_playback == true or type(level) ~= "string" or level == "" then return nil end

        local channel = netchan.data and address(netchan.data()) or 0
        local loopback = netchan.is_loopback == true
        if channel == 0 and not loopback then return nil end
        local server = netchan.address
        if type(server) ~= "string" or server == "" then server = nil end
        return {level = level, channel = channel, server = server, age = netchan.time_connected}
    end

    local request, active, stopRequested, danceCamera
    local function sameSession(job)
        local old = job.session
        local current = currentSession()
        if not current or current.level ~= old.level or current.channel ~= old.channel then return false end
        if old.server and current.server and current.server ~= old.server then return false end
        return type(old.age) ~= "number" or type(current.age) ~= "number" or current.age + 0.25 >= old.age
    end

    local function cameraAmount(camera, now)
        local t = math.max(0, math.min(1, (now - camera.started) / camera.duration))
        local eased = t * t * (3 - 2 * t)
        return camera.from + (camera.target - camera.from) * eased
    end

    local function aimDanceCamera(job, target)
        local now = tonumber(utils.timestamp())
        if not now then danceCamera = nil return end
        local current = danceCamera
        local from = current and current.playerHandle == job.playerHandle and sameSession(current)
            and cameraAmount(current, now) or 0
        if from == 0 and target == 0 then danceCamera = nil return end
        local fullDuration = target == 1 and 220 or 180
        danceCamera = {session = job.session, playerHandle = job.playerHandle, from = from, target = target,
            started = now, duration = math.max(55, fullDuration * math.abs(target - from))}
    end

    local function stopSound(job)
        if not job.audio then return true end
        if sound.PlaySoundW(nil, nil, 0) == 0 then return false end
        job.audio = nil
        return true
    end

    local volumeSettleMs = 90
    local function updateMusic(job, now, resume)
        if not job.emote.wav or job.musicEnded then return end
        if not musicEnabled:get() then
            job.pendingVolume = nil
            if stopSound(job) then job.musicLevel = nil end
            return
        end

        local level = volume:get()
        if level == job.musicLevel then
            job.pendingVolume = nil
            return
        end
        if level > 0 and job.musicLevel and job.musicLevel > 0 then
            if job.pendingVolume ~= level then
                job.pendingVolume, job.volumeChangedAt = level, now
            end
            if now - job.volumeChangedAt < volumeSettleMs then return end
        end
        if not stopSound(job) then return end

        job.musicLevel, job.pendingVolume = level, nil
        if level == 0 then return end
        local audio, ended = playSound(job.emote.wav, level, resume and job.propStarted or nil)
        job.audio, job.musicEnded = audio, ended
        if not audio and not ended then
            logError(job.emote[2] .. " · не удалось воспроизвести WAV")
        end
    end

    local function release(errorMessage)
        request, stopRequested = nil, nil
        if active then
            local job = active
            active = nil
            stopSound(job)
            if job.restoreCrosshair then pcall(utils.console, "crosshair", 1) end
            if sameSession(job) then
                if job.camera then aimDanceCamera(job, 0) end
                for _, record in pairs(job.equipment or {}) do
                    if stillExists(job.spawner, record) then changeVisibility(job, record, false) end
                end
                if job.restoreOriginal and stillExists(job.spawner, job.original)
                    and not changeVisibility(job, job.original, false) then
                    logError("Не удалось вернуть исходный режим видимости")
                end
                restoreC4Light(job)
                if job.clone and stillExists(job.spawner, job.clone) then
                    job.spawner.remove(job.clone.pointer)
                end
                if job.prop and stillExists(job.spawner, job.prop) then
                    job.spawner.remove(job.prop.pointer)
                end
                job.methods.destroy(job.methods.service, job.handle)
            elseif job.camera then
                danceCamera = nil
            end
        end
        if errorMessage then logError(errorMessage) end
    end

    local function startPlayback(job)
        hideCrosshair(job)
        local entry = job.emote
        local transition = entry.nextSequence and (entry.transitionMs or entry.cycleMs)
        local onePass = transition and transition + entry.nextCycleMs or entry.cycleMs
        job.endMs = entry.endMs or math.max(onePass, entry.soundMs or 0)
        job.transitionMs = transition
        job.loopAnimation = loopAnimation:get()
        local looping = not transition and (job.loopAnimation or job.endMs - entry.cycleMs >= animationFrameMs)
        job.spawner.setAnimation(job.prop.pointer, entry[4], looping and 1 or 0)
        job.propStarted = tonumber(utils.timestamp())
        updateMusic(job, job.propStarted)
    end

    playSelectedDance = function(entry)
        if not currentSession() then return end
        request = entry
    end
    stopSelectedDance = function() stopRequested = true end

    events.pre_render:set(function()
        if stopRequested then
            release()
            return
        end
        if request then
            local entry = request
            request = nil
            if active then release() end
            local session = currentSession()
            if not session then return end
            local player = entity.local_pawn()
            if not player or not player:is_valid() or not player:is_alive() then return end
            local methods, errorMessage = resolve()
            if not methods then logError(errorMessage) return end
            local spawner
            spawner, errorMessage = resolveSpawner(methods)
            if not spawner then logError(errorMessage) return end
            local agentSchema
            agentSchema, errorMessage = resolveAgent(methods, spawner)
            if not agentSchema then logError(errorMessage) return end
            local name = ffi.new("char[?]", #modelName + 1)
            ffi.copy(name, modelName, #modelName)
            local names = ffi.new("const char *[1]", name)
            local handle = methods.create(methods.service, 1, names, 1, methods.reason, 2)
            if address(handle) == 0 then logError("Движок не создал манифест") return end
            active = {methods = methods, handle = handle, name = name, names = names, spawner = spawner,
                started = tonumber(utils.timestamp()), session = session, agentSchema = agentSchema, emote = entry}
        end

        local job = active
        if not job then return end
        local now = tonumber(utils.timestamp())
        if not sameSession(job) then
            release()
        elseif job.prop then
            if not stillExists(job.spawner, job.prop) then
                release("Клиентский проп больше не существует")
            elseif job.clone and not stillExists(job.spawner, job.clone) then
                release("Копия агента исчезла")
            elseif not job.loopAnimation and now - job.propStarted >= job.endMs then
                release()
            else
                local elapsed = now - job.propStarted
                if job.transitionMs and elapsed >= job.transitionMs then
                    local loop = job.loopAnimation or job.endMs - job.transitionMs - job.emote.nextCycleMs >= animationFrameMs
                    job.spawner.setAnimation(job.prop.pointer, job.emote.nextSequence, loop and 1 or 0)
                    job.transitionMs = nil
                end
                if job.clone then
                    local me = entity.local_pawn()
                    if not me or not me:is_valid() or not me:is_alive() or me:handle() ~= job.playerHandle then
                        release()
                    else
                        local origin = me:origin()
                        local dx = origin.x - job.position.x
                        local dy = origin.y - job.position.y
                        local dz = origin.z - job.position.z
                        local walking = allowWalking:get()
                        if not validPosition(origin) then
                            release("Некорректная позиция игрока")
                        elseif walking and not followPlayer(job, origin, me:angles():yaw()) then
                            release("Не удалось обновить позицию танца при ходьбе")
                        elseif not walking and dx * dx + dy * dy + dz * dz > 64 then
                            release()
                        elseif not changeVisibility(job, job.original, true) then
                            release("Не удалось удержать исходную модель скрытой")
                        elseif job.helperTint and not setModelTint(job, job.prop, job.helperTint, true) then
                            release("Прозрачность управляющего пропа сброшена")
                        else
                            suppressEquipment(job, me)
                        end
                    end
                end
                if active == job then updateMusic(job, now, true) end
            end
        elseif job.methods.loaded(job.methods.service, job.handle) then

            local player = entity.local_pawn()
            if not player or not player:is_valid() or not player:is_alive() then
                release()
                return
            end
            local ok, model, modelError = pcall(modelOf, player, job.agentSchema)
            if not ok then
                release("Ошибка чтения агента: " .. tostring(model))
                return
            end
            if not model then release(modelError) return end
            job.original = modelVisibility(job, player:data(), player:handle())
            if not job.original or not job.original.tint then
                release("Не удалось сохранить видимость исходного агента")
                return
            end
            local pose, yaw = player:origin(), player:angles():yaw()
            if not validPosition(pose) or not (math.abs(yaw) < 10000) then
                release("Некорректная позиция или угол агента")
                return
            end
            if allowWalking:get() and not job.agentSchema.movement then
                release("Ходьба во время танца недоступна на этом билде")
                return
            end
            local position = string.format("%.2f %.2f %.2f", pose.x, pose.y, pose.z)
            local angles = string.format("0 %.2f 0", yaw)
            local prop, why = spawn(job.methods, job.spawner, position, angles, modelName, job.emote[4], true)
            if not prop then release(why) return end
            job.prop = prop
            local clone
            clone, why = spawn(job.methods, job.spawner, position, angles, model)
            if not clone then release("Копия агента: " .. why) return end
            job.clone = clone
            if not mergeAgent(job.spawner, job.agentSchema, clone, prop) then
                release("Привязка модели к скелету не подтверждена")
                return
            end
            job.helperTint = tintSnapshot(job, address(prop.pointer))
            if job.helperTint and not setModelTint(job, prop, job.helperTint, true) then job.helperTint = nil end
            job.restoreOriginal = true
            if not changeVisibility(job, job.original, true) then
                release("Не удалось скрыть исходного агента")
                return
            end
            job.position, job.playerHandle, job.yaw = pose, job.original.handle, yaw
            job.camera = true
            job.equipment = {}
            suppressEquipment(job, player)
            startPlayback(job)
            aimDanceCamera(job, 1)
        elseif now - job.started >= 15000 then
            release("Движок не завершил загрузку за 15 секунд")
        end
    end)
    events.override_view:set(function(view)
        freezeWheelView(view)
        local camera = danceCamera
        if not camera then return end
        local player = entity.local_pawn()
        if not sameSession(camera) or not player or not player:is_valid() or not player:is_alive()
            or player:handle() ~= camera.playerHandle then
            danceCamera = nil
            return
        end
        local now = tonumber(utils.timestamp())
        if not now then return end
        local amount = cameraAmount(camera, now)
        if amount <= 0 then
            if camera.target == 0 then danceCamera = nil end
            return
        end
        local origin = cameraOrigin(player, view, amount)
        if origin then view.origin = origin end
    end)
    events.round_start:set(function()
        release()
        danceCamera = nil
    end)
    events.config_state:set(function()
        resetWheel()
        release()
        danceCamera = nil
    end)
    events.shutdown:set(function()
        resetWheel()
        release()
        danceCamera = nil
        if closeInstaller then closeInstaller() end
    end)
end

do
    ffi.cdef[[
        typedef struct {
            uint32_t cb; void *reserved, *desktop, *title;
            uint32_t x, y, width, height, charsX, charsY, fill, flags;
            uint16_t show, reservedSize; void *reservedBytes, *input, *output, *error;
        } emote_install_startup;
        typedef struct { void *process, *thread; uint32_t pid, tid; } emote_install_process;
        uint32_t __stdcall GetEnvironmentVariableW(const uint16_t *, uint16_t *, uint32_t);
        uint32_t __stdcall GetSystemDirectoryW(uint16_t *, uint32_t);
        uint32_t __stdcall GetModuleFileNameW(void *, uint16_t *, uint32_t);
        int __stdcall WideCharToMultiByte(uint32_t, uint32_t, const uint16_t *, int, char *, int, void *, void *);
        int __stdcall CreateProcessW(const uint16_t *, uint16_t *, void *, void *, int, uint32_t, void *,
            const uint16_t *, emote_install_startup *, emote_install_process *);
        int __stdcall GetExitCodeProcess(void *, uint32_t *);
        int __stdcall CryptBinaryToStringA(const void *, uint32_t, uint32_t, char *, uint32_t *);
    ]]
    local win = ffi.load("kernel32")
    local crypto = ffi.load("crypt32")
    local function utf16(s)
        local n = win.MultiByteToWideChar(65001, 8, s, -1, nil, 0)
        if n <= 1 then return end
        local data = ffi.new("uint16_t[?]", n)
        if win.MultiByteToWideChar(65001, 8, s, -1, data, n) == n then return data, n - 1 end
    end
    local function utf8(wide, length)
        if length == 0 or length >= 32768 then return end
        local n = win.WideCharToMultiByte(65001, 0, wide, length, nil, 0, nil, nil)
        if n <= 0 then return end
        local buffer = ffi.new("char[?]", n)
        if win.WideCharToMultiByte(65001, 0, wide, length, buffer, n, nil, nil) == n then
            return ffi.string(buffer, n)
        end
    end
    local pathBuffer = ffi.new("uint16_t[32768]")
    local appData = utf8(pathBuffer, win.GetEnvironmentVariableW(utf16("LOCALAPPDATA"), pathBuffer, 32768))
    if appData then resourceRoot = appData .. "\\RezTOP\\EmoteWheel\\v1.0.0" end
    gameResourceDir = function()
        local client = win.GetModuleHandleA("client.dll")
        if client == nil then return end
        local length = win.GetModuleFileNameW(client, pathBuffer, 32768)
        local path = utf8(pathBuffer, length)
        return path and path:match("^(.*)\\[Bb][Ii][Nn]\\[Ww][Ii][Nn]64\\[Cc][Ll][Ii][Ee][Nn][Tt]%.[Dd][Ll][Ll]$")
    end

    local installScript = [==[
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$root = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'RezTOP\EmoteWheel\v1.0.0'
$modelPath = Join-Path ([Environment]::CurrentDirectory) 'characters\kolka\fortnite_dance.vmdl_c'
$modelHash = '45BFA5B2D87D0305CF29D076F8C7B15B5F086D8C521FC8FB4683C812054C43EE'
$url = 'https://github.com/ennuiplug/flex/releases/download/v1.0.0/emotes.zip'
$archiveHash = 'C214489498AC541C4C87CBF1F2ABDCF528E44911597CE9D391A592752AC04DF0'
$mutex = New-Object Threading.Mutex($false, 'Local\RezTOP.EmoteWheel.v1')
$owns = $false
$zip = $null
$part = $null
$modelPart = $null
$exitCode = 0
try {
    try { $owns = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $owns = $true }
    if (-not $owns) { exit 2 }
    [void][IO.Directory]::CreateDirectory($root)
    $hasModel = [IO.File]::Exists($modelPath)
    if ($hasModel -and (Get-FileHash -LiteralPath $modelPath -Algorithm SHA256).Hash -ne $modelHash) {
        throw "Existing model differs from the release: $modelPath"
    }
    $part = Join-Path $root ([IO.Path]::GetRandomFileName() + '.zip')
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $part
    if ((Get-Item -LiteralPath $part).Length -ne 250242910 -or
        (Get-FileHash -LiteralPath $part -Algorithm SHA256).Hash -ne $archiveHash) {
        throw 'Resource archive checksum does not match release'
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($part)
    $icons = @($zip.Entries | Where-Object { $_.FullName -cmatch '^emotes/icons/[a-zA-Z0-9_.-]+\.png$' })
    $music = @($zip.Entries | Where-Object { $_.FullName -cmatch '^emotes/music/[a-zA-Z0-9_.-]+\.wav$' -and $_.Name -notlike 'unused_*' })
    $model = $zip.GetEntry('emotes/csgo_addons/characters/kolka/fortnite_dance.vmdl_c')
    if ($icons.Count -ne 118 -or $music.Count -ne 102 -or -not $model) { throw 'Incomplete archive' }
    $iconDir = [IO.Directory]::CreateDirectory((Join-Path $root 'icons')).FullName
    $musicDir = [IO.Directory]::CreateDirectory((Join-Path $root 'music')).FullName
    foreach ($asset in $icons) {
        [IO.Compression.ZipFileExtensions]::ExtractToFile($asset, (Join-Path $iconDir $asset.Name), $true)
    }
    foreach ($asset in $music) {
        [IO.Compression.ZipFileExtensions]::ExtractToFile($asset, (Join-Path $musicDir $asset.Name), $true)
    }
    if (-not $hasModel) {
        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($modelPath))
        $modelPart = $modelPath + '.' + [IO.Path]::GetRandomFileName()
        [IO.Compression.ZipFileExtensions]::ExtractToFile($model, $modelPart, $false)
        if ((Get-FileHash -LiteralPath $modelPart -Algorithm SHA256).Hash -ne $modelHash) { throw 'Model checksum does not match release' }
        [IO.File]::Move($modelPart, $modelPath)
    }
    [IO.File]::WriteAllText((Join-Path $root 'installed'), $archiveHash)
} catch {
    $exitCode = 1
    if ([IO.Directory]::Exists($root)) {
        [IO.File]::WriteAllText((Join-Path $root 'install-error.txt'), $_.Exception.Message)
    }
} finally {
    if ($zip) { $zip.Dispose() }
    if ($part -and [IO.File]::Exists($part)) { [IO.File]::Delete($part) }
    if ($modelPart -and [IO.File]::Exists($modelPart)) { [IO.File]::Delete($modelPart) }
    if ($owns) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
exit $exitCode
]==]

    local installer = tab:group("Ресурсы", "right")
    local status = installer:label("Ресурсы не установлены")
    local process
    local exitCode = ffi.new("uint32_t[1]")
    local function fileExists(path)
        local wide = widePath(path)
        if not wide then return false end
        local attr = tonumber(win.GetFileAttributesW(wide))
        return attr ~= 0xffffffff and math.floor(attr / 16) % 2 == 0
    end
    local function installed(gameDir)
        return resourceRoot and gameDir and fileExists(resourceRoot .. "\\installed")
            and fileExists(gameDir .. "\\characters\\kolka\\fortnite_dance.vmdl_c")
    end
    local function encodedCommand()
        local body, chars = utf16(installScript)
        if not body then return end
        local count = ffi.new("uint32_t[1]")
        local flags = 0x40000001
        if crypto.CryptBinaryToStringA(body, chars * 2, flags, nil, count) == 0 then return end
        local encoded = ffi.new("char[?]", count[0])
        if crypto.CryptBinaryToStringA(body, chars * 2, flags, encoded, count) == 0 then return end
        return ffi.string(encoded)
    end

    local gameDir = gameResourceDir()
    if installed(gameDir) then status:name("Ресурсы установлены") end
    installer:button("Скачать ресурсы", function()
        if process then return end
        gameDir = gameResourceDir()
        if not resourceRoot or not gameDir then status:name("Не удалось определить папки установки") return end
        if installed(gameDir) then status:name("Ресурсы установлены") return end
        local base = utf8(pathBuffer, win.GetSystemDirectoryW(pathBuffer, 32768))
        local encoded = encodedCommand()
        if not base or not encoded then status:name("Не удалось подготовить установщик") return end
        local exe = base .. "\\WindowsPowerShell\\v1.0\\powershell.exe"
        local command = utf16('"' .. exe .. '" -NoProfile -NonInteractive -EncodedCommand ' .. encoded)
        local startup, info = ffi.new("emote_install_startup[1]"), ffi.new("emote_install_process[1]")
        startup[0].cb = ffi.sizeof("emote_install_startup")
        if not command or win.CreateProcessW(utf16(exe), command, nil, nil, 0, 0x08000000, nil,
            widePath(gameDir), startup, info) == 0 then
            status:name("Не удалось запустить установщик")
            return
        end
        process = info[0].process
        win.CloseHandle(info[0].thread)
        status:name("Загрузка и установка ресурсов (250 МБ)")
    end)

    closeInstaller = function()
        if process then win.CloseHandle(process) process = nil end
    end
    tickInstaller = function(icons)
        if not process then return end
        local ok = win.GetExitCodeProcess(process, exitCode) ~= 0
        if ok and exitCode[0] == 259 then return end
        closeInstaller()
        if ok and exitCode[0] == 0 and installed(gameDir) then
            for key in pairs(icons) do icons[key] = nil end
            status:name("Ресурсы установлены")
        elseif ok and exitCode[0] == 2 then
            status:name("Установка уже запущена")
        else
            status:name("Ошибка установки · install-error.txt")
            logError("Ошибка установки ресурсов. Журнал: " .. resourceRoot .. "\\install-error.txt")
        end
    end
end
