module("luci.controller.jxustportal", package.seeall)

function index()
    entry({"admin", "services", "jxustportal"}, call("action_index"), _("JXUST Portal"), 60)
end

-- 登录函数（直接执行，不生成脚本文件）
local function do_login(user, pass, operator)
    local sys = require "luci.sys"

    -- 获取 WAN 接口名
    local wan_if = sys.exec("uci get network.wan.ifname 2>/dev/null"):gsub("\n","")
    if wan_if == "" then return "无法获取 WAN 接口" end

    -- 获取 WAN IP
    local wan_ip = sys.exec(string.format(
        "ip -4 addr show dev %s 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1", wan_if
    )):gsub("\n","")
    if wan_ip == "" then return "无法获取 IP" end

    -- 构造登录 URL
    local login_url = "http://10.17.8.18:801/eportal/portal/login"
    local full_url = ""
    if operator == "campus" then
        full_url = string.format(
            "%s?callback=dr1003&login_method=1&user_account=%s&user_password=%s&wlan_user_ip=%s&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=876",
            login_url, user, pass, wan_ip
        )
    else
        full_url = string.format(
            "%s?callback=dr1003&login_method=1&user_account=%s@%s&user_password=%s&wlan_user_ip=%s&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=876",
            login_url, user, operator, pass, wan_ip
        )
    end

    -- 执行 wget 请求
    local out = sys.exec("wget -qO- '" .. full_url .. "'")
    return out
end

-- 注销函数（直接执行，不生成脚本文件）
local function do_logout()
    local sys = require "luci.sys"

    local wan_if = sys.exec("uci get network.wan.ifname 2>/dev/null"):gsub("\n","")
    if wan_if == "" then return "无法获取 WAN 接口" end

    local wan_ip = sys.exec(string.format(
        "ip -4 addr show dev %s 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1", wan_if
    )):gsub("\n","")
    if wan_ip == "" then return "无法获取 IP" end

    local logout_url = "http://10.17.8.18:801/eportal/portal/logout"
    local full_url = string.format(
        "%s?callback=dr1004&login_method=1&user_account=drcom&user_password=123&ac_logout=0&register_mode=1&wlan_user_ip=%s&wlan_user_ipv6=&wlan_vlan_id=0&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1.3&v=10250&lang=zh",
        logout_url, wan_ip
    )

    local out = sys.exec("wget -qO- '" .. full_url .. "'")
    return out
end

-- LuCI 页面主函数
function action_index()
    local tpl  = require "luci.template"
    local http = require "luci.http"
    local sys  = require "luci.sys"

    -- 读取 UCI 保存的账号密码（可能为空）
    local user     = sys.exec("uci get jxustportal.@main[0].user 2>/dev/null"):gsub("\n","")
    local pass     = sys.exec("uci get jxustportal.@main[0].pass 2>/dev/null"):gsub("\n","")
    local remember = sys.exec("uci get jxustportal.@main[0].remember 2>/dev/null"):gsub("\n","")

    -- 处理表单
    local action = http.formvalue("action")
    local out = ""
    if action == "login" then
        local form_user     = http.formvalue("user") or ""
        local form_pass     = http.formvalue("password") or ""
        local form_operator = http.formvalue("operator") or "campus"

        if http.formvalue("remember") then
            sys.call(string.format("uci -q set jxustportal.@main[0].user='%s'", form_user))
            sys.call(string.format("uci -q set jxustportal.@main[0].pass='%s'", form_pass))
            sys.call("uci -q set jxustportal.@main[0].remember='1'; uci commit jxustportal")
        else
            sys.call("uci -q delete jxustportal.@main[0].user")
            sys.call("uci -q delete jxustportal.@main[0].pass")
            sys.call("uci -q set jxustportal.@main[0].remember='0'; uci commit jxustportal")
        end

        -- 执行登录
        out = do_login(form_user, form_pass, form_operator)

    elseif action == "logout" then
        -- 执行注销
        out = do_logout()
    end

    -- 渲染模板
    tpl.render("jxustportal/index", {
        output   = out,
        user     = http.formvalue("user") or user,
        pass     = http.formvalue("password") or pass,
        remember = http.formvalue("remember") or remember,
        operator = http.formvalue("operator") or "campus"
    })
end