--------------------------CONFIG--------------------------
local VERSION = "8"
----------------------------------------------------------


local guiform = nil
local picbox = nil
local chkBoundingBox = nil
local chkFogOfWar = nil
local lbl_x = nil
local lbl_y = nil

local hue = 0
local mapbytes = {}
local mapseen = {}
local warp_coords = {}
local prev_locs = {}

local prev_ow_x_px = 0
local prev_ow_y_px = 0
local prev_render_x = 0
local prev_render_y = 0
local needs_redraw = false
local entireMapDrawn = false
local restoringFromUserdata = false
local framecounter = 0

--most of these colors are the average color of the tile (basically what you get if you infinitely blur the tile)
--only exception are the docks that I set to gray
TILE_COLORS = {
    [0x00] = 0xFF00AD00, -- GrassTile
    [0x03] = 0xff24a301, -- ForestTopLeft
    [0x04] = 0xff279e01, -- ForestTopMid
    [0x05] = 0xff229101, -- ForestTopRight
    [0x06] = 0xff5ac0a4, -- CoastTopLeft
    [0x07] = 0xff78d1fb, -- CoastTop
    [0x08] = 0xff61c3ae, -- CoastTopRight
    [0x0F] = 0xffbdbdbd, -- DockLeftMid
    [0x10] = 0xff9dbc9d, -- MountainTopLeft
    [0x11] = 0xffc8d0c8, -- MountainTopMid
    [0x12] = 0xff98b398, -- MountainTopRight
    [0x13] = 0xff359f02, -- ForestMidLeft
    [0x14] = 0xff3a9f02, -- ForestMid
    [0x15] = 0xff227d01, -- ForestMidRight
    [0x16] = 0xff78d1fb, -- CoastLeft
    [0x17] = 0xff70ceff, -- OceanTile
    [0x18] = 0xff79d1fd, -- CoastRight
    [0x1F] = 0xffbdbdbd, -- DockRightMid
    [0x20] = 0xffc3cac3, -- MountainMidLeft
    [0x21] = 0xffd6d6d6, -- MountainMid
    [0x22] = 0xffbec2be, -- MountainMidRight
    [0x23] = 0xff299801, -- ForestBottomLeft
    [0x24] = 0xff198701, -- ForestBottomMid
    [0x25] = 0xff077e00, -- ForestBottomRight
    [0x26] = 0xff65c5b8, -- CoastBottomLeft
    [0x27] = 0xff7ad1fc, -- CoastBottom
    [0x28] = 0xff60c2ad, -- CoastBottomRight
    [0x30] = 0xff92b292, -- MountainBottomLeft
    [0x31] = 0xffc0c2c0, -- MountainBottomMid
    [0x33] = 0xff90ac90, -- MountainBottomRight
    [0x37] = 0xffffdea2, -- maybe regular desert?
    [0x3B] = 0xff42ab42, -- castle foundation
    [0x3C] = 0xffbcbcbc, -- castle foundation
    [0x3D] = 0xffbcbcbc, -- castle foundation
    [0x3E] = 0xffbcbcbc, -- castle foundation
    [0x3F] = 0xff42ab42, -- castle foundation
    [0x40] = 0xff4bc1f7, -- RiverTopLeft
    [0x41] = 0xff4bc1f7, -- RiverTopRight
    [0x42] = 0xffbcc876, -- DesertTopLeft
    [0x43] = 0xffbcc876, -- DesertTopRight
    [0x44] = 0xff4fc2ff, -- RiverTile
    [0x45] = 0xffffdea2, -- DesertMid
    [0x4B] = 0xff74ae74, -- castle foundation
    [0x4F] = 0xff74ae74, -- castle foundation
    [0x50] = 0xff4bc1f7, -- RiverBottomLeft
    [0x51] = 0xff4bc1f7, -- RiverBottomRight
    [0x52] = 0xffbec877, -- DesertBottomLeft
    [0x53] = 0xffbec877, -- DesertBottomRight
    [0x54] = 0xffb6f917, -- GrassyMid
    [0x55] = 0xff18b078, -- MarshTile
    [0x5B] = 0xff95b295, -- castle foundation
    [0x5F] = 0xff95b295, -- castle foundation
    [0x60] = 0xff86d90e, -- GrassTopLeft
    [0x61] = 0xff86d90e, -- GrassTopRight
    [0x62] = 0xff16b071, -- MarshTopLeft
    [0x63] = 0xff16b071, -- MarshTopRight
    [0x6B] = 0xffafb6af, -- castle foundation
    [0x6F] = 0xffafb6af, -- castle foundation
    [0x70] = 0xff86d90e, -- GrassBottomLeft
    [0x71] = 0xff86d90e, -- GrassBottomRight
    [0x72] = 0xff16b071, -- MarshBottomLeft
    [0x73] = 0xff16b071, -- MarshBottomRight
    [0x76] = 0xff00ad00, -- solid green
    [0x77] = 0xffbdbdbd, -- dock
    [0x78] = 0xffbdbdbd, -- DockBottomMid
    [0x79] = 0xffbdbdbd, -- dock
    [0x7A] = 0xffbdbdbd, -- dock
    [0x7B] = 0xffa2a8a2, -- castle foundation
    [0x7C] = 0xffacacac, -- castle foundation
    [0x7D] = 0xffa1a3a1, -- castle foundation
    [0x7E] = 0xffa1a3a1, -- castle foundation
    [0x7F] = 0xffa2a8a2, -- castle foundation
}

