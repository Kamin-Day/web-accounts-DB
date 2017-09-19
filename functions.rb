require "pry"
require "rspec"
require "pg"
require "csv"


@conn = PGconn.open(:dbname => 'AccountsInfo')

# MESSAGES

# Message which welcomes user to application
def welcomeMessage
	return "Welcome to your accounts database"
end

# Message asking the user for imput regarding which accounts they would like to view
def askViewMessage
	return "What would you like to view? Enter a name or type all to continue."
end

# Returns user input from command line
def getResponse
	return gets.downcase.chomp
end

# Returns a message informing the user their query returned no results,
# and the content of their query
def notFound(query)
	return "Your query for " + query + " returned no results."
end
#Takes in an account name from user input and checks to see if it is present in the DB
# if it is found, the results are returned
# if not, false is returned
def DBcheckForAccount(name)
	result = @conn.exec("SELECT * FROM accounts").to_a
	binding.pry
	result.each do |account|
		if account["name"] == name
			return account["id"]
		end
	end
	return false
end

 SELECT * FROM accounts WHERE name='priya';

def CSVtoDB
	CSV.foreach("accounts.txt", {headers: true, return_headers: false}) do |row|
		 
		account = row["Account"].chomp
		date = row["Date"].split("/")
		formatted_date = date[2]+"/"+date[0]+"/"+date[1]
		payee = row["Payee"]
		payee = payee.tr("'", "").chomp
		outflow = row["Outflow"].gsub(/[,\$]/, "").to_f.round(2)
		inflow = row["Inflow"].gsub(/[,\$]/, "").to_f.round(2)

		if account == "Priya"
			account_id = 2
		elsif account == "Sonia"
			account_id = 1
		end
		result = conn.exec("INSERT INTO transactions (account_id, date, payee, category, outflow, inflow) VALUES('"+account_id.to_s+"', '" +formatted_date.to_s+"', '"+payee+"', '"+row["Category"].chomp+"', #{outflow}, #{inflow});")
	end
end