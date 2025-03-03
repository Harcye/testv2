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

-- Настройки скрипта
local script_vers = 2
local script_vers_text = "1.00"
local update_url = "https://raw.githubusercontent.com/Harcye/testv2/main/uptabe.ini"
local script_url = "https://raw.githubusercontent.com/Harcye/testv2/main/Auptabes.lua"

-- Пути к файлам
local update_path = getWorkingDirectory() .. "/update.ini"
local temp_path = getWorkingDirectory() .. "/Auptabes_tmp.lua"
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("update", cmd_update)
    check_for_update()
end

-- Проверка наличия обновлений
function check_for_update()
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == distatus.STATUS_ENDDOWNLOADDATA then
            local update_ini = inicfg.load(nil, update_path)
            if update_ini and update_ini.info and tonumber(update_ini.info.vers) then
                if tonumber(update_ini.info.vers) > script_vers then
                    sampAddChatMessage("Доступно обновление: версия " .. update_ini.info.vers, 0x00FF00)
                    download_script()
                else
                    sampAddChatMessage("У вас установлена последняя версия скрипта.", 0x00FF00)
                end
            else
                sampAddChatMessage("Ошибка: некорректные данные в update.ini", 0xFF0000)
            end
            os.remove(update_path)
        end
    end)
end

-- Загрузка и замена скрипта
function download_script()
    downloadUrlToFile(script_url, temp_path, function(id, status)
        if status == distatus.STATUS_ENDDOWNLOADDATA then
            local file = io.open(temp_path, "r")
            if file then
                file:close()
                os.remove(script_path) -- удаляем старый скрипт
                os.rename(temp_path, script_path) -- заменяем на новый
                sampAddChatMessage("Скрипт успешно обновлён! Перезагрузка...", 0x00FF00)
                thisScript():reload()
            else
                sampAddChatMessage("Ошибка при загрузке скрипта.", 0xFF0000)
            end
        end
    end)
end

-- Команда для ручного обновления
function cmd_update()
    check_for_update()
    sampAddChatMessage("Проверка обновлений алекс ...", 0xFFFF00)
end
