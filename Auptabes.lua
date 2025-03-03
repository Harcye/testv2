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

local script_vers = 1
local update_url = "https://raw.githubusercontent.com/Harcye/testv2/main/uptabe.ini"
local script_url = "https://raw.githubusercontent.com/Harcye/testv2/main/Auptabes.lua"

local update_path = getWorkingDirectory() .. "/update.ini"
local new_script_path = getWorkingDirectory() .. "/Auptabes_new.lua"
local marker_path = getWorkingDirectory() .. "/update_marker.txt"
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("update", cmd_update)

    -- Если есть маркер, значит, скрипт обновился — заменяем файл
    if doesFileExist(marker_path) and doesFileExist(new_script_path) then
        os.remove(script_path)
        os.rename(new_script_path, script_path)
        os.remove(marker_path)
        sampAddChatMessage("✅ Скрипт успешно обновлён!", 0x00FF00)
    end

    check_for_update()
end

function check_for_update()
    downloadUrlToFile(update_url, update_path, function(_, status)
        if status == distatus.STATUS_ENDDOWNLOADDATA then
            local update_ini = inicfg.load(nil, update_path)
            if update_ini and update_ini.info and tonumber(update_ini.info.vers) then
                if tonumber(update_ini.info.vers) > script_vers then
                    sampAddChatMessage("📦 Доступно обновление: версия " .. update_ini.info.vers, 0x00FF00)
                    download_script()
                else
                    sampAddChatMessage("✨ У вас последняя версия скрипта.", 0x00FF00)
                end
            else
                sampAddChatMessage("❌ Ошибка: некорректные данные в update.ini", 0xFF0000)
            end
            os.remove(update_path)
        end
    end)
end

function download_script()
    downloadUrlToFile(script_url, new_script_path, function(_, status)
        if status == distatus.STATUS_ENDDOWNLOADDATA then
            local file = io.open(new_script_path, "r")
            if file then
                file:close()
                local marker = io.open(marker_path, "w")
                marker:write("update")
                marker:close()
                sampAddChatMessage("⚙️ Скрипт загружен! Перезагрузите MoonLoader.", 0xFFFF00)
                thisScript():unload() -- Выключаем текущий скрипт
            else
                sampAddChatMessage("❌ Ошибка при загрузке нового скрипта.", 0xFF0000)
            end
        end
    end)
end

function cmd_update()
    check_for_update()
    sampAddChatMessage("🔍 Проверка обновлений...", 0xFFFF00)
end
