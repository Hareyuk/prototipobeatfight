--Main file - se tiene que llamar así


--love.load will only get called once when the game is first started (before any other callback), it's a fine place to put code which loads game content and otherwise prepares things.
--doing them here means that they are done once only

function love.load()
   image = love.graphics.newImage("cake.jpg")
   love.graphics.setNewFont(12)
   love.graphics.setColor(0,0,0)
   love.graphics.setBackgroundColor(255,255,255)
   num = 0
end

------------------------------------------------------------------------------------


function love.update(dt)
   if love.keyboard.isDown("up") then
      num = num + 100 * dt -- this would increment num by 100 per second
   end
end

--Called continuously. 'dt' is the amount of seconds since the last time this function was called 
-- num = num + 100 * dt would increment num by 100 per second

------------------------------------------------------------------------------------


function love.draw()
   love.graphics.draw(image, imgx, imgy)
   love.graphics.print("Click and drag the cake around or use the arrow keys", 10, 10)
end
--where all the drawing happens . if you call any of the love.graphics.draw outside of this function then it's not going to have any effect. 
--This function is also called continuously


------------------------------------------------------------------------------------
function love.mousepressed(x, y, button, istouch)
   if button == 1 then
      imgx = x -- move image to where mouse clicked
      imgy = y
   end
end
--This function is called whenever a mouse button is pressed.  it receives the button and the coordinates of where it was pressed. 

function love.mousereleased(x, y, button, istouch)
end


function love.keypressed(key)
   if key == 'b' then
      text = "The B key was pressed."
   elseif key == 'a' then
      a_down = true
   end
end
--This function is called whenever a keyboard key is pressed and receives the key that was pressed. The key can be any of the constants. 

function love.keyreleased(key)

end  

------------------------------------------------------------------------------------

function love.focus(f) gameIsPlaying = f end

--This function is called whenever the user clicks off and on the LÖVE window. For instance, if they are playing a windowed game and a user clicks on his Internet browser, the game could be notified and automatically pause the game.



function love.quit()
  print("Thanks for playing! Come back soon!")
end
--This function is called whenever the user clicks the window's close button (often an X). For instance, if the user decides they are done playing, they could click the close button. Then, before it closes, the game can save its state.