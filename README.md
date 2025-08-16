# Pipette

**Pipette** is a collection of pipeline-first utilities designed to enhance the ergonomics and expressiveness of data transformations in Elixir. It provides a focused set of tools that seamlessly integrate into `|>` pipelines, making your code more readable, maintainable, and robust.

For a comprehensive guide and API reference, please see the [full documentation](documentation.md).

## Philosophy

**Goal**: To provide ergonomic helpers that naturally fit into `|>` pipelines, simplifying common Elixir programming patterns. Pipette aims to solve specific problems related to data flow, error handling, and controlled parallelism within a pipeline context.

**Non-goals**: Pipette does not aim to reimplement the extensive functionalities of `Enum` or `Stream` modules, nor is it intended to be a general-purpose collection of random helpers. Its scope is intentionally narrow to ensure high utility and seamless integration within pipelines.

## Core Principles

Pipette is built upon four core principles, each addressing a key aspect of efficient and robust Elixir pipelines:

1.  **Pipe Control Combinators**: Utilities that allow for dynamic control and manipulation of the pipeline's flow, enabling conditional execution, early exits, and more expressive data routing.
2.  **Result/Maybe Flow**: Tools for managing and propagating success and failure states within pipelines, promoting clear error handling and reducing boilerplate for `{:ok, value}` and `{:error, reason}` patterns.
3.  **Deep Data Paths**: Convenient mechanisms for safely accessing and transforming deeply nested data structures, reducing the verbosity often associated with complex map or struct manipulations.
4.  **Bounded Parallelism**: Functions that enable controlled parallel execution within pipelines, offering performance benefits for I/O-bound operations while maintaining a familiar `Enum`-like interface.

## Installation

Add `pipette_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pipette_elixir, "~> 0.1.1"}
  ]
end
```

## Usage

Pipette provides a set of powerful functions that integrate directly into your Elixir pipelines. Here are a few examples demonstrating its capabilities:

```elixir
import Pipette
import Pipette.Path, only: [sigil_p: 2]

# Form validation: Safely extract, validate, and transform user input.
# This example demonstrates using `dig_get` for deep data access,
# `presence` for basic validation, and `bind`/`map_ok` for chaining
# operations that might return success or error tuples.
params
|> dig_get(~p"/email")
|> presence(:missing_email)
|> bind(&validate_email/1)
|> bind(&normalize_email/1)
|> map_ok(&%{email: &1})

# Parallel API calls: Efficiently fetch data from multiple sources in parallel.
# `pmap` allows for concurrent execution with a configurable maximum concurrency,
# while `pfilter` enables parallel filtering of results.
user_ids
|> pmap(&Users.fetch!/1, max_concurrency: 32, ordered: false)
|> pfilter(& &1.active)
|> Enum.map(& &1.email)
```

## Why Pipette?

Pipette helps you write cleaner, more functional Elixir code by:

*   **Improving Readability**: By keeping operations within the pipeline, the flow of data is clear and easy to follow.
*   **Enhancing Error Handling**: Explicitly managing success and error states within the pipeline reduces the need for nested `case` statements.
*   **Simplifying Data Access**: Safely navigate and modify complex data structures with concise path-based operations.
*   **Optimizing Performance**: Leverage controlled parallelism for I/O-bound tasks without sacrificing code clarity.

## Documentation

Full documentation, including a comprehensive API reference and additional examples, can be found in [documentation.md](documentation.md).

## Source Code

The source code for Pipette is available on GitHub: [https://github.com/alexzzzs/pipette](https://github.com/alexzzzs/pipette)

## Contributing

We welcome contributions to Pipette! If you have a feature request, bug report, or would like to contribute code, please refer to the project's GitHub repository for guidelines and issue tracking.