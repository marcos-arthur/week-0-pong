love = require 'love'

push = require 'push'

Class = require 'class'

require 'Paddle'

require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)

    scoreFont = love.graphics.newFont('font.ttf', 32)

    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    player1 = Paddle(10, 30, 5, 20, true)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20, true)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    originalBallspeed = math.random(140, 200)

    player1Score = 0
    player2Score = 0

    servingPlayer = 1

    winningPlayer = 0

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then            
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end

        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()
            
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
            
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if player1.isBot then
            if ball.dx < 0 and ball.x < VIRTUAL_WIDTH / 2 then
                if player1.y < ball.y + ball.height / 2 and player1.y  + player1.height > ball.y + ball.height  then
                    player1.dy = 0
                elseif player1.y + player1.height / 2 > ball.y + ball.height / 2 then
                    player1.dy = -PADDLE_SPEED
                elseif player1.y + player1.height / 2 < ball.y + ball.height / 2 then
                    player1.dy = PADDLE_SPEED
                end
            else
                player1.dy = 0
            end
        else
            if love.keyboard.isDown('w') then
                player1.dy = -PADDLE_SPEED
            elseif love.keyboard.isDown('s') then
                player1.dy = PADDLE_SPEED
            else
                player1.dy = 0
            end
        end        

        if player2.isBot then
            if ball.dx > 0 and ball.x > VIRTUAL_WIDTH / 2 then
                if player2.y < ball.y + ball.height / 2 and player2.y  + player2.height > ball.y + ball.height  then
                    player2.dy = 0
                elseif player2.y + player2.height / 2 > ball.y + ball.height / 2 then
                    player2.dy = -PADDLE_SPEED
                elseif player2.y + player2.height / 2 < ball.y + ball.height / 2 then
                    player2.dy = PADDLE_SPEED
                end
            else
                player2.dy = 0
            end
        else
            if love.keyboard.isDown('up') then
                player2.dy = -PADDLE_SPEED
            elseif love.keyboard.isDown('down') then
                player2.dy = PADDLE_SPEED
            else
                player2.dy = 0
            end
        end        

        if gameState == 'play' then
            ball:update(dt)
        end

        player1:update(dt)
        player2:update(dt)
    end

    
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'

            ball:reset()

            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    elseif key == 'x' then
        if player1.isBot then
            player1.isBot = false
        else
            player1.isBot = true
        end
    elseif key == 'c' then
        if player2.isBot then
            player2.isBot = false
        else
            player2.isBot = true
        end
    end
end

function love.draw()
    push:start()

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin', 0, 20, VIRTUAL_WIDTH, 'center')

        love.graphics.setColor(1, 1, 1, 1)
        
        love.graphics.setFont(largeFont)
        love.graphics.printf(player1.isBot == true and 'BOT' or 'PLAYER 1', 0, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH / 2, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf(player1.isBot == true and 'Press X to select this side' or 'Press X to make your enemy suffer', 0, VIRTUAL_HEIGHT / 2 + 30, VIRTUAL_WIDTH / 2, 'center')

        love.graphics.setFont(largeFont)
        love.graphics.printf(player2.isBot == true and 'BOT' or 'PLAYER 2', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH / 2 , 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf(player2.isBot == true and 'Press C to select this side' or 'Press C to make your enemy cry', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 30, VIRTUAL_WIDTH / 2 , 'center')

        love.graphics.setColor(0, 1, 0, 1)
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. " wins", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'serve' or gameState == 'play' then
        love.graphics.setFont(smallFont)
        love.graphics.printf(player1.isBot == true and 'BOT' or 'PLAYER 1', 0, 10, VIRTUAL_WIDTH / 2, 'center')
        love.graphics.printf(player2.isBot == true and 'BOT' or 'PLAYER 2', VIRTUAL_WIDTH / 2, 10, VIRTUAL_WIDTH / 2 , 'center')
    end

    displayScore()

    player1:render()
    player2:render()
    ball:render()

    -- displayFPS()

    push:finish()
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end
