---
name: otap-rust
description: Rust implementation guide for OTAP. Use when creating, transforming, splitting, concatenating, filtering, or transport-encoding OtapArrowRecords.
user-invocable: true
---

# OTAP Rust Implementation Guide

Maps OTAP protocol concepts to Rust types and provides practical patterns for working with `OtapArrowRecords`.

---

## 1. Key Files

All paths relative to `rust/otap-dataflow/crates/`.

| File | Role |
|------|------|
| `pdata/src/otap.rs` | `OtapArrowRecords` enum, `OtapBatchStore` trait, `Logs`/`Metrics`/`Traces` stores, `POSITION_LOOKUP` |
| `pdata/src/otap/batching.rs` | `make_item_batches` — public entry point for split+concatenate |
| `pdata/src/otap/groups.rs` | `RecordsGroup` — separate/split/concatenate/convert pipeline |
| `pdata/src/otap/transform/split.rs` | `split()` — row-level splitting with parent-child alignment |
| `pdata/src/otap/transform/concatenate.rs` | `concatenate()` — schema unification + BatchCoalescer |
| `pdata/src/otap/transform/reindex.rs` | `reindex()` — makes IDs unique across batches before concat |
| `pdata/src/otap/transform/transport_optimize.rs` | `apply_transport_optimized_encodings`, `remove_transport_optimized_encodings`, `remap_parent_ids` |
| `pdata/src/otap/transform/util.rs` | `id_column_dispatch!`, `payload_relations`, `take_record_batch_ranges`, `sort_by_parent_then_id`, `replace_column` |
| `pdata/src/otap/filter.rs` | Filter infrastructure: `MatchType`, `KeyValue`, `AnyValue`, attribute/ID matching |
| `pdata/src/otap/filter/logs.rs` | `LogFilter`, `LogMatchProperties` |
| `pdata/src/otap/filter/traces.rs` | `TraceFilter`, `TraceMatchProperties` |
| `pdata/src/otap/schema.rs` | `SchemaIdBuilder` — deterministic schema ID generation |
| `pdata/src/schema/consts.rs` | Column name constants (`ID`, `PARENT_ID`, `RESOURCE`, `SCOPE`, etc.) |
| `pdata/src/proto/opentelemetry.proto.experimental.arrow.v1.rs` | `ArrowPayloadType` enum (generated from protobuf) |
| `otap/src/batch_processor.rs` | Top-level batch processor using `make_item_batches` |

---

## 2. Core Types

### `OtapArrowRecords`

```rust
pub enum OtapArrowRecords {
    Logs(Logs),       // 4 payload types
    Metrics(Metrics), // 19 payload types
    Traces(Traces),   // 8 payload types
}
```

Key methods:
- `set(payload_type, record_batch)` / `get(payload_type) -> Option<&RecordBatch>` / `remove(payload_type)`
- `allowed_payload_types() -> &'static [ArrowPayloadType]`
- `root_payload_type() -> ArrowPayloadType` / `root_record_batch() -> Option<&RecordBatch>`
- `num_items() -> usize` — logs: root rows, traces: root rows, metrics: sum of all data point table rows
- `encode_transport_optimized()` / `decode_transport_optimized_ids()`
- `signal_type() -> SignalType`

### `OtapBatchStore` trait

```rust
pub trait OtapBatchStore: Default + Clone {
    const TYPE_MASK: u64;      // bitmask of valid ArrowPayloadType values
    const COUNT: usize;        // number of payload slots
    type BatchArray;           // [Option<RecordBatch>; Self::COUNT]
    fn batches(&self) -> &[Option<RecordBatch>];
    fn batches_mut(&mut self) -> &mut [Option<RecordBatch>];
    fn set(&mut self, payload_type: ArrowPayloadType, record_batch: RecordBatch);
    fn get(&self, payload_type: ArrowPayloadType) -> Option<&RecordBatch>;
    fn allowed_payload_types() -> &'static [ArrowPayloadType];
    fn num_items(&self) -> usize;
    // ... encode/decode transport optimized methods
}
```

Implemented by `Logs` (COUNT=4), `Metrics` (COUNT=19), `Traces` (COUNT=8).

### `POSITION_LOOKUP`

A const array mapping `ArrowPayloadType` enum values to indices within each store's batch array. Used by `OtapBatchStore::set`/`get` to convert payload type → array index.

```rust
const POSITION_LOOKUP: &[usize] = &[
    UNUSED_INDEX, // Unknown = 0
    0,            // ResourceAttrs = 1
    1,            // ScopeAttrs = 2
    // ... (see otap.rs for full mapping)
];
```

### `ArrowPayloadType` enum

Generated from protobuf. Key values: `Logs=30`, `Spans=40`, `UnivariateMetrics=10`. See the `/otap` skill for the complete enum table.

---

## 4. Transform Operations

### Reindexing

