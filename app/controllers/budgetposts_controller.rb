
class BudgetpostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @budgetpost = current_user.budgetposts.build(budgetpost_params)
    if @budgetpost.save
      flash[:success] = "Budgetpost was successfully created."
      # format.xml  { render :xml => @budgetpost, :status => :created, :location => @budgetpost }
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end


=begin
  #EXTRA

  def new
     @budget_item = BudgetPost.new
 
     respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @budgetpost }
    end
  end

  def create
 @budgetpost = Bcurrent_user.budgetposts.build(budgetpost_params)
 
 respond_to do |format|
 if @budgetpost.save
         format.html { redirect_to(@budgetpost, :notice => 'BudgetPost was successfully created.') }
        format.xml  { render :xml => @budgetpost, :status => :created, :location => @budgetpost}
     else
        format.html { render :action => "new" }
        format.xml  { render :xml => @budgetpost.errors, :status => :unprocessable_entity }
      end
    end
  end


# GET /budget_items/1/edit
 def edit
    @budgetpost = BudgetPost.find(params[:id])
 end

# PUT /budget_items/1
   # PUT /budget_items/1.xml
  def update
     @budgetpost = BudgetPost.find(params[:id])
 
     respond_to do |format|
       if @budgetpost.update_attributes(params[:budgetpost])
        format.html { redirect_to(@budgetpost, :notice => 'BudgetPost was successfully updated.') }
        format.xml  { head :ok }
       else
         format.html { render :action => "edit" }
         format.xml  { render :xml => @budgetpost.errors, :status => :unprocessable_entity }
       end
     end
   end
 

 #EXTRA
=end

  def destroy
  	@budgetpost.destroy
    flash[:success] = "Budgetpost deleted"
    redirect_to request.referrer || root_url
  end

  private

    def budgetpost_params
      params.require(:budgetpost).permit(:content, :picture)
    end

    def correct_user
      @budgetpost = current_user.budgetposts.find_by(id: params[:id])
      redirect_to root_url if @budgetpost.nil?
    end
end