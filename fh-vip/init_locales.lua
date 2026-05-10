Locales = {}

function _U(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
    end
end

function _L(str)
    return Locales[str] or {}
end