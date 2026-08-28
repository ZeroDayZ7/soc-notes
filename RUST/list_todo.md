Oto kompletny plan wdrażania oraz architektura wygenerowania i dystrybucji dynamicznych poświadczeń dla Twojego ekosystemu KMS.

---

### Odpowiedzi na kluczowe pytania projektowe

#### 1. Co dokładnie generujemy i szyfrujemy w KMS (vHSM)?

* **Login i Hasło są generowane dynamicznie w KMS** (np. `auth_svc_8f2a` i 32-bajtowe bezpieczne krypograficznie hasło).
* **KMS nie przechowuje haseł w czystym tekście (Plaintext).** W pamięci RAM KMS używana jest struktura z automatycznym wymazywaniem (`Zeroizing<String>`).
* **Szyfrowanie KEK (Key Encryption Key):**
1. Hasło jest szyfrowane wewnątrz vHSM przy użyciu KEK danej bazy/usługi (np. za pomocą `AES-256-GCM`).
2. W bazie danych KMS (`kms-db`) zapisujesz wyłącznie **zaszyfrowaną postać (Ciphertext)**, `lease_id`, czas utworzenia, czas wygaśnięcia (`expires_at`) oraz status konta.
3. Jeśli ktoś wykradnie bazę danych KMS, nie pozna haseł do PostgreSQL/MinIO/RabbitMQ.



#### 2. Synchronizacja z bazą docelową (Potwierdzenie od PostgreSQL)

**Tak, potwierdzenie z bazy danych jest bezwzględnie wymagane.** KMS nie zwraca odpowiedzi do Sidecara, dopóki baza docelowa nie potwierdzi sukcesu.

```
Sidecar              KMS (vHSM + Scheduler)             PostgreSQL
   │                           │                             │
   │  1. GET /lease/auth-db    │                             │
   ├──────────────────────────►│                             │
   │                           │ 2. Gen login/pass w RAM    │
   │                           │ 3. Exec: CREATE USER ...    │
   │                           ├────────────────────────────►│
   │                           │                             │
   │                           │ 4. SQL SUCCESS (OK)         │
   │                           │◄────────────────────────────┤
   │                           │                             │
   │                           │ 5. Encrypt pass with KEK    │
   │                           │ 6. Persist Lease in kms-db  │
   │  7. Return Plaintext Pass │                             │
   │◄──────────────────────────┤                             │

```

---

### Plan Wdrożenia (Step-by-Step Architecture Roadmap)

1. **Faza 1: Rozbudowa KMS o Dynamic Secrets & Provider Adaptery:** Backend w KMS (Rust).
Stwórz wewnątrz KMS abstrakcję traita `SecretProvider` do komunikacji z systemami docelowymi:

* **PostgreSQL Provider:** Łączy się przez `sqlx`/`tokio-postgres` przy użyciu stałych poświadczeń administracyjnych KMS i wykonuje `CREATE USER ... VALID UNTIL ...` oraz `GRANT ...`.
* **MinIO Provider:** Łączy się z MinIO Admin API i generuje dynamiczne pary `AccessKey` / `SecretKey` powiązane z politykami IAM.
* **RabbitMQ Provider:** Odpytuje HTTP Management API RabbitMQ (`PUT /api/users/{username}`), nadając tagi i uprawnienia do vhosta.


2. **Faza 2: Wdrożenie Schedulera i Czyszczenia (Reaper Task):** Asynchroniczny silnik w KMS (Tokio).
Zaimplementuj w KMS zadanie działające w tle:

* **Lease Store:** Tabela w `kms-db` przechowująca zaszyfrowane sekrety (`lease_id`, `service_id`, `target_system`, `username`, `encrypted_password`, `expires_at`, `status`).
* **Reaper Loop:** Pętla uruchamiana co minutę (`tokio::time::interval`), która wyszukuje rekordy, gdzie `expires_at < NOW()`, odszyfrowuje je w vHSM, wydaje komendę usunięcia konta do bazy docelowej (np. `DROP USER IF EXISTS ...`), a następnie oznacza dzierżawę jako wygasłą.


3. **Faza 3: Budowa uniwersalnego Sidecara (secret-agent w Rust):** Lokalny agent w podzie.
Napisz lekką binarkę w Rust, działającą obok Twojego mikroserwisu:

* **UDS Server:** Otwiera i nasłuchuje na gnieździe `/run/kms-agent/agent.sock`.
* **Lifecycle Manager:**
1. Uwierzytelnia się w KMS przy użyciu tożsamości poda (ServiceAccount Token K8s lub dedykowany certyfikat).
2. Odpytuje KMS o poświadczenia, odebrane dane trzyma w pamięci RAM.
3. Uruchamia timer odnawiania (`renew_interval = TTL - OverlapWindow`, np. co 30 min przy TTL 45 min).
4. Udostępnia aktualne sekrety dla mikroserwisu przez prosty protokół na Unix Socket.




4. **Faza 4: Integracja Mikroserwisów (Go / Rust):** Klient gniazda Unix Socket.
W kodzie Twoich mikroserwisów (np. `auth-service` w Go czy `citizen-docs-service`):

* Zamień sztywne czytanie haseł ze zmiennych środowiskowych na wywołanie funkcji pobierającej poświadczenia z gniazda Unix `/run/kms-agent/agent.sock`.
* Skonfiguruj sterownik bazy danych (np. `pgxpool` w Go), aby w przypadku odrzucenia połączenia autoryzacyjnego pobrał nowe hasło z gniazda i odświeżył pulę połączeń.


---

### Model Danych dla Dzierżawy (kms-db)

Poniżej znajduje się zalecana struktura tabeli w bazie KMS do bezśladkowego i bezpiecznego śledzenia aktywnych dzierżaw:

| Pole | Typ | Opis |
| --- | --- | --- |
| **`id`** | `UUID` | Unikalny identyfikator dzierżawy (`lease_id`). |
| **`service_id`** | `VARCHAR` | Serwis, dla którego wydano sekret (np. `auth-service`). |
| **`target_resource`** | `VARCHAR` | Docelowa baza/zasób (np. `postgres-auth-db`). |
| **`username`** | `VARCHAR` | Wygenerowany login w systemie docelowym (`auth_svc_8f2a`). |
| **`encrypted_password`** | `BYTEA` | Hasło zaszyfrowane w vHSM kluczem KEK. |
| **`issued_at`** | `TIMESTAMPTZ` | Czas wygenerowania poświadczeń. |
| **`expires_at`** | `TIMESTAMPTZ` | Dokładny czas, po którym Reaper usunie konto w bazie docelowej. |
| **`status`** | `ENUM` | `ACTIVE`, `REVOKED`, `EXPIRED`. |

https://gemini.google.com/app/62424e57dba20472