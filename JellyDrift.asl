state("Jelly Drift") {
    string250 level : "UnityPlayer.dll", 0x18117F8, 0x48, 0x10, 0x0;
    long levelAddress : "UnityPlayer.dll", 0x18117F8, 0x48, 0x10;
    float igt : "UnityPlayer.dll", 0x17AEDD0, 0x8, 0x0, 0xD0, 0x0, 0x88, 0x20;
    int totalChecks : "mono-2.0-bdwgc.dll", 0x00496D20, 0x858, 0x10, 0xA50;
}

startup {
    vars.checkDict = new Dictionary<string, int>(){
	    {"Assets/Scenes/0.unity", 4},
    	{"Assets/Scenes/1.unity", 4},
	    {"Assets/Scenes/2.unity", 4},
	    {"Assets/Scenes/3.unity", 6},
	    {"Assets/Scenes/4.unity", 7}
    };

    settings.Add("subsplits", false, "Splitting for Subsplits");
    settings.SetToolTip("subsplits", "If you are using a subsplits (one for each checkpoint), use this setting");
    settings.Add("starton0", true, "Only start on Dusty Desert");
}

init {
    vars.time = 0f;
    vars.atLights = false;
    vars.levelChecks = 0;
}

update {
    if(current.igt > 0 && current.level != "Assets/Scenes/Menu.unity") {
        vars.time += (current.igt - old.igt);
    }
    if(old.levelAddress != current.levelAddress) {
        if(settings["starton0"]) {
            vars.atLights = current.level == "Assets/Scenes/0.unity";
        } else {
            vars.atLights = true;
        }
    }
}

start {
    if(vars.atLights && current.igt > 0) {
        vars.levelChecks = 0;
        vars.atLights = false;
        vars.time = current.igt;
        return true;
    }
}

split {
    if (current.totalChecks > old.totalChecks) {
        if(settings["subsplits"]) {
            return true;
        }
        vars.levelChecks++;
        return(vars.levelChecks == vars.checkDict[current.level]);
    }
}
reset {
    return(old.levelAddress != current.levelAddress && current.level == "Assets/Scenes/0.unity" && settings["starton0"]);
}
isLoading { return true; }

gameTime {
    return(TimeSpan.FromSeconds(Math.Round((float)vars.time, 2)));
}