# <YYYY-MM> impact assessment

**Window:** YYYY-MM-DD → YYYY-MM-DD · **Assessed:** YYYY-MM-DD · **Prior entry:** <link>
**Evidence tags:** [D] git/GitLab/Datadog · [S] Slack/user-corroborated · [Needs input] unanswered

## Headline (one paragraph: what shipped and what it changed)

## Shipped this month

| Date | Delivery | Repo / MR / release | Evidence |
|---|---|---|---|

(Raw material: `impact/<YYYY-MM>-git.md` subjects + MR titles; GitLab releases; note which MRs were *merged to mainline* vs still in flight.)

## Metrics delta (vs prior entry)

(Rows per the local cookbook's monthly query set — `~/dev/resume/impact/datadog-queries.md`. Example shape:)

| Metric | Prior | This month | Δ | Direction |
|---|---|---|---|---|
| <primary service: production traffic> | | | | |
| <primary service: 5xx volume / share> | | | | |
| <primary service: latency p95> | | | | |
| <secondary service: volume> | | | | |
| <secondary service: error ratio> | | | | |

## Achievements worth keeping (resume-grade, with receipts)

## Cautions status (check against master-source §11)

- [ ] <caution items whose status may have changed this month> ______

## New caveats / corrections discovered this month

## Open questions for next month

## Raw evidence files

- `~/dev/resume/impact/<YYYY-MM>-git.md` (collect-git.sh output)
- (Datadog query outputs pasted/summarized above with query strings)
