class IO_ #add the _ to not clash with ruby IO class

    def initialize
        @fiat = "USD"
    end

  def coin(again=false)
    if (again == true) then again_text = "Viable coin are: BTC, LTC, etc" end
    puts "Which Coin are we trading for #{@fiat} on Coinbase today? #{again_text}"  
    STDOUT.flush  
    coin = gets.chomp.to_s.upcase  
    if ['BTC','LTC','ETH'].include? coin then return coin else coin(true) end
  end

  def percent(again=false)
    if (again == true) then again_text = "Must enter Number & cannot be 0" end
    puts "take action on what percent change. #{again_text}"  
    STDOUT.flush  
    percent = gets.chomp
    percent.delete! '%'
    regex_check = /[^.\d]/.match(percent)
    if regex_check == nil then percent = percent.to_f end 
    if ( (percent.is_a? Numeric) and percent != 0 ) then p percent else percent(true) end
  end

  def freq(again=false)
    if (again == true) then again_text = "Must be a number, can be several seperated by commas or spaces" end
    puts "Frequency of check, in minutes. #{again_text}"  
    STDOUT.flush  
    minutes = gets.chomp
    minutes = minutes.split(/\W/)
    if minutes.empty? then freq(true) end

    minutes.reject! { |minute| (/\D/).match(minute) || minute == "" }
    minutes.map! { |minute| minute.to_f }

    if minutes.empty? then freq(true)  end

    puts "Did you mean the following #{minutes}. Y/N"  
    STDOUT.flush  
    answer = gets.chomp.upcase
    if (answer != "Y" and answer != "YES") then freq(true) else return minutes end
  end

end #class end