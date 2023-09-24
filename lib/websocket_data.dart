enum DataTypes {
  motorRotation,
  buttons,

  motorModeChenge,
  limitSwitchStop,
}

Map getFormattedData(DataTypes type, dynamic data) {
  return {
    "type": type.index,
    "data": data,
  };
}
