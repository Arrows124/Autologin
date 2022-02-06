require "selenium-webdriver"
require "nokogiri"
require "active_record"
require "./secret"

driver = Selenium::WebDriver.for :chrome
driver.manage.timeouts.implicit_wait = 3

ActiveRecord::Base.logger = Logger.new(STDOUT)

class Matrix < ActiveRecord::Base
end

#ログインページに遷移
sleep 1
driver.navigate.to "https://portal.nap.gsic.titech.ac.jp/GetAccess/Login?Template=userpass_key&AUTHMETHOD=UserPassword&GAREASONCODE=-1&GARESOURCEID=resourcelistID2&GAURI=https://portal.nap.gsic.titech.ac.jp/GetAccess/ResourceList&Reason=-1&APPID=resourcelistID2&URI=https://portal.nap.gsic.titech.ac.jp/GetAccess/ResourceList"

#ユーザー情報を送信
driver.find_element(:name, "usr_name").send_keys("user_id")
driver.find_element(:name, "usr_password").send_keys("password")

sleep 1
driver.find_element(:name, "OK").click

doc = Nokogiri::HTML.parse(driver.page_source)

#ローカルのデータベースに接続し、条件に合致する値を送信
[5,6,7].each do |number|
  sleep 1
  text = doc.css("#authentication > tbody > tr:nth-child(#{number}) > th:nth-child(1)").text
  value = Matrix.where(yoko:text[1], tate:text[3]).pluck(:alph_key)

  driver.find_element(:name, "message#{number-2}").send_keys(value[0])
end

driver.find_element(:name, "OK").click

sleep 300
