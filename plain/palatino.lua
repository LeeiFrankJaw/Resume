function pairsByKeys (t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0
  local iter = function ()
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end
  return iter
end

-- local dumpfile = "fontdump.lua"
local dump_font = function (tfmdata)
  if tfmdata.shared.rawdata.metadata and tfmdata.shared.rawdata.metadata.familyname == "Palatino Linotype" then
    texio.write_nl("fullname: " .. tfmdata.fullname)
    local seq = tfmdata.resources.sequences
    for k, v in ipairs(seq) do
      if v.name:find("^s_s_11?$") then
        texio.write_nl(v.name)
        for k2, v2 in pairsByKeys(v.steps[1].coverage) do
          if not tfmdata.descriptions[v2].unicode then
            texio.write_nl(k2 .. "\t" .. v2)
            tfmdata.descriptions[v2].unicode = k2 - ((v.name == "s_s_1" and 32) or 0)
          end
        end
      end
    end
    local data = table.serialize(tfmdata)
    io.savedata("fontdump-" .. tfmdata.fontname .. ".lua", data)
  end
end

luatexbase.add_to_callback(
  "luaotfload.patch_font",
  dump_font,
  "my_private_callbacks.dump_font"
)
