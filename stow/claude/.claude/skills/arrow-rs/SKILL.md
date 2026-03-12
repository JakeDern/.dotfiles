---
name: arrow-rs
description: Guide for working with Apache Arrow record batches and arrays in Rust using the `arrow` crate. Use when writing code that manipulates Arrow arrays, RecordBatches, schemas, or compute kernels.
user-invocable: true
---

# Arrow-RS Skill

Guide for working with Apache Arrow record batches and arrays in Rust using the `arrow` crate.

---

## 1. Array Types & the Type System

Arrow arrays are columnar, immutable, and length-typed. The common currency is 
`ArrayRef` (`Arc<dyn Array>`), a type-erased reference. To work with concrete data 
you must downcast.

### Downcasting

**Safe (returns `Option`)** — prefer these:
```rust
array.as_any().downcast_ref::<UInt32Array>()       // -> Option<&UInt32Array>
array.as_any().downcast_ref::<DictionaryArray<UInt8Type>>()
array.as_any().downcast_ref::<StructArray>()
```

**Panicking shorthands** — these panic on type mismatch. Only use when you have already verified the type (e.g. after matching on `DataType`). Add a safety comment explaining why the cast is guaranteed to succeed:
```rust
// SAFETY: we matched DataType::UInt32 above
array.as_primitive::<UInt32Type>()    // panics if wrong type
array.as_dictionary::<UInt8Type>()    // panics if wrong type
array.as_string::<i32>()             // panics if wrong type
array.as_fixed_size_binary()         // panics if wrong type
```

### Primitive Arrays (`PrimitiveArray<T>`)

Fixed-width numeric types: `UInt8Array`, `UInt16Array`, `UInt32Array`, `Int32Array`, `Int64Array`, `Float64Array`, etc.

```rust
let arr = array.as_any().downcast_ref::<UInt32Array>().unwrap();
arr.value(i)          // -> u32, single element access
arr.values()          // -> &ScalarBuffer<u32>, the underlying typed buffer
arr.values().as_slice() // -> &[u32]
arr.values().inner()  // -> &[u8], raw byte buffer (useful for hashing/cardinality)
arr.len()             // -> usize, row count
arr.null_count()      // -> usize
arr.is_null(i)        // -> bool
```

### String & Binary Arrays

Variable-length types backed by an offset buffer and a value buffer:

```rust
let arr = array.as_any().downcast_ref::<StringArray>().unwrap();
arr.value(i)          // -> &str
arr.value_data()      // -> raw byte buffer of all values
arr.offsets()         // -> &OffsetBuffer<i32>
arr.offsets().inner()  // -> &ScalarBuffer<i32>
```

- `StringArray` / `BinaryArray` use `i32` offsets.
- `LargeStringArray` / `LargeBinaryArray` use `i64` offsets.
- Generic code can use the `OffsetSizeTrait` to abstract over offset size.

### Dictionary Arrays (`DictionaryArray<K>`)

Store repeated values efficiently via key-value indirection. Keys are per-row indices into a shared values array of unique entries.

```rust
let dict = array.as_any().downcast_ref::<DictionaryArray<UInt8Type>>().unwrap();
dict.keys()           // -> &UInt8Array (per-row indices)
dict.values()         // -> &ArrayRef (unique values)
dict.key(i)           // -> Option<usize>, logical key lookup (None if null)
dict.len()            // -> row count (same as keys().len())
```

Common key types: `UInt8Type`, `UInt16Type`. Values are typically `StringArray` or a primitive type.

**Key pattern — filtering/sorting dictionary data**: apply the operation to the values array, then map results back through keys. This avoids expanding the dictionary.

```rust
// Example: regex filter on dictionary-encoded strings
let string_values = dict.values().as_any().downcast_ref::<StringArray>().unwrap();
let val_filter = regexp_is_match_scalar(string_values, regex, None)?;

// Map value-level results back to per-row results through keys
let mut row_filter = BooleanBuilder::with_capacity(dict.len());
for key in dict.keys() {
    match key {
        Some(k) => row_filter.append_value(val_filter.value(k as usize)),
        None => row_filter.append_value(false),
    }
}
```

### Struct Arrays

Nested columnar data — a list of named child arrays (fields) of equal length:

