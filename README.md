# Thor::Completion

`Thor::Completion` provides an automatic completion for `Thor` based tools. Commands, arguments and options are automatically computed using Ruby's introspection.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'thor-completion'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install thor-completion

## Usage

Using this gem just consist in including `Thor::Completion::Command` to your main class, which already inherits from the `Thor` class, such as:
```
class MyTool < Thor
    include Thor::Completion::Command
```

Once this is done, the tool completion can be configured in Bash shells using the `completion` command of the tool itself, for instance with the following command:
```
bash$ eval $(mytool completion --bash-setup)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/npf/thor-completion. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/npf/thor-completion/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Thor::Completion project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/npf/thor-completion/blob/master/CODE_OF_CONDUCT.md).
