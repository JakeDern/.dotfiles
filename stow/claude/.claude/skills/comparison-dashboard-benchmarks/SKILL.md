---
name: comparison-dashboard-benchmarks
description: Step-by-step guide for administering the otel-arrow comparison_dashboard benchmark suite runs (logs / metrics / traces across DFE and OTC, multiple protocols and compressions). Use when the user asks to run, re-run, validate, or refresh comparison-dashboard suites; or to investigate run hangs, anomalies, or missing data in `.site/data/suite/`.
user-invocable: true
---

# Comparison Dashboard Benchmark Administration

A repeatable procedure for running the otel-arrow comparison_dashboard benchmark
suites end-to-end. Follow the steps in order. The pitfalls and workarounds in
the "Known traps" section are load-bearing — read them before starting and
again whenever something hangs or returns wrong-looking data.

All paths are relative to `tools/comparison_dashboard/` unless stated.

---

## 1. Inventory

The dashboard ships 48 suites in `manifest.yaml`:

| Binary | Signal  | Protocols                        | Compressions       | Count |
|--------|---------|----------------------------------|--------------------|-------|
| dfe    | logs    | otap, otlp, otlphttp             | none, gzip, zstd   | 9     |
| dfe    | metrics | otap, otlp, otlphttp             | none, gzip, zstd   | 9     |
| dfe    | traces  | otap, otlp, otlphttp             | none, gzip, zstd   | 9     |
| otc    | logs    | otap, otlp (none/gzip/zstd), otlphttp (none only) | -- | 7 |
| otc    | metrics | same shape as otc logs           | --                 | 7     |
| otc    | traces  | same shape as otc logs           | --                 | 7     |

Each suite runs 7 rates: `100k 200k 300k 400k 600k 800k 1000k` logs/sec
(or metrics/sec or spans/sec).

The default observation interval is 20s; the user may ask for 60s for
more stable numbers. Pass `--observation-interval 60` to lengthen.

---

## 2. Environment prerequisites

Before the first run, verify these once:

```bash
cd tools/comparison_dashboard
PY=/home/jakedern/repos/otel-arrow/.venv/bin/python

# 1. Python deps include py-cpuinfo (publishing step needs it).
$PY -c "import yaml, cpuinfo" || $PY -m pip install py-cpuinfo

# 2. Both container images must be present (do NOT pull blindly inside the
#    sandbox; docker socket access is blocked there). If missing, pull
#    with `dangerouslyDisableSandbox`.
docker image ls --format '{{.Repository}}:{{.Tag}}' | grep -E 'df_engine:latest|otel/opentelemetry-collector-contrib:latest'

# 3. df_engine:latest image rebuilt AFTER any DFE Rust changes you care
#    about — check Created against the branch's relevant commit:
docker inspect df_engine:latest --format 'Created: {{.Created}}'
git log --oneline -5

# 4. Manifest is clean.
$PY dashboard.py validate
```

All Bash commands that touch docker (run / image ls / rm) must be issued
with `dangerouslyDisableSandbox: true` — the sandbox blocks the docker
socket and you will see `permission denied while trying to connect to the
docker API at unix:///var/run/docker.sock`. That is *not* a real
permission problem; it is the sandbox. Disable it for docker commands.

---

## 3. Helper scripts (set up once per session)

Two helpers live alongside this skill in `scripts/`. Copy them into
`tools/comparison_dashboard/.run-logs/` at the start of each session so
they sit next to the suite logs they'll produce. (`.run-logs/` may have
been cleaned between sessions — recreate if missing.)

```bash
SKILL_DIR="$HOME/.claude/skills/comparison-dashboard-benchmarks"
mkdir -p .run-logs
cp "$SKILL_DIR/scripts/run-with-watch.sh" .run-logs/
cp "$SKILL_DIR/scripts/analyze.py" .run-logs/
cp "$SKILL_DIR/scripts/verify-completeness.sh" .run-logs/
chmod +x .run-logs/run-with-watch.sh .run-logs/verify-completeness.sh
```

What each one does:

- **`run-with-watch.sh <suite> [args...]`** — Launches
  `python -u dashboard.py run <suite> [args...]`, monitors the log file
  mtime, and SIGTERMs (then SIGKILLs) the orchestrator if it goes silent
  for 5 minutes (default `STALL_LIMIT=300`) or hits 40-minute wall clock
  (default `MAX_RUNTIME=2400`). On kill it also tears down the
  load-generator / backend-service / go-collector containers so the next
  run starts clean. Exit 124 means it killed something; that is the
  signal to retry the rate that didn't publish.
