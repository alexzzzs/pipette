# Pipette Library Documentation

**Pipette** is a collection of pipeline-first utilities designed to enhance the ergonomics and expressiveness of data transformations in Elixir. It provides a focused set of tools that seamlessly integrate into `|>` pipelines, making your code more readable, maintainable, and robust.

## Philosophy

**Goal**: To provide ergonomic helpers that naturally fit into `|>` pipelines, simplifying common Elixir programming patterns. Pipette aims to solve specific problems related to data flow, error handling, and controlled parallelism within a pipeline context.

**Non-goals**: Pipette does not aim to reimplement the extensive functionalities of `Enum` or `Stream` modules, nor is it intended to be a general-purpose collection of random helpers. Its scope is intentionally narrow to ensure high utility and seamless integration within pipelines.

## Core Principles

Pipette is built upon four core principles, each addressing a key aspect of efficient and robust Elixir pipelines:

1.  **Pipe Control Combinators**: Utilities that allow for dynamic control and manipulation of the pipeline's flow, enabling conditional execution, early exits, and more expressive data routing.
2.  **Result/Maybe Flow**: Tools for managing and propagating success and failure states within pipelines, promoting clear error handling and reducing boilerplate for `{:ok, value}` and `{:error, reason}` patterns.
3.  **Deep Data Paths**: Convenient mechanisms for safely accessing and transforming deeply nested data structures, reducing the verbosity often associated with complex map or struct manipulations.
4.  **Bounded Parallelism**: Functions that enable controlled parallel execution within pipelines, offering performance benefits for I/O-bound operations while maintaining a familiar `Enum`-like interface.
5.  **Functional Lenses**: Tools for immutably focusing on, viewing, setting, and transforming specific parts of nested data structures.

## Installation

Add `pipette_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pipette_elixir, "~> 0.1.3"}
  ]
end
```

## Usage and API Reference

Import the `Pipette` module to access all functions, or import specific sub-modules as needed.

```elixir
import Pipette
# or
import Pipette.Control
import Pipette.Result
# etc.
```

### `Pipette.Control`

Provides utilities for dynamic control and manipulation of the pipeline's flow.

#### `do_tap(value, fun)`

Runs `fun.(value)` without changing the `value`. Useful for side effects within a pipeline.

```elixir
"hello"
|> Pipette.Control.do_tap(&IO.puts("Tapping: #{&1}"))
|> String.upcase()
# Output: Tapping: hello
# => "HELLO"
```

#### `pipe_when(value, cond, fun)`

If `cond` is truthy, applies `fun.(value)`; otherwise, passes `value` through unchanged.

```elixir
5
|> Pipette.Control.pipe_when(true, &(&1 * 2))
# => 10

5
|> Pipette.Control.pipe_when(false, &(&1 * 2))
# => 5
```

#### `pipe_unless(value, cond, fun)`

Inverse of `pipe_when`. If `cond` is falsy, applies `fun.(value)`; otherwise, passes `value` through unchanged.

```elixir
5
|> Pipette.Control.pipe_unless(false, &(&1 * 2))
# => 10

5
|> Pipette.Control.pipe_unless(true, &(&1 * 2))
# => 5
```

#### `pipe_case(value, do: block)`

A macro that allows pattern-matching inside a pipeline while keeping it flowing.

```elixir
%{email: "test@example.com", name: "John"}
|> Pipette.Control.pipe_case do
  %{email: e} -> String.downcase(e)
  _           -> nil
end
# => "test@example.com"

%{name: "John"}
|> Pipette.Control.pipe_case do
  %{email: e} -> String.downcase(e)
  _           -> nil
end
# => nil
```

#### `dbg_when(value, cond)`

A pipe-friendly `dbg/1` wrapper controlled by a predicate. The `value` is debugged only if `cond` is truthy.

```elixir
"some_data"
|> Pipette.Control.dbg_when(Mix.env() == :dev) # Will print if in :dev environment
|> String.upcase()
# => "SOME_DATA"
```

