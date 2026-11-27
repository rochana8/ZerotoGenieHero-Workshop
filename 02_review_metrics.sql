-- Lab 1, file 2 of 2: review KPIs. Paste into the SQL Editor and click Run.

CREATE OR REPLACE VIEW workspace.genie_lab.review_metrics
WITH METRICS
LANGUAGE YAML
AS $$
version: 1.1
comment: "Guest review KPIs. Deleted reviews are excluded."
source: samples.wanderbricks.reviews
filter: is_deleted = false
joins:
  - name: property
    source: samples.wanderbricks.properties
    'on': source.property_id = property.property_id
    joins:
      - name: destination
        source: samples.wanderbricks.destinations
        'on': property.destination_id = destination.destination_id
dimensions:
  - name: Review Month
    expr: DATE_TRUNC('MONTH', source.created_at)
  - name: Property Type
    expr: property.property_type
  - name: Destination
    expr: property.destination.destination
    synonyms: ["city", "location"]
  - name: Destination Country
    expr: property.destination.country
    synonyms: ["country", "market"]
measures:
  - name: Reviews
    expr: COUNT(1)
  - name: Average Rating
    expr: AVG(source.rating)
    synonyms: ["rating", "score", "stars"]
  - name: Low Rating Share
    expr: COUNT(1) FILTER (WHERE source.rating <= 2) / COUNT(1)
    comment: "Share of reviews rated 2 stars or lower"
    synonyms: ["bad reviews", "detractors"]
    format: { type: percentage }
$$;
