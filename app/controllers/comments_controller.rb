class CommentsController < ApplicationController
#before_action :correct_user,   only: :destroy
before_action :logged_in_user, only: [:create, :destroy]

	def create
	@budgetpost = Budgetpost.find(params[:budgetpost_id])
    @comment = Comment.new(comment_params)
    @comment.budgetpost = @budgetpost
    @comment.user = current_user
    if @comment.save
       flash[:success] = "Allocation created!"
       redirect_to request.referrer || root_url
    else
      @feed_items = []
      redirect_to request.referrer || root_url
    end
   end

  def destroy
  	#1st you retrieve the budgetpost thanks to params[:budgetpost_id]
  	budgetpost = Budgetpost.find(params[:budgetpost_id])
  	#2nd you retrieve the comment thanks to params[:id]
  	@comment = budgetpost.comments.find(params[:id])
    @comment.destroy
    flash[:success] = "Allocation deleted"
    redirect_to request.referrer || root_url
  end


	private
      def comment_params
      params.require(:comment).permit(:content)
      end

   def correct_user
      @budgetpost = current_user.budgetposts.find_by(id: params[:id])
      redirect_to root_url if @budgetpost.nil?
      @comment = current_user.comments.find_by(id: params[:id])
      redirect_to root_url if @comment.nil?
   end
end
