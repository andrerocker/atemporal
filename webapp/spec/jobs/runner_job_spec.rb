require 'rails_helper'

RSpec.describe RunnerJob do
  context "perform job runner" do
    it "should load a current job and call prepare!" do
      current = double(Job)
      allow(current).to receive(:prepare!).and_return("Yo!")
      allow(Job).to receive(:find).with([1]).and_return(current)

      expect(subject.perform([1])).to eql "Yo!"
    end
  end
end
