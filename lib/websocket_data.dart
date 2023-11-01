enum DataTypes {
  motorRotation,
  buttons,
  servoRotation,

  motorModeChenge,
  limitSwitchStop,
}

Map getFormattedData(DataTypes type, dynamic data) {
  return {
    "type": type.index,
    "data": data,
  };
}