```rust
let s = array.as_any().downcast_ref::<StructArray>().unwrap();
s.column_by_name("field_name") // -> Option<&ArrayRef>
s.fields()                     // -> &Fields (field definitions)
s.columns()                    // -> &[ArrayRef] (child arrays)
s.nulls()                      // -> Option<&NullBuffer>

// Decompose (takes ownership):
let (fields, columns, nulls) = struct_array.into_parts();

// Construct:
StructArray::new(fields.into(), columns, nulls)
StructArray::try_new_with_length(fields, columns, nulls, num_rows)
```

To access a nested column like `"resource.id"`:
1. Find the struct column `"resource"` in the batch.
2. Downcast to `StructArray`.
3. Call `.column_by_name("id")`.

### DataType Matching

Use `DataType` for runtime type dispatch:

```rust
match array.data_type() {
    DataType::UInt16 => { /* downcast to UInt16Array */ }
    DataType::UInt32 => { /* downcast to UInt32Array */ }
    DataType::Dictionary(key_type, value_type) => {
        match (key_type.as_ref(), value_type.as_ref()) {
            (DataType::UInt8, DataType::Utf8) => { /* DictionaryArray<UInt8Type> with StringArray values */ }
            _ => { /* other combinations */ }
        }
    }
    DataType::Struct(fields) => { /* StructArray */ }
    _ => { /* ... */ }
}
```

---

## 2. Null Values & Validity Bitmaps

Arrow represents nulls via a validity bitmap (`NullBuffer`): one bit per row, where a set bit means the value is valid (non-null).

### Querying Nulls

```rust
array.null_count()       // -> usize, fast (cached)
array.is_null(i)         // -> bool, check single row
array.nulls()            // -> Option<&NullBuffer>, None means no nulls at all
```

### Building Null Bitmaps

```rust
let mut builder = NullBufferBuilder::new(capacity);
builder.append_n_non_nulls(count);   // mark N rows as valid
builder.append_n_nulls(count);       // mark N rows as null
builder.append_buffer(&existing_nulls); // append from existing NullBuffer
let nulls: Option<NullBuffer> = builder.finish();
```

### Preserving Nulls When Constructing New Arrays

When building a new array from an existing one, clone the null buffer:

```rust
let nulls = original_array.nulls().cloned();
PrimitiveArray::<T>::new(new_scalar_buffer, nulls)
```

### Iterating Over Valid (Non-Null) Ranges

`BitSliceIterator` yields contiguous runs of set bits — useful for skipping nulls in batch:

```rust
use arrow::util::bit_iterator::BitSliceIterator;

if let Some(nulls) = array.nulls() {
    for (start, end) in BitSliceIterator::new(nulls.buffer().as_slice(), 0, array.len()) {
        // Process valid rows in [start, end)
        for val in &values[start..end] {
            // ...
        }
    }
}
```

`BitIndexIterator` yields individual set bit positions — useful for sparse valid data.

### Raw Bitmap Manipulation

For performance-critical code, operate on validity bitmaps at the byte level:

```rust
let eq_bits = boolean_array.values().inner().clone();  // equality result buffer
if let Some(null_buf) = boolean_array.nulls() {
    let null_bits = null_buf.inner();
    let mut result = MutableBuffer::from_len_zeroed(byte_len);
    for i in 0..byte_len {
        result.as_slice_mut()[i] = eq_bits.as_slice()[i] & null_bits.as_slice()[i];
    }
    // result now has nulls forced to "false"
}
```

---

## 3. Building Arrays

### Builders (Sequential Append)

For building arrays value-by-value:

```rust
// Primitive
let mut builder = PrimitiveBuilder::<UInt32Type>::with_capacity(n);
builder.append_value(42u32);
builder.append_null();
let array: UInt32Array = builder.finish();

// String
let mut builder = StringBuilder::with_capacity(n, estimated_data_bytes);
builder.append_value("hello");
let array: StringArray = builder.finish();
```
### Creating Array Data efficiently from existing Array Data 

When creating Array Data based on existing Array Data, use MutableArrayData which
allows for copying data in ranges.

```rust
let len = /** compute length of new array */
let mut new_data = MutableArrayData::new(vec![&data], false, new_len);
for range in ranges {
    new_data.extend(0, range.start, range.end);
}
```

