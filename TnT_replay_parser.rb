require 'rubygems'
require 'nokogiri'
require 'cgi'
require 'open-uri'

def parse(filename)
	@doc = Nokogiri::XML(File.open(filename))
	player_names = @doc.xpath("//Name")
	player_ids = @doc.xpath("//m_SteamID")
	player_teams = @doc.xpath("//Team")
	player_picks = @doc.xpath("//Card")
	names = []
	ids = []
	teams = []
	picks = []

	player_names.each {|name| names << name.to_s}
	player_ids.each {|id| ids << id.to_s}
	player_teams.each {|team| teams << team.to_s}
	player_picks.each {|card| picks << card.to_s}

	parsed_to_string(teams,names,ids,picks)

end

def parsed_to_string(teams,names,ids,picks)
	playarr = []
	names.delete_at(0)
	ids.each_index do |i|
		playarr[i]=[]
		playarr[i] << teams[i][6]
		playarr[i] << names[i][6..-8]
		playarr[i] << ids[i][11..-13]
		newpicks = picks.slice!(0,6)
		playarr[i] << picks_to_str(newpicks)
	end
	playarr
end

def picks_to_str(picks_arr)
	outstr = ''
	picks_arr.each do |pick|
		if pick[6] == 'w'
			case pick[13,2]
			when 'li'; outstr << '0'
			when 'sq'; outstr << '1'
			when 'to'; outstr << '2'
			when 'pi'; outstr << '3'
			when 'mo'; outstr << '4'
			when 'fe'; outstr << '5'
			when 'ch'; outstr << '6'
			when 'sn'; outstr << '7'
			when 'fa'; outstr << '8'
			when 'sk'; outstr << '9'
			when 'bo'; outstr << 'a'
			when 'fo'; outstr << 'b'
			when 'ba'; outstr << 'c'
			when 'wo'; outstr << 'd'
			when 'ow'; outstr << 'e'
			end
		else
			case pick[16,3]
			when 'bar'; outstr << 'f'
			when 'lan'; outstr << 'g'
			when 'mac'; outstr << 'h'
			when 'bal'; outstr << 'i'
			when 'art'; outstr << 'j'
			end
		end
	end
	outstr
end


stats_arr = parse("Straw_beats_rofl.xml")

winner_name = ""
winner_id = ""
winner_picks = ""
loser_name = ""
loser_id = ""
loser_picks = ""


if stats_arr[0][0] = 1
	winner_name = CGI::escape(stats_arr[0][1])
	winner_id = stats_arr[0][2]
	winner_picks = stats_arr[0][3]
	loser_name = CGI::escape(stats_arr[1][1])
	loser_id = stats_arr[1][2]
	loser_picks = stats_arr[1][3]
else
	winner_name = CGI::escape(stats_arr[1][1])
	winner_id = stats_arr[1][2]
	winner_picks = stats_arr[1][3]
	loser_name = CGI::escape(stats_arr[0][1])
	loser_id = stats_arr[0][2]
	loser_picks = stats_arr[0][3]
end

sitename = "http://localhost:3000/matches/create"

open("#{sitename}/#{winner_name}/#{winner_id}/#{winner_picks}/#{loser_name}/#{loser_id}/#{loser_picks}")
