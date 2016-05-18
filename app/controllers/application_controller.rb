class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

=begin
#EXTRA
  def createStateQuery(state, category, isexpense)
      first_subquery = "select statecode, subcategory, budgetId, year, supercategory, sum(dollarAmount) as dol , (sum(dollarAmount)/(select sum(dollarAmount) from budgetposts where isexpense=#{isexpense} and length(statecode) > 0"
      
      second_subquery = "))as fract  from  budgetposts where length(statecode) > 0 "
      
      if state!=nil and state.to_s().length > 1
         first_subquery = first_subquery + " and statecode='" + state +"'"
         second_subquery = second_subquery + " and statecode='" + state +"'" 
      end
     
      if category !=nil and category.to_s().length > 1
        first_subquery = first_subquery  + " and subcategory like '%" + category +"%'" 
        second_subquery = second_subquery  + " and subcategory like '%" + category +"%'" 
      end
      
      query = first_subquery + second_subquery
      query = query + " group by supercategory order by statecode,dol desc";
     
      return query
     
  end
  
  def createComparisonBudgets(comparisonStates, category, items, isexpense)
    
    budgetsArray = Array.new
    for i in 0..comparisonStates.length-1
        state = comparisonStates[i]
        stateQuery = createStateQuery(state, category, isexpense)
        budget_expenses_and_resources = items.find_by_sql(stateQuery)
        budgetsArray.push(budget_expenses_and_resources)
        
    end
    return budgetsArray  
end


  def filter
 
      items = BudgetPost
      
      puts "--------------params: #{params[:budgetSide] }"
      
       if (params[:budgetSide] == 'revenue')    
        @isexpense= 0;
        puts"----requesting revenues----------"
      elsif (params[:budgetSide] == 'expense')
         @isexpense = 1;
         puts"----requesting expenses----------"
      end
     
      @state = params[:statecode]  
      
      puts "%%%%%%%%state received:#{@state} %%%%%%%%%%%%"
      @comparisonStates = params[:comparisonstates]
      
      if @comparisonStates == nil
        @comparisonStates = Array.new
      end
      
      if @state != nil and @state.length > 0
        @comparisonStates.push(@state)
      end
      #@comparisonStates.push(@state)
      #puts "length of comp states: " +  @comparisonStates.length.to_s

      
      #TODO combine primary and comparison codes
      
      primaryBudgetQuery = createStateQuery(@state, @category, @isexpense)
      
      puts "primaryBudgetQuery: #{primaryBudgetQuery}"
      
      @budget_expenses_and_resources = items.find_by_sql(primaryBudgetQuery)
      
      superCatsQuery = "select distinct supercategory from budgetposts where isexpense=#{@isexpense}"
      @supercats = items.find_by_sql(superCatsQuery)
      @superCategories = generateSuperCategoryNames(@supercats)
      
      if @comparisonStates != nil and @comparisonStates.length > 0
        @comparisonBudgets = createComparisonBudgets(@comparisonStates, @category, items, @isexpense)
         puts "**********size of comparison budgets:  #{@comparisonBudgets.length} *****************"
        #@comparisonBudgets.push(@budget_expenses_and_resources)
        @javascriptGraphData = generateJavaScriptData(@comparisonBudgets,@supercats)
        
        puts "**********size of javascript data:  #{@javascriptGraphData.length} *****************"
        
        #printJavaScriptData(@javascriptGraphData)
      end
      
      stateNamesQuery = "select distinct statecode from budgetposts order by statecode"
      @stateNames = items.find_by_sql(stateNamesQuery)
      @budgetposts = BudgetPost.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @budget_expenses_and_resources }
        #format.xml  { render :xml => @budget_expenses_and_resources_compare }  
        #TODO remove next 3 variables if using google visualization api
        format.xml  { render :xml => @comparisonBudgets }  
        format.xml  { render :xml => @stateNames }  
        format.xml  { render :xml => @supercats }  
        format.xml  { render :xml => @budgetposts }  
        format.xml  { render :xml => @javascriptGraphData }  
        format.xml  { render :xml => @superCategories }  
        
        end 
  end  
#EXTRA
=end

  private

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end