### Pre-Allocated Buffer Path (Performance-Critical)

When the output size is known and performance matters, bypass builder overhead:

```rust
let mut buffer = MutableBuffer::with_capacity(num_rows * std::mem::size_of::<u32>());

for value in source_values {
    // SAFETY: buffer was allocated with exact capacity for num_rows elements
    #[allow(unsafe_code)]
    unsafe {
        buffer.push_unchecked(value);
    }
}

// Convert: MutableBuffer -> Buffer -> ScalarBuffer -> PrimitiveArray
let scalar_buf = ScalarBuffer::<u32>::new(buffer.into(), 0, num_rows);
let array = UInt32Array::new(scalar_buf, nulls);
```

This avoids per-element capacity checks. Always document the safety argument.

### Offset Buffers for Variable-Length Types

String and binary arrays need an offset buffer alongside the value buffer:

```rust
let offsets = OffsetBuffer::new(ScalarBuffer::new(offset_buffer.into(), 0, num_rows + 1));
// Or skip monotonicity validation when offsets are computed from valid source:
// SAFETY: offsets are copied from a valid source array and are guaranteed monotonic
let offsets = unsafe { OffsetBuffer::new_unchecked(scalar_buffer) };

let array = StringArray::new(offsets, value_data_buffer, nulls);
// Or skip UTF-8 validation when copied from validated input:
// SAFETY: value bytes are copied verbatim from a valid StringArray
let array = unsafe { StringArray::new_unchecked(offsets, value_data_buffer, nulls) };
```

### Dictionary Array Construction

```rust
// From keys + values:
let keys = UInt8Array::from(vec![0u8, 1, 0, 2]);
let values: ArrayRef = Arc::new(StringArray::from(vec!["a", "b", "c"]));
let dict = DictionaryArray::<UInt8Type>::new(keys, values);

// Preserving dictionary structure when replacing values:
let original_dict = array.as_dictionary::<UInt8Type>();
let new_dict = DictionaryArray::new(
    original_dict.keys().clone(),  // reuse keys
    Arc::new(new_values),          // new values array
);
```

### Struct Array Construction

```rust
let fields: Fields = vec![
    Field::new("id", DataType::UInt32, false),
    Field::new("name", DataType::Utf8, true),
].into();
let columns: Vec<ArrayRef> = vec![id_array, name_array];
let struct_array = StructArray::new(fields, columns, None);
```

### Null Array Creation

Create a type-appropriate array of all nulls (useful when a field is missing from some batches):

```rust
let null_array = arrow::array::new_null_array(&DataType::UInt32, num_rows);
```

### MutableArrayData (Range-Based Construction)

Efficiently gather non-contiguous ranges from existing arrays without per-element overhead. Works generically across all array types (primitive, string, dictionary, struct, etc.) via `ArrayData`. See Section 7 for full RecordBatch-level patterns using this API.

```rust
let data = source_array.to_data();
let mut mutable = MutableArrayData::new(vec![&data], false, expected_len);

for range in &ranges {
    mutable.extend(0, range.start, range.end);  // source_idx=0, start, end
}

let new_array = make_array(mutable.freeze());
```

---

## 4. RecordBatch Operations

A `RecordBatch` is a collection of equal-length arrays (columns) with a shared `Schema`.

### Access

```rust
batch.num_rows()              // -> usize
batch.num_columns()           // -> usize
batch.schema_ref()            // -> &SchemaRef (Arc<Schema>)
batch.column_by_name("col")   // -> Option<&ArrayRef>
batch.column(index)           // -> &ArrayRef
batch.columns()               // -> &[ArrayRef]
```

### Decomposition & Construction

```rust
// Take ownership of parts:
let (schema, columns, _num_rows) = batch.into_parts();

// Construct from parts (validates lengths and types match schema):
let batch = RecordBatch::try_new(schema, columns)?;
```

### Column Replacement

For a flat column, replace at the index in the columns vec. For a nested struct column (e.g. replacing `"id"` inside a `"resource"` struct):

1. Downcast the struct column.
2. Decompose with `.into_parts()`.
3. Replace the target field in the struct's columns vec.
4. Reconstruct the `StructArray`.
5. Replace the struct column in the batch's columns vec.

---

## 5. Schema Operations

