# Latent — Klisza na iPhone'a

**Dokument projektowy v0.1** · Projekt Zespołowy · Zespół: Jan Narozny, Jan Naklicki
**Platforma:** iOS (natywnie, offline-first) · **Data:** październik 2026

---

## 1. Opis projektu

### 1.1 Problem
Większość aplikacji z „filtrami filmowymi" nakłada LUT-y lub nakładki na gotowe, już przetworzone pliki JPEG/HEIC. W tym momencie potok przetwarzania iPhone'a (Smart HDR, Deep Fusion, redukcja szumów, wyostrzanie, mapowanie tonów) zdążył już spłaszczyć światła, rozmazać szum i nadać obrazowi znany efektowny ale wysoce przetworzony charakter. Z danych, które mają już cyfrowy wygląd, nie da się uzyskać prawdziwego zachowania kliszy.

### 1.2 Rozwiązanie
**Latent** to natywna aplikacja aparatu na iOS, która rejestruje **nieprzetworzone dane z matrycy** (Bayer RAW / Apple ProRAW DNG). Dane te przechodzą przez **fizycznie inspirowany potok emulacji filmu**. Potok symuluje charakterystykę kliszy (krzywą H&D), przesunięcia barwne, ziarno zależne od naświetlenia, halację oraz etapy odbitki/skanu. Całość działa lokalnie na urządzeniu, w Metalu.

Działający na urządzeniu **asystent AI „Laborant"** zamienia opisy w języku naturalnym („rozmarzone lato lat 70., lekko prześwietlone") na konkretne parametry wywołania. Robi to za pomocą wywołań narzędzi przez LLM (*tool calling*).

### 1.3 Cele
- Odtworzyć *proces* fotografii analogowej, a nie tylko jej wygląd: rolki, ograniczona liczba klatek, odroczone „wywołanie".
- Zachować w pełni lokalne, prywatne i niedestrukcyjne przetwarzanie. Oryginalny plik RAW jest zawsze zachowywany.
- Spełnić wymóg ≥15 punktów złożoności przy natywnej architekturze, bez warstwy webowej (zob. §6).

### 1.4 Poza zakresem
Wersja na Androida, funkcje społecznościowe, backend chmurowy, nagrywanie wideo (ewentualny cel dodatkowy) oraz edycja zdjęć importowanych z innych aparatów (cel dodatkowy).

---

## 2. Role w zespole (adaptacja dla 2 osób i aplikacji natywnej)

Regulamin przedmiotu definiuje cztery role (A–D) dla 3–4-osobowych zespołów webowych. W dwuosobowym zespole tworzącym aplikację natywną role te zostały połączone w dwie role seniorskie. Każda z nich przejmuje zakres webowy w postaci natywnego odpowiednika. *Modyfikacja wymaga zgody prowadzącego (Zasada 1).*

### 2.1 Mapowanie ról

| Rola oryginalna | Zakres webowy | Odpowiednik natywny w Latent | Osoba |
|---|---|---|---|
| **A – Backend i Integracje AI** | Baza danych, logika API, integracja LLM, inżynieria promptów | Potok rejestracji i przetwarzania obrazu (AVFoundation, Core Image, Metal), model SwiftData i migracje, warstwa wywołań narzędzi AI, projektowanie promptów | **[Twoje Imię]** |
| **B – Frontend i UI/UX** | Interfejs React/Vue, komunikacja z API, prezentacja wyników AI | Interfejs SwiftUI, UX wizjera, ekrany galerii i „ciemni", prezentacja sugestii AI, dostępność | **Jan Naklicki** |
| **C – QA i DevOps** | Testy, CI/CD, wdrożenie w chmurze | Swift Testing/XCTest, testy UI, testy regresyjne potoku obrazu, GitHub Actions (runnery macOS) lub Xcode Cloud, dystrybucja przez TestFlight | **Jan Naklicki** |
| **D – Dane i Walidacja AI** | Struktury danych, logowanie LLM, optymalizacja tokenów, testy prompt injection | Logowanie interakcji z AI, metryki opóźnień i tokenów, strategia awaryjna, testy prompt injection i błędnych odpowiedzi modelu | **Podział:** logowanie i metryki → [Twoje Imię]; testy adwersaryjne → Jan |
| **Scrum Master / PM** | Koordynacja sprintów | Backlog w GitHub Projects, planowanie sprintów, przygotowanie demo | **[Twoje Imię]** |

