class LineLengthCheck < LintWorm::Check

	LONG_LINE_LENGTH = 200 # From 100 to 200 which is stupidly long
	
	def check_line(file_name, line_number, line_content)
		if (line_content.length > LONG_LINE_LENGTH) then
			add_note(LintWorm::Note::WARNING, "Line exceeding #{LONG_LINE_LENGTH.to_s} bytes", line_number) 
		end
	end
end
