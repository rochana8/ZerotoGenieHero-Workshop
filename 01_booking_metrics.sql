-- Lab 1, file 1 of 2: booking KPIs. Paste into the SQL Editor and click Run.
CREATE SCHEMA IF NOT EXISTS workspace.genie_lab;

CREATE OR REPLACE VIEW workspace.genie_lab.booking_metrics
WITH METRICS
LANGUAGE YAML
AS $$
version: 1.1
comment: "Wanderbricks booking KPIs. One row in the source = one booking. Revenue counts only confirmed + completed bookings."
source: samples.wanderbricks.bookings
joins:
  - name: property
    source: samples.wanderbricks.properties
    'on': source.property_id = property.property_id
    joins:
      - name: destination
        source: samples.wanderbricks.destinations
        'on': property.destination_id = destination.destination_id
      - name: host
        source: samples.wanderbricks.hosts
        'on': property.host_id = host.host_id
  - name: guest
    source: samples.wanderbricks.users
    'on': source.user_id = guest.user_id
dimensions:
  - name: Check-in Month
    expr: DATE_TRUNC('MONTH', source.check_in)
    comment: "Month the stay starts"
    synonyms: ["stay month", "travel month"]
  - name: Booking Status
    expr: source.status
    comment: "pending, confirmed, completed or cancelled"
  - name: Property Type
    expr: property.property_type
    synonyms: ["listing type", "category"]
  - name: Destination
    expr: property.destination.destination
    synonyms: ["city", "location"]
  - name: Destination Country
    expr: property.destination.country
    synonyms: ["country", "market"]
  - name: Host Verified
    expr: property.host.is_verified
  - name: Guest Type
    expr: guest.user_type
    comment: "individual or business traveller"
    synonyms: ["customer type", "segment"]
measures:
  - name: Bookings
    expr: COUNT(1)
    synonyms: ["number of bookings", "reservations"]
  - name: Gross Booking Value
    expr: SUM(source.total_amount)
    comment: "All bookings incl. pending and cancelled"
    synonyms: ["GBV"]
    format: { type: currency, currency_code: USD }
  - name: Revenue
    expr: SUM(source.total_amount) FILTER (WHERE source.status IN ('confirmed','completed'))
    comment: "Realised revenue = confirmed + completed bookings only"
    synonyms: ["sales", "income", "realised revenue"]
    format: { type: currency, currency_code: USD }
  - name: Cancellation Rate
    expr: COUNT(1) FILTER (WHERE source.status = 'cancelled') / COUNT(1)
    synonyms: ["cancel rate"]
    format: { type: percentage }
  - name: Room Nights
    expr: SUM(DATEDIFF(source.check_out, source.check_in)) FILTER (WHERE source.status IN ('confirmed','completed'))
    synonyms: ["nights", "nights stayed"]
  - name: Average Daily Rate
    expr: MEASURE(`Revenue`) / MEASURE(`Room Nights`)
    comment: "Revenue per room night (ADR)"
    synonyms: ["ADR", "nightly rate"]
    format: { type: currency, currency_code: USD }
  - name: Unique Guests
    expr: COUNT(DISTINCT source.user_id)
    synonyms: ["customers", "travellers"]
$$;

-- Check: should return 14044896
SELECT round(MEASURE(Revenue)) AS total_revenue FROM workspace.genie_lab.booking_metrics;
