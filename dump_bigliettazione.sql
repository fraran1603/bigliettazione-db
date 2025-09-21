
-- Dump SQL per sistema di bigliettazione (azienda di trasporto generica)
-- Creazione delle tabelle principali

CREATE TABLE Passeggero (
    id_passeggero SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    documento_identita VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20)
);

CREATE TABLE Prenotazione (
    id_prenotazione SERIAL PRIMARY KEY,
    data_prenotazione DATE NOT NULL,
    stato VARCHAR(20) CHECK (stato IN ('attiva','annullata','completata')),
    passeggero_id INT NOT NULL,
    FOREIGN KEY (passeggero_id) REFERENCES Passeggero(id_passeggero) ON DELETE CASCADE
);

CREATE TABLE Mezzo (
    id_mezzo SERIAL PRIMARY KEY,
    tipo_mezzo VARCHAR(30) NOT NULL,
    capacita INT CHECK (capacita > 0)
);

CREATE TABLE Tratta (
    id_tratta SERIAL PRIMARY KEY,
    origine VARCHAR(100) NOT NULL,
    destinazione VARCHAR(100) NOT NULL,
    orario_partenza TIMESTAMP NOT NULL,
    orario_arrivo TIMESTAMP NOT NULL,
    mezzo_id INT NOT NULL,
    FOREIGN KEY (mezzo_id) REFERENCES Mezzo(id_mezzo) ON DELETE CASCADE
);

CREATE TABLE Biglietto (
    id_biglietto SERIAL PRIMARY KEY,
    data_emissione DATE NOT NULL,
    prezzo DECIMAL(8,2) NOT NULL,
    stato_biglietto VARCHAR(20) CHECK (stato_biglietto IN ('valido','annullato','utilizzato')),
    prenotazione_id INT NOT NULL,
    tratta_id INT NOT NULL,
    FOREIGN KEY (prenotazione_id) REFERENCES Prenotazione(id_prenotazione) ON DELETE CASCADE,
    FOREIGN KEY (tratta_id) REFERENCES Tratta(id_tratta) ON DELETE CASCADE
);

CREATE TABLE Transazione (
    id_transazione SERIAL PRIMARY KEY,
    importo DECIMAL(10,2) NOT NULL,
    metodo_pagamento VARCHAR(30) NOT NULL,
    data_pagamento TIMESTAMP NOT NULL,
    stato_transazione VARCHAR(20) CHECK (stato_transazione IN ('autorizzata','rifiutata','rimborsata')),
    prenotazione_id INT NOT NULL,
    FOREIGN KEY (prenotazione_id) REFERENCES Prenotazione(id_prenotazione) ON DELETE CASCADE
);

CREATE TABLE Operatore (
    id_operatore SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    ruolo VARCHAR(50) NOT NULL,
    area_servizio VARCHAR(100)
);

CREATE TABLE Controllo (
    id_operatore INT NOT NULL,
    id_biglietto INT NOT NULL,
    data_controllo TIMESTAMP NOT NULL,
    esito VARCHAR(20) CHECK (esito IN ('valido','non valido')),
    PRIMARY KEY (id_operatore, id_biglietto, data_controllo),
    FOREIGN KEY (id_operatore) REFERENCES Operatore(id_operatore) ON DELETE CASCADE,
    FOREIGN KEY (id_biglietto) REFERENCES Biglietto(id_biglietto) ON DELETE CASCADE
);

-- Indici
CREATE INDEX idx_prenotazione_passeggero ON Prenotazione(passeggero_id);
CREATE INDEX idx_biglietto_prenotazione ON Biglietto(prenotazione_id);
CREATE INDEX idx_biglietto_tratta ON Biglietto(tratta_id);
CREATE INDEX idx_tratta_mezzo ON Tratta(mezzo_id);
CREATE INDEX idx_transazione_prenotazione ON Transazione(prenotazione_id);
CREATE INDEX idx_biglietto_stato ON Biglietto(stato_biglietto);
CREATE INDEX idx_transazione_stato ON Transazione(stato_transazione);

-- Dati di esempio
INSERT INTO Passeggero (nome,cognome,documento_identita,email,telefono)
VALUES ('Mario','Rossi','AB12345','mario.rossi@email.com','3331112222');

INSERT INTO Mezzo (tipo_mezzo,capacita)
VALUES ('Treno',500),('Autobus',60);

INSERT INTO Tratta (origine,destinazione,orario_partenza,orario_arrivo,mezzo_id)
VALUES ('Roma','Milano','2025-09-25 08:00','2025-09-25 11:00',1);

INSERT INTO Prenotazione (data_prenotazione,stato,passeggero_id)
VALUES ('2025-09-20','attiva',1);

INSERT INTO Biglietto (data_emissione,prezzo,stato_biglietto,prenotazione_id,tratta_id)
VALUES ('2025-09-20',59.90,'valido',1,1);

INSERT INTO Transazione (importo,metodo_pagamento,data_pagamento,stato_transazione,prenotazione_id)
VALUES (59.90,'Carta di credito','2025-09-20 10:00','autorizzata',1);

INSERT INTO Operatore (nome,cognome,ruolo,area_servizio)
VALUES ('Luca','Bianchi','Controllore','Roma Termini');

INSERT INTO Controllo (id_operatore,id_biglietto,data_controllo,esito)
VALUES (1,1,'2025-09-21 09:00','valido');

-- Query rappresentative

-- Q1: Biglietti validi per tratte future
SELECT b.id_biglietto, t.origine, t.destinazione, t.orario_partenza
FROM Biglietto b
JOIN Tratta t ON t.id_tratta = b.tratta_id
WHERE b.stato_biglietto = 'valido' AND t.orario_partenza > NOW()
ORDER BY t.orario_partenza;

-- Q2: Storico prenotazioni di un passeggero
SELECT p.id_prenotazione, p.data_prenotazione, b.id_biglietto, t.origine, t.destinazione
FROM Prenotazione p
JOIN Biglietto b ON b.prenotazione_id = p.id_prenotazione
JOIN Tratta t ON t.id_tratta = b.tratta_id
WHERE p.passeggero_id = 1
ORDER BY p.data_prenotazione DESC;

-- Q3: Ricavi mensili da transazioni autorizzate
SELECT DATE_TRUNC('month', data_pagamento) AS mese, SUM(importo) AS ricavi
FROM Transazione
WHERE stato_transazione = 'autorizzata'
GROUP BY 1
ORDER BY 1;

-- Q4: Numero controlli effettuati per operatore
SELECT o.id_operatore, o.nome, o.cognome, COUNT(*) AS num_controlli
FROM Controllo c
JOIN Operatore o ON o.id_operatore = c.id_operatore
GROUP BY o.id_operatore, o.nome, o.cognome
ORDER BY num_controlli DESC;

-- Q5: Tasso di annullamento biglietti
SELECT COUNT(*) FILTER (WHERE stato_biglietto='annullato')::decimal / COUNT(*) AS tasso_annullamento
FROM Biglietto;