### `Pipette.Result`

Provides helpers for working with `{:ok, value}` and `{:error, reason}` tuples, promoting clear error handling.

#### `ok(value)`

Wraps a value in an `{:ok, value}` tuple.

```elixir
Pipette.Result.ok(123)
# => {:ok, 123}
```

#### `error(reason)`

Wraps a reason in an `{:error, reason}` tuple.

```elixir
Pipette.Result.error(:invalid_input)
# => {:error, :invalid_input}
```

#### `presence(value, error_reason)`

Converts `nil` or an empty string to `{:error, error_reason}`; otherwise, wraps the non-nil/non-empty value in `{:ok, value}`.

```elixir
nil
|> Pipette.Result.presence(:missing_value)
# => {:error, :missing_value}

""
|> Pipette.Result.presence(:empty_string)
# => {:error, :empty_string}

"hello"
|> Pipette.Result.presence(:missing_value)
# => {:ok, "hello"}
```

#### `map_ok(result, fun)`

If `result` is `{:ok, value}`, applies `fun` to the value and wraps the result in `{:ok, ...}`; otherwise, passes the error through unchanged.

```elixir
{:ok, 5}
|> Pipette.Result.map_ok(&(&1 * 2))
# => {:ok, 10}

{:error, :bad_input}
|> Pipette.Result.map_ok(&(&1 * 2))
# => {:error, :bad_input}
```

#### `map_error(result, fun)`

If `result` is `{:error, reason}`, applies `fun` to the reason and wraps the result in `{:error, ...}`; otherwise, passes the ok value through unchanged.

```elixir
{:error, :not_found}
|> Pipette.Result.map_error(&("Error: " <> Atom.to_string(&1)))
# => {:error, "Error: not_found"}

{:ok, "data"}
|> Pipette.Result.map_error(&("Error: " <> Atom.to_string(&1)))
# => {:ok, "data"}
```

#### `bind(result, fun)` (also `and_then`)

Monadic bind operation. If `result` is `{:ok, value}`, applies `fun` to the value. `fun` is expected to return another `{:ok, ...}` or `{:error, ...}` tuple. If `result` is `{:error, reason}`, the error is propagated.

```elixir
# Example: Form validation from README
def validate_email(email) do
  if String.contains?(email, "@"), do: {:ok, email}, else: {:error, :invalid_email}
end

def normalize_email(email) do
  {:ok, String.downcase(email)}
end

params = %{email: "TEST@EXAMPLE.COM"}
params
|> Map.get(:email)
|> Pipette.Result.presence(:missing_email)
|> Pipette.Result.bind(&validate_email/1)
|> Pipette.Result.bind(&normalize_email/1)
|> Pipette.Result.map_ok(&%{email: &1})
# => {:ok, %{email: "test@example.com"}}

params_invalid = %{email: "invalid-email"}
params_invalid
|> Map.get(:email)
|> Pipette.Result.presence(:missing_email)
|> Pipette.Result.bind(&validate_email/1)
|> Pipette.Result.bind(&normalize_email/1)
|> Pipette.Result.map_ok(&%{email: &1})
# => {:error, :invalid_email}
```

#### `with_default(result, default_value)`

Returns the `value` if `result` is `{:ok, value}`; otherwise, returns `default_value`.

```elixir
{:ok, "data"}
|> Pipette.Result.with_default("fallback")
# => "data"

{:error, :failed}
|> Pipette.Result.with_default("fallback")
# => "fallback"
```

#### `sequence(list_of_results)`

Takes a list of `{:ok, ...}` or `{:error, ...}` tuples. If all are `{:ok, value}`, returns `{:ok, [value1, value2, ...]}`. If any is `{:error, reason}`, returns the first `{:error, reason}` encountered.

