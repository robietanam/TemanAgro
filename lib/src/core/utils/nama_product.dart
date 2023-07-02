class InitialName {
  // @string name
  // @int letterLimit (optional) to limit the number of letters that appear
  static String parseName({required String name, int? letterLimit}) {
    // separate each word
    var parts = name.trim().split(' ');
    String initial = '';

    // check length
    if (parts.length > 1) {
      // check max limit
      if (letterLimit != null) {
        for (var i = 0; i < letterLimit; i++) {
          // combine the first letters of each word
          initial += parts[i][0];
        }
      } else {
        // this default, if word > 1
        initial = parts[0][0] + parts[1][0];
      }
    } else {
      // this default, if word <=1
      initial = parts[0][0];
    }
    return initial;
  }
}
