ghomes.utils = ghomes.utils or {}

function ghomes.utils.arrayToHashtable(array)
    local hashtable = {}
    for _, value in ipairs(array) do
        hashtable[value] = true
    end
    return hashtable
end
