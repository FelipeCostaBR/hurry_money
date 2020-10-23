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

    def create_investor(firstname, lastname, email, phone, dt_birth, address, photo,password_digest)
        return results = run_sql("INSERT INTO investors (firstname, lastname, email, phone, dt_birth, address, photo, password_digest) VALUES ($1, $2, $3, $4, $5, $6, $7, $8);", [firstname, lastname, email, phone, dt_birth, address, photo, password_digest])
    end


    def create_debtor(firstname, lastname, email, phone, dt_birth, address, photo, password_digest)
        return results = run_sql("INSERT INTO debtors (firstname, lastname, email, phone, dt_birth, address, photo, password_digest) VALUES ($1, $2, $3, $4, $5, $6, $7, $8);", [firstname, lastname, email, phone, dt_birth, address, photo, password_digest])
    end

    def value_total_to_borrow()
      result =run_sql("select SUM(wallet_value) from investors;")
      return result[0]['sum']
    end

    def apply_loan(loan_amount, fee, installments, id_debtors)
      results = run_sql("INSERT INTO loans (money_asked, fee, installments, id_debtors) VALUES ($1, $2, $3, $4);", [loan_amount, fee, installments, id_debtors])
    end

    