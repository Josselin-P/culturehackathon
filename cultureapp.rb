#cultureapp.rb

require 'sinatra'
require 'sinatra/reloader'
require 'open-uri'
require 'bundler'
require 'json'
require 'csv'

Bundler.require

class Dataset
	attr_accessor :title, :publication_date, :producer, :period, :creation_date, :periodicity, :licence, :lang, :keywords, :download_link

	def to_json
		{:title => @title}.to_json
	end
end

datasetsInfo = Array.new
for i in 1..3
	if i==1
		url = 'http://www.data.gouv.fr/content/search?SearchText=&SortBy=PublishDate&SortOrder=0&Type=data&SortBy=PublishDate&SortOrder=0&Contexte=add_hit_meta%3Dhtml_simple_view%2540html_simple_view%26start%3D0%26q%3Dtype%253Adata%26nresults%3D8%26lang%3Dfr%26s%3Dissued_time%26sa%3D0%26r%3DTop%252Fprimary_producer%252Fministere%2Bde%2Bla%2Bculture%2Bet%2Bde%2Bla%2Bcommunication&Facet=Top/primary_producer/ministere%20de%20la%20culture%20et%20de%20la%20communication'
	else
		url = 'http://www.data.gouv.fr/content/search/(offset)/' + ((i-1)*8).to_s + '?SearchText=&SortBy=PublishDate&SortOrder=0&Type=data&SortBy=PublishDate&SortOrder=0&Contexte=add_hit_meta%3Dhtml_simple_view%2540html_simple_view%26start%3D0%26q%3Dtype%253Adata%26nresults%3D8%26lang%3Dfr%26s%3Dissued_time%26sa%3D0%26r%3DTop%252Fprimary_producer%252Fministere%2Bde%2Bla%2Bculture%2Bet%2Bde%2Bla%2Bcommunication&Facet=Top/primary_producer/ministere%20de%20la%20culture%20et%20de%20la%20communication'
	end
	doc = Nokogiri::HTML(open(url))
	#binding.pry
	doc.css('.rechResul_item .publititre a').each_with_index do |link, index|
		begin
			dataset = Dataset.new
			#binding.pry
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
			datasetsInfo.push dataset
			#binding.pry
		rescue NoMethodError
	      	next
		end
		#binding.pry
	end
end

get '/'  do	
	record_per_page = 20
	#binding.pry
	@page_count = (datasetsInfo.length.to_f / record_per_page).ceil
	@page = params[:page] || 1
	@datasetsInfo = datasetsInfo.drop((@page-1)*record_per_page).take(record_per_page)
	respond_to do |format|
	    format.json { '{' + @datasetsInfo.map {|dataset| dataset.to_json }.join(',') + '}' }
	    format.html { erb :index }
	end
end


# / => liste datasets, HTML & JSON	
# /dataset/:dataset => dataset HTML & JSON, HTML: nombre de lignes, noms des champs, JSON: csv to JSON
