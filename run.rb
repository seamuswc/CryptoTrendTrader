
require_relative 'trade'
require_relative 'io_'
require_relative 'sms'

io = IO_.new #add the _ to not clash with ruby IO class
coin = io.coin
percent = io.percent
minutes = io.freq

$threads = Array.new
$trade_executed = false
$thread_failed = false
money = Make_Money.new(coin)

def start_threads(minutes, percent, coin, money)
  puts
  puts "New starting"
  puts
  minutes.each do |minute|
    $threads << Thread.new {money.check_change(minute.to_f, percent.to_f)}
    puts "#{coin} : #{minute} minutes : #{percent}%"
  end
  puts
  puts "Runninng..."
  puts

  Nexmo_.new.sms_start #add the _ to not clash with nexmo class

end

start_threads(minutes, percent, coin, money)

while true
  
  if $trade_executed != false or $thread_failed !=false then 
    
    money = nil
    $threads.each do |thr|
      thr.join
    end
    $threads = nil
    $threads = Array.new 
    $trade_executed = false
    $thread_failed = false
    money = Make_Money.new(coin)
    start_threads(minutes, percent, coin, money)
  
  else 

    $threads.each do |thr|
      if thr.status == nil or thr.status == false or thr.status == "aborting" then
        $thread_failed = true
      end    
    end

  end    

end



  



