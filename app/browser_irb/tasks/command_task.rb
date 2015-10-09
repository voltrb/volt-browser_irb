class CommandTask < Volt::Task
  def run(command)
  	begin
	    Opal.compile(command, irb: true)
	  rescue RuntimeError => e
	  	# Check to see if we have a parse error
	  	if e.message =~ /An error occurred while compiling/
	  		# Pass that we are continuing
	  		'...continue...'
	  	else
	  		raise
	  	end
	  end
  end
end
