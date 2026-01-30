local pg_utils = require "api-umbrella.utils.pg_utils"

return function()
  local database = pg_utils.db_config["database"]

  pg_utils.db_config["database"] = "postgres"
  pg_utils.db_config["user"] = os.getenv("DB_USERNAME")
  pg_utils.db_config["password"] = os.getenv("DB_PASSWORD")

  pg_utils.query("DROP DATABASE IF EXISTS :database", { database = pg_utils.identifier(database) }, { verbose = true, fatal = true })
end