`reindex::reindex<const N: usize>(batches: &mut [[Option<RecordBatch>; N]])` — walks the DAG via `payload_relations()`, assigns unique ID ranges across all batches for each payload type, and remaps child `parent_id` columns accordingly. Also removes transport-optimized encoding. Must be called before concatenation.

### Concatenation

`concatenate::concatenate<const N: usize>(items: &mut [[Option<RecordBatch>; N]]) -> Result<[Option<RecordBatch>; N]>` — for each payload slot, unifies schemas (selects common schema, estimates dictionary cardinality to pick optimal dict key size), then uses `BatchCoalescer` to merge the record batches. Precondition: batches must already be reindexed.

### Transport Encode/Decode

```rust
// Encode for wire transport (idempotent, cheap if already encoded)
pub fn apply_transport_optimized_encodings(
    payload_type: &ArrowPayloadType,
    record_batch: &RecordBatch,
) -> Result<(RecordBatch, Option<Vec<ParentIdRemapping>>)>

// Decode after receiving from wire
pub fn remove_transport_optimized_encodings(
    payload_type: ArrowPayloadType,
    record_batch: &RecordBatch,
) -> Result<RecordBatch>

// Remap child parent_ids after parent encoding changed IDs
pub fn remap_parent_ids(
    payload_type: &ArrowPayloadType,
    record_batch: &RecordBatch,
    remapping: &RemappedParentIds,
) -> Result<RecordBatch>
```

`Encoding` enum variants: `Delta`, `DeltaRemapped`, `AttributeQuasiDelta`, `ColumnarQuasiDelta(&[&str])`.

### Utility Functions

| Function | Description |
|----------|-------------|
| `take_record_batch_ranges(rb, ranges)` | Create new batch from specified row ranges (MutableArrayData) |
| `remove_record_batch_ranges(rb, ranges)` | Create new batch excluding specified row ranges |
| `sort_by_parent_then_id(rb)` | Sort by `parent_id` then `id` columns |
| `extract_id_column(rb, column_path)` | Get ID column by path (handles nested struct paths) |
| `replace_column(path, encoding, schema, columns, new_column)` | Replace column at path (handles nested structs) |
| `payload_relations(parent_type)` | Get primary ID info and FK relations for a payload type |
| `access_column(path, schema, columns)` | Access column by possibly-nested path (e.g. `"resource.id"`) |

---

## 5. ID Column Handling

### `id_column_dispatch!` macro

Canonical pattern for dispatching on the DataType of an ID column:

```rust
id_column_dispatch!(
    column,
    Native[T] => {
        // T is UInt16Type or UInt32Type
        let arr = column.as_primitive::<T>();
        // ...
    },
    Dictionary[KType, VType] => {
        // KType is UInt8Type or UInt16Type, VType is UInt16Type or UInt32Type
        let dict = column.as_dictionary::<KType>();
        // ...
    },
    _ => { return Err(Error::UnsupportedIdType { .. }) },
);
```

Supported combinations: Native U16/U32, Dict(U8,U16), Dict(U8,U32), Dict(U16,U32).

### `PayloadRelationInfo`

```rust
pub(crate) struct PayloadRelationInfo {
    pub primary_id: Option<PrimaryIdInfo>,  // name + IdColumnType (U16 or U32)
    pub relations: &'static [Relation],     // key_col + child_types
}
```

`payload_relations(ArrowPayloadType)` returns the parent-child DAG structure. Used by reindex and split.

### Accessing Nested ID Columns

Resource and scope IDs are nested in struct columns. Use path constants:

```rust
use crate::otap::transform::transport_optimize::{RESOURCE_ID_COL_PATH, SCOPE_ID_COL_PATH};
// RESOURCE_ID_COL_PATH = "resource.id"
// SCOPE_ID_COL_PATH = "scope.id"

// Access via util function:
let id_col = access_column(RESOURCE_ID_COL_PATH, &schema, columns);

// Or manually:
let struct_col = rb.column_by_name("resource")?.as_struct();
let id = struct_col.column_by_name("id")?;
```

---

## 6. Filtering

### Architecture

Filters use `BooleanArray` masks and parent-child propagation:
1. Build per-table filter masks from match properties
2. Propagate masks between parent and child tables (parent include → children include; child exclude → parent exclude)
3. Apply masks with `arrow::compute::filter_record_batch`

### Config Types

```rust
pub struct LogFilter {
    include: Option<LogMatchProperties>,
    exclude: Option<LogMatchProperties>,
    log_record: Vec<String>,  // field-level log record filters
}

pub struct TraceFilter {
    include: Option<TraceMatchProperties>,
    exclude: Option<TraceMatchProperties>,
}
```

`LogMatchProperties` fields: `match_type` (Strict/Regexp), `resource_attributes`, `record_attributes`, `severity_texts`, `severity_number`, `bodies`.

`TraceMatchProperties` fields: `match_type`, `resource_attributes`, `span_attributes`, `span_names`, `event_names`, `event_attributes`, `link_attributes`.

