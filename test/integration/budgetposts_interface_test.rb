require 'test_helper'

class BudgetpostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "budgetpost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    # Invalid submission
    assert_no_difference 'Budgetpost.count' do
      post budgetposts_path, budgetpost: { content: "" }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = "This budgetpost really ties the room together"
    assert_difference 'Budgetpost.count', 1 do
      post budgetposts_path, budgetpost: { content: content }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # Delete a post.
    assert_select 'a', text: 'delete'
    first_budgetpost = @user.budgetposts.paginate(page: 1).first
    assert_difference 'Budgetpost.count', -1 do
      delete budgetpost_path(first_budgetpost)
    end
    # Visit a different user.
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
end