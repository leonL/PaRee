<div id="page2_title">
	<%= 
	case params[:action]
		when 'preface'
			'<h4>Preface</h4>'
		when 'navigation'
			'<h3>Navigation</h3>'
		when 'aboutTitle'
			'<h3>About Title</h3>'
		end
		%>
</div>