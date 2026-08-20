-- ============================================================
-- SMART FACTORY MANUFACTURING DATASET v0.1
-- Starter SQL Queries
-- PostgreSQL 17
-- ============================================================

SET search_path TO smart_factory;


-- ============================================================
-- 1. PRODUCTION BY LINE
-- ============================================================

SELECT
    pl.line_code,
    pl.line_name,
    COUNT(po.order_id) AS production_orders,
    SUM(po.planned_quantity) AS planned_quantity,
    SUM(po.actual_quantity) AS actual_quantity,
    SUM(po.rejected_quantity) AS rejected_quantity
FROM production_orders po
JOIN production_lines pl
    ON pl.line_id = po.line_id
GROUP BY
    pl.line_code,
    pl.line_name
ORDER BY actual_quantity DESC;


-- ============================================================
-- 2. PRODUCTION FULFILLMENT RATE BY LINE
-- ============================================================

SELECT
    pl.line_code,
    pl.line_name,
    SUM(po.planned_quantity) AS planned_quantity,
    SUM(po.actual_quantity) AS actual_quantity,
    ROUND(
        100.0 * SUM(po.actual_quantity)
        / NULLIF(SUM(po.planned_quantity), 0),
        2
    ) AS fulfillment_rate_pct
FROM production_orders po
JOIN production_lines pl
    ON pl.line_id = po.line_id
GROUP BY
    pl.line_code,
    pl.line_name
ORDER BY fulfillment_rate_pct DESC;


-- ============================================================
-- 3. REJECT RATE BY LINE
-- ============================================================

SELECT
    pl.line_code,
    pl.line_name,
    SUM(po.actual_quantity) AS actual_quantity,
    SUM(po.rejected_quantity) AS rejected_quantity,
    ROUND(
        100.0 * SUM(po.rejected_quantity)
        / NULLIF(SUM(po.actual_quantity), 0),
        2
    ) AS reject_rate_pct
FROM production_orders po
JOIN production_lines pl
    ON pl.line_id = po.line_id
GROUP BY
    pl.line_code,
    pl.line_name
ORDER BY reject_rate_pct DESC;


-- ============================================================
-- 4. PRODUCTION BY PRODUCT
-- ============================================================

SELECT
    p.product_code,
    p.product_name,
    COUNT(po.order_id) AS production_orders,
    SUM(po.actual_quantity) AS actual_quantity,
    SUM(po.rejected_quantity) AS rejected_quantity
FROM production_orders po
JOIN products p
    ON p.product_id = po.product_id
GROUP BY
    p.product_code,
    p.product_name
ORDER BY actual_quantity DESC;


-- ============================================================
-- 5. DOWNTIME BY MACHINE
-- ============================================================

SELECT
    m.machine_code,
    m.machine_name,
    COUNT(d.downtime_id) AS downtime_events,
    ROUND(
        SUM(
            EXTRACT(
                EPOCH FROM (d.end_time - d.start_time)
            ) / 60.0
        )::numeric,
        2
    ) AS downtime_minutes
FROM machines m
LEFT JOIN downtime_events d
    ON d.machine_id = m.machine_id
GROUP BY
    m.machine_code,
    m.machine_name
ORDER BY downtime_minutes DESC;


-- ============================================================
-- 6. UNPLANNED DOWNTIME BY MACHINE
-- ============================================================

SELECT
    m.machine_code,
    m.machine_name,
    COUNT(d.downtime_id) AS unplanned_events,
    ROUND(
        SUM(
            EXTRACT(
                EPOCH FROM (d.end_time - d.start_time)
            ) / 60.0
        )::numeric,
        2
    ) AS unplanned_downtime_minutes
FROM machines m
JOIN downtime_events d
    ON d.machine_id = m.machine_id
WHERE d.planned = FALSE
GROUP BY
    m.machine_code,
    m.machine_name
ORDER BY unplanned_downtime_minutes DESC;


-- ============================================================
-- 7. MONTHLY PERFORMANCE OF MACHINE M005
-- ============================================================

SELECT *
FROM v_machine_monthly_performance
WHERE machine_code = 'M005'
ORDER BY month;


-- ============================================================
-- 8. MACHINE PERFORMANCE BY MONTH
-- ============================================================

SELECT
    DATE_TRUNC(
        'month',
        pe.event_timestamp
    )::date AS month,
    m.machine_code,
    m.machine_name,
    COUNT(*) AS production_events,
    SUM(pe.quantity_produced) AS quantity_produced,
    SUM(pe.quantity_rejected) AS quantity_rejected,
    ROUND(
        AVG(pe.cycle_time_sec),
        2
    ) AS avg_cycle_time_sec