WARP_TILES = {
    [0x01] = true,[0x02] = true,[0x09] = true,[0x0A] = true,[0x0B] = true,[0x0C] = true,[0x0D] = true,[0x0E] = true,[0x19] = true,[0x1A] = true,
    [0x1B] = true,[0x1C] = true,[0x1D] = true,[0x1E] = true,[0x29] = true,[0x2A] = true,[0x2B] = true,[0x2F] = true,[0x32] = true,[0x34] = true,
    [0x35] = true,[0x36] = true,[0x38] = true,[0x39] = true,[0x3A] = true,[0x46] = true,[0x47] = true,[0x48] = true,[0x49] = true,[0x4A] = true,
    [0x4C] = true,[0x4D] = true,[0x4E] = true,[0x57] = true,[0x58] = true,[0x5A] = true,[0x5D] = true,[0x64] = true,[0x65] = true,[0x66] = true,
    [0x67] = true,[0x68] = true,[0x69] = true,[0x6A] = true,[0x6C] = true,[0x6D] = true,[0x6E] = true,[0x74] = true,[0x75] = true
}

Band = function(op1, op2) end
if string.sub(_VERSION, -1,-1) == "4" then
    assert(load("Band = function(op1, op2) return op1 & op2 end"))()
else
    assert(loadstring("Band = function(op1, op2) return bit.band(op1, op2) end"))()
end

function Tf(b)
    if b == true then return 't'
    else return 'f' end
end

function Tfread(c)
    if c == 't' then return true
    else return false end
end

local function serialize_mapseen()
    local outstring = ""
    local outstrings = {}
    for i = 0,255 do
        outstrings[i] = ""
        for j = 0,255 do
            local b = false
            if mapseen[i][j] == true then b = true end
            outstrings[i] = outstrings[i] .. Tf(b)
        end
    end
    for i = 0,255 do
        outstring = outstring .. outstrings[i]
    end
    return outstring
end

local function deserialize_mapseen(s)
    local intable = {}
    for i = 0,255 do
        intable[i] = {}
        for j = 0,255 do
            local idx = (i*256)+j+1
            intable[i][j] = Tfread(string.sub(s, idx, idx))
        end
    end
    return intable
end

local function cleanUp()
	print("Exiting...")
	gui.clearGraphics()
	gui.clearImageCache()
	forms.destroyall()
end

local function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

local function drawDoublePixel(hwnd, x, y, color)
    x = x * 2
    y = y * 2
    forms.drawPixel(hwnd, x, y, color)
    forms.drawPixel(hwnd, x+1, y, color)
    forms.drawPixel(hwnd, x, y+1, color)
    forms.drawPixel(hwnd, x+1, y+1, color)
end

