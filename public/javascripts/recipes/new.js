/* Can these binding functions be refactored so there is less repetition? */
$j(function() { 
	$j('#down_arrow').bind('mouseover', {divToScrollId: 'page1', scrollDown: true}, scrollControl.scroll).bind('mouseout', 
		scrollControl.stopScroll); 
	$j('#up_arrow').bind('mouseover', {divToScrollId: 'page1', scrollDown: false}, scrollControl.scroll).bind('mouseout', 
		scrollControl.stopScroll);
});


