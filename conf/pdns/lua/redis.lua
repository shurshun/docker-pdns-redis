local redis_sock    = "/tmp/redis.sock"
local redis_prefix  = 'pdns.'

local records = {}
local redis

function matchqtype(q, have)
    return have == q or q == "ANY"
end

function makerecord(name, type, content, ttl)
    return {domain_id=1, name=name, type=type, content=content, ttl=ttl}
end

function init()
    local hiredis = require 'hiredis'

    redis = hiredis.connect(redis_sock)
end

function lookup(qtype, qname, domainid)
    --print("(l_lookup)", "qtype:", qtype, " qname:", qname, " domain_id:", domainid )

    local domain = qname:sub(0, #qname-1)

    local data = redis:command("HGETALL", redis_prefix .. domain)

    for i = 1, #data, 2 do
        local type, content = data[i]:match('(.-)\t(.-)$')
        local ttl = data[i+1]
        if matchqtype(qtype, type) then
            table.insert(records, makerecord(qname, type, content, ttl))
        end
    end

    --print("end of lookup, #records=", #records)

    return true    
end

function get()
    --print("get, #records=", #records)

    while #records > 0 do
        --print("get going to return something")
        local r = table.remove(records)
        --print(r)
        --for k,v in pairs(r) do print(k,v) end
        return r
    end
    
    --print("get returned nothing")
end

function getsoa(name)
    --print("getsoa ", name)
    -- if name == domain then
    --     records={makerecord(name, 'SOA', 'ns.'..domain, 'hostmaster.'..domain)}
    -- else
    --     records = {}
    -- end
    -- return true
end

function list(name)
    return false
end

init()