### 2.2 Mechanizm Senior / Junior (dwuosobowy krąg wiedzy)

| Student | Rola Seniora (czego uczę) | Mój Mentor | Czego się uczę | Dowód w Git |
|---|---|---|---|---|
| [Twoje Imię] | Potok obrazu, shadery Metal, wywołania narzędzi AI | Jan Naklicki | Architektura SwiftUI, XCTest/CI | PR #… (testy napisane przeze mnie, recenzja: Jan) |
| Jan Naklicki | SwiftUI, testowanie, CI/CD | [Twoje Imię] | Podstawy Core Image / Metal, dekodowanie RAW | PR #… (funkcja shadera autorstwa Jana, recenzja: ja) |

Każda osoba musi scalić co najmniej jeden nietrywialny PR z dziedziny, w której jest juniorem, zrecenzowany przez seniora. Te PR-y stanowią dowód do Karty Transferu Wiedzy (Tydzień 14).

---

## 3. Wymagania funkcjonalne

Priorytet: **M** = Must (MVP), **S** = Should, **C** = Could (cel dodatkowy)

### 3.1 Rejestracja zdjęć
| ID | Wymaganie | Priorytet |
|---|---|---|
| FR-01 | Użytkownik może robić zdjęcia w formacie Bayer RAW (lub ProRAW, jeśli dostępny) przez AVCapturePhotoOutput. | M |
| FR-02 | Wizjer wyświetla podgląd na żywo z wybraną emulacją kliszy, w czasie rzeczywistym. | M |
| FR-03 | Użytkownik może ręcznie ustawić ISO, czas naświetlania i ostrość albo korzystać z automatyki. | S |
| FR-04 | Użytkownik może stosować korekcję ekspozycji, symulując push/pull. | S |
| FR-05 | Na obsługiwanych urządzeniach dostępny jest wybór obiektywu (szeroki/ultraszeroki/tele). | S |
| FR-06 | Aplikacja wyświetla odczyt światłomierza w stylu aparatu analogowego. | C |

### 3.2 Klisze i rolki
| ID | Wymaganie | Priorytet |
|---|---|---|
| FR-07 | Użytkownik „zakłada rolkę", wybierając kliszę i liczbę klatek (12/24/36). | M |
| FR-08 | Aplikacja zawiera co najmniej 5 wbudowanych profili kliszy (np. negatyw kolorowy, diapozytyw, cz-b, tungsten, przeterminowana). | M |
| FR-09 | **Tryb rolki:** zdjęcia pozostają ukryte, dopóki rolka nie zostanie wypstrykana i „wywołana". | S |
| FR-10 | **Tryb natychmiastowy:** zdjęcia są wywoływane od razu (rezygnacja z trybu rolki). | M |
| FR-11 | Użytkownik może tworzyć i zapisywać własne profile klisz i receptury wywołania. | S |

### 3.3 Wywoływanie (potok przetwarzania)
| ID | Wymaganie | Priorytet |
|---|---|---|
| FR-12 | Obraz RAW przechodzi przez potok: liniowe demozaikowanie → balans bieli → macierz czułości spektralnej kliszy → krzywa charakterystyczna (H&D) → etap odbitki/skanu. | M |
| FR-13 | Ziarno jest symulowane z rozmiarem i intensywnością zależnymi od czułości kliszy i lokalnej luminancji. | M |
| FR-14 | Symulowana jest halacja (czerwona poświata wokół mocnych świateł). | S |
| FR-15 | Efekty opcjonalne: winietowanie, prześwietlenia (light leaks), znacznik daty, ramka kliszy. | C |
| FR-16 | Użytkownik może ponownie wywołać dowolne zdjęcie z innymi parametrami (edycja niedestrukcyjna). | M |
| FR-17 | Wywoływanie wielu zdjęć odbywa się w kolejce w tle. | M |

### 3.4 Biblioteka
| ID | Wymaganie | Priorytet |
|---|---|---|
| FR-18 | Użytkownik przegląda zdjęcia pogrupowane w rolki, z widokiem stykówki. | M |
| FR-19 | Zdjęcia można tagować, oznaczać gwiazdką i układać w albumy. | S |
| FR-20 | Eksport do biblioteki Zdjęcia jako HEIC/JPEG, opcjonalnie z oryginalnym DNG. | M |
| FR-21 | Aplikacja zapisuje i wyświetla metadane (EXIF, klisza, receptura, pogoda/lokalizacja za zgodą). | S |

