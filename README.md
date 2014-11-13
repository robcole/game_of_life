# Building the Game of Life as a Ruby Gem

In this tutorial, we'll walk through a TDD-focused approach to building [Conway's Game of Life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life) as a ruby gem. Unit tests and integration tests will be written in RSpec.

We'll be using Ruby 2.1.5 along with bundler, though any version >= 2.0.0 should work for our purposes. If you don't have bundler installed, `gem install bundler` will do the trick.

<h3>Sections</h3>
<a href="#bundler-bootstrap">Getting Started with Bundler</a><br>
<a href="#rspec-setup">RSpec setup</a><br>
<a href="#writing-tests">The Tests</a><br>
<a href="#time-to-code">The Code</a><br>

--

<br>
# <a name="bundler-bootstrap"></a>Using Bundler to Bootstrap your Gem

Bundler makes the initial setup of a gem painless. We'll stick with [standard gem naming conventions](http://guides.rubygems.org/name-your-gem/) and use underscores as spaces.

`bundle gem game_of_life`

You should see something like this:

```
create  game_of_life/Gemfile
create  game_of_life/Rakefile
create  game_of_life/LICENSE.txt
create  game_of_life/README.md
create  game_of_life/.gitignore
create  game_of_life/game_of_life.gemspec
create  game_of_life/lib/game_of_life.rb
create  game_of_life/lib/game_of_life/version.rb

Initializing git repo in <path>/game_of_life
```

The scaffolding is fairly straightforward -- bundler takes care of the proper directory structure, adding a README, initializing a git repository, and giving you some generic structure to build your gem.

There are two noteworthy here. First, let's take a look at our Gemfile.

#### Gemfile

```
source 'https://rubygems.org'

# Specify your gem's dependencies in game_of_life.gemspec
gemspec
```

#### game\_of\_life.gemspec

The `gemspec` line in your Gemfile tells bundler that we won't be using our Gemfile to manage dependencies; instead, we'll be using `game_of_life.gemspec`. Let's take a look at that.

```
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'game_of_life/version'

Gem::Specification.new do |spec|
  spec.name          = "game_of_life"
  spec.version       = GameOfLife::VERSION
  spec.authors       = ["Rob Cole"]
  spec.email         = ["email@example.com"]
  spec.summary       = %q{Game of Life as a Ruby Gem}
  spec.description   = %q{TDD Practice: Game of Life Ruby Gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
```