### Schema & Field Construction

```rust
use arrow_schema::{Schema, SchemaBuilder, Field, DataType};

let mut builder = SchemaBuilder::with_capacity(n);
builder.push(Field::new("id", DataType::UInt32, false));
builder.push(Field::new("name", DataType::Utf8, true));
let schema = builder.finish();
```

### Field Lookup

```rust
schema.index_of("column_name")       // -> Result<usize>
schema.column_with_name("name")      // -> Option<(usize, &FieldRef)>
schema.field(index)                   // -> &FieldRef
schema.fields().find("name")         // -> Option<(usize, &FieldRef)>
```

### Field Metadata

Fields carry a `HashMap<String, String>` of arbitrary metadata:

```rust
let field = Field::new("id", DataType::UInt32, false)
    .with_metadata(HashMap::from([("encoding".into(), "plain".into())]));

field.metadata()          // -> &HashMap<String, String>
field.metadata_mut()      // -> &mut HashMap<String, String> (when you own the field)
```

---

## 6. Sorting Record Batches

The right sorting strategy depends on the number of sort columns and whether columns are dictionary-encoded.

### Single-Column Sort

Use `arrow::compute::sort_to_indices` directly:

```rust
use arrow::compute::{sort_to_indices, SortOptions};

let options = SortOptions { descending: false, nulls_first: false };
let indices: UInt32Array = sort_to_indices(&column, Some(options), None)?;
```

This returns a `UInt32Array` of indices that would sort the input. Apply with `take` (see below).

### Multi-Column Sort — RowConverter

For sorting by 2+ columns, convert to Arrow's row format and sort the row bytes. This is significantly faster than repeated per-column comparisons because it reduces the sort to a single byte-array comparison per row pair.

```rust
use arrow::row::{RowConverter, SortField};

let sort_fields: Vec<SortField> = sort_columns.iter()
    .map(|sc| SortField::new_with_options(sc.values.data_type().clone(), sc.options.unwrap_or_default()))
    .collect();

let row_converter = RowConverter::new(sort_fields)?;
let rows = row_converter.convert_columns(&arrays)?;

let mut indices: Vec<u32> = (0..rows.num_rows() as u32).collect();
indices.sort_unstable_by(|&a, &b| rows.row(a as usize).cmp(&rows.row(b as usize)));

let indices_array = UInt32Array::from_iter_values(indices);
```

