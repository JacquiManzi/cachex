defmodule Cachex.Actions.Set do
  @moduledoc false
  # Command module to enable insertion of cache entries.
  #
  # This is the main entry point for adding new entries to the cache table. New
  # entries are inserted taking an optional expiration time into account.
  #
  # This command will use lock aware contexts to ensure that there are no key
  # clashes when writing values to the cache.
  alias Cachex.Actions
  alias Cachex.Services.Locksmith
  alias Cachex.Util

  # add our macros
  import Cachex.Actions
  import Cachex.Spec

  @doc """
  Inserts a value into the cache.

  This takes expiration times into account before insertion and will operate
  inside a lock aware context to avoid clashing with other processes.
  """
  defaction set(cache() = cache, key, value, options) do
    ttlval = Util.get_opt(options, :ttl, &is_integer/1)
    expiry = Util.get_expiration(cache, ttlval)

    record = entry_now(key: key, ttl: expiry, value: value)

    Locksmith.write(cache, key, fn ->
      Actions.write(cache, record)
    end)
  end
end
