class StopSorter
	# g: 5, h:20, f:10, d:3, e:4
	# [5,20] s: [5,20]
	# [5,10,20] s: [5,10,20]
	# [5,10,3,4,15] s:[5,10,3,4,20]

	# Algorithm...
	# * First list is the initial sort order.
	# * For the next list, check each item in the list.
		# * Is the value in the sorted list? Y, Move to the next item. N, next steps
		# * Is the value before it in the sorted list? Y/N.
		# * Is the value after it in the sorted list? Y/N.
		#   * Only value before in sorted list... insert after value before.
		#   * Only value after in sorted list... insert before value after
		# 	* Are neither values in the stop order list? Insert at start of stop order list?
		# 	* Are both values in the stop order list? Insert between them.

	# [c,c,c,c,c,c,c,c,....] # All correct!
	# [1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073]
	# [c,c,c,c,c,c,c,c,c,c,c,c,c,.....] # All correct!
	# [1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036, 1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073]
	# correct!
	# [                        1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036, 1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073]
	# [                        1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036, 1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073]
	# [1155, 1120, 1068, 1181, 1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036, 1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073]
	# [1155, 1120, 1068, 1181, 1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036, 1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073]

	lists = [
	[                                                                                                                                          1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073], 
	[                        1071,                                     1036], # g,h
	[                        1071, 1162, 1180,                         1036], # g,f,h
	[                        1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036], # g,f,d,e,h
	[                        1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036, 1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039],
	[                        1071, 1162, 1180,                         1036, 1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073], 
	[                        1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036, 1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073],
	[1155, 1120, 1068, 1181, 1071, 1162, 1180,                         1036], 
	[1155, 1120, 1068, 1181, 1071, 1162, 1180,                         1036,                   1081, 1152, 1119, 1020, 1157, 1132], 
	[1155, 1120, 1068, 1181, 1071, 1162, 1180,                         1036,                   1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134, 1011, 1060, 1038, 1024, 1035],
	[1155, 1120, 1068, 1181, 1071, 1162, 1180,                         1036,                   1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073], 
	[1155, 1120, 1068, 1181, 1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036,                   1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073], 
	[                  1181, 1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036,                   1081, 1152, 1119, 1020, 1157, 1132], 
	[                  1181, 1071, 1162, 1180,                         1036,                   1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134], 
	[                  1181, 1071, 1162, 1180, 1089, 1194, 1008, 1118, 1036,                   1081, 1152, 1119, 1020, 1157, 1132, 1095, 1001, 1039, 1122, 1154, 1134, 1011, 1060, 1038, 1024, 1035, 1174, 1106, 1073]
	]


	# First Stop... which stop has the most number of lists starting with it.
	# Flinders St: 6
	# Parliament: 5
	# Southern Cross: 3
	# Mordialloc: 1

	# stops[0] = Flinders St.

	# Second Stop... of the lists with the first stop (1,2,3,5,6,9) what is the most frequent second stop.
	# Richmond: 5
	# Caulfield: 1
	# stops[1] = Richmond

	# Third Stop... of the lists with the first stop, what is the most frequent third stop. (1,2,5,6,9) (3 has dropped out. Only two stops)
	# South Yarra: 5
	# stops[2] = South Yarra

	# 4... same logic again.
	# Hawksburn: 3
	# Caulfield: 2
	# stops[3] = Hawksburn

	# 5... 6 drops out. Only four stops. (1,2,5,9)
	# Toorak: 3 (1,2,5)
	# Glenhuntly: 1 (9)
	# stops[4] = Toorak

	# 6...
	# Armadale: 3 (1,2,5)
	# Ormond: 1 (9)
	# stops[5] = Armadale



	def sort_list(sorted, list)

		# list = list to insert into sorted list
		# sorted_list = current sorted list

		# current_sorted_index = 0 # I don't think this is right.
		list.each_index do |list_idx|
			value = list[list_idx]
			# is value in the sorted list? What is the index?
			sorted_idx = sorted.index(value)

			# if the value is not in the sorted list, work out where to put it.
			if sorted_idx.nil?

				before = false
				after = false

				insert_index = -1
				# so, the current value isn't in the sorted list.
				# Is the value before the current value in the sorted list?
				if value_in_sorted(true, sorted, list, list_idx)
					before = true
					insert_index = list_idx-1
				end
				if value_in_sorted(false, sorted, list, list_idx)
					after = true
					insert_index = list_idx+1
				end

				sorted_index = sorted.index(list[insert_index])

				if (before && !after)
					# insert after value before
					sorted.insert(sorted_index+1, value)
				end

				if (!before && after)
					# insert before value after
					sorted.insert(sorted_index+1, value)
				end

				if (before && after)
					# insert between before and after
					value_after_index = sorted.index(list[list_idx+1])
					sorted.insert(value_after_index, value)
				end

				if (!before && !after)
					# insert at the start of the sorted list. Not sure about this one.
					sorted.insert(0, value)
				end
			end
		end
	end

	def value_in_sorted(before, sorted, list, list_idx)
		if before
			index_to_check = list_idx-1
		else
			index_to_check = list_idx+1
		end
		value = list[index_to_check]

		value_in = false

		# Need to check if idx falls within bounds.
		if index_to_check >= 0 && index_to_check < list.length-1
			if !sorted.index(value).nil?
				value_in = true
			end
		end

		value_in
	end


# USAGE:
# lists = [][]
# = [[1,2,3,4],[6,7,8,9,10]]
# 	-> set the first element of the sorted list to 

	# sorted_list = lists[0]

	# (1..lists.length-1).each do |list_index|
	# 	sort_list(sorted_list, lists[list_index])
	# end

	# p "#{sorted_list}"
end