### Key Functions

```rust
// Returns (filtered records, items_before, items_after)
impl LogFilter {
    pub fn filter(&self, logs_payload: OtapArrowRecords) -> Result<(OtapArrowRecords, u64, u64)>
}

impl TraceFilter {
    pub fn filter(&self, traces_payload: OtapArrowRecords) -> Result<(OtapArrowRecords, u64, u64)>
}
```

### ID Set Optimization

For parent-child filter propagation, `RoaringBitmap` is used when the ID column is large and the matching set is small (thresholds: column length > 2000, matching percentage < 5%, ID set < 20). Otherwise falls back to direct `BooleanArray` construction.

---

## 7. Common Patterns

### Creating Records

```rust
use pdata::otap::{OtapArrowRecords, Logs, OtapBatchStore};
use pdata::proto::opentelemetry::arrow::v1::ArrowPayloadType;

let mut logs = Logs::new();
logs.set(ArrowPayloadType::Logs, log_record_batch);
logs.set(ArrowPayloadType::ResourceAttrs, resource_attrs_batch);
logs.set(ArrowPayloadType::LogAttrs, log_attrs_batch);
let records = OtapArrowRecords::Logs(logs);
```

### Transport Encode/Decode Lifecycle

```rust
// Before sending over gRPC:
records.encode_transport_optimized()?;
// serialize to Arrow IPC ...

// After receiving from gRPC:
// deserialize from Arrow IPC ...
records.decode_transport_optimized_ids()?;
```

### Batching

```rust
use pdata::otap::batching::make_item_batches;
use std::num::NonZeroU64;

let max = NonZeroU64::new(8192);
let output = make_item_batches(SignalType::Logs, max, input_records)?;
```

### Iterating Payload Batches

```rust
for payload_type in records.allowed_payload_types() {
    if let Some(rb) = records.get(*payload_type) {
        println!("{:?}: {} rows", payload_type, rb.num_rows());
    }
}
```

### Accessing ID Columns

```rust
use pdata::otap::transform::util::{extract_id_column, id_column_dispatch};

let id_col = extract_id_column(&rb, "id")?;
id_column_dispatch!(
    id_col,
    Native[T] => {
        let arr = id_col.as_primitive::<T>();
        // work with arr.values()
    },
    Dictionary[KType, VType] => {
        let dict = id_col.as_dictionary::<KType>();
        // work with dict.keys() and dict.values()
    },
    _ => { return Err(/* unsupported type */); },
);
```

### Schema ID Generation

```rust
use pdata::otap::schema::SchemaIdBuilder;

let mut builder = SchemaIdBuilder::new();  // reusable, pre-allocated
let id: &str = builder.build_id(&record_batch.schema());
// id is a deterministic string like "id:U16,name:Str,resource:{id:U16,schema_url:Str}"
```

### Column Name Constants

Key constants from `pdata::schema::consts`:

```rust
pub const ID: &str = "id";
pub const PARENT_ID: &str = "parent_id";
pub const RESOURCE: &str = "resource";
pub const SCOPE: &str = "scope";
pub const NAME: &str = "name";
pub const TRACE_ID: &str = "trace_id";
pub const SPAN_ID: &str = "span_id";
pub const METRIC_TYPE: &str = "metric_type";
pub const SEVERITY_NUMBER: &str = "severity_number";
pub const BODY: &str = "body";
pub const ATTRIBUTE_KEY: &str = "key";
pub const ATTRIBUTE_TYPE: &str = "type";
// ... see consts.rs for full list
```

Metadata constants: `consts::metadata::COLUMN_ENCODING`, `consts::metadata::encodings::{DELTA, PLAIN, QUASI_DELTA}`.

---

## 8. Conventions and Gotchas

- **POSITION_LOOKUP**: Always use `OtapBatchStore::set`/`get` rather than indexing batch arrays directly — the mapping from `ArrowPayloadType` to array index is non-trivial and signal-dependent.
- **Metrics `num_items`**: Counts the sum of rows across all four `*_DATA_POINTS` tables, NOT the rows in the root UNIVARIATE_METRICS table.
- **Reindex before concatenate**: `reindex()` MUST be called before `concatenate()` to ensure IDs are unique. The `groups.rs` concatenation pipeline does this automatically.
- **Transport encoding is idempotent**: `encode_transport_optimized()` checks field metadata and skips already-encoded columns. Safe to call unconditionally.
- **`id_column_dispatch!`**: The canonical macro for handling ID columns that may be UInt16, UInt32, or dictionary-encoded. Always use this rather than manual DataType matching.
- **`RecordsGroup` is `pub(crate)`**: Not part of the public API. External callers should use `make_item_batches()`.
- **`MultivariateMetrics`**: Defined in the enum (value 25) but not yet implemented in transforms.
- **`from_record_messages`**: Utility to build an `OtapBatchStore` from decoded `RecordMessage` vec (typically from Arrow IPC deserialization).
