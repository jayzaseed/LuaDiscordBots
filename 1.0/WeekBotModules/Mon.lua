local date = {}

function date:Init()
	_G.avatar = "http://az616578.vo.msecnd.net/files/2015/07/26/635735497317415146-502010203_image.imgopt1000x70.jpg"
	_G.status = "Oh crap it's monday..."
	_G.facts = {
		[1] = "According to a study by Marmite, most people don't even smile any earlier than 11:16 AM on Monday mornings. No wonder everyone avoids you on Monday mornings. Must be that frown.",
		[2] = "According to a study by Marmite, they found that the best way for people to smile on Monday mornings is to watch TV. Also on the list? Having sex and buying chocolate. Duh, right?",
		[3] = [[Got time to complain?
		 		Apparently all of those 'don't you just hate Monday' people complain for 34 minutes on average every Monday. 
		 		That's compared to 22 minutes on any other day.
		 		You count toward that average, too. Are you one of those annoying complainers?]],
		[4] = [[In general, the stock market tends to rise a bit every day. Except for Mondays. They're the only day of the week that is more likely to fall instead of rise. 
				Did you lose money on the stock market? You have permission to blame it on Mondays.]],
	}
	_G.color = 5218047
end

return date