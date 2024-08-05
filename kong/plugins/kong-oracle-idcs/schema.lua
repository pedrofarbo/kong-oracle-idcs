local typedefs = require "kong.db.schema.typedefs"

return {
  name = "kong-oracle-idcs",
  fields = {
    {
      consumer = typedefs.no_consumer
    },
    {
      protocols = typedefs.protocols_http
    },
    { config = {
        type = "record",
        fields = {
          { oracle_idcs_base_url = { type = "string", required = true }, },
          { clients = {
              type = "array",
              elements = {
                type = "record",
                fields = {
                  { client_id = { type = "string", required = true }, },
                  { client_secret = { type = "string", required = true, encrypted = true }, },
                  { scope = { type = "string", required = false }, },
                }
              },
              required = true,
          }, },
        },
      },
    },
  },
}
