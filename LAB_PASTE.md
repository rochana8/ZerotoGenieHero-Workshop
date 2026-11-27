# Genie Workshop lab pack: paste-ready text

Replace `workspace.genie_lab` if you used a different catalog or schema.

## Lab 2: test questions (ask these before and after Lab 3)

1. What was revenue by country in 2025?
2. Which destination has the worst guest ratings?
3. What's our busiest season?
4. What is our ADR for ski resorts vs urban year-round properties?
5. Who are our top 5 hosts by revenue?
6. What was revenue in 2026?

## Lab 3: instructions (paste into the agent's Instructions)

```
Revenue always means the Revenue measure (confirmed + completed bookings only). Never use Gross Booking Value unless the user says GBV or gross.
When ranking destinations or property types by rating, only include those with at least 30 reviews, and show the review count.
'Season' or 'busiest time' means Check-in Month, ranked by Bookings.
Data covers check-ins from Dec 2022 to Jul 2025. If a question asks about a later period, say so.
Format money as USD with no decimals and rates as percentages with 1 decimal.
```

## Lab 3: example SQL

Question: What is ADR by property type?

```sql
SELECT `Property Type`, MEASURE(`Average Daily Rate`) AS adr, MEASURE(`Room Nights`) AS room_nights
FROM workspace.genie_lab.booking_metrics
GROUP BY ALL
ORDER BY adr DESC
```

## Lab 4: benchmarks (question + SQL answer)

1. **What was revenue by destination country in 2025?**

```sql
SELECT `Destination Country`, MEASURE(`Revenue`) AS revenue FROM workspace.genie_lab.booking_metrics WHERE `Check-in Month` >= DATE'2025-01-01' AND `Check-in Month` < DATE'2026-01-01' GROUP BY ALL ORDER BY revenue DESC
```

2. **What is the cancellation rate by property type?**

```sql
SELECT `Property Type`, MEASURE(`Cancellation Rate`) AS cancellation_rate FROM workspace.genie_lab.booking_metrics GROUP BY ALL ORDER BY cancellation_rate DESC
```

3. **What is the average daily rate by property type?**

```sql
SELECT `Property Type`, MEASURE(`Average Daily Rate`) AS adr FROM workspace.genie_lab.booking_metrics GROUP BY ALL ORDER BY adr DESC
```

4. **What are the top 5 destinations by number of bookings?**

```sql
SELECT `Destination`, MEASURE(`Bookings`) AS bookings FROM workspace.genie_lab.booking_metrics GROUP BY ALL ORDER BY bookings DESC LIMIT 5
```

5. **Which 5 destinations have the lowest average rating, counting only destinations with at least 30 reviews?**

```sql
SELECT `Destination`, MEASURE(`Average Rating`) AS avg_rating, MEASURE(`Reviews`) AS reviews FROM workspace.genie_lab.review_metrics GROUP BY ALL HAVING reviews >= 30 ORDER BY avg_rating ASC LIMIT 5
```

6. **How many bookings were there each month in 2025?**

```sql
SELECT `Check-in Month`, MEASURE(`Bookings`) AS bookings FROM workspace.genie_lab.booking_metrics WHERE `Check-in Month` >= DATE'2025-01-01' AND `Check-in Month` < DATE'2026-01-01' GROUP BY ALL ORDER BY `Check-in Month`
```

## Expected answers (measured 25 Nov 2026 on a 2X-Small warehouse)

| Question | Before instructions | After instructions |
|---|---|---|
| Revenue by country 2025 | Spain $2,020,037 first | Same, USD formatting |
| Worst-rated destination | Aspen, 2.3 (4 reviews) | Banff, 2.79 (70 reviews) |
| Busiest season | Clarifying question or invented seasons | July 2025, 25,708 bookings |
| Top 5 hosts by revenue | Answers verified vs unverified hosts | Says there is no host field |
| Revenue in 2026 | 0 | 0 (instruction not followed: known stump) |
| Total revenue, all time | $14,044,896 | |

## Lab 3: Host Name dimension

Add under `dimensions:` in 01_booking_metrics.sql, then re-run the file. After that, question 5 should list host names:

```yaml
  - name: Host Name
    expr: property.host.name
    synonyms: ["host"]
```
