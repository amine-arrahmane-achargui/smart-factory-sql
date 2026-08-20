# Industrial SQL Challenges

Use the public examples and sample data to start investigating the Smart Factory.

The complete dataset is intentionally not included in this repository. The full commercial package contains the complete PostgreSQL database, all CSV records, generator SQL and documentation.

## Challenge 1 — Find the strongest production line

Identify the production line with the highest actual production quantity.

Consider:
- actual quantity;
- planned quantity;
- fulfillment rate.

## Challenge 2 — Find the weakest fulfillment rate

Calculate the fulfillment rate for each production line and identify the weakest one.

## Challenge 3 — Investigate rejects

Calculate the reject rate by production line.

Which line deserves further investigation?

## Challenge 4 — Find the machine with the most downtime

Aggregate downtime events by machine and calculate total downtime in minutes.

Separate planned and unplanned downtime.

## Challenge 5 — Investigate machine performance

Calculate production quantity and average cycle time by machine and month.

Look for changes over time.

## Challenge 6 — Investigate quality

Calculate inspection volume, passed quantity, failed quantity and defect rate by machine.

Which machines require attention?

## Challenge 7 — Investigate energy consumption

Calculate total energy consumption and average power by machine.

Then compare energy consumption with production output.

## Challenge 8 — Connect production and quality

Join production orders with quality inspections.

Look for relationships between production volume and failed inspections.

## Challenge 9 — Investigate maintenance

Analyse maintenance interventions by machine.

Calculate maintenance cost from parts and labor costs.

## Challenge 10 — Build a root-cause investigation

Choose an underperforming production line and investigate it across multiple domains:

```text
Production
   ↓
Machines
   ↓
Downtime ── Quality ── Energy
   ↓
Maintenance
   ↓
Root-cause hypothesis
```

Do not jump directly to a conclusion. Build the evidence with SQL.

## Suggested SQL skills

Try to solve the challenges using:

- `JOIN`
- `GROUP BY`
- aggregate functions
- `CASE`
- date/time functions
- subqueries
- CTEs
- window functions
- PostgreSQL-specific features

**The objective is not to memorize queries. It is to learn how to use SQL to investigate an industrial problem.**
