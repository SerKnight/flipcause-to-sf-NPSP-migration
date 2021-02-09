require 'csv'

csv = CSV.parse(File.read('./flipcause.csv'), :headers => true)
sf_objects = []

def phone(row)
  mobile = "#{row['Primary Mobile Country Code']} #{row['Primary Mobile Number']} #{row["Primary Mobile Number Ext"]}"
  home = "#{row['Primary Home Number Country Code']} #{row['Primary Home Number']} #{row["Primary Home Number Ext"]}"
  if mobile.length > 5
    mobile
  elsif home.length > 5
    home
  else
    ''
  end
end

def donor?(row)
  total_donated(row) > 0
end

def total_donated(row)
  if row["All Time Donation Amount"]
    row["All Time Donation Amount"].gsub("$",'').to_f
  else
    0
  end
end

def donor_level(num)
  if num <= 25
    'Bronze'
  elsif num <= 50
    'Silver'
  elsif num >= 100
    'Gold'
  else
    ''
  end
end

def donation_description(row)
  %(Largest Contribution: #{row["Largest Contribution Amount"]} #{row["Largest Contribution Date"]})
end

csv.each_with_index do |row, index|
  # if index == 1
    flipcause_mapped = {
      "Contact1 First Name": row["First Name"].nil? ? row["Business/Organization Name"] : row["First Name"], # Freeman,
      "Contact1 Last Name": row["Last Name"].nil? ? row["First Name"] : row["Last Name"], # Freeman,
      "Contact1 Birthdate": row["Birthdate"], # 01/15/1975,
      "Contact1 Home Email": row["Email"], # martha.freeman@email.com,
      "Contact1 Mobile Phone": phone(row), # 555-231-1234,
      "Home Street": row["Address"], # 9012 4th St,
      "Home City": row["City"], # Home Town,
      "Home State/Province": row["State/Province"], # MA,
      "Home Zip/Postal Code": row["Postal Code"], # 02345,
      "Home Country": row["Country"], # USA,
      "Donation Donor": donor?(row) ? "Contact1" : nil, # Contact1,
      "Donation Amount": donor?(row) ? total_donated(row) : nil, # 250.50,
      "Donation Name": donor?(row) ? row["Tags"] : nil, # Freeman Family Membership,
      "Donation Record Type Name": donor?(row) ? 'Donation' : nil, # Membership,
      "Donation Stage": donor?(row) ? 'Posted' : nil, # Posted,
      "Donation Type": donor?(row) ? 'Existing Funding' : nil, # Existing Funding,
      "Donation Description": donor?(row) ? donation_description(row) : nil, # ,
      "Donation Member Level": donor?(row) ? donor_level(total_donated(row)) : nil# Gold,
    }
  # end

  sf_objects << flipcause_mapped
  # end
end

CSV.open("sf_import.csv", "wb") do |csv|  
  puts "sf_objects -> #{sf_objects}"
  keys = sf_objects.first.keys
  csv << keys

  sf_objects.each do |obj|
    puts "OBJ #{obj}"

    csv << obj.values
  end
end