### 3.5 Asystent AI „Laborant"
| ID | Wymaganie | Priorytet |
|---|---|---|
| FR-22 | Użytkownik opisuje pożądany efekt w języku naturalnym. LLM odpowiada, **wywołując narzędzia** (`set_film_stock`, `set_push_pull`, `set_grain`, `set_halation`, `create_recipe`), które zmieniają parametry wywołania. | M |
| FR-23 | Asystent może przeanalizować scenę (lokalna klasyfikacja Vision/Core ML: portret, krajobraz, noc itp.) i zaproponować pasującą kliszę. | S |
| FR-24 | Wszystkie zmiany zaproponowane przez AI są prezentowane jako podgląd różnic, który użytkownik akceptuje lub odrzuca. | M |
| FR-25 | Gdy AI jest niedostępne, aplikacja wyświetla czytelny komunikat i przechodzi na sterowanie ręczne. | M |

### 3.6 Dane zewnętrzne
| ID | Wymaganie | Priorytet |
|---|---|---|
| FR-26 | Za zgodą użytkownika aplikacja pobiera aktualną pogodę (WeatherKit) w momencie zrobienia zdjęcia. Pogoda jest zapisywana w metadanych i przekazywana asystentowi AI jako kontekst. | S |

---

## 4. Wymagania niefunkcjonalne

| ID | Kategoria | Wymaganie |
|---|---|---|
| NFR-01 | Wydajność | Podgląd emulacji na żywo działa z ≥30 kl./s na iPhonie 13 i nowszych. |
| NFR-02 | Wydajność | Wywołanie pełnej rozdzielczości RAW 12 MP trwa ≤3 s na iPhonie 15 Pro. |
| NFR-03 | Wydajność | Opóźnienie od naciśnięcia spustu do rejestracji wynosi ≤300 ms (bez przetwarzania). |
| NFR-04 | Niezawodność | Brak utraty zdjęć: oryginalny RAW jest zapisywany na dysk przed rozpoczęciem przetwarzania i przetrwa awarię aplikacji. |
| NFR-05 | Prywatność | Całe przetwarzanie obrazu odbywa się na urządzeniu. Żadne zdjęcie nie opuszcza urządzenia bez wyraźnej akcji użytkownika. |
| NFR-06 | Prywatność | Uprawnienia do aparatu, lokalizacji i zdjęć są wymagane dopiero w momencie potrzeby, z jasnym uzasadnieniem. |
| NFR-07 | Offline | Wszystkie funkcje poza opcjonalnym chmurowym LLM i pogodą działają bez internetu. |
| NFR-08 | Energia/temperatura | Przy przegrzaniu aplikacja obniża jakość podglądu zamiast gubić klatki lub się zawieszać. |
| NFR-09 | Pamięć | Aplikacja pokazuje zajmowane miejsce, a użytkownik może usuwać oryginały z poszczególnych rolek. |
| NFR-10 | Użyteczność | Podstawowa ścieżka (otwarcie → zdjęcie) wymaga ≤2 dotknięć. Aplikacja obsługuje Dynamic Type i VoiceOver. |
| NFR-11 | Lokalizacja | Język polski i angielski. |
| NFR-12 | Utrzymywalność | Moduły są wydzielone jako Swift Packages, a pokrycie logiki biznesowej testami wynosi ≥60%. |
| NFR-13 | Prawo | Profile klisz mają oryginalne nazwy, bez znaków towarowych Kodak/Fujifilm/Ilford. |

---

## 5. Wymagania techniczne i architektura

