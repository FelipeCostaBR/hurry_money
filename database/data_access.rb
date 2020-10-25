def run_sql(sql, params = [])
    db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'hurrymoney'})
    result = db.exec_params(sql, params)
    db.close
    return result
  end
#    
  def find_user_by_id(id)
    if id[:type] == 'investor'
        results = run_sql("SELECT * FROM investors WHERE id = #{id[:id]};")
    else
        results = run_sql("SELECT * FROM debtors WHERE id = #{id[:id]};")
    end
    return results[0]
  end

  def find_investor_by_email(email)
    results = run_sql("SELECT *, 'investor' as type FROM investors WHERE email = $1;", [email])
    return results.none? ? [] : results[0]
  end

  def find_debtor_by_email(email)
    results = run_sql("SELECT *, 'debtor' as type FROM debtors WHERE email = $1;", [email])
    return results.none? ? [] : results[0]
  end

    def create_investor(firstname, lastname, email, phone, dt_birth, address, photo,password_digest, wallet_value)
        return run_sql("INSERT INTO investors (firstname, lastname, email, phone, dt_birth, address, photo, password_digest, wallet_value) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9);", [firstname, lastname, email, phone, dt_birth, address, photo, password_digest, wallet_value])
    end


    def create_debtor(firstname, lastname, email, phone, dt_birth, address, photo, password_digest, wallet_value)
        return  run_sql("INSERT INTO debtors (firstname, lastname, email, phone, dt_birth, address, photo, password_digest, wallet_value) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9);", [firstname, lastname, email, phone, dt_birth, address, photo, password_digest, wallet_value])
    end

    def value_total_to_borrow()
      result =run_sql("SELECT SUM(wallet_value) FROM investors;")
      return result[0]['sum']
    end
    

    def apply_loan(loan_amount, fee, installments, id_debtors)
      return run_sql("INSERT INTO loans (money_asked, fee, installments, id_debtors) VALUES ($1, $2, $3, $4);", [loan_amount, fee, installments, id_debtors])
    end

    def loan_pending()
      return run_sql("SELECT DISTINCT
        a.id AS id_loan,
        b.id AS id_debtors,
        CONCAT(b.firstname, ' ',b.lastname) AS debtor_name,
        a.money_asked, a.fee, a.create_date,
        (SELECT count(paid) FROM installments WHERE paid = 1 AND id_loan = a.id ) AS paid,
        a.installments, b.photo
            FROM loans a
                INNER JOIN debtors b ON a.id_debtors = b.id
                LEFT JOIN installments c ON c.id_loan = a.id
                WHERE a.id_investors is NULL
                ORDER BY create_date,debtor_name ASC;")
    end

    def total_loan()
       result = run_sql("SELECT count(id) FROM loans WHERE id_investors is NULL;")
       return result[0]['count']
    end

    def investor_lender_loan(id_investor,id_debtor, value_loan, id_loan)
      update_investor_wallet_withdraw(value_loan, id_investor) 
      update_debtor_wallet_boost(value_loan, id_debtor)
      return run_sql("UPDATE loans SET id_investors = $1, money_lended = $2 WHERE id = $3;",[id_investor, value_loan, id_loan] )
       
    end

    def next_payment_into_investor(id_investor)
      return run_sql("SELECT DISTINCT a.id,c.photo,CONCAT(c.firstname, ' ',c.lastname) AS debtor_name,
      (SELECT count(paid) FROM installments WHERE paid = 1 AND id_loan = a.id ) AS paid,
      (SELECT count(paid) FROM installments WHERE paid = 0 AND id_loan = a.id ) AS not_paid,
      (SELECT min(due_date) FROM installments WHERE paid = 0 AND id_loan = a.id ) AS due_date,
      b.value
          FROM loans a 
              INNER JOIN installments b ON a.id = b.id_loan 
              INNER JOIN debtors c ON c.id = a.id_debtors
                  WHERE a.id_investors = $1
                  GROUP BY a.id,c.photo,c.firstname,c.lastname,b.value;", [id_investor])
    end

    def next_payment_from_debtor(id_debtor)
      return run_sql("SELECT DISTINCT
        a.id AS id_loan,
        b.id AS id_installment,
        a.id AS id_debtors,
        a.id_investors,
        b.due_date,
        b.value, 
        paid
            FROM loans a
            INNER JOIN installments b ON a.id = b.id_loan
                WHERE a.id_debtors = $1
                ORDER BY paid, a.id,b.due_date;", [id_debtor])
      
    end

    def check_debtor_successfully_loans_paid(id_debtor)
      return run_sql("SELECT (SELECT count(p.paid) FROM installments p WHERE p.paid = 1 AND p.id_loan = t.id_loan) = COUNT(id_loan) AS loans_paid
    FROM installments t
    INNER JOIN loans l ON l.id = t.id_loan
    INNER JOIN debtors d ON l.id_debtors = d.id     
    WHERE d.id = $1
    GROUP BY t.id_loan;", [id_debtor])
      
    end
    
    def total_investor_wallet(id_investor)
      result = run_sql("SELECT wallet_value FROM investors WHERE id = $1;", [id_investor])
      return result[0]['wallet_value']
    end

    def total_debtor_wallet(id_debtor)
      result = run_sql("SELECT wallet_value FROM debtors WHERE id = $1;", [id_debtor])
      return result[0]['wallet_value']
    end

    def update_investor_wallet_boost(new_value, id_investor)
      return run_sql("UPDATE investors SET wallet_value = (wallet_value + $1)  WHERE id = $2;", [new_value, id_investor])
    end

    def update_investor_wallet_withdraw(new_value, id_investor)
      return run_sql("UPDATE investors SET wallet_value = (wallet_value) - $1  WHERE id = $2;", [new_value, id_investor])
    end


    def update_debtor_wallet_boost(new_value, id_debtor)
      return run_sql("UPDATE debtors SET wallet_value = (wallet_value + $1)  WHERE id = $2;", [new_value, id_debtor])
    end

    def update_debtor_wallet_withdraw(new_value, id_debtor)
      return run_sql("UPDATE debtors SET wallet_value = (wallet_value) - $1  WHERE id = $2;", [new_value, id_debtor])
    end

def pay_installment(value, id_investor, id_installment)
  update_investor_wallet_boost(value, id_investor)
  return run_sql("UPDATE installments SET paid = 1 WHERE id = $1;",[id_installment]);
end