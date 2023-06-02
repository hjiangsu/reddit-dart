class RateLimit {
  int used = 0;
  int remaining = 0;
  int resetSeconds = 0;

  RateLimit({this.used = 0, this.remaining = 600, this.resetSeconds = 0});

  void setRemaining(double value) {
    remaining = value.toInt();
  }

  void setUsed(double value) {
    used = value.toInt();
  }

  void setResetSeconds(double value) {
    resetSeconds = value.toInt();
  }

  bool hasExceeded() {
    return used >= remaining;
  }

  @override
  String toString() {
    return "Used: $used, Remaining: $remaining, Refresh in: ${resetSeconds}s";
  }
}
