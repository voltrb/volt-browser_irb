module BrowserIrb
  class MainController < Volt::ModelController

    # Include the collection helpers for irb
    `
    Opal.Object.$include((($scope.get('Volt')).$$scope.get('CollectionHelpers')))
    `

    def initialize(*args)
      super
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

      prompt

      $stdout.write_proc = proc {|str| `#{@term}.Write(str)` }
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
      }
      `
    end

    def prompt
      `
      self.term.Prompt(true, function(input) {
        self.$command(input);
      }, function (input) {
        return false;
      });
      `
    end

    def command(command)
      if command.present?
        CommandTask.run(command).then do |code|
          begin
            # Run the code returned from the server
            result = `eval(code)`
            `self.term.Write('=> ' + #{result.inspect} + "\n");`
          rescue => e
            `self.term.Write(#{e.inspect} + "\n", 'error');`
          end

          prompt
        end.fail do |err|
          `self.term.Write(err)`

          prompt
        end
      else
        prompt
      end
    end
  end
end

if Volt.client?
  `$(document).ready(function() {`
    BrowserIrb::MainController.new
  `});`
end