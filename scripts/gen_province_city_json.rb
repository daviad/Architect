#!/usr/bin/ruby

require 'json'

# province.txt & city.txt see here:
# https://192.168.0.102/svn/docs/server-api

f_province = File.open('province.txt', 'r')
if f_province then
    text = f_province.read()
    province_list = []
    text.each_line do |line|
        items = line.split(' ')
        if items.first.match(/\d+/) then
            province_list.push({
                'id' => items[0],
                'name' => items[1],
            })
        end
    end
    File.open('province.json', 'w') do |f|
        f.write(JSON.pretty_generate(province_list))
    end
end

f_city = File.open('city.txt', 'r')
if f_province then
    text = f_city.read()
    city_list = []
    text.each_line do |line|
        items = line.split(' ')
        if items.first.match(/\d+/) then
            city_list.push({
                'id' => items[0],
                'name' => items[1],
                'province_id' => items[2]
            })
        end
    end
    File.open('city.json', 'w') do |f|
        f.write(JSON.pretty_generate(city_list))
    end
end
