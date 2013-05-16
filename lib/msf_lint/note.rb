# encoding: utf-8
module MsfLint
	# A note created by a check.
	#
	# it indicates the filenname, line number, severity and a message
	class Note
		attr_reader :filename, :severity, :line, :message

		INFO = "INFORMATION"
		WARNING = "WARNING"
		SUGGESTION = "SUGGESTION"
		ERROR = "ERROR" 

		def initialize(severity, message, line_number)
			@severity = severity
			@line = line_number.to_s
			@message = message
		end

		def to_s
			"#{@line}:#{@severity} - #{@message}"
		end
	end
end