```elixir
[
  {:ok, 1},
  {:ok, 2},
  {:ok, 3}
]
|> Pipette.Result.sequence()
# => {:ok, [1, 2, 3]}

[
  {:ok, 1},
  {:error, :first_error},
  {:ok, 3},
  {:error, :second_error}
]
|> Pipette.Result.sequence()
# => {:error, :first_error}
```

#### `traverse(enumerable, fun)`

Applies `fun` (which must return a `Result` tuple) to each element of the `enumerable`, then sequences the results.

```elixir
def fetch_user(id) do
  case id do
    1 -> {:ok, %{id: 1, name: "Alice"}}
    2 -> {:ok, %{id: 2, name: "Bob"}}
    _ -> {:error, :user_not_found}
  end
end

[1, 2]
|> Pipette.Result.traverse(&fetch_user/1)
# => {:ok, [%{id: 1, name: "Alice"}, %{id: 2, name: "Bob"}]}

[1, 99, 2]
|> Pipette.Result.traverse(&fetch_user/1)
# => {:error, :user_not_found}
```

### `Pipette.Deep`

Provides convenient mechanisms for safely accessing and transforming deeply nested data structures.

#### `dig_get(data, path, default_value)`

Safely retrieves a value from a deeply nested `data` structure using a `path`. Returns `default_value` if any part of the path is not found or invalid. Supports wildcard `:*` for fanning out over lists/maps.

```elixir
import Pipette.Path, only: [sigil_p: 2]

data = %{
  users: [
    %{id: 1, profile: %{name: "Alice", email: "alice@example.com"}},
    %{id: 2, profile: %{name: "Bob", email: "bob@example.com"}}
  ],
  settings: %{app: %{version: "1.0"}}
}

data
|> Pipette.Deep.dig_get(~p"/users/0/profile/email", nil)
# => "alice@example.com"

data
|> Pipette.Deep.dig_get(~p"/users/*/profile/name", nil)
# => ["Alice", "Bob"]

data
|> Pipette.Deep.dig_get(~p"/settings/app/version", nil)
# => "1.0"

data
|> Pipette.Deep.dig_get(~p"/non_existent/path", "default")
# => "default"
```

#### `dig_put(data, path, value)`

Inserts or updates a `value` at a deeply nested `path` within `data`. Creates intermediate maps/lists if they don't exist. Does not support wildcard `:*` writes.

```elixir
import Pipette.Path, only: [sigil_p: 2]

data = %{a: %{b: 1}}

data
|> Pipette.Deep.dig_put(~p"/a/c", 2)
# => %{a: %{b: 1, c: 2}}

%{}
|> Pipette.Deep.dig_put(~p"/x/y/z", "new_value")
# => %{x: %{y: %{z: "new_value"}}}

list_data = [1, 2, %{a: 1}]
list_data
|> Pipette.Deep.dig_put(~p"/2/b", 2)
# => [1, 2, %{a: 1, b: 2}]

# Creating a list with a gap
[]
|> Pipette.Deep.dig_put(~p"/2/value", "hello")
# => [nil, nil, %{value: "hello"}]
```

#### `dig_update(data, path, fun)`

Updates a value at a deeply nested `path` within `data` by applying `fun` to the current value. If the path does not exist, `fun` receives `nil`.

```elixir
import Pipette.Path, only: [sigil_p: 2]

data = %{count: 10, nested: %{value: 5}}

data
|> Pipette.Deep.dig_update(~p"/count", &(&1 + 1))
# => %{count: 11, nested: %{value: 5}}

data
|> Pipette.Deep.dig_update(~p"/nested/value", &(&1 * 2))
# => %{count: 10, nested: %{value: 10}}

data
|> Pipette.Deep.dig_update(~p"/new_key", &(&1 || 0) + 1)
# => %{count: 10, nested: %{value: 5}, new_key: 1}
```

#### `dig_pop(data, path)`

Retrieves a value from a deeply nested `path` and removes it (sets to `nil`) from the `data` structure. Returns `{value, updated_data}`.

