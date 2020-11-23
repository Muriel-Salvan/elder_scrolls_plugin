# Elder Scrolls Plugin

Elder Scrolls Plugin - Reading Bethesda\'s esp, esm and esl files

## Getting Started

### Prerequisites

You just need to have Ruby installed.

### Installing

ElderScrollsPlugin installs as any Rubygem, either using `gem` command or Bundler.

```bash
gem install elder_scrolls_plugin
```

Or using Bundler, add this in your `Gemfile` and issue `bundle install`.

```
gem 'elder_scrolls_plugin'
```

Once the gem is installed you can require its main library in your Ruby code and use its API:

```ruby
require 'elder_scrolls_plugin'

my_esp = ElderScrollsPlugin.new 'my_file.esp'
```

The gem also comes with a nice executable that dumps various info about an esp file.

```bash
esp_dump my_file.esp
```

Here is the usage help of the `esp_dump` executable:
```
Usage: esp_dump [options] files
    -d, --debug                      Activate log debugs
    -f, --include-fields             Read the fields
    -j, --output-json                Output the tree of records as JSON
    -i, --diff                       Output a JSON of the differences between 2 esps. Requires 2 esps files to be given. Will display file2 - file1.
    -m, --output-masters             Output the masters list
    -o, --only-tes4                  Read only the TES4 header
    -r, --output-form-ids            Output the absolute form IDs
    -t, --output-tree                Output the tree of records
    -u, --output-unknown             Output unknown chunks
```

## ElderScrollsPlugin API

ElderScrollsPlugin uses a simple API that exposes the structure of an esp file as a tree of [`Riffola::Chunk`](https://github.com/Muriel-Salvan/riffola/blob/master/lib/riffola.rb) objects.
A Chunk object contains:
1. A 4 bytes header
2. An encoded data size (on 4 or 2 bytes)
3. An optional header
4. Data of the given encoded data size

## Running the tests

Executing tests is done by:

1. Cloning the repository from Github:
```bash
git clone https://github.com/Muriel-Salvan/elder_scrolls_plugin
cd elder_scrolls_plugin
```

2. Installing dependencies
```bash
bundle install
```

3. Running tests
```bash
bundle exec rspec
```

## Deployment

Like any Rubygem:
```bash
gem build elder_scrolls_plugin.gemspec
```

## Contributing

Please fork the repository from Github and submit Pull Requests. Any contribution is more than welcome! :D

## Versioning

We use [SemVer](http://semver.org/) for versioning.

## Authors

* **Muriel Salvan** - *Initial work* - [Muriel-Salvan](https://github.com/Muriel-Salvan)

## License

This project is licensed under the BSD License - see the [LICENSE](LICENSE) file for details