local function hsv_to_rgb32(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs(((h/60) % 2) - 1))
    local m = v - c
    local rp, gp, bp = 0,0,0
    if h >= 300 then
        rp = c
        bp = x
    elseif h >= 240 then
        rp = x
        bp = c
    elseif h >= 180 then
        gp = x
        bp = c
    elseif h >= 120 then
        gp = c
        bp = x
    elseif h >= 60 then
        rp = x
        gp = c
    else
        rp = c
        gp = x
    end

    local r,g,b = (rp+m)*255, (gp+m)*255, (bp+m)*255
    local color = 0xFF000000 + bit.rol(math.floor(r/1), 16) + bit.rol(math.floor(g/1), 8) + math.floor(b/1)
    return color
end

local function clamp(i)
    if i < 0 then return 0 end
    if i > 255 then return 255 end
    return i
end


local function refreshGui()
    framecounter = framecounter + 1
    memory.usememorydomain("RAM")

    local ow_x_px = (memory.readbyte(0x0027) + 8)
    local ow_y_px = (memory.readbyte(0x0028) + 8)

    for i = 10,2,-1 do
        prev_locs[i] = prev_locs[i-1]
    end
    prev_locs[1] = {ow_x_px, ow_y_px}

    if ow_x_px == nil then ow_x_px = 0 end
    if ow_y_px == nil then ow_y_px = 0 end

    --hack to disable drawing before game starts
    if ow_x_px == 0 and ow_y_px == 0 then return end

    --if we moved this much then we're doing the map transition animation
    if math.abs(ow_y_px - prev_ow_y_px) > 1 then
        --prev_ow_x_px = ow_x_px
        --prev_ow_y_px = ow_y_px
        if ow_x_px ~= prev_locs[3][1] or ow_y_px ~= prev_locs[3][2] then
            return
        end
        --return
    end

    forms.settext(lbl_x, "X: "..ow_x_px)
    forms.settext(lbl_y, "Y: "..ow_y_px)

    local ow_x = ow_x_px * 2
    local ow_y = ow_y_px * 2

    --mark current screen as seen
    for x = ow_x_px-8, ow_x_px+8 do
        for y = ow_y_px-8, ow_y_px+8 do
            mapseen[clamp(y)][clamp(x)] = true
        end
    end

    if framecounter > 600 then
        framecounter = 0
        userdata.set("mapseen", serialize_mapseen())
    end

    --redraw map under current location
    --todo: this could be optimized to not redraw the inside
    for x = prev_render_x - 8,prev_render_x+8 do
        for y = prev_render_y - 8,prev_render_y+8 do
            drawDoublePixel(picbox, clamp(x), clamp(y), TILE_COLORS[mapbytes[clamp(y)][clamp(x)]])
        end
    end

    if forms.ischecked(chkFogOfWar) == false and entireMapDrawn == false then
        --fog of war disabled, draw entire map
        for x = 0,255 do
            for y = 0,255 do
                drawDoublePixel(picbox, x, y, TILE_COLORS[mapbytes[y][x]])
            end
        end
        entireMapDrawn = true
    end

    if forms.ischecked(chkFogOfWar) == true and entireMapDrawn == true then
        --hide entire map and redraw seen map
        for x = 0,255 do
            for y = 0,255 do
                if mapseen[y][x] == true then
                    drawDoublePixel(picbox, x, y, TILE_COLORS[mapbytes[y][x]])
                else
                    drawDoublePixel(picbox, x, y, 0xFF000000)
                end
            end
        end
        entireMapDrawn = false
    end

    if forms.ischecked(chkBoundingBox) then
        --draw bounding box around current location
        forms.drawBox(picbox, ow_x - 16, ow_y - 16, ow_x + 16, ow_y + 16, 0xFFFF0000)
    end

    --color cycle for entrances
    hue = hue + 8
    if hue > 360 then hue = 0 end
    local color = hsv_to_rgb32(hue, 0.6, 1)

    for _, xy in pairs(warp_coords) do
        if mapseen[xy[2]][xy[1]] == true or forms.ischecked(chkFogOfWar) == false then
            drawDoublePixel(picbox, xy[1], xy[2], color)
        end
    end

    forms.refresh(picbox)

    prev_ow_x_px = ow_x_px
    prev_ow_y_px = ow_y_px
    prev_render_x = ow_x_px
    prev_render_y = ow_y_px
end

