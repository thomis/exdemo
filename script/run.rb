puts "starting...."
Bundler.require

colors = [:green, :red, :yellow, :blue, :orange, :white, :magenta, :cyan].shuffle

puts ARGV[0].strip.colorize(colors.sample)
puts colors.map { |color| color.to_s.colorize(color) }.join(", ")
puts "Stopped"
