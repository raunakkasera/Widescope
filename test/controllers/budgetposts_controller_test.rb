require 'test_helper'

class BudgetpostsControllerTest < ActionController::TestCase

  def setup
    @budgetpost = budgetposts(:orange)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Budgetpost.count' do
      post :create, budgetpost: { content: "Lorem ipsum" }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Budgetpost.count' do
      delete :destroy, id: @budgetpost
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong budgetpost" do
    log_in_as(users(:michael))
    budgetpost = budgetposts(:ants)
    assert_no_difference 'Budgetpost.count' do
      delete :destroy, id: budgetpost
    end
    assert_redirected_to root_url
  end
end