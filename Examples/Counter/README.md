# Counter
This code controls the 8 leds on the mimas by writing to r13.
We use another register for sleep and increasing r13 only when it is equal to (68 ** 4)
