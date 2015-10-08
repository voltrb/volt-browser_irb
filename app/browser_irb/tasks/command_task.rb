class CommandTask < Volt::Task
  def run(command)
    Opal.compile(command, irb: true)
  end
end
