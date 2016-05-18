require 'test_helper'

class BudgetpostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    # This code is not idiomatically correct.
    @budgetpost = @user.budgetposts.build(content: "Lorem ipsum")
  end

  test "should be valid" do
    assert @budgetpost.valid?
  end

  test "user id should be present" do
    @budgetpost.user_id = nil
    assert_not @budgetpost.valid?
  end


  test "content should be present" do
    @budgetpost.content = "   "
    assert_not @budgetpost.valid?
  end

  test "order should be most recent first" do
    assert_equal budgetposts(:most_recent), Budgetpost.first
  end
end