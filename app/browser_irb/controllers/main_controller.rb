module BrowserIrb
  class MainController < Volt::ModelController

    # Include the collection helpers for irb
    if RUBY_PLATFORM == 'opal'
      `
      Opal.Object.$include((($scope.get('Volt')).$$scope.get('CollectionHelpers')))
      `
    end

    def initialize(*args)
      super

      @indented = false
      # Setup ESC keybinding
      `
      $(document).keyup(function(e) {
        if (e.keyCode == 27) {
          #{toggle_console}
        }
      });

      self.main_node = $('<div class="terminal-area">').appendTo('body');
      #{@term} = self.main_node.jqconsole(false, 'volt> ', '...');
      `

      restore_history

      prompt

      $stdout.write_proc = proc {|str| `#{@term}.Write(str, 'line')` }
      $stderr.write_proc = proc {|str| `#{@term}.Write(str, 'error')` }
    end

    def toggle_console
      `
      if ($('body').is('.terminal-open')) {
        $('body').removeClass('terminal-open');
        $('.terminal-area').hide();
      } else {
        $('body').addClass('terminal-open');
        $('.terminal-area').show();
        #{@term}.Focus();
      }
      `
    end

    def prompt
      `
      self.term.Prompt(true, function(input) {
        //self.$command(input);
      }, function (input, cb) {
        self.$command(input, cb);
        return false;
      }, true);
      `
    end

    def command(command, callback)
      if command.present?
        CommandTask.run(command).then do |code|
          if code == '...continue...'
            indent = @indented ? 0 : 2
            @indented = true
            `callback(indent);`
          else
            @indent = false
            `callback(false);`
            begin
              # Run the code returned from the server
              result = `eval(code)`
              `self.term.Write('=> ' + #{result.inspect} + "\n", 'line');`
            rescue => e
              `self.term.Write(#{e.inspect} + "\n", 'error');`
            end
          end

          stash_history
          prompt
        end.fail do |err|
          @indent = false
          `self.term.Write(err, 'error')`

          `callback(false);`
          stash_history
          prompt
        end
      else
        prompt
      end
    end

    def stash_history
      `
      var history = self.term.GetHistory();

      history = history.slice(0, 50);
      sessionStorage.setItem('irbhistory', JSON.stringify(history));
      `
    end

    def restore_history
      `
      var data = sessionStorage.getItem('irbhistory');

      if (data) {
        data = JSON.parse(data);

        self.term.SetHistory(data);
      }
      `
    end
  end
end

if Volt.client?
  `$(document).ready(function() {`
    BrowserIrb::MainController.new
  `});`
end