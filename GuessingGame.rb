# date formatters
DATE_FORMAT     = "%Y/%m/%d %H:%M:%S"

#globals
$scoreboard = {}
$stats

#get name from player
def name
    puts "Your name: "
    player_name = gets.chomp
    player_name = player_name.strip #get rid of spaces
    player_name = player_name.gsub(/\s+/,"")
    if player_name.length > 0
        return  player_name
    else
        return "Anon"
    end
end

#show best plays of every player, sorted from best to worst
def leaderboard
    printf("\nLEADERBOARD\n%10s %10s %19s\n", "NAME", "SCORE", "DATE")
    if $scoreboard.length == 0
        puts "No games played in this session"
    end
    $scoreboard.each do |k, v|
        printf("%10s %10d %10s\n", k, v[0], v[1])
    end

    sleep(5)
    menu
end

#show stats about game
def statistics
    puts "\nSTATISTICS"
    puts "Minimum tries: " + $stats[0].to_s
    puts "Maximum tries: " + $stats[1].to_s
    printf "Average number of tries: %.2f\n", $stats[3]

    sleep(5)
    menu
end

#instruction how to play
def instruction
    puts "\nGuessing game is about guessing number that is randomly generated between 0 and 1000 (integers only).\n
Program will tell you if your guess is lower or higher than number you are looking for.\n
When you win program will ask your name and will save your progress.\n
By playing you agree to collect and use data in form of your name, score and date you played.\n"
    sleep(5)
    menu
end


#play game
def play_game(start_range, end_range, tries)
    computer_guess = rand(start_range..end_range)
    player_guesses = []

    puts "Guess a number (type end to get back to menu)"
    puts "attempt #" + tries.to_s

    player_guess = gets.chomp.to_i

    while player_guess != computer_guess
        if player_guesses.include?(player_guess) && player_guess > computer_guess
        puts "You've already tried " + player_guess.to_s + " and it's too high!"
        elsif player_guesses.include?(player_guess) && player_guess < computer_guess
        puts "You've already tried " + player_guess.to_s + " and it's too low!"
        elsif player_guess > computer_guess
            puts "Wrong! " + player_guess.to_s + " is too high!"
            player_guesses << player_guess # Add user guess to the array of previous guesses
        elsif player_guess < computer_guess
            puts "Wrong! " + player_guess.to_s + " is too low!"
            player_guesses << player_guess # Add user guess to the array of previous guesses
        elsif player_guess == "end"
            menu
        end
        tries += 1
        puts "attempt #" + tries.to_s
        player_guess = gets.chomp.to_i
    end
    puts "Congrats, you guessed it in " + (tries).to_s + " tries!"
    player_name = name
    date = Time.now.strftime DATE_FORMAT

    unless $scoreboard.has_key? player_name
        $scoreboard[player_name] = tries, date
        puts "This is your first win! :D"
    end

    if $scoreboard[player_name][0] > tries
        $scoreboard[player_name] = tries, date
        puts "You beat your personal record! Congratulations! :D"
    end

    $scoreboard = $scoreboard.sort_by {|k, v| v[0]}.to_h

    File.open("scoreboard.txt", "w") {
      |log|
      $scoreboard.each do |k, v|
          log.write "#{k} #{v[0]} #{v[1]}\n"
      end
    }
    if $stats[0].to_i > tries or $stats[0].to_i == 0
        $stats[0] = tries
    end

    if $stats[1].to_i < tries
        $stats[1] = tries
    end

    $stats[2] = $stats[2].to_i + 1
    $stats[3] = $stats[3].to_f + ((tries.to_i - $stats[3].to_f )/ ($stats[2].to_i).to_f)

    File.open("stats.txt", "w") { |f| f.write "#{$stats[0]}\n#{$stats[1]}\n#{$stats[2]}\n#{$stats[3]}\n"}

    menu
end

#menu
def menu
    choice = 0
    tries = 1
    loop do
        puts "\n--------------------"
        puts "Number Guessing Game"
        puts "--------------------"
        puts "Press key with number next to option you want to select it"
        puts "1 - PLAY"
        puts "2 - LEADERBOARD"
        puts "3 - STATISTICS"
        puts "4 - HOW TO PLAY AND TOS"
        puts "5 - EXIT"

        choice = gets.chomp.to_i

        if [1, 2, 3, 4, 5].include? choice
            break
        end
        puts "This input is not supported!"
    end

    case choice
    when 1
        # play the game
        play_game(0, 1000, tries)
    when 2
        # show best score of every player
        leaderboard
    when 3
        statistics
    when 4
        # instructions how to play the game
        instruction
    when 5
        # exit the game
        puts "Closing game"
        exit
    else
        # not possible to be here
        puts "How are you here! :O"
        exit
    end
    nil
end

def main
    unless File.exist? "scoreboard.txt"
        File.open("scoreboard.txt", "w") { |f| f.write "" }
    end

    File.open("scoreboard.txt", "r").readlines.map.each do |line|
        player, score, date, hour = line.split
        $scoreboard[player] = score.to_i, (date + " " + hour).to_s
    end

    unless File.exist? "stats.txt"
        File.open("stats.txt", "w") { |f| f.write "0\n0\n0\n0\n" }
    end
    $stats = File.read("stats.txt").split

    menu
    nil
end

main # Start the game