FROM production_events pe
JOIN machines m
    ON m.machine_id = pe.machine_id
GROUP BY
    DATE_TRUNC('month', pe.event_timestamp)::date,
    m.machine_code,
    m.machine_name
ORDER BY
    month,
    m.machine_code;


-- ============================================================
-- 9. QUALITY BY LINE
-- ============================================================

SELECT *
FROM v_quality_by_line
ORDER BY defect_rate_pct DESC;


-- ============================================================
-- 10. QUALITY BY MACHINE
-- ============================================================

SELECT
    m.machine_code,
    m.machine_name,
    SUM(q.inspected_quantity) AS inspected_quantity,
    SUM(q.passed_quantity) AS passed_quantity,
    SUM(q.failed_quantity) AS failed_quantity,
    ROUND(
        100.0 * SUM(q.failed_quantity)
        / NULLIF(SUM(q.inspected_quantity), 0),
        2
    ) AS defect_rate_pct
FROM quality_inspections q
JOIN machines m
    ON m.machine_id = q.machine_id
GROUP BY
    m.machine_code,
    m.machine_name
ORDER BY defect_rate_pct DESC;


-- ============================================================
-- 11. ENERGY CONSUMPTION BY MACHINE
-- ============================================================

SELECT
    m.machine_code,
    m.machine_name,
    ROUND(
        SUM(e.energy_kwh)::numeric,
        2
    ) AS total_energy_kwh,
    ROUND(
        AVG(e.power_kw)::numeric,
        2
    ) AS avg_power_kw
FROM energy_consumption e
JOIN machines m
    ON m.machine_id = e.machine_id
GROUP BY
    m.machine_code,
    m.machine_name
ORDER BY total_energy_kwh DESC;


-- ============================================================
-- 12. MONTHLY ENERGY CONSUMPTION
-- ============================================================

SELECT
    DATE_TRUNC(
        'month',
        e.measurement_timestamp
    )::date AS month,
    m.machine_code,
    ROUND(
        SUM(e.energy_kwh)::numeric,
        2
    ) AS total_energy_kwh,
    ROUND(
        AVG(e.power_kw)::numeric,
        2
    ) AS avg_power_kw
FROM energy_consumption e
JOIN machines m
    ON m.machine_id = e.machine_id
GROUP BY
    DATE_TRUNC(
        'month',
        e.measurement_timestamp
    )::date,
    m.machine_code
ORDER BY
    month,
    m.machine_code;


-- ============================================================
-- 13. M005 MAINTENANCE HISTORY
-- ============================================================

SELECT
    m.machine_code,
    m.machine_name,
    me.maintenance_type,
    me.start_time,
    me.end_time,
    me.description,
    me.parts_cost,
    me.labor_cost,
    me.parts_cost + me.labor_cost AS total_cost
FROM maintenance_events me
JOIN machines m
    ON m.machine_id = me.machine_id
WHERE m.machine_code = 'M005'
ORDER BY me.start_time;


-- ============================================================
-- 14. MAINTENANCE COST BY MACHINE
-- ============================================================

SELECT
    m.machine_code,
    m.machine_name,
    COUNT(me.maintenance_id) AS maintenance_events,
    ROUND(
        SUM(me.parts_cost + me.labor_cost)::numeric,
        2
    ) AS total_maintenance_cost
FROM maintenance_events me
JOIN machines m
    ON m.machine_id = me.machine_id
GROUP BY
    m.machine_code,
    m.machine_name
ORDER BY total_maintenance_cost DESC;


-- ============================================================
-- 15. INDUSTRIAL INVESTIGATION — M005
-- ============================================================

SELECT
    DATE_TRUNC(
        'month',
        pe.event_timestamp
    )::date AS month,
    m.machine_code,
    SUM(pe.quantity_produced) AS quantity_produced,
    SUM(pe.quantity_rejected) AS quantity_rejected,
    ROUND(
        AVG(pe.cycle_time_sec),
        2
    ) AS avg_cycle_time_sec,
    ROUND(
        100.0 * SUM(pe.quantity_rejected)
        / NULLIF(SUM(pe.quantity_produced), 0),
        2
    ) AS reject_rate_pct
FROM production_events pe
JOIN machines m
    ON m.machine_id = pe.machine_id
WHERE m.machine_code = 'M005'
GROUP BY
    DATE_TRUNC(
        'month',
        pe.event_timestamp
    )::date,
    m.machine_code
ORDER BY month;
