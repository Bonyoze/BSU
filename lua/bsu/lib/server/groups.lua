-- lib/server/groups.lua
-- functions for managing the player groups

function BSU.RegisterGroup(id, name, color, usergroup, inherit)
  BSU.SQLInsert(BSU.SQL_GROUPS,
    {
      id = id,
      name = name,
      color = type(color) == "table" and BSU.ColorToHex(color) or string.gsub(color, "#", ""),
      usergroup = usergroup,
      inherit = inherit
    }
  )
end

function BSU.RemoveGroup(id)
  BSU.SQLDeleteByValues(BSU.SQL_GROUPS, { id = id })
end

function BSU.GetAllGroups()
  return BSU.SQLSelectAll(BSU.SQL_GROUPS) or {}
end

-- get group by its numeric id
function BSU.GetGroupByID(id)
  local query = BSU.SQLSelectByValues(BSU.SQL_GROUPS, { id = id })
  return query and query[1]
end

-- get all groups with the
function BSU.GetGroupsByName(name)
  return BSU.SQLSelectByValues(BSU.SQL_GROUPS, { name = name }) or {}
end

function BSU.SetGroupData(id, values)
  BSU.SQLUpdateByValues(BSU.SQL_GROUPS, { id = id }, values)
end

-- setup teams
function BSU.PopulateTeams()
  local groups = BSU.GetAllGroups()
  for k, v in ipairs(groups) do
    team.SetUp(v.id, v.name, BSU.HexToColor(v.color))
  end
end