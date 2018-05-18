class	Game
	def initialize()
		# pool of colors to pick
		@colors = ['Blue', 'Green', 'Orange', 'Purple', 'Red', 'Yellow']
		@human_score = 0
		@ai_score = 0
		
		puts
		puts "Welcome to Mastermind, a code breaking game."
		puts
		puts "RULES"
		puts
		puts 'You must first decide how many rounds you want to play, must be an even number. You will alternate between being the Codebreaker and Codemaker every round.'
		puts
		puts 'The codemaker chooses a pattern of four code pegs. Duplicates are allowed, so the player could even choose four code pegs of the same color.'
		puts
		puts 'The codebreaker tries to guess the pattern, in both order and color, within ten turns. Each guess is made by placing a row of code pegs on the decoding board. Once placed, the codemaker provides feedback by placing from zero to four key pegs in the small holes of the row with the guess. A colored or black key peg is placed for each code peg from the guess which is correct in both color and position. A white key peg indicates the existence of a correct color code peg placed in the wrong position.'
		puts
		puts 'If there are duplicate colours in the guess, they cannot all be awarded a key peg unless they correspond to the same number of duplicate colours in the hidden code. For example, if the hidden code is white-white-black-black and the player guesses white-white-white-black, the codemaker will award two colored key pegs for the two correct whites, nothing for the third white as there is not a third white in the code, and a colored key peg for the black. No indication is given of the fact that the code also includes a second black.'
		puts
		puts 'Once feedback is provided, another guess is made; guesses and feedback continue to alternate until either the codebreaker guesses correctly, or ten incorrect guesses are made.'
		puts
		puts "The codemaker gets one point for each guess a codebreaker makes. An extra point is earned by the codemaker if the codebreaker doesn't guess the pattern exactly in the last guess. The winner is the one who has the most points after the agreed-upon number of games are played."
		puts
		puts 'How many rounds will you play?'
		@rounds = gets.to_i
		until @rounds.even? && @rounds.positive?
			puts 'Please pick an even number. The minimum number of rounds allowed is 2.'
			@rounds = gets.to_i
		end
		puts
		puts 'Would you like to start the game as the Codebreaker or Codemaker?'
		puts '1. Codebreaker'
		puts '2. Codemaker'
		puts
		@player_role = gets.to_i
		until @player_role.between?(1, 2)
			puts "Please pick either 1 or 2."
			@player_role = gets.to_i
		end
	end

	def new_round
		@turn = 1
		@results = []
		if @player_role == 1
			start_codebreaker
			@player_role = 2
			current_score
		else 
			start_codemaker
			@player_role = 1
			current_score
		end
	end

	def start_game
		round = 1
		until round > @rounds
			new_round
			round += 1			
		end
		if @human_score > @ai_score
			puts 'Congratulations!! You WIN the game.'
		elsif @ai_score > @human_score
			puts 'The Opponent WINS the game.'
		else
			puts "It's a tie!"
		end
	end


	# resets al variables to start a new round.
	def reset 
		@colors_left = 4
		@guess = []
		@guess_bad_position = []
		@black_pegs = 0
		@white_pegs = 0
	end

	def current_score
		puts
		puts 'Current Score:'
		puts "YOU: #{@human_score} / OPPONENT: #{@ai_score}"
		puts 
	end


	# gets the code from the AI.
	def ai_picks
		4.times.map { @colors.sample }
	end

	# gets the code from the human player.
	def human_picks
		pick = []
		4.times do				
			puts 'Type the number of the corresponding color you want to use in your code.'
			puts "Picks left: #{@colors_left}"
			puts
			puts '1. Blue'
			puts '2. Green'
			puts '3. Orange'
			puts '4. Purple'
			puts '5. Red'
			puts '6. Yellow'
			puts
			color = gets.to_i
			until color.between?(1, 6)
				puts 'Please pick a number between 1 and 6.'
				color = gets.to_i		
			end
			pick.push @colors[color - 1]
			puts
			puts pick.join(" - ")
			puts
			@colors_left -= 1
		end
		return pick
	end

	def human_picks_pegs
		puts 'Please specify how many colors in the right position were guessed.'
		@black_pegs = gets.to_i
		until @black_pegs < 4 && @black_pegs >= 0
			puts "Maximum number of black pegs exceeded"
			@black_pegs = gets.to_i
		end
		puts 'And, how many colors were gueesed right but the position was wrong?'
		@white_pegs = gets.to_i
		until @white_pegs >= 0
			puts 'There can be no less than 0 pegs, the laws of physics demand it.'
		end
		if (@black_pegs + @white_pegs) > 4
			puts "Maximum number of pegs exceeded, please try again."
			human_picks_pegs
		end
	end

	def show_turn
		puts
		puts "=== TURN #{@turn} ==="
	end

	# starts the game as the codebreaker.
	def start_codebreaker
		code = ai_picks
		puts 'You are the Codebreaker. Remember, you only have 10 tries to guess the secret code. Good luck.'
		10.times do
			show_turn
			reset
			# Cheat for testing purposes
			# puts code
			@guess = human_picks
			if @guess == code
				@ai_score -= 1
				return puts 'Congratulations you cracked the code!'
			else
				@ai_score += 1
				pegs_code = code.dup
				@guess.each_with_index do |item, index|
					if item == code[index]
						@black_pegs += 1
						pegs_code.delete_at(pegs_code.index(item))
					else
						@guess_bad_position.push item
					end
				end	
				pegs_code.each do |x| 
					if @guess_bad_position.include? x
						@white_pegs += 1
					end
				end
			end
			puts
			if @black_pegs == 0 && @white_pegs == 0
				puts "No color was right on your guess. Thats OK, keep trying..."
			end					
			if @black_pegs > 0
				puts "#{@black_pegs} Black pegs: You guessed #{@black_pegs} #{@black_pegs == 1 ? 'color' : 'colors'} in the right position."
			end
			if @white_pegs > 0
				puts "#{@white_pegs} White pegs: #{@black_pegs > 0 ? "Also, you" : "You"} guessed #{@white_pegs} #{@white_pegs == 1 ? 'color' : 'colors'} right, but #{@white_pegs == 1 ? 'it was' : 'they were'} in the wrong position."
			end
			@turn += 1
			@results.push "#{@guess.join(" - ")} // Black pegs: #{@black_pegs} - White pegs: #{@white_pegs}"
			puts
			puts "Your guesses so far:"
			puts
			puts @results
			puts
		end
		@ai_score += 1
	end

	# starts the game as the codemaker.
	def start_codemaker
		puts 'You are the Codemaker. You must pick a code and provide feedback to the Codebreaker. Good luck.'
		puts
		reset
		code = human_picks
		10.times do
			show_turn
			reset
			@guess = ai_picks
			puts
			puts "Opponent Guess: #{@guess.join(" - ")}"
			if @guess == code
				puts
				@human_score -= 1
				return puts 'The Opponent cracked your code!'
			else
				@human_score += 1
				puts "Secret Code: #{code.join(' - ')}"
				puts
				human_picks_pegs
				@results.push "#{@guess.join(" - ")} // Black pegs: #{@black_pegs} - White pegs: #{@white_pegs}"
				puts
				puts 'Your opponent guesses so far:'
				puts
				puts @results
				@turn += 1
			end
		end
		@human_score += 1
	end

end

master = Game.new
master.start_game

