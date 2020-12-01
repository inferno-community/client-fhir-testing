require 'json'
require 'dm-migrations'
require 'nokogiri'
require_relative './CapabilityStatement-db'

DataMapper.auto_migrate!
DataMapper.auto_upgrade!

CSfile = File.join(File.dirname(__FILE__), 'resources', 'CapabilityStatement-us-core-client.json')
json = File.read(CSfile)
CapStat = JSON.parse(json)

# Interaction summary table
CapStat['rest'][0]['resource'].each do |res|
  type = res['type']
  next unless res.include? 'interaction'

  res['interaction'].each do |hash|
    url = hash['extension'][0]['url']
    valueCode = hash['extension'][0]['valueCode']
    code = hash['code']
    Interaction.create type: type, url: url, valueCode: valueCode, code: code
  end
end

# SearchParam
CapStat['rest'][0]['resource'].each do |res|
  type = res['type']
  next unless res.include? 'searchParam'

  res['searchParam'].each do |s|
    url = s['extension'][0]['url']
    valueCode = s['extension'][0]['valueCode']
    name = s['name']
    definition = s['definition']
    stype = s['type']
    SearchParam.create type: type, url: url, valueCode: valueCode,
                       name: name, definition: definition, stype: stype
  end
end

# Interaction.get(1)
# int1 = Interaction.all type: 'Patient', valueCode: 'SHOULD'
# puts(int1[0].code)
# SearchParam.get(1)

# parameter combination
docs = Nokogiri::HTML(CapStat['text']['div'])
table = docs.at('.grid')

table.search('tr').each do |tr|
  cells = tr.search('th, td')
  # puts(cells)
  # output cell data
  cell_array = []
  cells.each do |cell|
    cell_array.append(cell.text.strip)
  end

  next unless cell_array[0] != "Resource Type"
  #next unless cell_array[0] == "Medication"

  unless cell_array[2] == ""
    sup_params = cell_array[2].split("\n")
    s_params = sup_params[0]
    # puts(sup_params[1])
    if sup_params[1].nil?
      c_params = nil
    else
      c_params = sup_params[1].gsub("\t", "")
    end
  end
  SearchCriteria.create res_type: cell_array[0],
                          profiles: cell_array[1],
                          s_searches: s_params,
                          c_searches: c_params,
                          includes: cell_array[3],
                          revincludes: cell_array[4],
                          opterations: cell_array[5]
end
