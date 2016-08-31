--[[ Methods used by the tstolua compiler ]]

local LibStub = LibStub

-- Function used by define to call a factory that is ready
local function call(exports) 
    local parameters = {}
    for _,v in ipairs(exports.imports) do
        parameters[#parameters + 1] = v.exports
    end
    exports.exports = {}
    local result = exports.factory(exports.exports, unpack(parameters))
    if result then
        exports.exports = result
    end

    -- If some modules were waiting for these modules,...
    if exports.wait then
        for _,v in ipairs(exports.wait) do
            -- print(v .. " is no more waiting for " .. exports.name)
            v.missing[exports.name] = nil
            -- This module is waiting for nothing, call the factory
            if not next(v.missing) and v.imports then
                -- print("missing nothing")
                call(v)
            end
        end
    end
end 

-- Used by the AMD-like module system
function define( addonName, addon, mod, dependencies, factory)
    local exports

    mod = "./" .. mod

    -- print("Define " .. mod)

    if not addon[mod] then
      exports = { missing = {}, name = mod }
      addon[mod] = exports
    else
      exports = addon[mod]
    end

    exports.factory = factory
    
    local imports = {}

    -- Check dependencies
    for _,v in ipairs(dependencies) do
      local dependency = addon[v]
      -- Dependency not found, register it 
      if not dependency then
        if LibStub and LibStub.libs[v] then
          -- It's a global dependency
          -- print("Global " .. v)
          dependency = { exports = { default = LibStub.libs[v] }, name = v, missing = {} }
        else
          -- Create the dependency, empty for now
          -- Register the fact that this module is waiting for this dependency
          -- print("Local " .. v)
          dependency = { wait = { exports }, name = v, missing = {} }
          exports.missing[v] = dependency
        end
        addon[v] = dependency 
      else
        if next(dependency.missing) then
          -- print(v .. " is not ready")
          if dependency.wait then
            dependency.wait[#dependency.wait + 1] = exports
          else
            dependency.wait = { exports }
          end
          exports.missing[v] = dependency
        end
      end
      imports[#imports + 1] = dependency
    end

    exports.imports = imports
    
    -- If missing nothing, call the factory
    if not next(exports.missing) then
      call(exports)
    end
end

typeof = function(x)
	local t = type(x)
	if t == 'table' then return 'object'
	else return t; end
end

__extends = function(sub, base)
	setmetatable(sub, base)
	if base.__getters == nil then
		base.__index = base
	end
end;

__new = function(class, ...)
	local new={}
	__extends(new, class)
	if new.constructor ~= nil then
		new:constructor(...)
	end
	return new
end;

-- classof = function(object)
--     return getmetatable(object)
-- end

-- Emulate switch
__switch_return_break = 1
__switch_return_return = 2
switch = function(t)
	t.case = function (self,x)
		local startfunid = self[x] or self.default
		if startfunid == nil then
			return
		end		
		local len = #self.__codesegments
		for fid=startfunid, len do
			local f = self.__codesegments[fid]
			if f ~= 0 then
				local rtflag, rt = f(x, self)
				if rtflag ~= nil then
					return rtflag, rt 
				end
			end
		end
	end;
	return t
end