- **`analyze.py <slug>`** — Reads every `.site/data/suite/<slug>/<rate>/metrics.json`
  and reports anomalies: dropped% > 5, received-rate outside ±5% of nominal,
  or missing data. Exit 1 if any anomalies present.
- **`verify-completeness.sh [expected_count]`** — Final sweep that confirms
  every suite × rate has a `metrics.json` with `expected_count` (default 10)
  metrics. The 10-metric set is: drop%, CPU avg/max, RAM avg/max,
  produced rate, received rate, test_duration, network TX/RX. OTC suites
  publish only 4 of these unless the report fix from §6.1 is in place.

---

## 4. The core loop (one suite at a time)

**The user's standing instruction is "one suite at a time, analyze, retry,
move on." Do not batch-run multiple suites in a single command.** When
something breaks you want it caught before five more suites are corrupted.

For each suite in this order: logs → metrics → traces. Within each
signal, do DFE first then OTC, and within DFE do OTAP → OTLP → OTLP-HTTP,
each across none → gzip → zstd. Maintain a running counter (`N/48`) in
your messages to the user so they can see remaining work.

### 4a. DFE suites and non-OTAP OTC suites (no known hang)

These can run as two stages: low rates (100k–400k) then high rates
(600k–1000k). The user wants half-or-less per invocation so a stall doesn't
cost the entire suite.

```bash
SUITE=suites/dfe/dfe-logs-otap-none-baseline.yaml   # example
SLUG=dfe_logs_otap_none_baseline                    # from `grep slug: $SUITE`
OBS=60   # or 20 if user wants the default

MAX_RUNTIME=1800 .run-logs/run-with-watch.sh "$SUITE" --observation-interval $OBS \
  --tests 100k,200k,300k,400k
MAX_RUNTIME=1800 .run-logs/run-with-watch.sh "$SUITE" --observation-interval $OBS \
  --tests 600k,800k,1000k
$PY .run-logs/analyze.py "$SLUG"
echo "PROGRESS: N/48"
```

### 4b. OTC OTAP suites (known to hang at rate transitions)

The OTC orchestrator hangs reliably on rate-to-rate transitions when the
OTC OTAP receiver hits backpressure. Symptoms: dashboard.py log goes
silent after `Run Report` for the previous test, container shows
`arrow stream error: transport is closing`. To work around it, split the
top 3 rates into individual invocations:

```bash
MAX_RUNTIME=1800 .run-logs/run-with-watch.sh "$SUITE" --observation-interval $OBS \
  --tests 100k,200k,300k,400k
MAX_RUNTIME=1800 .run-logs/run-with-watch.sh "$SUITE" --observation-interval $OBS --tests 600k
MAX_RUNTIME=1800 .run-logs/run-with-watch.sh "$SUITE" --observation-interval $OBS --tests 800k
MAX_RUNTIME=1800 .run-logs/run-with-watch.sh "$SUITE" --observation-interval $OBS --tests 1000k
$PY .run-logs/analyze.py "$SLUG"
```

Even with this split a single rate occasionally stalls. If a stage exits
124 (STALLED) or the rate's `metrics.json` is missing/short, retry just
that one rate after manually clearing stray containers:

```bash
docker rm -f load-generator backend-service go-collector 2>/dev/null
MAX_RUNTIME=1800 .run-logs/run-with-watch.sh "$SUITE" --observation-interval $OBS --tests 800k
```

Two retries is usually enough; if it stalls three times in a row, note
it in the summary and move on.

### 4c. Interpreting anomalies

`analyze.py` flags two classes you should classify before acting:

1. **Window error** — received rate is between 95% and ~94% of nominal at
   a single low/mid rate, or dropped% is just over 5% (e.g. 5.2%) while
   neighboring rates are clean. This is measurement noise from the
   observation-window boundaries. Retry the single rate; usually clears.
2. **Real saturation** — received-rate plateaus across multiple high
   rates and CPU is pinned at ~100% (DFE) or you see arrow-stream/dropped
   errors in container logs (OTC). Do *not* retry. Note in the summary
   and move on. The user said "poor performance is not an anomaly."

Move on quickly if triage isn't obvious within a couple of attempts;
the user prefers progress to deep dives.

---

## 5. End of run

Once all suites are at status OK or accepted-as-saturated:

```bash
.run-logs/verify-completeness.sh 10     # confirm 336/336 cells with 10 metrics
$PY dashboard.py build                  # regenerates .site/compare/*
```

Then write a summary at `.run-logs/SUMMARY.md` that includes:

