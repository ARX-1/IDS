# Poznamky k obhajobe (4. cast)

## 1) EXPLAIN PLAN a indexy
- Pouzity dotaz spaja PRODUCT_CATEGORY -> PRODUCT_table -> ORDER_ITEM, agreguje SUM(quantity * selling_price) a COUNT, a GROUP BY category_name.
- Pred indexami: Oracle pri malych tabulkach casto zvoli full table scan, lebo je to lacnejsie nez pristup cez index. Plan typicky ukazuje plne skeny a hash join.
- Po indexoch:
  - IDX_ORDER_ITEM_PRODUCT urychluje join ORDER_ITEM.ID_product -> PRODUCT_table.ID_product.
  - IDX_PRODUCT_CATEGORY urychluje join PRODUCT_table.ID_category -> PRODUCT_CATEGORY.ID_category.
- Vysvetlenie: pri vacsich objemoch dat moze optimalizator vyuzit indexy na vyhladavanie riadkov pre join, cim znizi I/O a urychli agregaciu.

### Ako by sa dal dotaz este urychlit
- Mozne zlepsenie: zlozeny index na ORDER_ITEM(ID_product, quantity, selling_price) by mohol pomoct pri agregacii, alebo materializovany pohlad pre casto pouzivane reporty.
- Prakticky krok v projekte: vytvorenie IDX_ORDER_ITEM_PRODUCT a IDX_PRODUCT_CATEGORY a zopakovanie EXPLAIN PLAN, porovnanie planov pred/po.

## 2) Triggery
- TRG_CART_ITEM_CHECK_PRICE: pri vkladani/aktualizacii polozky kosika skontroluje mnozstvo > 0, doplni cenu z katalogu, pripadne vyhodi chybu pri nesulade.
- TRG_ORDER_TOTAL_RECALC (compound trigger): po INSERT/UPDATE/DELETE na ORDER_ITEM prepocita total_amount v ORDER_table podla sumy poloziek, bez problemu mutating table.
- Demonstracia: vlozenie polozky do kosika bez ceny a vlozenie polozky do novej objednavky s prepocitanim total_amount.

## 3) Ulozene procedury
- PRINT_CUSTOMER_SUMMARY: %ROWTYPE, %TYPE, NO_DATA_FOUND; vypise pocet objednavok a uhradu.
- CREATE_ORDER_FROM_CART: explicitny kurzor, osetrenie vynimiek, vytvorenie objednavky z aktivneho kosika, deaktivacia kosika; TRG_ORDER_TOTAL_RECALC sa postara o total_amount.

## 4) Pristupove prava a materializovany pohlad
- GRANT SELECT na zakladne tabulky pre xbadiks00.
- MV_CATEGORY_SALES v schematach xbadiks00 pouziva tabulky xuchytj00; REFRESH COMPLETE ON DEMAND; ukazany select a manualny refresh.

## 5) Komplexny SELECT s WITH a CASE
- WITH customer_stats spocita pocet objednavok a uhradu.
- CASE rozdeli zakaznikov na VIP / Regular / Inactive.
- Poznamka k vysledku: dotaz vracia zakaznikov s agregovanou statistikou objednavok a kategorizaciou podla uhrady/pocetnosti.