```elixir
import Pipette.Path, only: [sigil_p: 2]

data = %{a: 1, b: %{c: 2, d: 3}}

{value, new_data} = data |> Pipette.Deep.dig_pop(~p"/b/c")
# value => 2
# new_data => %{a: 1, b: %{c: nil, d: 3}}

{value, new_data} = data |> Pipette.Deep.dig_pop(~p"/a")
# value => 1
# new_data => %{a: nil, b: %{c: 2, d: 3}}
```

### `Pipette.Parallel`

Functions that enable controlled parallel execution within pipelines, offering performance benefits for I/O-bound operations while maintaining a familiar `Enum`-like interface.

#### `pmap(enumerable, fun, opts \ [])`

Maps `fun` over `enumerable` in parallel. Options include:
*   `:max_concurrency` (default: `System.schedulers_online() * 4`)
*   `:timeout` (default: `30_000` ms)
*   `:ordered` (default: `true`)

```elixir
# Example from README
user_ids = [1, 2, 3, 4, 5]

# Simulate a slow API call
defmodule Users do
  def fetch!(id) do
    :timer.sleep(100) # Simulate network latency
    %{id: id, active: rem(id, 2) == 0, email: "user#{id}@example.com"}
  end
end

user_ids
|> Pipette.Parallel.pmap(&Users.fetch!/1, max_concurrency: 2, ordered: true)
# => [%{id: 1, ...}, %{id: 2, ...}, ...] (results in order)

user_ids
|> Pipette.Parallel.pmap(&Users.fetch!/1, max_concurrency: 2, ordered: false)
# => [%{id: 2, ...}, %{id: 1, ...}, ...] (results may be out of order)
```

#### `pmap_reduce(enumerable, initial_acc, mapper_fun, reducer_fun, opts \ [])`

Performs a parallel map followed by a reduce. `mapper_fun` is applied in parallel, and `reducer_fun` combines the results. Order-insensitive by default.

```elixir
data = 1..100 |> Enum.to_list()

# Parallel sum of squares
data
|> Pipette.Parallel.pmap_reduce(
  0,
  &(&1 * &1),
  &(&1 + &2),
  max_concurrency: 4
)
# => 338350 (sum of squares from 1 to 100)
```

#### `pfilter(enumerable, predicate_fun, opts \ [])`

Filters `enumerable` in parallel using `predicate_fun` (which should return a boolean).

```elixir
# Example from README
user_ids = [1, 2, 3, 4, 5]

# Simulate a slow API call (re-using Users module from pmap example)
# defmodule Users do ... end

user_ids
|> Pipette.Parallel.pmap(&Users.fetch!/1, max_concurrency: 32, ordered: false)
|> Pipette.Parallel.pfilter(& &1.active)
|> Enum.map(& &1.email)
# => ["user2@example.com", "user4@example.com"] (order may vary)
```

### `Pipette.Path`

Defines the structure for paths used in `Pipette.Deep` and provides a convenient sigil for parsing them.

#### `~p"path/string"` (sigil)

Parses a slash-separated path string into a list of segments.
*   Atom keys: `~p"/users/name"` => `[:users, :name]`
*   Integer indices: `~p"/items/0/id"` => `[:items, 0, :id]`
*   Wildcard: `~p"/users/*/email"` => `[:users, :*, :email]`

```elixir
import Pipette.Path, only: [sigil_p: 2]

~p"/users/0/profile/email"
# => [:users, 0, :profile, :email]

~p"/data/*/value"
# => [:data, :*, :value]
```

#### `parse(path_string)`

Parses a slash path string into a list of segments. This is the underlying function used by the `~p` sigil.

```elixir
Pipette.Path.parse("/users/0/profile/email")
# => [:users, 0, :profile, :email]

Pipette.Path.parse("data/*/value")
# => [:data, :*, :value]
```

## Why Pipette?

Pipette helps you write cleaner, more functional Elixir code by:

