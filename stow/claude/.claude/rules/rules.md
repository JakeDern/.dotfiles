# Writing comments

- Never use fancy unicode characters, always use ascii only. For example don't 
use special arrows, use ->.

# Organizing code

- Organize code in callstack order. If function A calls function B, place B below
A in the file.
- Always prefer early returns instead of nesting

# Assertions

- Document function preconditions by writing assertions
- If assertions are too expensive to run, use features like Rusts `debug_assert`
to only run them in debug builds

# Writing efficient code

- Avoid unnecessary allocations always, re-use scratch or buffer space when possible
- Always size new data structures appropriately with the expected element count

# Bugfixing

- Before implementing a bugfix, reproduce the bug with a test. Do not fix the bug
until it is reproducable.

# Profiling

Never create your own instrumentation to profile without asking first. Prefer
to use perf which can be found in /usr/lib/linux-tools/<version>/perf on WSL.

# Optimizing code

- Always check if a benchmark exists and create one if not.
- We must be able to compare the old implementation with the new implementation
for the same benchmarks. If you had to write new benchmarks, then preserve the
old implementation somewhere in the branch for comparison while developing e.g.
if developing a new version of `reindex.rs`, save the old in `reindex_old.rs`.
- Always run the benchmark before implementing  optimization and run it after
to validate.
- Always validate test coverage. Add and run any missing coverage before starting 
implementation.

# Writing Benchmarks

- A benchmark should generate data with the characteristics that will trigger the
different optimizations or code paths.
- Data generation for benchmarks must not affect benchmark results generate data
outside the benchmark code and use framework tools like `bench_with_input`.
- When writing a benchmark to compare implementations, always run both benchmarks
with the exact same input data.
