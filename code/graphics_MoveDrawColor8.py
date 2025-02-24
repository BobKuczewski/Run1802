# Define a Generic graphics simulator
#
# 0,r,g,b = Erase Screen to r,g,b
# 1,x,y = Move to x,y
# 2,x,y = Draw to x,y
# 3,r,g,b = Set Color to r,g,b

name = "Move Draw Color 8bit"

def update ( canvas, data ):
  print ( "  Data = " + str(data) )
  x = 0
  y = 0
  r = 0
  g = 0
  b = 0
  draw_color = "#aaaaaa"
  i = 0
  while i < len(data):
    print ( "Top with i = " + str(i) + ", data[i] = " + str(data[i]) )
    if data[i] == 0:
      print ( "Working on Erase Command" )
      if i+3 < len(data):
        # Erase the screen with color r,g,b
        r = data[i+1]
        g = data[i+2]
        b = data[i+3]
        print ( "  Erase with color (" + str(r) + "," + str(g) + "," + str(b) + ")" )
        canvas.delete('all')
        canvas['bg'] = "#" + "{:02X}".format(r) + "{:02X}".format(g) + "{:02X}".format(b)
      i += 4
    elif data[i] == 1:
      print ( "Working on Move Command" )
      if i+2 < len(data):
        # Move to x,y
        x = data[i+1]
        y = data[i+2]
        print ( "  Move to (" + str(x) + "," + str(y) + ")" )
      i += 3
    elif data[i] == 2:
      print ( "Working on Draw Command" )
      if i+2 < len(data):
        # Draw to x,y
        canvas.create_line ( x, y, data[i+1], data[i+2], fill=draw_color )
        x = data[i+1]
        y = data[i+2]
        print ( "  Draw to (" + str(x) + "," + str(y) + ")" )
      i += 3
    elif data[i] == 3:
      print ( "Working on Color Command" )
      if i+3 < len(data):
        # Set color to r,g,b
        r = data[i+1]
        g = data[i+2]
        b = data[i+3]
        draw_color = "#" + "{:02X}".format(r) + "{:02X}".format(g) + "{:02X}".format(b)
        print ( "  Set color to (" + draw_color + ")" )
        # canvas['fg'] = "#" + "{:02X}".format(r) + "{:02X}".format(g) + "{:02X}".format(b)
      i += 4
    else:
      print ( "Unknown command" )

  print ( "Done" )

