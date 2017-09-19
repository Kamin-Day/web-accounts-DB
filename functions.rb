require "pry"
require "rspec"
require "pg"
require "csv"


@conn = PGconn.open(:dbname => 'AccountsInfo')
def buildHash(results)
	accounts = {}

	results.each do |transaction|
	 
	 # Add a key for each account to the accounts Hash.
	  account = transaction["account_id"]

	  if !accounts[account]
	    accounts[account] = {
	      balance: 0.00,
	      categories: {
	      }
	    }
	  end

	  # Set the account which is being affected by this iteration.
	  current_account = accounts[account]
	  # Clean up outflow and inflow.
	  outflow = transaction["outflow"].gsub(/[,\$]/, "").to_f.round(2)
	  inflow = transaction["inflow"].gsub(/[,\$]/, "").to_f.round(2)
	  transaction_amount = inflow - outflow

	  # Keep a balance for current balance of the account.
	  current_account[:balance] += transaction_amount
	  category = transaction["category"].chomp

	  # Initialize category.
	  if !current_account[:categories][category]
	    current_account[:categories][category] = {
	      balance: 0.00,
	      num_transactions: 0,
	      average_transaction_cost: 0.00
	    }
	  end

	  # balance category.
	  current_account[:categories][category][:balance] += transaction_amount

	  # Increment transaction counter.
	  current_account[:categories][category][:num_transactions] += 1

	  # Update average transaction cost.
	  current_account[:categories][category][:average_transaction_cost] = current_account[:categories][category][:balance] / current_account[:categories][category][:num_transactions]  
	end
	

	return accounts

end

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
	result = @conn.exec("SELECT * FROM accounts WHERE name='#{name}';").to_a
	result.each do |account|
		if account["name"] == name
			return account["id"]
		end
	end
	return false
end

#Takes in the account name and transaction results, calls a function to get
# the change in funds then calculates the balance 
def displayAccountBalance(results)
	balance = 0
	results.each do |transaction|
		balance += changeInFunds(transaction['inflow'], transaction['outflow'])
	end
	return toCurrency(balance)
end

# #Takes in query results and returns an array of hashes with the category name and total spent
# def getCategoryTotal(results)
# 	categoryTotals = []
# 	results.each do |transaction|
# 		transaction 
# 		gameWord.split('').each do |c|
# 			gameField.push(Hash[c, false])
# 	end


# end

def included?(list)

end

#Takes in the inflow and outflow of a transaction and returns the difference
def changeInFunds (inflow, outflow)
	return toNum(inflow) - toNum(outflow)
end

#Converts a floating point number into currency formatted string
def toCurrency(ammount)
	return "$" + ammount.round(2).to_s
end

#Converts a string currency to floating point num
def toNum (input)
	return input.gsub(/[,\$]/, "").to_f.round(2)
end

#Takes in an account ID and fetches all the transactions for that account 
# from the database. Returns those results
def getAccountInfo(id)
	return @conn.exec("SELECT * FROM transactions WHERE account_id=#{id.to_i};").to_a
end

#Gets the information about all of the transactions from the database
def getAllTrans
	return @conn.exec("SELECT * FROM transactions").to_a
end

#Some function to read CSV and add to transactions table
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