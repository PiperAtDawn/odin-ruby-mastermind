# odin-ruby-mastermind
Mastermind game for the Odin Project's Ruby course

This implementation uses the rule where duplicate colors require multiple matching instances to be included in the hint, as per Wikipedia:
"If there are duplicate colors in the guess, they cannot all be awarded a key peg unless they correspond to the same number of duplicate colors in the hidden code. For example, if the hidden code is red-red-blue-blue and the player guesses red-red-red-blue, the codemaker will award two colored key pegs for the two correct reds, nothing for the third red as there is not a third red in the code, and a colored key peg for the blue. No indication is given of the fact that the code also includes a second blue."