"use strict";

var TimeToString;

TimeToString = function(time, brief) {
  var hour, min, sec, text;
  sec = Math.round(time % 60);
  min = Math.round(((time - sec) / 60) % 60);
  hour = Math.round((time - (time % 3600)) / 3600);
  text = "";
  if (sec === 0 && min === 0 && hour === 0) {
    return "-";
  }
  if (hour === 1) {
    text += hour + " hour ";
  }
  if (hour > 1) {
    text += hour + " hours ";
  }
  if (min === 1) {
    text += min + " minute ";
  }
  if (min > 1) {
    text += min + " minutes ";
  }
  if (sec < 2) {
    text += sec + " second";
  }
  if (sec > 1) {
    text += sec + " seconds";
  }
  if (brief) {
    text = "";
    if (hour > 0) {
      text = hour + ":";
    }
    if (min > 0 && min < 10 && hour > 0) {
      text += "0" + min + ":";
    } else if (min === 0 && hour > 0) {
      text += "00:";
    } else if (min === 0 && hour === 0) {
      text = "";
    } else {
      text += min + ":";
    }
    if (sec > 0 && sec < 10 && (hour > 0 || min > 0)) {
      text += "0" + sec;
    } else if (sec === 0 && (hour > 0 || min > 0)) {
      text += "00";
    } else {
      text += sec;
    }
  }
  return text;
};