*   **Improving Readability**: By keeping operations within the pipeline, the flow of data is clear and easy to follow.
*   **Enhancing Error Handling**: Explicitly managing success and error states within the pipeline reduces the need for nested `case` statements.
*   **Simplifying Data Access**: Safely navigate and modify complex data structures with concise path-based operations.
*   **Optimizing Performance**: Leverage controlled parallelism for I/O-bound tasks without sacrificing code clarity.

### `Pipette.Path`

Defines the structure for paths used in `Pipette.Deep` and provides a convenient sigil for parsing them.

#### `~p"path/string"` (sigil)

Parses a slash-separated path string into a list of segments.
*   Atom keys: `~p"/users/name"` => `[:users, :name]`
*   Integer indices: `~p"/items/0/id"` => `[:items, 0, :id]`
*   Wildcard: `~p"/users/*/email"` => `[:users, :*, :email]`

```elixir
import Pipette.Path, only: [sigil_p: 2]

~p"/users/0/profile/email"
# => [:users, 0, :profile, :email]

~p"/data/*/value"
# => [:data, :*, :value]
```

#### `parse(path_string)`

Parses a slash path string into a list of segments. This is the underlying function used by the `~p` sigil.

```elixir
Pipette.Path.parse("/users/0/profile/email")
# => [:users, 0, :profile, :email]

Pipette.Path.parse("data/*/value")
# => [:data, :*, :value]
```

## Why Pipette?

Pipette helps you write cleaner, more functional Elixir code by:

*   **Improving Readability**: By keeping operations within the pipeline, the flow of data is clear and easy to follow.
*   **Enhancing Error Handling**: Explicitly managing success and error states within the pipeline reduces the need for nested `case` statements.
*   **Simplifying Data Access**: Safely navigate and modify complex data structures with concise path-based operations.
*   **Optimizing Performance**: Leverage controlled parallelism for I/O-bound tasks without sacrificing code clarity.

## Contributing

We welcome contributions to Pipette! If you have a feature request, bug report, or would like to contribute code, please refer to the project's GitHub repository for guidelines and issue tracking.

### `Pipette.Lens`

Provides functional lenses for immutably focusing on, viewing, setting, and transforming specific parts of nested data structures.

#### `key(atom)`

Creates a lens that focuses on a specific key in a map.

```elixir
user = %{name: "Alice", age: 30}
name_lens = Pipette.Lens.key(:name)

Pipette.Lens.view(name_lens, user)
# => "Alice"

Pipette.Lens.set(name_lens, "Bob", user)
# => %{name: "Bob", age: 30}

Pipette.Lens.over(name_lens, &String.upcase/1, user)
# => %{name: "ALICE", age: 30}
```

#### `index(integer)`

Creates a lens that focuses on a specific index in a list.

```elixir
list = [10, 20, 30]
second_element_lens = Pipette.Lens.index(1)

Pipette.Lens.view(second_element_lens, list)
# => 20

Pipette.Lens.set(second_element_lens, 25, list)
# => [10, 25, 30]

Pipette.Lens.over(second_element_lens, &(&1 * 2), list)
# => [10, 40, 30]
```

#### `compose(lens1, lens2)`

Composes two lenses to create a new lens that focuses on a deeply nested part of a data structure.

```elixir
user = %{id: 1, profile: %{name: "Alice", email: "alice@example.com"}}
name_lens = Pipette.Lens.compose(Pipette.Lens.key(:profile), Pipette.Lens.key(:name))

Pipette.Lens.view(name_lens, user)
# => "Alice"

Pipette.Lens.set(name_lens, "Bob", user)
# => %{id: 1, profile: %{name: "Bob", email: "alice@example.com"}}

Pipette.Lens.over(name_lens, &String.upcase/1, user)
# => %{id: 1, profile: %{name: "ALICE", email: "alice@example.com"}}
```

#### `view(lens, data)`

Views the value at the focus of the lens.

#### `set(lens, value, data)`

Sets the value at the focus of the lens.

#### `over(lens, fun, data)`

Applies a function to the value at the focus of the lens.

