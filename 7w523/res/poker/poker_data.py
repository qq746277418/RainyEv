
write_file = open("poker_data.lua", "w")

#poker_data[1] = {id = 1, value = 1, color = 1, img = "poker/1.png"}
write_str = "poker_data[0] = {id = 0, value = 0, color = 0, weg = 0, weg_pra = 0, img = 'poker/0.png'}\n"
for i in range(1, 50 + 1):
	index = i / 14 + 1
	value = i % 13
	if value == 0:
		value = 13
	str1 = "poker_data[%d] = {id = %d, value = %d, color = %d, weg = %d, weg_pra = %d, img = 'poker/%d.png'}"  % (i,i,value,index,5,index,i)
	write_str = write_str + str1 + "\n"
	
write_file.write(write_str)