require 'newrelic_rpm'

class Mysql2ClientWithNewRelic < Mysql2::Client
  def initialize(*args)
    super
  end

  def query(sql, *args)
    callback = -> (result, metrics, elapsed) do
      NewRelic::Agent::Datastores.notice_sql(sql, metrics, elapsed)
    end
    op = sql[/^(select|insert|update|delete|begin|commit|rollback|truncate)/i] || 'other'
    table = sql[/\btable1|tabl2|table3\b/] || 'other'
    NewRelic::Agent::Datastores.wrap('MySQL', op, table, callback) do
      super
    end
  end
end
