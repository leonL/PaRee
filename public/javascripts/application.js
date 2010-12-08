// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function revealBookmark() 
{
	$("bookmark").style.zIndex = "5";
}

function concealBookmark(event)
{
	var xCoord = Event.pointerX(event);
	var yCoord = Event.pointerY(event);
	
	if ((xCoord < 269 || xCoord > 393) || (yCoord < 80 || yCoord > 505)) { 
		$("bookmark").style.zIndex = "";
	}
}

function identifyBookmarkLink(event)
{
	var linkSelected = Event.element(event).innerHTML;
	revealBookmark();	
}

/* A function triggered by the selection of a 'category' in the 'recipe browser' that then handles 
the necessary adjustment to the menu of categories: closing the submenus that are no longer releveant, and 
opening the submenu of the selected category (if there is one) via an AJAX call. */
function browseRecipes(selectedCategory, renderMenuURL, renderRecipesListURL)
{
	/* Denote which category has been selected, and reomve the denotation from the one previously selected */
	if ($('selected_category') != null) 
		$('selected_category').id = '';
	selectedCategory.id = 'selected_category';
	
	// Creates an object with the property 'category' equal to the id of the selected link. 
	var selectedCategoryID = selectedCategory.parentNode.id.toQueryParams();	
	
	// An array of all the submenus that comprise the category menu in its current state.
	var categoryMenuElements = $A($('category_menu').getElementsByTagName('ul'));
	
	/* Calcualte numMenusToDelete, the difference between the level of the most deeply nested submenu, 
		and the level to which the selected category belongs. */
	var selectedSubmenuID = selectedCategory.parentNode.parentNode.id.toQueryParams();
	var highestSubmenuID = categoryMenuElements[categoryMenuElements.length - 1].id.toQueryParams();
		var numMenusToDelete = highestSubmenuID.level - selectedSubmenuID.level;
	
	/*  Proceed with processing the submenus to close unless the selected category is in the most deeply nested one. */
	if (numMenusToDelete != 0)
	{
		/* Set submenusToDelete, an array of all the submenus to be closed, namely, all the open submenus 
		   	more deeply nested than the one to which the selected category belongs */
		var submenusToDelete = categoryMenuElements.slice(-numMenusToDelete);
	
		/* Remove the highest level submenu from submenusToDelete if it is the child submenu of the selected category.
			submenuAlreadyOpen is a boolean flag represeting whehter the submenu of the selected category is already on screen. */ 
		var submenuAlreadyOpen = true;
		var submenuID = submenusToDelete[0].id.toQueryParams();
			selectedCategoryID.category == submenuID.parent ? submenusToDelete.splice(0, 1) : submenuAlreadyOpen = false;

		// Close the submenus in submenusToDelete with the Blindup effect
		for (var index = 1, len = submenusToDelete.length; index <= len; ++index) { 
			Effect.BlindUp(submenusToDelete[len - index])
		}
	
		/* Remove the DOM nodes representing the closed submenus (delayed in order to allow the Blindup effect to finish first) */
		setTimeout(function() {
			submenusToDelete.each(function(node) {
				node.parentNode.removeChild(node);
			});
		}, 1500);  	
	}

	if (!submenuAlreadyOpen) {
		/* Insert the submenu of the selected category using AJAX */
		new Ajax.Updater('category=' + selectedCategoryID.category, renderMenuURL, 
			{asynchronous:true, evalScripts:true, insertion: 'after', parameters: {id: selectedCategoryID.category}});
		/* Reveal the newly inserted submenu using the BlindDown effect (if in fact one was returned)
			(delayed in order to allow the AJAX call to insert the submenu before the node is referenced) */
		setTimeout(function() {
			var newSubmenu = $('level=' + (parseInt(selectedSubmenuID.level) + 1) + '&parent=' + selectedCategoryID.category);
			if (newSubmenu != null)
				Effect.BlindDown(newSubmenu);
		}, 500);
	}
	
	/* Refresh the list of recipes showing only those that belong to the selected category and its descendent categories */
	new Ajax.Updater('list_of_recipes', renderRecipesListURL, {asynchronous:true, evalScripts: true,
		parameters: {id: selectedCategoryID.category}}); 
}

