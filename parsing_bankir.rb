require 'open-uri'
require 'nokogiri'

@links = []
@page_count = 2

def cikle
  @news_page.css('.inner-wrap').css('.row').css('.article-list').css('.list-row').each do |row|
    @news_date = row.css('.info').css('a').text.to_s
    @news_date = @news_date.gsub(/^\d{2}:\d{2}/, "")
    @news_date = @news_date.gsub(/[^0-9]/, " ").split(' ').map(&:to_i)
    @news_date = Date.new(@news_date[2], @news_date[1], @news_date[0])

    @link = row.css('h2').css('a').first.attributes['href'].text
    @links << @link if @user_date <= @news_date
  end
end

puts "регистрационный номер"
reg_num = gets.to_i

parsed_page = Nokogiri::HTML(open("http://bankir.ru/bank/search/?txt_title=&city=0&txt_regn=#{reg_num}&txt_okpo=&txt_bic=&txt_swift=&form-closed=0"))

bankir_id = parsed_page.css('.banks-list').css('.row').css('.title').css('a').first.attributes['href'].value.to_s
bankir_id = bankir_id.gsub(/[^0-9]/, "")

@news_page = Nokogiri::HTML(open("http://bankir.ru/novosti/?b=#{bankir_id}"))

puts "Какого числа смотрели последний раз? "
@user_date = gets.chomp.gsub(/[^0-9]/, " ").split(' ').map(&:to_i)
@user_date = Date.new(@user_date[2], @user_date[1], @user_date[0])

cikle
while @user_date < @news_date
  @news_page = Nokogiri::HTML(open("http://bankir.ru/novosti/page/#{@page_count}/?b=#{bankir_id}"))
  cikle
  @page_count += 1
end

file = File.new("./#{reg_num}.txt", "a:UTF-8")

@links.each do |link|
  news = Nokogiri::HTML(open("http://bankir.ru#{link}"))

  date = news.at_css('.article-date').text.strip
  header = news.at_css('.article-title').text.strip
  header2 = news.at_css('.article-lid').text.strip
  body = news.at_css('.article-text.clearfix').text.strip

  date = Date.parse(date).strftime('%d.%m.%Y')

  file.print("#{date}\n #{header}\n #{header2}\n #{body}\n\n")
end

file.close