- Counts: OK / saturation / unresolved.
- Per-signal throughput ceilings observed for each (binary, protocol,
  compression) combo.
- Any anomalies still outstanding, with file paths to the relevant raw
  logs (`.run-logs/<suite>.log`) and staging data
  (`.data/<slug>/<timestamp>/`).
- Whatever working theories you have about hangs.

If the user has also asked for cross-binary comparisons, add or update
`comparisons/dfe_vs_otc_<signal>.yaml` (one per signal); see existing
files for shape.

---

## 6. Known traps — read before starting and whenever something is weird

### 6.1. OTC suites publish only 4 metrics if the report templates are unpatched

The shared report YAMLs at
`tools/pipeline_perf_test/test_suites/comparison_dashboard/reports/report_{logs,metrics,traces}.yaml`
historically hard-code `component_name IN ('df-engine')` on the CPU /
RAM / network queries. The OTC container is named `go-collector`, so
those rows silently drop and every OTC suite publishes only 4 metrics
per rate (drop%, produced rate, received rate, test_duration) instead
of 10.

Verify with `verify-completeness.sh 10`. If OTC suites come up
"SHORT 4 metrics (expected 10)", apply the union fix:

```bash
cd tools/pipeline_perf_test/test_suites/comparison_dashboard/reports/
sed -i "s/IN ('df-engine')/IN ('df-engine', 'go-collector')/g" \
    report_logs.yaml report_metrics.yaml report_traces.yaml
```

Then re-run every OTC suite. The DFE suites are unaffected.

### 6.2. Python stdout buffering can false-positive the stall watcher

If you remove `-u` from the `python` invocation in `run-with-watch.sh`,
or run dashboard.py directly without `-u`, the orchestrator's output
will buffer and the watcher (or you) will think it's stalled when it
isn't. Always use `python -u dashboard.py run …`.

### 6.3. DFE metrics produced-rate stuck at ~100k regardless of nominal

This bug existed before commit `bdb39841a` (PR #2956:
"fix(admin): group Prometheus metrics contiguously per spec"). If you see
`metrics_produced_rate ≈ 100k` while `metrics_received_rate ≈ nominal`
and `dropped_metrics_percentage` is a huge negative number, the running
`df_engine:latest` image does NOT contain that PR. Check:

```bash
git log --oneline --grep='2956'
docker inspect df_engine:latest --format 'Created: {{.Created}}'
```

If the image is older than the commit, the image needs rebuilding (not
something this skill does — flag to the user). With the fix in place,
produced ≈ received within a few % at any rate.

### 6.4. `.site/data/suite/<slug>/<rate>/metrics.json` may lag the actual run

Publishing only happens at the end of a `dashboard.py run` invocation.
If a run stalls partway, the `.site` view stays stale from a previous
run. When verifying a fix or a re-run, prefer the raw sql_report under
the most-recent staging dir before trusting `.site`:

```bash
latest=$(ls -td .data/<slug>/*/ | head -1)
cat $latest/tests/<rate>/sql_report-*.json | python -m json.tool
```

### 6.5. OTC loadgen `produced_rate=0` and `dropped_pct=None` under backpressure

At very high rates the OTC OTAP loadgen counter goes to 0 while the
backend continues receiving. This makes `dropped_logs_percentage`
report `None` (the analyzer tolerates that). It's a loadgen counter
artifact, not a real ingestion gap; document it but don't retry.

### 6.6. Re-using stale data across runs is the easiest way to confuse yourself

When the user says "do a clean re-run", actually wipe both `.data/<slug>`
and `.site/data/suite/<slug>` before re-running. Otherwise the analyzer
will read whatever the prior incomplete run left behind and report
either nothing or last week's numbers.

```bash
rm -rf .data/<slug> .site/data/suite/<slug>
```

### 6.7. Manifest source of truth

`dashboard.py run` only accepts suites that are listed in `manifest.yaml`,
even if the YAML file exists on disk. If a suite file doesn't run, check
the manifest first.

---

## 7. Reporting progress to the user

The user has explicitly asked for a running `N/48` counter so they can
see remaining work. After each suite completes (or is accepted as
saturated), include a line like `PROGRESS: 17/48` in your message. Also
call out anything you skipped or accepted-as-known.

Avoid narrating each `analyze.py` line; summarize each suite as one of:

- `[OK]` — clean
- `[saturation]` — high-rate anomalies are real CPU-bound saturation
- `[retry]` — single rate retried due to window-error or stall
- `[skip]` — gave up after repeated stalls, documented in SUMMARY.md
