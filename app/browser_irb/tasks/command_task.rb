class CommandTask < Volt::Task
  def run(command)
    puts "COMMAND: #{command.inspect}"

    Opal.compile(command, irb: true)
  end
end
