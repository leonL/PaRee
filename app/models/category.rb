class Category < ActiveRecord::Base
  has_many :recipes

# Class methods(s):

# A class method that prepares an array of Categories sequenced for display in the view. The generated menu includes all the 
# parent menus that the category with id 'selection' is nested in, as well as the category's immediate children. Each subsequent 
# submenu is represented by a succesively nested array in the return value. If the string 'all' is passed in as the 'selection'
# parameter rather than a Category id, the complete range of Categories is returned, with subCategories in nested arrays following
# immediately after their parent Categories. 
def Category.categoryMenuSequence(selection = nil)

  menuSequence = Category.find(:all, :conditions => "parent_category_id IS NULL", :order => 'id') # the root level of the menu

  if (selection == nil) 
    return menuSequence
  
  elsif (selection == 'all') 
    return Category.nestChildCategories(menuSequence)

  else
  # Set 'insertParent' to the root level category of which 'selection' is a descendent (the method setCategoryChain chains 
  # the series of parent Categories between the two to one another).
  insertParent = Category.find(selection).setCategoryChain 

  menu = menuSequence
  until (insertParent == nil)
    submenu = insertParent.getChildCategories

    unless (submenu.empty?)
      insertIndex = menu.index{|c| c.id == insertParent.id} + 1
      menu.insert(insertIndex, submenu)
      menu = submenu 
    end

    insertParent = insertParent.subparent
  end
  return menuSequence

  end
end

# A recursive helper class method that nests the array of Categories 'menu' with arrays representing the full 
# hierarchy of child Categories that descend from each.
def Category.nestChildCategories(menu) 
  insertIndex = 1
  menu.each do |cat|
    if (cat.kind_of?(Array))
      Category.nestChildCategories(cat)
    else
      submenu = cat.getChildCategories
      unless (submenu.empty?)
        menu.insert(insertIndex, submenu)
      end
    end
    insertIndex += 1
  end
  return menu
end

# Instance methods:

attr_accessor :subparent

# 'level' attribute setter.
def level=(value)
  @level = value
end

# Returns the depth at which the the cateogry is nested in the hierarchy. Numbering begins at 1, which denotes the root level.
def computeLevelBySQL()
  parentNode = self.parent_category_id
  depth = 1
  while (parentNode != nil)
    depth = depth + 1
    parentNode = Category.find(parentNode).parent_category_id
  end 
  depth
end

# 'level' attribute getter. Calls computeLevelBySQL() if the level has yet to be set, and the category is not at the root level.
def level 
  if (self.parent_category_id == nil)
    @level = 1
  elsif (@level == nil) 
    @level = computeLevelBySQL
  end 
  @level
end

# If the category has subcategories returns an array of them. Otherwise, returns an empty array
def getChildCategories
  Category.find(:all, :conditions => "parent_category_id = #{self.id}", :order => ':id')
end

# If the category belongs to a parent category, returns it. Otherwise, returns false.
def getParentCategory()
  self.level == 1 ? false : Category.find(self.parent_category_id)
end

# Returns an array of all the Categories that have SELF as an ancestor (the array includes SELF)
# (A step taken in finding all the recipes that belong under a Category, and all its descendants.)
def getAllSubcategories(reset=false)  
  reset ? @allSubcategories = [self] + self.setAllSubcategories() : 
    @allSubcategories ||= [self] + self.setAllSubcategories() 
end

# A recursive helper method for setting (or resetting) the @allSubcategories property 
def setAllSubcategories()
  subcategories = self.getChildCategories
  
  subcategories.each do |cat|
    subcategories += cat.setAllSubcategories
  end
  
  return subcategories
end

# Recursive function that chains 'self' to the root level category of which it is a descendant,
# by linking all the parent nodes in between to one another. Returns the root category. 
def setCategoryChain()
  @parentCategory = getParentCategory
  
  if (@parentCategory != false)
    @parentCategory.subparent = self
    superParent = @parentCategory.setCategoryChain 
  elsif
    superParent = self
  end
  
  return superParent
end

# A getter that returns a collection of the Recipe objects (abbreviated to the properties id and name) that 
# are keyed to the Category 'self'.    
def recipeNames(reset=false) 
  reset ? 
    @recipeNames = Recipe.find(:all, :select => 'id, name', :conditions => "category_id = #{self.id}") :
      @recipeNames ||= Recipe.find(:all, :select => 'id, name', :conditions => "category_id = #{self.id}")
end

end
