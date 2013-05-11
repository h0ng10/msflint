class BadIndentCheck < LintWorm::Check
	
	def check_line(file_name, line_number, line_content)
		if (line_content.length > 1) and (line_content =~ /^([\t ]*)/) and ($1.include?(' '))
			add_note(LintWorm::Note::WARNING, "Bad indent: #{line_content.inspect}", line_number) 
		end
	end
end
