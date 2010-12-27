# The categories modeled here are logically organized into a tree structure. The DB table itself supports the sturucture only 
# to the extent that each record has a reference to the id of its parent (except for in the case of root categories, where
# the reference field is NULL). Much of the purpose of the class's custom functionality is to make explicit representations 
# of the implied hierarchy. 

class Category < ActiveRecord::Base
  has_many :recipes

# Class methods(s):

# Category.categoryMenuSequence
# Defines an array of Category objects structured to represent either the full tree (if the argument passed to SELECTION is 'all'), or
# a tree segment relative to a given category (if the argument is an id). In the later case, the path to the given category is 
# represented, as well as all the subcategories that belong to it, and the siblings of each node on the path (used to construct
# the category menu in /recipe/browser for one).     
# Each sublevel of categories is represented by a succesively nested array imediately following its parent category. 
# Calling the method with the default argument nil returns an array of all the root categories.  
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
# hierarchy of child Categories that descend from each. (?Why can't I make this method private?)
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

attr_accessor :subparent # the succeeding category object to THIS within the the context of a hierarchy path.  
attr_writer :level # the level in the tree hierarchy to which THIS belongs (Numbering begins at 1, the level of the root categories)

# @level getter. Calls computeLevelBySQL() if the level has yet to be set, and the category is not at the root level.
def level 
  if (self.parent_category_id == nil)
    @level = 1
  elsif (@level == nil) 
    @level = computeLevelBySQL
  end 
  @level
end

# A helper method that computes @level by counting the succesive parent references from THIS to a root category.
def computeLevelBySQL()
  parentNode = self.parent_category_id
  depth = 1
  while (parentNode != nil)
    depth = depth + 1
    parentNode = Category.find(parentNode).parent_category_id
  end 
  depth
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