### 5.1 Stos technologiczny
| Obszar | Technologia |
|---|---|
| Język | Swift 6 (strict concurrency) |
| UI | SwiftUI (+ UIKit dla warstwy podglądu aparatu) |
| Rejestracja | AVFoundation (`AVCaptureSession`, `AVCapturePhotoOutput`, formaty RAW/ProRAW) |
| Dekodowanie RAW | Core Image `CIRAWFilter` (wyjście liniowe, scene-referred) |
| Przetwarzanie | Shadery obliczeniowe Metal + własne `CIKernel` (krzywa, ziarno, halacja), LUT-y 3D dla etapu odbitki |
| Trwałość danych | SwiftData (wersjonowany schemat + plan migracji) + system plików dla DNG i przetworzonych obrazów |
| Pamięć podręczna | Dwupoziomowa: `NSCache` w pamięci dla podglądów + cache miniatur/LUT-ów na dysku |
| Praca w tle | Kolejka zadań Swift Concurrency + `BGProcessingTask` do wywoływania wsadowego |
| AI (główne) | Framework Apple Foundation Models (lokalny LLM z wywoływaniem narzędzi) |
| AI (zapasowe) | Chmurowe API LLM (Claude/OpenAI) z tool use, klucz API w Keychain. Używane tylko na urządzeniach bez obsługi lokalnego AI. |
| Analiza sceny | Vision / Core ML (klasyfikacja obrazu) |
| API zewnętrzne | WeatherKit |
| Testy | Swift Testing, XCTest, XCUITest, testy snapshotowe wyników potoku |
| CI/CD | GitHub Actions (runnery macOS) lub Xcode Cloud → TestFlight |
| Zarządzanie projektem | GitHub Projects (Kanban) + GitHub Issues jako User Stories |

### 5.2 Architektura modułowa
```
LatentApp (powłoka SwiftUI, nawigacja, DI)
├── CaptureKit      – sesja AVFoundation, rejestracja RAW, możliwości urządzenia
├── FilmEngine      – potok RAW → film (Metal/Core Image), definicje profili
├── DevelopQueue    – planowanie zadań asynchronicznych/w tle, postęp, odtwarzanie po awarii
├── LibraryStore    – modele SwiftData, migracje, przechowywanie plików, cache
├── LabAssistant    – sesja LLM, definicje narzędzi, analiza sceny, logowanie
└── SharedUI        – system projektowy, kontrolki w stylu analogowym
```
Moduły komunikują się wyłącznie przez publiczne protokoły. Każdy moduł jest niezależnym Swift Package z własnym targetem testowym.

### 5.3 Model danych (≥8 powiązanych encji)
`Roll` (rolka), `Exposure` (klatka/zdjęcie), `FilmStock` (klisza), `DevelopRecipe` (receptura wywołania), `CaptureMetadata` (EXIF), `WeatherSnapshot` (pogoda), `Tag`, `Album`, `AIInteraction` (prompt, wywołania narzędzi, opóźnienie, wynik), `DevelopJob` (zadanie wywołania).

### 5.4 Wymagania sprzętowe
- **Minimum:** iOS 26, iPhone z obsługą rejestracji RAW.
- **Lokalny asystent AI:** urządzenia obsługujące Apple Intelligence. Na pozostałych urządzeniach używane jest AI w chmurze lub tryb ręczny.

### 5.5 Odporność na błędy AI (punkt 5 DoD)
- Aplikacja stosuje limit czasu i ponowienia z wykładniczym opóźnieniem (exponential backoff) dla zapasowego AI w chmurze.
- Argumenty wywołań narzędzi są walidowane według schematów, a wartości spoza zakresu są przycinane lub odrzucane.
- Model jedynie *proponuje* zmiany parametrów. Nigdy nie usuwa ani nie eksportuje plików, co ogranicza skutki ataków prompt injection.
- Każda interakcja jest logowana w `AIInteraction` na potrzeby obserwowalności (opóźnienie, wywołania narzędzi, błędy).

---

## 6. Matryca złożoności (cel ≥15 pkt)

Część kryteriów matrycy zakłada stos webowy. Poniższa tabela proponuje natywne odpowiedniki. Pozycje oznaczone ⚠ wymagają potwierdzenia prowadzącego na Kamieniu Milowym 1.

| Kategoria | Kryterium | Implementacja natywna | Pkt | Status |
|---|---|---|---|---|
| Baza danych | ≥8 powiązanych tabel | Model SwiftData, 10 encji (§5.3) | 2 | ✅ |
| Baza danych | Migracje / transakcyjność | SwiftData `VersionedSchema` + `SchemaMigrationPlan`; atomowy zapis zdjęcia | 2 | ✅ |
| Baza danych | Dwa typy magazynów danych | SwiftData + dwupoziomowy cache obrazów (NSCache + dysk) | 3 | ⚠ |
| Integracje | Zewnętrzne API | WeatherKit | 2 | ✅ |
| Integracje | Przetwarzanie asynchroniczne | Kolejka wywoływania w tle (`BGProcessingTask`, kolejka zadań) | 3 | ✅ |
| Integracja AI | Autonomiczny agent / tool use | LLM wywołuje narzędzia do wywoływania zdjęć (FR-22) | 5 | ✅ |
| Architektura | Rozdzielenie warstw | Modułowe Swift Packages z granicami opartymi na protokołach | 3 | ⚠ |
| Integracje | Czas rzeczywisty | Podgląd emulacji na GPU na żywo, 30+ kl./s | 3 | ⚠ |
| **Suma** | | Tylko pozycje potwierdzone: **14** · Z pozycjami ⚠: **23** | | |

