require 'open-uri'
require 'csv'
require 'json'
require 'bundler'

Bundler.require

class Dataset
	attr_accessor :title, :publication_date, :producer, :period, :creation_date, :periodicity, :licence, :lang, :keywords, :download_link, :content

	def to_json
		{:title => @title}.to_json
	end
end

datasetsInfo = Array.new
for i in 1..1
	if i==1
		url = 'http://www.data.gouv.fr/content/search?SearchText=&SortBy=PublishDate&SortOrder=0&Type=data&SortBy=PublishDate&SortOrder=0&Contexte=add_hit_meta%3Dhtml_simple_view%2540html_simple_view%26start%3D0%26q%3Dtype%253Adata%26nresults%3D8%26lang%3Dfr%26s%3Dissued_time%26sa%3D0%26r%3DTop%252Fprimary_producer%252Fministere%2Bde%2Bla%2Bculture%2Bet%2Bde%2Bla%2Bcommunication&Facet=Top/primary_producer/ministere%20de%20la%20culture%20et%20de%20la%20communication'
	else
		url = 'http://www.data.gouv.fr/content/search/(offset)/' + ((i-1)*8).to_s + '?SearchText=&SortBy=PublishDate&SortOrder=0&Type=data&SortBy=PublishDate&SortOrder=0&Contexte=add_hit_meta%3Dhtml_simple_view%2540html_simple_view%26start%3D0%26q%3Dtype%253Adata%26nresults%3D8%26lang%3Dfr%26s%3Dissued_time%26sa%3D0%26r%3DTop%252Fprimary_producer%252Fministere%2Bde%2Bla%2Bculture%2Bet%2Bde%2Bla%2Bcommunication&Facet=Top/primary_producer/ministere%20de%20la%20culture%20et%20de%20la%20communication'
	end
	doc = Nokogiri::HTML(open(url))
	dataset = Dataset.new
	
	doc.css('.rechResul_item .publititre a').each_with_index do |link, index|
		#begin
			datasetPage = Nokogiri::HTML(open('http://www.data.gouv.fr' + link['href']))
			dataset.title = datasetPage.css('.museo h1').text.strip
			dataset.publication_date =  datasetPage.css('.publi time').first.attributes['datetime'].value
			dataset.producer =  datasetPage.css('.rechResul_ty_donProducteur a').last.text.strip
			period = Hash.new
			period[:start_date] = datasetPage.css('#periode').text.split(' ')[1]
			period[:end_date] = datasetPage.css('#periode').text.split(' ')[3]
			dataset.period =  period
			dataset.creation_date =  datasetPage.css('#created').text.strip
			dataset.periodicity =  datasetPage.css('#accrualPeriodicity').text.strip
			dataset.licence =  datasetPage.css('#license').text
			dataset.lang =  datasetPage.css('#langue').text.strip
			keywords = Array.new
			datasetPage.css('.rechResul_MotsCles .like_nav_ul a').each do |keyword|
				keywords.push keyword.text
			end
			dataset.keywords = keywords
			dataset.download_link = 'http://www.data.gouv.fr' + datasetPage.css('.Prtg_Aside_Bloc .download a').first.attributes['href'].value
			buffer = ''
			#open(dataset.download_link) do |file|
			#	file.each_line do |line|
			#		begin
			#			buffer += CSV.parse(line.gsub(/"/,"'")).join(';')
			#		rescue
			#			binding.pry
			#		end
			#	end
			#end
			#dataset.content = buffer.to_json
			#buffer = open(dataset.download_link).read.gsub(/"/,"'")
			#buffer = CSV.parse(open(dataset.download_link).read.gsub(/"/,"'").gsub(/;/,",").gsub(/\t/,";").encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?"), col_sep: ";").to_json
			buffer = Hash.new
			#csv = File.new
			text = open(dataset.download_link).read.gsub(/"/,"'").gsub(/;/,",").gsub(/\t/,";").encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
			
			CSV.foreach(csv, headers: true) do |row|
				buffer.push row.to_hash
			end
			datasetsInfo.push dataset
			binding.pry
		#rescue NoMethodError
			#binding.pry 
	      	#next
		#end
	end
end
binding.pry


