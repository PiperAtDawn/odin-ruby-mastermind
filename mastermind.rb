# frozen_string_literal: true

require_relative 'string_color'

COLORS = {
  1 => 'red',
  2 => 'green',
  3 => 'blue',
  4 => 'magenta',
  5 => 'brown',
  6 => 'gray'
}.freeze

CLUES = {
  colored: "\e[91m\u25CF\e[0m ",
  empty: "\e[37m\u25CB\e[0m "
}.freeze

PLAYER_TYPE = {
  human: 'human',
  computer: 'computer'
}.freeze

# Any player
class Player
  attr_reader :game

  def initialize(game)
    @game = game
  end
end

# Human player
class HumanPlayer < Player
  attr_reader :type

  def initialize(args)
    super(args)
    @type = PLAYER_TYPE[:human]
  end

  def input_code(prompt)
    loop do
      print prompt
      code = gets.gsub(/\s+/, '').to_i.digits.reverse
      return code if code.size == 4 && code.all? { |int| (1..6).to_a.include?(int) }

      puts 'Incorrect input. Try again.'
    end
  end

  def choose_code
    code = input_code('Choose a code of 4 numbers from 1 to 6 (they may repeat): ')
    puts "This is the code you've chosen:"
    game.print_code(code)
    code
  end

  def guess_code
    guess = input_code("* Try to guess the code.\n* It has 4 numbers from 1 to 6 (they may repeat): ")
    print 'Your guess: '
    game.print_code(guess)
    guess
  end

  def to_s
    'The human player'
  end
end

# AI player
class ComputerPlayer < Player
  attr_reader :type, :available_guesses

  attr_accessor :previous_guess

  def initialize(args)
    super(args)
    @type = PLAYER_TYPE[:computer]
    @previous_guess = nil
    @available_guesses = [1, 2, 3, 4, 5, 6].repeated_permutation(4).to_a
  end

  def choose_code
    code = []
    4.times { code << rand(1..6) }
    puts 'The computer has chosen a code.'
    code
  end

  def guess_code(hint)
    if !previous_guess
      guess = [1, 1, 2, 2]
    else
      available_guesses.select! { |x| game.get_hint(x, false, previous_guess) == hint }
      guess = available_guesses[0]
    end
    self.previous_guess = guess
    print 'The computer guessed: '
    game.print_code(guess)
    guess
  end

  def to_s
    'The computer player'
  end
end

# The game
class Game
  ATTEMPTS = 12
  RULES = '* Mastermind is a game for two players: the codemaker and the codebreaker.' +
          "\n* The codemaker thinks of a 4-digit code. Each number has a corresponding color." +
          "\n* The codebreaker then has 12 tries to guess the code. Each time you guess wrong, you get a hint." +
          "\n* Each colored-in circle represents a number in the correct position." +
          "\n* Each empty circle represents a number present in the code in a different position."
  @code = []

  attr_reader :code

  def initialize(human_class, computer_class)
    print_rules
    player_role = choose_role
    @players = []
    @players[player_role] = human_class.new(self)
    @players[1 - player_role] = computer_class.new(self)
  end

  def codebreaker
    @players[0]
  end

  def codemaker
    @players[1]
  end

  def play
    @code = codemaker.choose_code
    attempt = 1
    hint = nil
    until attempt > ATTEMPTS
      puts "Attempt #{attempt}:"
      guess = codebreaker.type == PLAYER_TYPE[:human] ? codebreaker.guess_code : codebreaker.guess_code(hint)
      if guess == @code
        puts "Congradulations! #{codebreaker} guessed it in #{attempt} tries."
        return
      end
      print 'Hint: '
      hint = get_hint(guess)
      attempt += 1
      sleep(1) if codebreaker.type == PLAYER_TYPE[:computer]
    end
    puts 'Better luck next time! The code was:'
    print_code
  end

  def print_code(c = code)
    string = ''
    c.each { |num| string += "  #{num}  ".bg(COLORS[num]) + ' ' }
    puts string
  end

  def get_hint(guess, print = true, correct_code = code)
    hint = {
      colored: 0,
      empty: 0
    }
    guess_copy = guess.map(&:clone)
    code_copy = correct_code.map(&:clone)
    guess.each_with_index do |num, i|
      if num == correct_code[i]
        hint[:colored] += 1
        guess_copy.delete_at(guess_copy.index(num))
        code_copy.delete_at(code_copy.index(num))
      end
    end
    guess_copy.each do |num|
      if code_copy.include?(num)
        hint[:empty] += 1
        code_copy.delete_at(code_copy.index(num))
      end
    end
    hint_text = ''
    hint[:colored].times { hint_text += CLUES[:colored] }
    hint[:empty].times { hint_text += CLUES[:empty] }
    puts hint_text if print
    hint
  end

  private

  def print_rules
    puts RULES
  end

  def choose_role
    puts 'Would you like to be the Codebreaker (1) or Codemaker (2)?'
    role = gets.to_i
    return role - 1 if [1, 2].include?(role)

    puts 'Incorrect input! Try again.'
  end
end

new_game = Game.new(HumanPlayer, ComputerPlayer)
new_game.play
