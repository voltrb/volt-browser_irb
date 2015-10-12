class Promise
  def then_puts
    self.then do |val|
      puts val.inspect
    end.fail do |err|
      puts "Error: #{err.inspect}"
    end
  end

  alias_method :tp, :then_puts
end
