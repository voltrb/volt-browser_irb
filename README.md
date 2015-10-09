# Volt::BrowserIrb

This gem provides a simple IRB that can run in the browser.  Unlike [opal-irb](https://github.com/fkchang/opal-irb), volt-browser_irb does not load up the opal compiler on the client.  Since volt already has a compiler loaded on the server, all compilation is done on the server and sent back to the client.  This avoids the load time associated with loading the opal compiler.

## Usage

Include the gem in development mode only in the Gemfile:

```ruby
group :development do
  gem 'volt-browser_irb'
end
```

Then in ```app/main/config/dependencies.rb``` you can require it as a dependency (for dev mode only)

```ruby
if Volt.env.development?
  dependency 'browser_irb'
end
```

Restart the server, and press ESCAPE to toggle the irb on the page.

## TODO

Currently browser-irb is pretty simple, here's some things I want to add:

- tab completion