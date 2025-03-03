script_name("Autoupdate Script")
script_author("FORMYS")
script_description("Автообновление скрипта")

require "lib.moonloader"
local inicfg = require "inicfg"
local keys = require "vkeys"
local imgui = require "imgui"
local encoding = require "encoding"
local distatus = require "moonloader".download_status

encoding.default = "CP1251"
u8 = encoding.UTF8

local update_state = false
local script_vers = 2
local script_vers_text = "1.00"
local update_url = "https://raw.githubusercontent.com/thechampguess/scripts/master/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"
local script_url = "https://raw.githubusercontent.com/thechampguess/scripts/master/autoupdate.lua"
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("update", cmd_update)
    check_for_update()
end

function check_for_update()
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == distatus.STATUS_ENDDOWNLOADDATA then
            local update_ini = inicfg.load(nil, update_path)
            if tonumber(update_ini.info.vers) > script_vers then
                sampAddChatMessage("Доступно обновление: " .. update_ini.info.vers, -1)
                update_state = true
            end
            os.remove(update_path)
            if update_state then download_script() end
        end
    end)
end

function download_script()
    downloadUrlToFile(script_url, script_path, function(id, status)
        if status == distatus.STATUS_ENDDOWNLOADDATA then
            sampAddChatMessage("Скрипт успешно обновлен!", -1)
            thisScript():reload()
        end
    end)
end

function cmd_update()
    sampShowDialog(1000, "Автообновление 2.0", "{FFFFFF} Это урок по обновлению\n{FFFF00} Новая версия доступна", "Закрыть", "", 0)
end
