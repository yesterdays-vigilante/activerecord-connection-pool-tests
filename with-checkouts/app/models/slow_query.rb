module SlowQuery
  def slow_all(time)
    connection.execute("select pg_sleep(#{time})")
    all
  end
end
