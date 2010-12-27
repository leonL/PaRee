class RecipesController < ApplicationController  
  layout 'application'
  
  def browse    
    @selectedCategory = params[:id]
    @selectedCategory == nil ? 
      allSubcategories = Category.find(:all) :
        allSubcategories = Category.find(@selectedCategory).getAllSubcategories
    # @listOfRecipes, an array of the recipes to be listed in response to the request
    @listOfRecipes = getListOfRecipes(allSubcategories)
    respond_to do |format|
      format.html do 
        # @categoryMenuSequence represents the category menu, and how it should be displayed
        @categoryMenuSequence = Category.categoryMenuSequence(@selectedCategory)
      end
      format.js do 
        render(:partial => 'recipe_listing', :collection => @listOfRecipes)
      end
    end
  end
  
  def renderBrowserMenu
    @selectedCategory = params[:id]
    respond_to do |format|
      format.js do
        # The @submenu array of Categories models, prepared in response to AJAX request, is nested in an empty array for
        # proper processing by the partial template (which understands a nested array as a submenu, and brackets it in 
        # a corresponding HTML block)
        @submenu = Array.new
        @submenu << Category.find(@selectedCategory).getChildCategories
        @submenu[0].empty? ? render(:nothing => true) : render(:partial => 'category_menu', :collection => @submenu)
      end
    end
  end
  
  # A (private) helper method that takes an array of Category model objects and returns an array of the Recipe model objects 
  # that belong to each.
  def getListOfRecipes(categories)  
    recipesList = []
    categories.each do |category|
      recipesList += category.recipeNames
    end
    return recipesList
  end
  private :getListOfRecipes
  
  # GET /recipes
  # GET /recipes.xml
  def index
    @recipes = Recipe.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @recipes }
    end
  end

  # GET /recipes/1
  # GET /recipes/1.xml
  def show
    @recipe = Recipe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @recipe }
      format.js {render :layout => false}
    end
  end

  # GET /recipes/new
  # GET /recipes/new.xml
  def new
    @recipe = Recipe.new
    @rootCategories = Category.categoryMenuSequence

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @recipe }
      format.js {render :layout => false}
    end
  end

  # GET /recipes/1/edit
  def edit
    @recipe = Recipe.find(params[:id])
  end

  # POST /recipes
  # POST /recipes.xml
  def create
    params[:recipe][:ingredients].delete("")
    params[:recipe][:ingredients] *= "&&"
    @recipe = Recipe.new(params[:recipe])

    respond_to do |format|
      if @recipe.save
        flash[:notice] = 'Recipe was successfully created.'
        format.html { redirect_to(@recipe) }
        format.xml  { render :xml => @recipe, :status => :created, :location => @recipe }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /recipes/1
  # PUT /recipes/1.xml
  def update
    @recipe = Recipe.find(params[:id])

    respond_to do |format|
      if @recipe.update_attributes(params[:recipe])
        flash[:notice] = 'Recipe was successfully updated.'
        format.html { redirect_to(@recipe) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.xml
  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy

    respond_to do |format|
      format.html { redirect_to(recipes_url) }
      format.xml  { head :ok }
    end
  end
  
  def addIngredientInput
    respond_to do |format|
      format.js { render :partial => 'ingredient_input' }
    end
  end
  
end