/* A function triggered by the change of a dropdown input identifying the cateogry that a recipe belongs 
to (when adding a new recipe or editing an existing one). It accomplishes the following:
1. Any dropdown inputs succeeding the one changed are removed. 
2. If a New Category is selected from the drop down, a name for the category is requested, and a call
is placed via AJAX to create the category. The selected drop down is updated with the new category
and set to its value. 
3. A new drop down input is inserted on the page populated by the selected cateogries subcategories (via AJAX).
If the selected category has no subcategories associated to it, a drop down with just one option, to create a
new subcategory is created (and the ID of that Select input is set to represent how deeply nested it is in 
the category heirarchy on account of this can't be accomplished on the server because there are no subcategories
sent to the client). */
function updateCategoryInput(selectInputChanged) {
	
    /* An IF spanning the entire function, which proceeds only if 'something' other than the blank, spacer 
	option was selected from the drop down menu. */
	if (selectInputChanged.value != "blank") { 
		
		var getCategoriesPath = "/categories/subcategories/", newCategoryPath = "/categories/";
		var allMenusDivId = "category_inputs"; 
		
		var categoryDropDowns = $(allMenusDivId).getElementsByTagName('select');  // A node list of all the category drop-down inputs
		var totalNumDropDowns = categoryDropDowns.length, newDropDown;
		var changedDropDownLevel = parseInt(selectInputChanged.id.toQueryParams().level);
			
		var setNewDropDownLevel = function() {
			setTimeout(function() {
				if (categoryDropDowns.length > changedDropDownLevel) {
					newDropDown = categoryDropDowns[categoryDropDowns.length - 1];
					if (newDropDown.id.toQueryParams().level == 0) 
						newDropDown.id = "level=" + (changedDropDownLevel + 1);
				}
				else {
					setNewDropDownLevel();
				}
			}, 100); 
		}
			
		var addNewMenu = function() {
			// Ajax call that requests a new drop down menu be added to the series, represeting the submenu of the selected category
			new Ajax.Updater(allMenusDivId, getCategoriesPath, {asynchronous:true, evalScripts: true,
				parameters: {id: selectInputChanged.value}, insertion: 'bottom', onComplete: setNewDropDownLevel() });
		}
		
		// A loop that removes all the drop-downs that succeed the one selected
		for (var i = categoryDropDowns.length; i > changedDropDownLevel; --i)  { 
			Element.remove(categoryDropDowns[i-1].parentNode);
		}
		
		if (selectInputChanged.value != "new") addNewMenu();
		else {
			
			/* Sets a reference to the last OPTION element on the page with the class 'new category_option',
			that being the element that triggered the function. */
			var newCategoryOptions = $$(".new_category_option");
			var selectNewCategoryOption = newCategoryOptions[newCategoryOptions.length - 1];
			
			var newCategoryName, params, subPrefix;
			
			var allOptions = selectInputChanged.getElementsByTagName('option'), newOption;	
			var totalNumOptions = allOptions.length;
			var setMenuToNewOption = function() {
					setTimeout(function() {
						if (allOptions.length > totalNumOptions) {
							newOption = allOptions[allOptions.length - 2];
							selectInputChanged.value = newOption.value;
							addNewMenu();
						}
						else
						{
							setMenuToNewOption();
						}
					}, 100); 
			}	
				
			/* set the parent_category_id of the new category (set to null if the new category is being added to the root menu) */
			var parentCategoryId, parentMenuLevel = changedDropDownLevel - 1;
				(parentMenuLevel == 0) ? parentCategoryId = null : parentCategoryId = $("level=" +  parentMenuLevel).value;
			 	
      		/* Prompt the user for a name for the new category */
      		(changedDropDownLevel == 1) ? subPrefix = "category" : subPrefix = "subcategory"; 
			newCategoryName = prompt("What would you like the new " + subPrefix + " to be called?", "");
			
			if (newCategoryName != null) {
			
				/* wrap the parameters that need to be sent to the server in a hash */
				params = $H({"category[name]" : newCategoryName, "category[parent_category_id]" : parentCategoryId}); 

      			/* Ajax call that adds the new category to the DB, and updates the drop down list to include it. */
				new Ajax.Updater(selectNewCategoryOption, newCategoryPath, {asynchronous:true, evalScripts: true, 
					parameters: params, insertion: 'before', onComplete: setMenuToNewOption() });
			}
			else { // the user cancels out of the prompt to name the new category
				selectInputChanged.value = "blank";	
			}
		}
	}	
}

/* A function triggered by the onchange event of the ingredient input fields of a recipe entry form.
If there is only one empty ingredient input field remaining, a new one is added to the DOM.   */
function addIngredientInput(triggerElement) {
	var numBlankInputs = 0;
	var ingredientInputs = $$(".recipe_ingredient_input");
	
	/* Count how many of the ingredient input fields are blank */
	ingredientInputs.each(function(input) {
		if (input.value == "") numBlankInputs++; 
	});
		
	if (numBlankInputs <= 1) {
		
		var newInputElement = triggerElement.parentNode.cloneNode(true);
		newInputElement.childNodes[0].value = "";
		$("ingredients_list").insert({ bottom: newInputElement });
	}
}