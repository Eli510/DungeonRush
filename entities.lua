function loadSprites(path)
    local sprite = require(path)

    sprite.quads = {}
    sprite.first = {}
    sprite.images = {}
    for i, tileset in ipairs(sprite.tilesets) do
        table.insert(sprite.first, tileset.firstgid + tileset.tilecount)
        table.insert(sprite.images, love.graphics.newImage(tileset.image))
        for y = 0, (tileset.imageheight / tileset.tileheight) - 1 do
            for x = 0, (tileset.imagewidth / tileset.tilewidth) - 1 do
                local quad = love.graphics.newQuad(
                    x * tileset.tilewidth, 
                    y * tileset.tileheight, 
                    tileset.tilewidth, 
                    tileset.tileheight, 
                    tileset.imagewidth, 
                    tileset.imageheight)
                table.insert(sprite.quads, quad)
            end
        end
    end
    function sprite:draw_sprite(position, entity)
        love.graphics.draw(
            self.images[1],
            self.quads[entity],
            position[1] * self.tilewidth,
            position[2] * self.tileheight)
    end
    return sprite
end