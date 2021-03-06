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

    it "should respond as alive when it is alive" do
      expect(@cell.alive?).to be true
    end

    describe "#neighbor_coordinates" do

      it "should calculate the coordinates of its 8 neighbors properly" do
        neighbors = [[0,0], [0,1], [0,2],
                     [1,0], [1,2],
                     [2,0], [2,1], [2,2]]
        expect(@cell.neighbor_coordinates).to eq neighbors
      end

    end

  end
end
