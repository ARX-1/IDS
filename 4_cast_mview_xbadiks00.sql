-- ============================================================
-- IDS projekt – 4. cast: Internetovy obchod
-- Tento soubor spousti druhy clen tymu pod uctem xbadiks00.
-- Pred spustenim musi byt pod uctem xuchytj00 spusten hlavni skript
-- (4_cast_main_xuchytj00.sql), ktery vytvori tabulky a udeli prava
-- pomoci GRANT.
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- MATERIALIZOVANY POHLED: MV_CATEGORY_SALES
--
-- POZOR:
-- Tuto cast spousti druhy clen tymu pod svym Oracle uctem xbadiks00.
-- Pred spustenim musi prvni clen tymu xuchytj00 udelit prava pomoci GRANT prikazu
-- (viz sekce GRANT v souboru 4_cast_main_xuchytj00.sql).
--
-- Materializovany pohled patri druhemu clenovi tymu a pouziva tabulky
-- prvniho clena pres prefix schematu xuchytj00.
-- Tato sekce se tedy nespousti pod uctem xuchytj00.
--
-- Pohled predpocita celkovy pocet prodanych polozek a trzby podle kategorie.
-- Slouzi pro rychle reporty bez nutnosti joinovat zdrojove tabulky pri kazdem dotazu.
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW MV_CATEGORY_SALES';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE MATERIALIZED VIEW MV_CATEGORY_SALES
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    pc.category_name,
    SUM(oi.quantity)                    AS total_items_sold,
    SUM(oi.quantity * oi.selling_price) AS total_revenue
FROM xuchytj00.ORDER_ITEM       oi
JOIN xuchytj00.PRODUCT_table    p  ON oi.ID_product  = p.ID_product
JOIN xuchytj00.PRODUCT_CATEGORY pc ON p.ID_category  = pc.ID_category
GROUP BY pc.category_name;

-- Ukázka: výpis pohledu po vytvoření
SELECT * FROM MV_CATEGORY_SALES ORDER BY total_revenue DESC;

-- Ruční refresh pohledu (přenačtení aktuálních dat ze zdrojových tabulek)
EXEC DBMS_MVIEW.REFRESH('MV_CATEGORY_SALES');

-- Výpis po refreshi
SELECT * FROM MV_CATEGORY_SALES ORDER BY total_revenue DESC;
