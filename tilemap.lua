function loadTiledMap(path)
    local map = require(path)

    map.quads = {}
    map.first = {}
    map.images = {}
    for i, tileset in ipairs(map.tilesets) do
        table.insert(map.first, tileset.firstgid + tileset.tilecount)
        table.insert(map.images, love.graphics.newImage(tileset.image))
        for y = 0, (tileset.imageheight / tileset.tileheight) - 1 do
            for x = 0, (tileset.imagewidth / tileset.tilewidth) - 1 do
                local quad = love.graphics.newQuad(
                    x * tileset.tilewidth, 
                    y * tileset.tileheight, 
                    tileset.tilewidth, 
                    tileset.tileheight, 
                    tileset.imagewidth, 
                    tileset.imageheight)
                table.insert(map.quads, quad)
            end
        end
    end


    function map:draw_map()
        for i, layer in ipairs(self.layers) do
            if layer.type == "tilelayer" then
                for y = 0, layer.height - 1 do
                    for x = 0, layer.width - 1 do
                        local index = (x + y * layer.width) + 1
                        local tid = layer.data[index]
                        if tid ~= 0 then
                            for i, tileset in ipairs(self.tilesets) do
                                if tid < self.first[i] then
                                    local quad = self.quads[tid]
                                    local xx = x * tileset.tilewidth
                                    local yy = y * tileset.tileheight
                                    love.graphics.draw(
                                        self.images[i],
                                        quad,
                                        xx,
                                        yy)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return map
end