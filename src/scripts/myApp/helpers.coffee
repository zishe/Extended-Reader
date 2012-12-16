"use strict"

TimeToString = (time, brief) ->
  sec = Math.round(time % 60)
  min = Math.round(((time - sec) / 60) % 60)
  hour = Math.round(((time - (time % 3600)) / 3600))

  text = ""
  return "-"  if sec is 0 and min is 0 and hour is 0
  text += hour + " hour "  if hour is 1
  text += hour + " hours "  if hour > 1
  text += min + " minute "  if min is 1
  text += min + " minutes "  if min > 1
  text += sec + " second"  if sec < 2
  text += sec + " seconds"  if sec > 1
  if brief
    text = ""
    text = hour + ":"  if hour > 0
    if min > 0 and min < 10 and hour > 0 #12:[0]3:33
      text += "0" + min + ":"
    else if min is 0 and hour > 0 #12:[00]:35
      text += "00:"
    else if min is 0 and hour is 0
      text = ""
    else
      text += min + ":"
    if sec > 0 and sec < 10 and (hour > 0 or min > 0) #12:34:[0]2
      text += "0" + sec
    else if sec is 0 and (hour > 0 or min > 0) #12:34:[00]
      text += "00"
    else
      text += sec
  text
