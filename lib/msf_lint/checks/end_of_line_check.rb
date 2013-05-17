class EndOfLineCheck < MsfLint::Check
	
	def check_line(file_name, line_number, line)

		if line =~ /[ \t]$/
			add_note(MsfLint::Note::WARNING, "Spaces at EOL", line_number) 
		end

		if line =~ /\r$/
			add_note(MsfLint::Note::WARNING, "Carriage return EOL", line_number) 
		end
	end
end