--returns bytes as array of rows
function DecompressMap()
    local _maprows = {}
    for x = 0,255 do
        _maprows[x] = {}
        for y = 0,255 do
            _maprows[x][y] = 0
        end
    end

    for row = 0, 255 do
        if row % 40 == 0 then
            --print("reading row "..row)
        end
        _maprows[row] = {}
        local ptr = memory.read_u16_le(0x4000 + (row*2))
        ptr = ptr - 0x4000
        --_maprows[row] = memory.read_u24_be(ptr)
        local col = 0
        local index = ptr
        --print(string.format("row %i, ptr is 0x%04x",row,ptr))
        while col < 256 do
            --print(string.format("row %i, ptr is 0x%04x",row,ptr))
            local curbyte = memory.readbyte(ptr)
            --print(string.format("read byte 0x%02x"),curbyte)
            --print(curbyte)
            if curbyte == 0xFF then
                --print("found 255")
                col = 255
            elseif curbyte > 0x7F then
                --print("curbyte > 0x7F")
                local tile = Band(curbyte, 0x7F)
                local run = memory.readbyte(ptr+1)
                if run == 0 then run = 256 end
                --print(string.format("col: %i, tile: %i, run: %i"),col, tile, luarun)
                --print("col: "..col..", tile: "..tile..", run: "..run)
                for i = 0,run-1 do
                    _maprows[row][col] = tile
                    col = col + 1
                end
                ptr = ptr + 2
            else
                _maprows[row][col] = curbyte
                col = col + 1
                ptr = ptr + 1
            end
        end
    end
    return _maprows
end

local function initForms()
    print("initforms")
    memory.usememorydomain("PRG ROM")
    guiform = forms.newform(513, 560, "Minimap v"..VERSION)
    picbox = forms.pictureBox(guiform, 0, 0, 512, 512)
    chkBoundingBox = forms.checkbox(guiform, "Show Location", 5, 515)
    chkFogOfWar = forms.checkbox(guiform, "Fog of War", 150, 515)
    forms.setproperty(chkBoundingBox, "Checked", "true")
    forms.setproperty(chkFogOfWar, "Checked", "true")
    lbl_x = forms.label(guiform, "X: ", 5, 540, 100)
    lbl_y = forms.label(guiform, "Y: ", 150, 540, 100)

    mapbytes = DecompressMap()
    --set any missing tiles to gray
    for x = 0,0x7F do
        if TILE_COLORS[x] == nil then
            TILE_COLORS[x] = 0xFF777777
        end
    end

    --load or initialize fog of war mask
    local stored_mapseen = userdata.get('mapseen')
    if stored_mapseen then
        mapseen = deserialize_mapseen(stored_mapseen)
        restoringFromUserdata = true
    else
        for y = 0,255 do
            mapseen[y] = {}
            for x = 0,255 do
                mapseen[y][x] = false
            end
        end
    end
    

    --draw starting canvas and fill warp_coords with coordinates of entrances
    for x = 0,255 do
        for y = 0,255 do
            if WARP_TILES[mapbytes[y][x]] ~= nil then
                table.insert(warp_coords, {x, y})
            end

            if restoringFromUserdata then
                if mapseen[y][x] == true then
                    drawDoublePixel(picbox, x, y, TILE_COLORS[mapbytes[y][x]])
                else
                    drawDoublePixel(picbox, x, y, 0xFF000000)
                end
            else
                drawDoublePixel(picbox, x, y, 0xFF000000)
            end
        end
    end

    for i = 1,10 do
        prev_locs[i] = {i,i}
    end

    forms.refresh(picbox)
    memory.usememorydomain("RAM")

    prev_ow_x_px = (memory.readbyte(0x0027) + 8)
    prev_ow_y_px = (memory.readbyte(0x0028) + 8)
    prev_locs[1][1] = prev_ow_x_px
    prev_locs[1][2] = prev_ow_y_px
    --forms.refresh(guiform)
    print("done initializing minimap script")
end

--print(string.format("Set memory domain to PRG ROM returned: %s",memory.usememorydomain("PRG ROM")))
memory.usememorydomain("PRG ROM")
initForms()
event.onexit(cleanUp)

--testUserData()

while true do
    refreshGui()
    emu.frameadvance()
end