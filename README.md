# Database bigliettazione – Tesi di Laurea

Questo repository contiene gli artefatti sviluppati a supporto della tesi:
- `dump_bigliettazione.sql` – Script PostgreSQL con definizione delle tabelle, vincoli, indici e query di esempio.
- `er_bigliettazione.png` – Diagramma ER del sistema di bigliettazione.
- *(Opzionale)* `dump_bigliettazione_mysql.sql` – Variante per MySQL.

## Requisiti
- PostgreSQL 14+ (consigliato) oppure MySQL 8+ (variante).
- Strumenti: **psql** o **pgAdmin** per PostgreSQL; **MySQL Workbench** per MySQL.

## Import in PostgreSQL
```bash
createdb bigliettazione
psql -U <utente> -d bigliettazione -f dump_bigliettazione.sql
```

## Query di esempio
Le query principali sono riportate in tesi al **Cap. 18**.  
Esempio: ricavi mensili (PostgreSQL):
```sql
SELECT DATE_TRUNC('month', data_pagamento) AS mese, SUM(importo) AS ricavi
FROM Transazione
WHERE stato_transazione = 'autorizzata'
GROUP BY 1
ORDER BY 1;
```

In MySQL:
```sql
SELECT DATE_FORMAT(data_pagamento, '%Y-%m-01') AS mese, SUM(importo) AS ricavi
FROM Transazione
WHERE stato_transazione = 'autorizzata'
GROUP BY mese
ORDER BY mese;
```

## Struttura del database
- Passeggero
- Prenotazione
- Biglietto
- Tratta
- Mezzo
- Transazione
- Operatore
- Controllo (tabella di supporto N:M)

## Licenza
MIT (o specificare altra licenza).