Reference: [Multi-Column Sorts in Arrow Rust](https://arrow.apache.org/blog/2022/11/07/multi-column-sorts-in-arrow-rust-part-1/)

### Multi-Column Sort with Dictionary Columns — Rank-Based Approach

`RowConverter` expands dictionaries, which is expensive for large arrays. When sort columns are dictionary-encoded (especially low-cardinality), a rank-based approach avoids expansion:

1. **Rank** the dictionary values (small array): `arrow::compute::rank(dict.values(), options)`.
2. **Map** each dictionary key to its rank (cheap, keys are small integers).
3. **Pack** type + rank into a single sortable integer (e.g., type in high byte, rank in low byte).
4. **Sort** the packed integers with a standard sort.

This is faster than RowConverter when dictionary cardinality is low because it operates on small integer keys instead of expanding every dictionary value for every row.

### Applying Sort Indices to a RecordBatch

After obtaining a `UInt32Array` of sort indices, reorder all columns:

```rust
use arrow::compute::take;

let sorted_columns: Vec<ArrayRef> = batch.columns().iter()
    .map(|col| take(col, &indices, None))
    .collect::<Result<_>>()?;

let sorted_batch = RecordBatch::try_new(batch.schema(), sorted_columns)?;
```

Or use `arrow::compute::take_record_batch(batch, &indices)` if available.

---

## 7. Slice Operations

How to efficiently extract subsets of rows from a record batch depends on whether you need one contiguous slice or multiple non-contiguous ranges.

### Single Contiguous Slice — `RecordBatch::slice()`

This is **O(n_columns)**, not O(n_rows). It adjusts offset and length metadata on each column's underlying buffers without copying data. Always prefer this for a single contiguous range:

```rust
let subset = batch.slice(offset, length);
// Zero-copy: shares underlying buffers with the original batch
```

### Multiple Non-Contiguous Ranges — `MutableArrayData`

When you need to gather rows from multiple disjoint ranges into a single new batch, use `MutableArrayData` (see Section 3) to extend ranges from the source, applied per-column:

```rust
fn take_record_batch_ranges(
    rb: &RecordBatch,
    ranges: &[Range<usize>],
) -> Result<RecordBatch> {
    let new_len: usize = ranges.iter().map(|r| r.end - r.start).sum();
    let mut new_columns = Vec::with_capacity(rb.num_columns());

    for column in rb.columns() {
        let data = column.to_data();
        let mut mutable = MutableArrayData::new(vec![&data], false, new_len);
        for range in ranges {
            mutable.extend(0, range.start, range.end);
        }
        new_columns.push(make_array(mutable.freeze()));
    }

    RecordBatch::try_new(rb.schema(), new_columns)
}
```

### Removing Ranges

The inverse — keep everything except the specified ranges:

```rust
fn remove_record_batch_ranges(
    rb: &RecordBatch,
    ranges: &[Range<usize>],  // sorted, non-overlapping
) -> Result<RecordBatch> {
    let new_len = rb.num_rows() - ranges.iter().map(|r| r.end - r.start).sum::<usize>();
    let mut new_columns = Vec::with_capacity(rb.num_columns());

    for column in rb.columns() {
        let data = column.to_data();
        let mut mutable = MutableArrayData::new(vec![&data], false, new_len);
        let mut pos = 0;
        for range in ranges {
            mutable.extend(0, pos, range.start);  // keep rows before this range
            pos = range.end;
        }
        mutable.extend(0, pos, rb.num_rows());    // keep rows after last range
        new_columns.push(make_array(mutable.freeze()));
    }

    RecordBatch::try_new(rb.schema(), new_columns)
}
```

### Binary Search on Sorted Columns

When data is sorted, use `partition_point` to find row ranges in O(log n):

```rust
// On a primitive ScalarBuffer:
let values = array.as_primitive::<UInt32Type>().values();
let start = values.partition_point(|&v| v < target_start);
let end = values.partition_point(|&v| v <= target_end);
// rows [start..end) match the range [target_start..=target_end]
```

For dictionary-encoded sorted columns, you cannot use `partition_point` on the values buffer directly because keys add an indirection layer. Instead, use a custom binary search that dereferences the logical value at each probe:

```rust
fn row_partition_point(n: usize, mut pred: impl FnMut(usize) -> bool) -> usize {
    let mut lo = 0;
    let mut hi = n;
    while lo < hi {
        let mid = lo + (hi - lo) / 2;
        if pred(mid) { lo = mid + 1; } else { hi = mid; }
    }
    lo
}

// Usage with dictionary:
let logical_val = |i: usize| -> u32 {
    let key_idx = dict.key(i).expect("non-null");
    primitive_values.value(key_idx).into()
};
let start = row_partition_point(dict.len(), |i| logical_val(i) < target_start);
let end = row_partition_point(dict.len(), |i| logical_val(i) <= target_end);
```

### Array Slicing

Individual arrays also support zero-copy slicing:

```rust
let sliced = array.slice(offset, length);  // returns new ArrayRef sharing buffers
```

`ScalarBuffer` supports direct slicing too:

```rust
let float_slice = scalar_buffer.slice(start, length); // no allocation
```

---

## 8. Compute Kernels

The `arrow::compute` module provides vectorized, null-aware operations over Arrow arrays. These are implemented as SIMD-optimized kernels that respect validity bitmaps automatically. Operations are available in several submodules — the ones listed here are commonly used but the module is large. Explore `arrow::compute` and `arrow::compute::kernels` for the full set.

### Comparison (`arrow::compute::kernels::cmp`)

Element-wise comparison returning `BooleanArray`. Scalar variants compare a column against a single value — prefer these over comparing two full arrays when one side is a constant:

```rust
use arrow::compute::kernels::cmp::{eq, gt_eq};

// Scalar comparison (preferred for single-value comparisons):
let scalar = StringArray::new_scalar("target_value");
let matches: BooleanArray = eq(&string_column, &scalar)?;

let threshold = Int32Array::new_scalar(42);
let above: BooleanArray = gt_eq(&int_column, &threshold)?;
```

Scalar comparisons avoid length-mismatch errors and are more efficient than comparing two full-length arrays.

### Boolean Logic (`arrow::compute`)

```rust
use arrow::compute::{and, or, not, and_kleene, or_kleene};

and(&a, &b)          // element-wise AND (nulls -> null)
or(&a, &b)           // element-wise OR (nulls -> null)
not(&a)              // element-wise NOT
and_kleene(&a, &b)   // three-valued AND (false AND null -> false)
or_kleene(&a, &b)    // three-valued OR (true OR null -> true)
```

Use Kleene variants when combining filter conditions to get SQL-like null semantics.

### Reorder (`arrow::compute`)

```rust
sort_to_indices(&array, Some(sort_options), None)  // -> UInt32Array of sort permutation
take(&array, &indices, None)                       // -> ArrayRef, reorder by index array
take_record_batch(&batch, &indices)                // -> RecordBatch, reorder all columns
```

### Filter (`arrow::compute`)

```rust
filter(&array, &boolean_mask)                      // -> ArrayRef, keep rows where mask is true
filter_record_batch(&batch, &boolean_mask)         // -> RecordBatch
```

### Type Conversion (`arrow::compute`)

```rust
cast(&array, &target_data_type)   // convert between types (e.g. dictionary <-> primitive)
```

### Other Useful Kernels

```rust
is_not_null(&array)                                 // -> BooleanArray
rank(&array, sort_options)                          // -> UInt32Array of value ranks
regexp_is_match_scalar(&string_array, regex, None)  // -> BooleanArray
concat_batches(&schema, &[batch1, batch2])          // -> RecordBatch
max(&array)                                         // -> Option<T>, aggregate max (primitive only)
min_array::<T, _>(accessor)                         // -> Option<T::Native>, null-aware min
max_array::<T, _>(accessor)                         // -> Option<T::Native>, null-aware max
```

**`min_array` / `max_array` vs `min` / `max`**: Import from `arrow::compute::kernels::aggregate`. The `min`/`max` functions only work on `&PrimitiveArray<T>` and return `Option<T::Native>`. Prefer `min_array`/`max_array` when you need null-aware min/max that also handles dictionary-encoded arrays. They take any `ArrayAccessor<Item = T::Native>` (e.g. `&PrimitiveArray<T>` or `TypedDictionaryArray` from `dict.downcast_dict::<PrimitiveArray<T>>()`) and return `Option<T::Native>`. Requires `T: ArrowNumericType`.

### `BatchCoalescer`

For efficiently concatenating many batches into one with a known total row count:

```rust
let mut coalescer = arrow::compute::BatchCoalescer::new(schema, total_rows);
for batch in batches {
    coalescer.push_batch(batch)?;
}
coalescer.finish_buffered_batch()?;
let result = coalescer.next_completed_batch().expect("complete");
```

---

## 9. Performance Patterns

Summary of performance principles covered throughout this document, plus additional tips.

- **Pre-allocate + unsafe push**: When output size is known, use `MutableBuffer::with_capacity` + `push_unchecked` to skip per-element capacity checks. Always document the safety argument. (See Section 3.)
- **`RecordBatch::slice()` is cheap**: It is a metadata-only O(n_columns) operation with no data copy. Always prefer it over `MutableArrayData` for a single contiguous range. (See Section 7.)
- **Skip already-sorted data**: Check `indices.values().is_sorted()` before materializing a reorder via `take`. (See Section 6.)
- **Prefer scalar comparisons**: Use `new_scalar()` with compute kernels when comparing a column against a single value. More efficient and avoids length-mismatch errors. (See Section 8.)
- **Avoid dictionary expansion**: When sorting or filtering dictionary-encoded columns, operate on values/keys instead of expanding with `cast`. Rank values for sorting; apply predicates to values and map through keys for filtering. (See Sections 1, 6.)
- **`ScalarBuffer::slice(start, len)`**: Returns a view with no allocation. Prefer this over `array.slice()` when you only need the raw typed values.
- **Early returns for trivial cases**: Skip processing for empty batches, single-row batches, or all-null columns.
- **Reusable scratch buffers**: For repeated operations (e.g., sorting partitions in a loop), maintain reusable `Vec` or `MutableBuffer` allocations across iterations rather than allocating fresh each time.
