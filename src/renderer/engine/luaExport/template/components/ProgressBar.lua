-- =============================================
-- ProgressBar
-- =============================================

ProgressBar = setmetatable({}, { __index = BaseObject })
ProgressBar.__index = ProgressBar

function ProgressBar:new(name, props)
    local obj = BaseObject.new(self, name, props)

    obj.type = "progressbar"

    return obj
end

local function clampProgress(progress)
    progress = tonumber(progress) or 0
    if progress < 0 then return 0 end
    if progress > 100 then return 100 end
    return progress
end

local function normalizeDirection(direction)
    local directions = {
        ["auto"] = "auto",
        ["left-right"] = "left-right",
        ["right-left"] = "right-left",
        ["bottom-up"] = "bottom-up",
        ["top-down"] = "top-down",
    }

    return directions[direction] or "left-right"
end

local function getAutoDirection(progressBar)
    if (progressBar.height or 0) > (progressBar.width or 0) then
        return "bottom-up"
    end

    return "left-right"
end

function ProgressBar:drawElement()
    local direction = normalizeDirection(self.direction)
    if direction == "auto" then
        direction = getAutoDirection(self)
    end
    local progress = clampProgress(self.progress)
    local alignedText = self:alignText(self.text or "", self.width, self.textAlign)
    local progressWidth = math.floor(self.width * progress / 100)
    local progressHeight = math.floor(self.height * progress / 100)

    -- Draw background
    term.setBackgroundColor(self.bgColor)
    for j = 0, self.height - 1 do
        term.setCursorPos(self.x, self.y + j)
        term.write(string.rep(" ", self.width))
    end

    -- Draw progress
    if progress > 0 then
        term.setBackgroundColor(self.progressColor)

        if direction == "left-right" then
            for j = 0, self.height - 1 do
                term.setCursorPos(self.x, self.y + j)
                term.write(string.rep(" ", progressWidth))
            end
        elseif direction == "right-left" then
            for j = 0, self.height - 1 do
                term.setCursorPos(self.x + self.width - progressWidth, self.y + j)
                term.write(string.rep(" ", progressWidth))
            end
        elseif direction == "bottom-up" then
            for j = 0, progressHeight - 1 do
                term.setCursorPos(self.x, self.y + self.height - 1 - j)
                term.write(string.rep(" ", self.width))
            end
        elseif direction == "top-down" then
            for j = 0, progressHeight - 1 do
                term.setCursorPos(self.x, self.y + j)
                term.write(string.rep(" ", self.width))
            end
        end
    end

    -- Draw text
    local textY = self.y + math.floor(self.height / 2)
    local filledStartX = self.x
    local filledEndX = self.x + progressWidth - 1

    if direction == "right-left" then
        filledStartX = self.x + self.width - progressWidth
        filledEndX = self.x + self.width - 1
    end

    for i = 1, #alignedText do
        local charX = self.x + i - 1
        local isFilled = false

        if direction == "left-right" or direction == "right-left" then
            isFilled = charX >= filledStartX and charX <= filledEndX
        elseif direction == "bottom-up" then
            isFilled = textY >= self.y + self.height - progressHeight
        elseif direction == "top-down" then
            isFilled = textY <= self.y + progressHeight - 1
        end

        term.setCursorPos(charX, textY)
        term.setTextColor(self.fgColor)
        term.setBackgroundColor(isFilled and self.progressColor or self.bgColor)
        term.write(alignedText:sub(i, i))
    end
end