Same pozycje potwierdzone dają 14 punktów, czyli o 1 punkt mniej niż wymagane minimum 15. Do zaliczenia potrzebna jest akceptacja co najmniej jednej pozycji ⚠. Najłatwiej obronić dwa typy magazynów danych oraz architekturę modułową. W razie potrzeby można dodać **Sign in with Apple** (odpowiednik OAuth, 3 pkt) dla opcjonalnej synchronizacji receptur przez iCloud.

---

## 7. Harmonogram (15 tygodni, zgodnie z kamieniami milowymi przedmiotu)

| Tygodnie | Faza | Rezultaty | Kamień milowy |
|---|---|---|---|
| 1–2 | Inicjacja | Niniejszy dokument, User Stories w GitHub Issues, karta projektu | **KM1:** Akceptacja tematu |
| 3–4 | Architektura | ERD, makiety w Figmie, diagram modułów, prototyp rejestracji RAW na urządzeniu | **KM2:** Obrona architektury |
| 5–6 | MVP | Rejestracja RAW + jeden profil kliszy + zapis do biblioteki | **KM3:** Pierwsza działająca funkcja |
| 7–8 | Sprint 1 | Ziarno, halacja, 5 klisz, model rolki | Demo T8 |
| 9–10 | Sprint 2 | Asystent AI „Laborant" (tool calling), kolejka w tle | Demo T10 |
| 11–12 | Sprint 3 | Tryb rolki, WeatherKit, eksport, własne receptury | Demo T12 |
| 13–14 | Stabilizacja | Refaktoryzacja, pokrycie testami, optymalizacja wydajności, Karta Transferu Wiedzy | **KM4:** Code freeze + build w TestFlight |
| 15 | Finał | Demo na żywo na urządzeniu, retrospektywa | Finałowe demo |

*„Wdrożenie na serwer produkcyjny" (KM4) interpretujemy jako publiczny build w TestFlight. Publikacja w App Store jest opcjonalna.*

---

## 8. Definicja Ukończenia (Definition of Done, adaptacja)

Zadanie jest ukończone, gdy:
1. Kod został scalony z gałęzią `main` na GitHubie przez Pull Request.
2. PR został przejrzany i zaakceptowany przez drugiego członka zespołu.
3. **Brak „u mnie działa":** funkcja działa na świeżej instalacji (czysty symulator/urządzenie), z magazynem danych utworzonym przez plan migracji. CI działa na czystym runnerze macOS.
4. Nowa logika biznesowa ma testy jednostkowe. Zmiany w potoku obrazu mają testy snapshotowe/regresyjne.
5. Obsłużone są błędy AI: przekroczenie czasu, niedostępny model, niepoprawne argumenty narzędzi → ponowienie lub czytelny komunikat.
6. Zadanie zostało przeniesione do kolumny **Done** w GitHub Projects, z linkiem do PR.

---

## 9. Ryzyka

| Ryzyko | Wpływ | Mitygacja |
|---|---|---|
| Potok RAW zbyt wolny na starszych urządzeniach | Wysoki | Podgląd w niskiej rozdzielczości; pełna rozdzielczość tylko przy wykonaniu zdjęcia |
| Lokalny LLM niedostępny na urządzeniach testowych | Średni | AI w chmurze jako zapas + tryb ręczny; testy na co najmniej jednym urządzeniu z Apple Intelligence |
| Emulacja kliszy wygląda „sztucznie" | Średni | Kalibracja względem prawdziwych skanów klisz; feedback użytkowników podczas demo sprintów |
| Odrzucenie natywnych odpowiedników w matrycy | Średni | Sign in with Apple (+3 pkt) przygotowane jako rezerwa |
| Tylko 2 osoby, wymagany Mac/iPhone | Średni | Obaj członkowie potrzebują dostępu do Xcode; wspólna pula urządzeń testowych |