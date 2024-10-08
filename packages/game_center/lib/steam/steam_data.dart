/// Directory within Steam's install path where actual Steam data is found.
const steamDataDir = '.steam/steam';

/// Directory where Steam expects 3rd party Proton versions to be.
String protonDirectory(String installLocation) {
  return '$installLocation/$steamDataDir/compatibilitytools.d';
}

/// Steam's global settings file path.
String steamGlobalConfig(String installLocation) {
  return '$installLocation/$steamDataDir/config/config.vdf';
}

/// Steam user settings *(not to be confused with the Linux user)* file path.
///
/// Most users of Steam will only have 1 account per Linux user. However, it is
/// possible to log in to multiple Steam accounts from a single Linux user so a
/// `userID` must be provided.
String steamUserConfig(String installLocation, String userID) {
  return '$installLocation/$steamDataDir/userdata/$userID/config/localconfig.vdf';
}