If you want to learn more about what each of these lines does and to learn more about building gems, I recommend [The Rubygems Guide to Making Your Own Gem](http://guides.rubygems.org/make-your-own-gem/) or for a very detailed read, [Brandon Hilkert's Learn to Build a Ruby Gem](http://brandonhilkert.com/books/build-a-ruby-gem/).

For our purposes, what we care about are setting the author, email, summary, description. We also need to add RSpec as a dependency to our project. This is done on the last line of our gemspec -- with the line`spec.add_development_dependency "rspec"`.

--

# <a name="rspec-setup""></a>Getting Started with RSpec


#### Installing the RSpec gem via Bundler

After you've added rspec to your gemspec file, you can run `bundle install`. You should see something like this, letting you know that rspec is now bundled with your project.

```
Fetching gem metadata from https://rubygems.org/.........
Resolving dependencies...
Using rake 10.3.2
Using bundler 1.7.3
Using diff-lcs 1.2.5
Using game_of_life 0.0.1 from source at .
Installing rspec-support 3.1.2
Installing rspec-core 3.1.7
Using rspec-expectations 3.1.2
Installing rspec-mocks 3.1.3
Using rspec 3.1.0
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
```

#### RSpec Setup
Once you've got RSpec bundled with your project, run `rspec --init` to setup RSpec in your project. This will add a spec_helper, and a .rspec configuration file that will require it.

Edit your spec_helper file, and require your gem.

```
require "game_of_life"
# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
...
```

Voila! You're setup and are ready to start writing tests. To verify, you can run tests via `rspec spec`.

```
$ rspec spec/
No examples found.

Finished in 0.0002 seconds (files took 0.13013 seconds to load)
```

Now we're ready to start writing tests.

--

# <a name="writing-tests"></a>It's Testing Time
For our version of the game, we'll model the game using Grids and Cells. A grid will be infinite.

To start, we'll create a `grid_spec.rb` file inside our `spec` directory. The basic template for our file will look like this:

```
require 'spec_helper'

module GameOfLife
  describe Grid do
    describe "#initialize" do
      it "creates a new grid" do
        skip("Not yet implemented")
      end
    end
  end
end
```

There are three important things to note here:

#### 1 - Namespacing
Because we're creating a gem, all code that we write will be namespaced under the GameOfLife module. This prevents conflicts between libraries and 

In order to call code from our gem, we'll prepend GameOfLife:: to any class methods we call in our tests.

#### 2 - Syntax for setting pending tests
The line ```skip("Not yet implemented")``` allows us to build tests that we plan on implementing later. For now, we know that we want to test that grid.draw draws the grid, but we've got some work to do before we can get there... so we create a pending test, with the intention of coming back to it later.

#### 3 - "Describe" syntax conventions

In this case, we're describing what the "draw" method will do on a specific grid. For instance methods, it's recommended to use ```describe "#method_name"```, and for class methods, ```describe ".method_name"```. For more on this and other best practices for RSpec, check out [Better Specs](http://betterspecs.org/).

### Running our Tests

If we try to run our pending tests using `rspec spec`, they will fail with the following error:
`uninitialized constant GameOfLife::Grid (NameError)` because our application doesn't have a Grid class yet. So let's create one.

--

# <a name="time-to-code"></a>Time to Code!

From here on out, we'll be working in a [Red-Green-Refactor](http://www.jamesshore.com/Blog/Red-Green-Refactor.html) style, starting with writing failing tests, then writing *just* enough code to make the tests pass, and eventually cleaning up our code (refactoring). We have our first failing test, 

## Part One: A Quick Look at Gem File Structure

We're going to start by editing `game_of_life/lib/game_of_life.rb`. We'll initially be cramming all of our code into a single file, but as our project grows, we will migrate code into separate files.

With that said, let's start with rule #1: **write just enough code to make the test pass.**

```
# game_of_life/lib/game_of_life.rb

require "game_of_life/version"

module GameOfLife
  class Grid
  end
end
```

Now, with our first non-failing test out of the way (just run `rspec spec` to verify), we can move on to writing some real tests and real code.

## Part Two: Real Code

Now we're ready to start implementing actual code. We'll be breaking the Game of Life down into two separate classes - Grids and Cells. Cells will be responsible for knowing their coordinates and their state (alive or dead). Grids will be able to find the nearest neighbors of a cell given a position, to create a new grid with a new pattern, and to calculate the next state for a given cell given its neighbors. Finally, a grid will also be able to call `grid#draw` in order to display itself.

### The Grid

Our first test will ensure that a new grid can be created. A grid will have many Cells, but we'll start with a single cell, located at [0, 0]. Grid will take an array of live cells in order to initialize the initial pattern.

```
# grid_spec.rb

require 'spec_helper'

module GameOfLife
  describe Grid do

    context "Grid is initialized with a single cell" do
      before(:each) do
        live_coordinates = [[0, 0]]
        @grid = GameOfLife::Grid.new(live_coordinates)
      end

      describe "#initialize" do
      	it "should create a cell with a position of 0,0"
	      expect(@grid.cells.first.position).to eq [0,0]
	    end
      end
    end

  end
end

```

We're using the context block to separate tests logically into different contextual segments. In this case, we're initializing a new grid with a single cell at 0,0 using the `before(:each)` syntax, and keeping that separated within the context of a single-cell grid. This will allow each text within that context block to access that specific instance of @grid.

Run your test suite, and you should see an error message: 
```
Failure/Error: @grid = GameOfLife::Grid.new(live_coordinates)
     ArgumentError:
       wrong number of arguments (1 for 0)
     # ./spec/grid_spec.rb:9:in `initialize'
     # ./spec/grid_spec.rb:9:in `new'
     # ./spec/grid_spec.rb:9:in `block (3 levels) in <module:GameOfLife>'
```

### A Grid of Cells

We're starting with a fairly complex test to make pass. In order for it to pass, we need to ensure the following things happen:

**1** - We can pass an array (or multiple arrays) as an argument to our new grid.
<br>**2** - For each coordinate pair passed to the grid, a new cell is created.
<br>**3** - Each cell needs to respond to the method position, and return an array of its x, y coordinates.

Let's start with #1, which is our simplest step. In order to allow the user to pass **either** an array or multiple arrays to the grid, we'll set up an initialize method that takes an array.

```
class Grid
  def initialize(arr)
    arr = [arr] unless arr.first.is_a?(Array)
  end
end
```

The first line in this method ensures that we have an array of arrays. For example, if we pass the coordinates [0,0] into this method, the first line will turn that into [[0,0]]. Keeping our input normalized in this format allows us to map the array and return an array of cells, regardless of how whether it receives one or many coordinates.

In order for a grid to create and associate itself with cells, we'll need to have a Cell class as well. Each cell will accept its coordinates as arguments, and will have a default state of "live" on creation. Let's create a quick set of tests in a new spec file, `cell_spec.rb`, to test our Cell.

```
require 'spec_helper'

module GameOfLife
  describe Cell do

    before(:each) do
      @cell = Cell.new([1,1])
    end

    it "should respond with a position of 1,1" do
      expect(@cell.position).to eq [1,1]
    end

    it "should be alive as a default" do
      expect(@cell.state).to eq :live
    end
  end
end
```

Running our Cell tests in `rspec spec/cell_spec.rb` should now result in a NameError. Just like we had to do with Grid earlier, we'll need to create a Cell class. For now, let's just add it to the bottom of `game_of_life.rb`, below the Grid class.

```
class Grid
  def initialize(arr)
    arr = [arr] unless arr.first.is_a?(Array)
  end
end

class Cell
  attr_accessor :position, :state

  def initialize(coordinates)
    @position = coordinates
    @state = :live
  end
end
```

The [`attr_accessor`](http://stackoverflow.com/questions/4370960/what-is-attr-accessor-in-ruby) method allows us to set and access the position of the cell by creating [setter and getter methods](http://rubymonk.com/learning/books/4-ruby-primer-ascent/chapters/45-more-classes/lessons/110-instance-variables). Now, we need to ensure that Grid will create a new Cell for each coordinate pair passed to it. For this, I'm using [ruby's Enumerable#map](http://ruby-doc.org/core-2.1.4/Enumerable.html#method-i-map), which allows you to take an enumerable object (in this case, an array) and run a block of code on each. We're using this to take an array of arrays and converts each **X,Y** pair to a cell. Here's what it all looks like when it's all put together.

```
require "game_of_life/version"

module GameOfLife

  class Grid
    attr_accessor :cells
    def initialize(arr)
      arr = [arr] unless arr.first.is_a?(Array)
      @cells = arr.map { |coords| Cell.new(coords) }
    end
  end

  class Cell
    attr_accessor :position, :state

    def initialize(coordinates)
      @position = coordinates
      @state = :live
    end
  end

end
```

With that code written, we can create a new test and context to ensure that if we pass multiple coordinates to a grid, it will work as well. Let's add that code to our `grid_spec.rb` file.

```
context "Grid is initialized with two cells" do
  before(:each) do
    @coord1 = [0,0]
    @coord2 = [1,1]
    @grid = GameOfLife::Grid.new(@coord1, @coord2)
  end

  describe "#initialize" do
    it "should create a cell with a position of 0,0" do
      expect(@grid.cells.first.position).to eq @coord1
    end

    it "should create a cell with a position of 1,1" do
      expect(@grid.cells[1].position).to eq @coord2
    end
  end
end
```

When you run `rspec spec`, you should have 3 passing tests -- a working grid of cells!

### Our first Refactor: Using Patterns to Create Grids

Our next goal is going to be to make grid creation easier. Right now, we're sending an array of coordinates as a message to the initialize method for the Grid. For us to play around with the grid later, it'll be much easier for us to be able to "draw" a pattern and then pass that.

To get to that point, we're going to refactor our Grid#initialize method to be able to handle patterns as well as coordinates. We'll be using the "-" character to note dead cells and "X" to note live cells, so we can write code like this:

```
pattern = %q(----X----
			 ----X----
			 ----X----
			 ---------
			 XXX---XXX
			 ---------
			 ----X----
			 ----X----
			 ----X----).gsub(/[^\S\n]/m, '')

grid = Grid.new(pattern: pattern)
grid.cells.count # => 12
```

A few quick things to note -- above, we're using %q to create a multiline string, and gsub to remove all non-newline whitespace from it. This is functionally the same as doing this:

```
pattern = "----X----\n----X----\n----X----\n---------\nXXX---XXX\n---------\n----X----\n----X----\n----X----"
```

...but has the added benefit of being more readable. We're using that specific pattern because it alternates between two shapes, so we can visually inspect how our grid is working later. [You can take a look at the alternation by creating the pattern here](http://projects.abelson.info/life/).

Let's start by writing our first failing test, using the pattern from above. We'll add a new context to our grid_spec, with a simple test to count the number of cells. 

```
context "Grid can be initialized using a pattern" do
  before(:each) do
    pattern = %q(----X----
                 ----X----
                 ----X----
                 ---------
                 XXX---XXX
                 ---------
                 ----X----
                 ----X----
                 ----X----).gsub(/\s+/m, '')
   @grid = GameOfLife::Grid.new(pattern: pattern)
  end

  it "should have 12 cells" do
    expect(@grid.cells.count).to eq 12
  end
  
  it "should have a position of [4,0] for the first cell" do
    expect(@grid.cells.first.position).to eq [4,0]
  end
end
```

Currently, our grid takes one argument, which is automatically converted to an array. In order to move forward, we'll need to modify it so that it can take two arguments -- either a string (the pattern) or an array (the coordinates) -- and work with either of them.

### Using Keyword Arguments in our Grid Class

We'll be using [keyword arguments](http://robots.thoughtbot.com/ruby-2-keyword-arguments) to build our grid to accept either of these types of input. A Grid will have an array of cells. We'll break the logic for how the cells are created out into two separate methods, `grid#build_cells_from_coordinates` and `grid#build_cells_from_pattern`. Here's what our #initialize code will look like to enable this:

```
def initialize(pattern: nil, coordinates: nil)
  if pattern
    @cells = build_cells_from_pattern(pattern)
  elsif coordinates.any?
    @cells = build_cells_from_coordinates(coordinates)
  else
    fail("A grid requires either a pattern or coordinates to be created.")
  end
end
```

This sets the default value of both pattern and coordinates to nil, and only creates cells if a pattern or coordinates are provided. If **both** a pattern and coordinates are provided, it will create cells based on the pattern. We'll come back to writing a test for this specific edge case once we have our previous tests passing. But first, we need to build the missing methods to process the input and create cells from it.

We already have the bulk of the code necessary for creating cells from coordinates (the Enumerable#map method we used earlier).

```
def build_cells_from_coordinates(arr)
  arr = [arr] unless arr.first.is_a?(Array)
  arr.map { |coords| Cell.new(coords) }
end
```

At this point, we'll need to do some small refactoring to our tests to get them working again, because we've changed what grid#initialize is expecting. You'll need to find all instances of GameOfLife::Grid.new(), and ensure that you're passing coordinates and patterns as separate arguments. Here's what the new tests look like:

```
require 'spec_helper'

module GameOfLife
  describe Grid do

    context "Grid is initialized with a single cell" do
      before(:each) do
        live_coordinates = [0, 0]
        @grid = GameOfLife::Grid.new(coordinates: live_coordinates)
      end

      describe "#initialize" do
        it "should create a cell with a position of 0, 0" do
          expect(@grid.cells.first.position).to eq [0,0]
        end
      end
    end

    context "Grid is initialized with two cells" do
      before(:each) do
        @coord1 = [0,0]
        @coord2 = [1,1]
        @grid = GameOfLife::Grid.new(coordinates: [@coord1, @coord2])
      end

      describe "#initialize" do
        it "should create a cell with a position of 0,0" do
          expect(@grid.cells.first.position).to eq @coord1
        end

        it "should create a cell with a position of 1,1" do
          expect(@grid.cells[1].position).to eq @coord2
        end
      end
    end

    context "Grid can be initialized using a pattern" do
      before(:each) do
        pattern = %q(----X----
                     ----X----
                     ----X----
                     ---------
                     XXX---XXX
                     ---------
                     ----X----
                     ----X----
                     ----X----).gsub(/\s+/m, '')
       @grid = GameOfLife::Grid.new(pattern: pattern)
      end

      it "should have 12 cells" do
        expect(@grid.cells.count).to eq 12
      end

      it "should have a position of [4, 0] for the first cell" do
        expect(@grid.cells.first.position).to eq [4, 0]
      end
    end

  end
end
```

At this point, you should have **2** failing tests:
```
Failures:

  1) GameOfLife::Grid Grid can be initialized using a pattern should have 12 cells
     Failure/Error: @grid = GameOfLife::Grid.new(pattern: pattern)
     NoMethodError:
       undefined method `build_cells_from_pattern' for #<GameOfLife::Grid:0x007fb5a1b2bac0>
     # ./lib/game_of_life.rb:11:in `initialize'
     # ./spec/grid_spec.rb:48:in `new'
     # ./spec/grid_spec.rb:48:in `block (3 levels) in <module:GameOfLife>'

  2) GameOfLife::Grid Grid can be initialized using a pattern should have a position of [5, 0] for the first cell
     Failure/Error: @grid = GameOfLife::Grid.new(pattern: pattern)
     NoMethodError:
       undefined method `build_cells_from_pattern' for #<GameOfLife::Grid:0x007fb5a1b29fe0>
     # ./lib/game_of_life.rb:11:in `initialize'
     # ./spec/grid_spec.rb:48:in `new'
     # ./spec/grid_spec.rb:48:in `block (3 levels) in <module:GameOfLife>'
```

Let's build our method to build cells from a pattern and take care of those errors.

#### Building Coordinates from Patterns

From a 10,000ft level, our goal with this method is to take a string and convert it into a series of coordinates. There are a few things that our method will do to accomplish this:

**1** - For every line in the pattern, find the X's in that line.<br>
**2** - When you find an X, add a coordinate to an coordinates array that corresponds to the line number you're on (the Y coordinate) and the character that the X was on (the X coordinate).<br>
**3** - Convert each of those coordinates to a cell.

We've already written a method that converts coordinates to cells, so we just need to sort through the lines in the patterns and build corresponding coordinates. There are multiple ways you could accomplish this, but we'll be relying heavily on built in methods in ruby's Enumerable and String classes. Here's what the final method looks like.

```
def build_cells_from_pattern(pattern)
  coordinates = []
  pattern.lines.each.with_index(0) do |line, line_index|
    line.each_char.with_index(0) do |char, char_index|
      if char == 'X'
        x_pos = char_index
        y_pos = line_index
        coordinates.push([x_pos, y_pos])
      end
    end
  end
  build_cells_from_coordinates(coordinates)
end
```

Let's go through it line by line. `coordinates = []` creates an empty array for us to store our coordinates in. The [`lines`](http://www.ruby-doc.org/core-2.1.4/String.html#method-i-lines) method allows us to take our pattern, and for every line in that pattern, evaluate the line, while keeping track of the current index (our Y position) of the line.

From there, the [each-char](http://www.ruby-doc.org/core-2.1.4/String.html#method-i-each_char) method lets us evaluate each character in the line, keeping track of the index (our X position) of the character. When we find a character that matches our "live" input, we create the coordinates, and push them to our array.

Finally, we use our previously built build_cells_from_coordinates method to create and return an array of cells from our current coordinates. Run your rspec tests again, and you should have 6 passing tests.

#### DRYing up our tests
In order to keep with the DRY (don't repeat yourself) ethos, we're going to make a few small changes to our tests. The pattern we've been using (of the cross) is something we are going to use frequently to initialize and test new grids. Rather than create the variable in multiple places, let's move it to the top of our test suite and ensure that it is created and saved as `@cross_pattern`, making it accessible to any future tests in grid_spec.rb.

```
require 'spec_helper'

module GameOfLife
  describe Grid do

    before(:all) do
      @cross_pattern = %q(----X----
                          ----X----
                          ----X----
                          ---------
                          XXX---XXX
                          ---------
                          ----X----
                          ----X----
                          ----X----).gsub(/[^\S\n]/m, '')
    end

    context "Grid is initialized with a single cell" do
      before(:each) do
        live_coordinates = [0, 0]
        @grid = GameOfLife::Grid.new(coordinates: live_coordinates)
      end

      describe "#initialize" do
        it "should create a cell with a position of 0, 0" do
          expect(@grid.cells.first.position).to eq [0,0]
        end
      end
    end

    context "Grid is initialized with two cells" do
      before(:each) do
        @coord1 = [0,0]
        @coord2 = [1,1]
        @grid = GameOfLife::Grid.new(coordinates: [@coord1, @coord2])
      end

      describe "#initialize" do
        it "should create a cell with a position of 0,0" do
          expect(@grid.cells.first.position).to eq @coord1
        end

        it "should create a cell with a position of 1,1" do
          expect(@grid.cells[1].position).to eq @coord2
        end
      end
    end

    context "Grid can be initialized using a pattern" do
      before(:each) do
        @grid = GameOfLife::Grid.new(pattern: @cross_pattern)
      end

      it "should have 12 cells" do
        expect(@grid.cells.count).to eq 12
      end

      it "should have a position of [4, 0] for the first cell" do
        expect(@grid.cells.first.position).to eq [4, 0]
      end
    end

  end
end
```

--

## A Quick Revisit of the Rules

We're about to start on the main logic of the game, so taking a quick step back to look at the rules and think about how **you** would implement it is a good idea.

#### The Rules

1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
2. Any live cell with two or three live neighbours lives on to the next generation.
3. Any live cell with more than three live neighbours dies, as if by overcrowding.
4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

We're going to start with a simple implementation of these rules, and refactor to improve efficiency later. To begin, here are the steps our program will be walking through:

1. The grid finds all live coordinates.
2. The grid adds 1 point to the score of each of the coordinates surrounding a live coordinate.
3. The grid creates a new living cell for all new living cells, and kills all cells which should be killed.

#### The Grid Finds all Live Coordinates

We'll start with tests for the first part: the grid should be able to locate any live coordinates. We'll be adding one method to our Cell class as well as one method to our Grid class to accomplish this.

First, let's add the following test to `cell_spec.rb`:
```
it "should respond as alive when it is alive" do
  expect(@cell.alive?).to be true
end
```

And the following code to `game_of_life.rb` to have the test pass:
```
def alive?
  @state == :live
end
```

Finally, let's add a few tests to `grid_spec.rb` and build the `#find_living_coordinates` method.

```
describe "#find_living_coordinates" do
  it "should find living coordinates" do
    expect(@grid.find_living_coordinates).to eq [@coord1, @coord2]
  end

  it "should not find dead coordinates" do
    @grid.cells[1].state = :dead
    expect(@grid.find_living_coordinates).to eq [@coord1]
  end
end
```

The `#find_living_coordinates` method takes the grid's collection of cells, selects only the ones that still have a state of `:live`, and maps them to their position. We'll use this method later to locate live cells, then check and change state of other cells neighboring them... which brings us to our next set of methods: finding your nearest neighbors.

## A Quick Organizational Refactor

We're about to start adding more methods to both the cell and grid classes to perform some more complex logic. Rather than continue to pile new methods into both of the classes, let's extract those classes into their own files to keep things better organized. Both of these files will be kept in the `lib/game_of_life` directory. We will require them using [require_relative](https://practicingruby.com/articles/ways-to-load-code), which requires the files relative to the current directory. Here's our updated file setup:

```
# lib/game_of_life.rb
require_relative "game_of_life/version"
require_relative "game_of_life/grid"
require_relative "game_of_life/cell"

module GameOfLife
end
```

```
# lib/game_of_life/cell.rb
module GameOfLife

  class Cell
    attr_accessor :position, :state

    def initialize(coordinates)
      @position = coordinates
      @state = :live
    end

    def alive?
      @state == :live
    end

  end

end
```

```
module GameOfLife

class Grid
    attr_accessor :cells

    def initialize(pattern: nil, coordinates: nil)
      if pattern
        @cells = build_cells_from_pattern(pattern)
      elsif coordinates.any?
        @cells = build_cells_from_coordinates(coordinates)
      end
    end

    def build_cells_from_coordinates(arr)
      arr = [arr] unless arr.first.is_a?(Array)
      arr.map { |coords| Cell.new(coords) }
    end

    def build_cells_from_pattern(pattern)
      coordinates = []
      pattern.lines.each.with_index(0) do |line, line_index|
        line.each_char.with_index(0) do |char, char_index|
          if char == 'X'
            x_pos = char_index
            y_pos = line_index
            coordinates.push([x_pos, y_pos])
          end
        end
      end
      build_cells_from_coordinates(coordinates)
    end

    def find_living_coordinates
      cells.find_all { |cell| cell.alive? }.map(&:position)
    end
  end

end
```

## Keeping Track of Cells: Knowing Your Neighbors

Once we have a list of living coordinates, we can start moving on to keeping track of which cells need to be updated. To do this, we first need to find the neighbors of the current cell.

If you think of the grid as a set of coordinates, your neighbors can be found based on applying an offset of [-1, 0, 1] to both the X and Y coordinates. For example, a coordinate of [4, 4] would have neighbors of: [3, 3], [3, 4], [3, 5], [4, 3], [4, 5], [5, 3], [5, 4], [5, 5].

We'll be storing these coordinates for each cell when a new cell is created, so the neighbors of a cell can easily accessed rather than computed each time. Here's the test we'll be using for that:

```
describe "#neighbor_coordinates" do

  it "should calculate the coordinates of its 8 neighbors properly" do
    neighbors = [[0,0], [0,1], [0,2],
                 [1,0], [1,2],
                 [2,0], [2,1], [2,2]]
    expect(@cell.neihbor_coordinates).to eq neighbors
  end

end
```

To calculate this when we create a new cell, we'll need to take the 8 offsets and add each of them to the cell's coordinates. Let's break this down into a few methods. The first method we'll be creating is a [private method](http://stackoverflow.com/questions/4293215/understanding-private-methods-in-ruby) called offset which will generate the 8 offsets. It's using ruby's product method to cross-multiply the arrays [-1, 0, 1], then remove the [0,0] pair using delete_if.

```
private

def offset
  offset_range = (-1..1).to_a
  offset_range.product(offset_range).delete_if { |pair| pair == [0,0] }
end
```

We'll use ruby's Enumerable#reduce (also known as [Enumerable#inject](http://blog.jayfields.com/2008/03/ruby-inject.html)) to add each of the offsets to the cell's position.

```
def calculate_neighbor_coordinates
  offset.reduce([]) do |new_arr, coord|
    new_arr << [coord[0] + @position[0], coord[1] + @position[1]]
  end
end
```

Putting it all together, we'll have this:

```
module GameOfLife

  class Cell
    attr_accessor :position, :state, :neighbor_coordinates

    def initialize(coordinates)
      @position = coordinates
      @state = :live
      @neighbor_coordinates = calculate_neighbor_coordinates
    end

    def alive?
      @state == :live
    end

    def calculate_neighbor_coordinates
      offset.reduce([]) do |new_arr, coord|
        new_arr << [coord[0] + @position[0], coord[1] + @position[1]]
      end
    end

    private

    def offset
      offset_range = (-1..1).to_a
      offset_range.product(offset_range).delete_if { |pair| pair == [0,0] }
    end

  end

end
```

## Finding Cells that Need to be Changed

WIP.

## Final Touches: Drawing the Grid

To add a last bit of polish to our UI, we'll want to draw the grid.


To do this, we'll start by using the coordinates from our previous pattern, and then define a grid#draw method which will print out a grid, appropriately 

