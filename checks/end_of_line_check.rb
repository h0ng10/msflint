class EndOfLineCheck < LintWorm::Check
	
	def check_line(file_name, line_number, line)

		if line =~ /[ \t]$/
			add_note(LintWorm::Note::WARNING, "Spaces at EOL", line_number) 
		end

		if line =~ /\r$/
			add_note(LintWorm::Note::WARNING, "Carriage return EOL", line_number) 
		end
	end
end
