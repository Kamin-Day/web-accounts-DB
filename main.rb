# Starting remake of web CSV report using database structures
require "pry"
require "rspec"
require "pg"
require "csv"
require_relative "functions.rb"

conn = PGconn.open(:dbname => 'AccountsInfo')

#Greets the user and asks for input about which accounts to view
puts welcomeMessage()
puts askViewMessage()

# viewSelection calls a function to get the users response and stores their response
viewSelection = getResponse()

# selectionID calls a function to query the accounts table in the DB to see 
# if a certain account is present. if the account name is not found, it stores 
# false return. if the account is found, selectionID stores the accounts ID from the DB
selectionID = DBcheckForAccount(viewSelection)

# if selectionID is false, the user is notified their query found no matches
if !selectionID
	puts notFound(viewSelection)

# otherwise, queryResults calls a function which returns all of the information
# regarding the transactions with that ID 
else
 	queryResults = getAccountInfo(selectionID)
end
binding.pry
puts viewSelection



# CSV.foreach("accounts.txt", {headers: true, return_headers: false}) do |row|
	 
# 	account = row["Account"].chomp
# 	date = row["Date"].split("/")
# 	formatted_date = date[2]+"/"+date[0]+"/"+date[1]
# 	payee = row["Payee"]
# 	payee = payee.tr("'", "").chomp
# 	outflow = row["Outflow"].gsub(/[,\$]/, "").to_f.round(2)
# 	inflow = row["Inflow"].gsub(/[,\$]/, "").to_f.round(2)

# 	if account == "Priya"
# 		account_id = 2
# 	elsif account == "Sonia"
# 		account_id = 1
# 	end
# 	result = conn.exec("INSERT INTO transactions (account_id, date, payee, category, outflow, inflow) VALUES('"+account_id.to_s+"', '" +formatted_date.to_s+"', '"+payee+"', '"+row["Category"].chomp+"', #{outflow}, #{inflow});")
# end

		



# database:
# AccountsInfo

# accounts:
# id name

# transactions:
# (id SERIAL PRIMARY KEY, account_id INTEGER, date DATE, payee VARCHAR, category VARCHAR, outflow MONEY, inflow MONEY);
