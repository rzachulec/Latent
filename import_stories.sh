#!/usr/bin/env bash
# Latent – import User Stories do GitHub Issues
# Wymagania: gh CLI zalogowane (gh auth login), uruchomić w katalogu repozytorium.
set -euo pipefail

ME="@me"   # [Twoje Imię]
JAN="Jannaklicki"         # Jan Naklicki

# ---------- Etykiety ----------
gh label create "user story"            --color 1D76DB --force
gh label create "zadanie techniczne"    --color 5319E7 --force
gh label create "priorytet: M"          --color B60205 --force
gh label create "priorytet: S"          --color FBCA04 --force
gh label create "priorytet: C"          --color C2E0C6 --force
gh label create "obszar: rejestracja"   --color 0E8A16 --force
gh label create "obszar: klisze"        --color 0E8A16 --force
gh label create "obszar: wywoływanie"   --color 0E8A16 --force
gh label create "obszar: biblioteka"    --color 0E8A16 --force
gh label create "obszar: AI"            --color 0E8A16 --force
gh label create "obszar: dane zewn."    --color 0E8A16 --force
gh label create "obszar: QA/DevOps"     --color 0E8A16 --force

# ---------- Kamienie milowe ----------
MVP="KM3 – MVP (T5–6)"
S1="Sprint 1 (T7–8)"
S2="Sprint 2 (T9–10)"
S3="Sprint 3 (T11–12)"
STAB="KM4 – Stabilizacja (T13–14)"
for m in "$MVP" "$S1" "$S2" "$S3" "$STAB"; do
  gh api "repos/{owner}/{repo}/milestones" -f title="$m" --silent 2>/dev/null || true
done

# story <tytuł> <etykiety> <kamień milowy|""> <osoba|""> <treść>
story() {
  local args=(--title "$1" --label "$2" --body "$5")
  [[ -n "$3" ]] && args+=(--milestone "$3")
  [[ -n "$4" ]] && args+=(--assignee "$4")
  gh issue create "${args[@]}"
}

# ================= REJESTRACJA =================
story "[FR-01] Zdjęcie w formacie RAW" \
"user story,priorytet: M,obszar: rejestracja" "$MVP" "$ME" \
"**Jako** fotograf **chcę** robić zdjęcia w formacie RAW (Bayer RAW lub ProRAW), **aby** emulacja kliszy działała na nieprzetworzonych danych z matrycy.

**Kryteria akceptacji:**
- [ ] Aplikacja wykrywa dostępne formaty RAW urządzenia
- [ ] Zdjęcie zapisuje się jako DNG przed jakimkolwiek przetwarzaniem
- [ ] Gdy RAW nie jest dostępny, użytkownik widzi czytelny komunikat

Wymaganie: FR-01, NFR-04"

story "[FR-02] Podgląd emulacji kliszy na żywo" \
"user story,priorytet: M,obszar: rejestracja" "$S1" "$ME" \
"**Jako** fotograf **chcę** widzieć w wizjerze efekt wybranej kliszy na żywo, **aby** komponować kadr pod kątem końcowego wyglądu.

**Kryteria akceptacji:**
- [ ] Podgląd działa z co najmniej 30 kl./s na iPhonie 13+
- [ ] Zmiana kliszy odświeża podgląd natychmiast
- [ ] Przy przegrzaniu jakość podglądu spada zamiast gubienia klatek

Wymaganie: FR-02, NFR-01, NFR-08"

story "[FR-03] Ręczne ustawienia ekspozycji" \
"user story,priorytet: S,obszar: rejestracja" "$S3" "$JAN" \
"**Jako** zaawansowany fotograf **chcę** ręcznie ustawiać ISO, czas naświetlania i ostrość, **aby** mieć pełną kontrolę jak w aparacie analogowym.

**Kryteria akceptacji:**
- [ ] Kontrolki ISO, czasu i ostrości w stylu analogowym
- [ ] Przełącznik auto/manual
- [ ] Wartości zapisywane w metadanych zdjęcia

Wymaganie: FR-03"

story "[FR-04] Push/pull przez korekcję ekspozycji" \
"user story,priorytet: S,obszar: rejestracja" "$S3" "$ME" \
"**Jako** fotograf **chcę** stosować korekcję ekspozycji jako push/pull, **aby** symulować forsowne lub osłabione wywołanie kliszy.

**Kryteria akceptacji:**
- [ ] Zakres co najmniej od -2 do +2 EV
- [ ] Push/pull wpływa na kontrast i ziarno w potoku wywołania

Wymaganie: FR-04"

story "[FR-05] Wybór obiektywu" \
"user story,priorytet: S,obszar: rejestracja" "$S3" "$JAN" \
"**Jako** fotograf **chcę** przełączać obiektywy (szeroki/ultraszeroki/tele), **aby** wybierać ogniskową jak w prawdziwym aparacie.

**Kryteria akceptacji:**
- [ ] Widoczne są tylko obiektywy dostępne na danym urządzeniu
- [ ] Przełączenie nie przerywa sesji podglądu

Wymaganie: FR-05"

story "[FR-06] Analogowy światłomierz" \
"user story,priorytet: C,obszar: rejestracja" "" "$JAN" \
"**Jako** fotograf **chcę** widzieć odczyt światłomierza w stylu analogowym, **aby** świadomie dobierać ekspozycję.

**Kryteria akceptacji:**
- [ ] Wskaźnik pokazuje odchylenie od poprawnej ekspozycji w EV

Wymaganie: FR-06"

# ================= KLISZE I ROLKI =================
story "[FR-07] Zakładanie rolki" \
"user story,priorytet: M,obszar: klisze" "$MVP" "$JAN" \
"**Jako** użytkownik **chcę** założyć rolkę, wybierając kliszę i liczbę klatek (12/24/36), **aby** fotografować jak aparatem analogowym.

**Kryteria akceptacji:**
- [ ] Ekran wyboru kliszy i długości rolki
- [ ] Licznik pozostałych klatek w wizjerze
- [ ] Po ostatniej klatce rolka jest oznaczona jako zakończona

Wymaganie: FR-07"

story "[FR-08] Pięć wbudowanych profili klisz" \
"user story,priorytet: M,obszar: klisze" "$S1" "$ME" \
"**Jako** użytkownik **chcę** wybierać spośród co najmniej 5 profili klisz, **aby** dopasować charakter zdjęć do sytuacji.

**Kryteria akceptacji:**
- [ ] Profile: negatyw kolorowy, diapozytyw, cz-b, tungsten, przeterminowana
- [ ] Oryginalne nazwy, bez znaków towarowych producentów
- [ ] Każdy profil ma test snapshotowy na obrazie referencyjnym

Wymaganie: FR-08, NFR-13"

story "[FR-09] Tryb rolki z odroczonym wywołaniem" \
"user story,priorytet: S,obszar: klisze" "$S3" "$JAN" \
"**Jako** użytkownik **chcę**, aby zdjęcia były ukryte do momentu wywołania rolki, **aby** poczuć oczekiwanie jak przy prawdziwej kliszy.

**Kryteria akceptacji:**
- [ ] Zdjęcia z niewywołanej rolki są niewidoczne w galerii
- [ ] Wywołanie rolki uruchamia przetwarzanie wszystkich klatek w tle
- [ ] Animacja wywołania po zakończeniu

Wymaganie: FR-09"

story "[FR-10] Tryb natychmiastowy" \
"user story,priorytet: M,obszar: klisze" "$MVP" "$JAN" \
"**Jako** użytkownik **chcę** móc od razu zobaczyć wywołane zdjęcie, **aby** korzystać z aplikacji bez trybu rolki.

**Kryteria akceptacji:**
- [ ] Przełącznik trybu w ustawieniach rolki
- [ ] Zdjęcie pojawia się w galerii zaraz po wywołaniu

Wymaganie: FR-10"

story "[FR-11] Własne profile i receptury" \
"user story,priorytet: S,obszar: klisze" "$S3" "$ME" \
"**Jako** zaawansowany użytkownik **chcę** tworzyć i zapisywać własne receptury wywołania, **aby** wielokrotnie używać ulubionego wyglądu.

**Kryteria akceptacji:**
- [ ] Zapis, edycja i usuwanie receptur
- [ ] Receptura może bazować na wbudowanym profilu

Wymaganie: FR-11"

# ================= WYWOŁYWANIE =================
story "[FR-12] Podstawowy potok RAW → film" \
"user story,priorytet: M,obszar: wywoływanie" "$MVP" "$ME" \
"**Jako** użytkownik **chcę**, aby zdjęcie było wywoływane z RAW przez model kliszy, **aby** uzyskać autentyczny analogowy wygląd.

**Kryteria akceptacji:**
- [ ] Etapy: demozaikowanie liniowe, balans bieli, macierz kliszy, krzywa H&D, etap odbitki
- [ ] Wywołanie 12 MP w czasie poniżej 3 s na iPhonie 15 Pro
- [ ] Testy jednostkowe krzywej charakterystycznej

Wymaganie: FR-12, NFR-02"

story "[FR-13] Symulacja ziarna" \
"user story,priorytet: M,obszar: wywoływanie" "$S1" "$ME" \
"**Jako** użytkownik **chcę** realistycznego ziarna zależnego od czułości i jasności, **aby** zdjęcie wyglądało jak skan kliszy.

**Kryteria akceptacji:**
- [ ] Rozmiar i intensywność ziarna zależą od ISO kliszy
- [ ] Ziarno jest silniejsze w półcieniach niż w światłach
- [ ] Shader Metal z testem snapshotowym

Wymaganie: FR-13"

story "[FR-14] Halacja" \
"user story,priorytet: S,obszar: wywoływanie" "$S1" "$JAN" \
"**Jako** użytkownik **chcę** czerwonej poświaty wokół mocnych świateł, **aby** odwzorować charakterystyczną cechę kliszy.

**Kryteria akceptacji:**
- [ ] Efekt pojawia się tylko powyżej progu jasności
- [ ] Intensywność regulowana w recepturze

Wymaganie: FR-14 (zadanie juniorskie Jana – recenzja: senior obrazu)"

story "[FR-15] Efekty dodatkowe" \
"user story,priorytet: C,obszar: wywoływanie" "" "" \
"**Jako** użytkownik **chcę** opcjonalnych efektów (winieta, light leaks, data, ramka), **aby** nadać zdjęciom dodatkowy charakter.

**Kryteria akceptacji:**
- [ ] Każdy efekt można włączyć niezależnie

Wymaganie: FR-15"

story "[FR-16] Niedestrukcyjne ponowne wywołanie" \
"user story,priorytet: M,obszar: wywoływanie" "$S2" "$JAN" \
"**Jako** użytkownik **chcę** ponownie wywołać zdjęcie z innymi parametrami, **aby** eksperymentować bez utraty oryginału.

**Kryteria akceptacji:**
- [ ] Oryginalny DNG pozostaje nienaruszony
- [ ] Historia receptur dla każdego zdjęcia
- [ ] Podgląd przed zatwierdzeniem

Wymaganie: FR-16"

story "[FR-17] Kolejka wywoływania w tle" \
"user story,priorytet: M,obszar: wywoływanie" "$S2" "$ME" \
"**Jako** użytkownik **chcę**, aby wiele zdjęć wywoływało się w tle, **aby** móc dalej fotografować.

**Kryteria akceptacji:**
- [ ] Kolejka oparta na Swift Concurrency i BGProcessingTask
- [ ] Widoczny postęp
- [ ] Przerwane zadania są wznawiane po ponownym uruchomieniu

Wymaganie: FR-17"

# ================= BIBLIOTEKA =================
story "[FR-18] Galeria rolek i stykówka" \
"user story,priorytet: M,obszar: biblioteka" "$MVP" "$JAN" \
"**Jako** użytkownik **chcę** przeglądać zdjęcia pogrupowane w rolki, **aby** łatwo wracać do sesji.

**Kryteria akceptacji:**
- [ ] Lista rolek z miniaturami
- [ ] Widok stykówki dla rolki
- [ ] Płynne przewijanie dzięki cache miniatur

Wymaganie: FR-18"

story "[FR-19] Tagi, gwiazdki i albumy" \
"user story,priorytet: S,obszar: biblioteka" "$S3" "$JAN" \
"**Jako** użytkownik **chcę** tagować i oznaczać zdjęcia oraz tworzyć albumy, **aby** organizować bibliotekę.

**Kryteria akceptacji:**
- [ ] Encje Tag i Album w SwiftData
- [ ] Filtrowanie galerii po tagach i gwiazdkach

Wymaganie: FR-19"

story "[FR-20] Eksport do Zdjęć" \
"user story,priorytet: M,obszar: biblioteka" "$S1" "$JAN" \
"**Jako** użytkownik **chcę** eksportować zdjęcia do biblioteki Zdjęcia, **aby** udostępniać je dalej.

**Kryteria akceptacji:**
- [ ] Eksport HEIC lub JPEG
- [ ] Opcjonalny eksport oryginalnego DNG
- [ ] Uprawnienie do zdjęć wymagane dopiero przy pierwszym eksporcie

Wymaganie: FR-20, NFR-06"

story "[FR-21] Metadane zdjęcia" \
"user story,priorytet: S,obszar: biblioteka" "$S3" "$ME" \
"**Jako** użytkownik **chcę** widzieć EXIF, kliszę i recepturę zdjęcia, **aby** wiedzieć, jak powstało.

**Kryteria akceptacji:**
- [ ] Panel informacji o zdjęciu
- [ ] Pogoda i lokalizacja tylko za zgodą użytkownika

Wymaganie: FR-21"

# ================= AI =================
story "[FR-22] Laborant AI – wywołanie z opisu (tool calling)" \
"user story,priorytet: M,obszar: AI" "$S2" "$ME" \
"**Jako** użytkownik **chcę** opisać pożądany efekt słowami, **aby** AI samo dobrało parametry wywołania.

**Kryteria akceptacji:**
- [ ] Narzędzia: set_film_stock, set_push_pull, set_grain, set_halation, create_recipe
- [ ] Argumenty walidowane i przycinane do dozwolonych zakresów
- [ ] Foundation Models na urządzeniu, API w chmurze jako zapas
- [ ] Każda interakcja logowana w AIInteraction

Wymaganie: FR-22"

story "[FR-23] Analiza sceny i sugestia kliszy" \
"user story,priorytet: S,obszar: AI" "$S2" "$ME" \
"**Jako** użytkownik **chcę**, aby aplikacja rozpoznała scenę i zaproponowała kliszę, **aby** szybciej uzyskać dobry efekt.

**Kryteria akceptacji:**
- [ ] Lokalna klasyfikacja Vision lub Core ML
- [ ] Sugestia jest niewymuszona i można ją zignorować

Wymaganie: FR-23"

story "[FR-24] Podgląd zmian proponowanych przez AI" \
"user story,priorytet: M,obszar: AI" "$S2" "$JAN" \
"**Jako** użytkownik **chcę** zobaczyć różnice przed zastosowaniem zmian AI, **aby** zachować kontrolę nad zdjęciem.

**Kryteria akceptacji:**
- [ ] Widok przed/po oraz lista zmienionych parametrów
- [ ] Przyciski Akceptuj i Odrzuć

Wymaganie: FR-24"

story "[FR-25] Obsługa niedostępności AI" \
"user story,priorytet: M,obszar: AI" "$S2" "$JAN" \
"**Jako** użytkownik **chcę** czytelnego komunikatu, gdy AI nie działa, **aby** móc kontynuować pracę ręcznie.

**Kryteria akceptacji:**
- [ ] Limit czasu i ponowienia z wykładniczym opóźnieniem
- [ ] Komunikaty dla braku modelu, braku sieci i błędnej odpowiedzi
- [ ] Testy jednostkowe każdej ścieżki błędu

Wymaganie: FR-25, DoD pkt 5"

# ================= DANE ZEWNĘTRZNE =================
story "[FR-26] Pogoda w momencie zdjęcia (WeatherKit)" \
"user story,priorytet: S,obszar: dane zewn." "$S3" "$ME" \
"**Jako** użytkownik **chcę**, aby aplikacja zapisywała pogodę przy zdjęciu, **aby** AI mogło uwzględnić warunki oświetlenia.

**Kryteria akceptacji:**
- [ ] Pobranie pogody tylko za zgodą na lokalizację
- [ ] Zapis w encji WeatherSnapshot
- [ ] Brak sieci nie blokuje zrobienia zdjęcia

Wymaganie: FR-26, NFR-07"

# ================= ZADANIA TECHNICZNE (QA/DevOps) =================
story "Konfiguracja CI (GitHub Actions, runner macOS)" \
"zadanie techniczne,priorytet: M,obszar: QA/DevOps" "$MVP" "$JAN" \
"Pipeline uruchamiający build i testy przy każdym PR do main.

**Kryteria akceptacji:**
- [ ] Build i testy na czystym runnerze macOS
- [ ] Ochrona gałęzi main: wymagany zielony CI i jedna recenzja

DoD pkt 1–3"

story "Modułowa struktura projektu (Swift Packages)" \
"zadanie techniczne,priorytet: M,obszar: QA/DevOps" "$MVP" "$ME" \
"Utworzenie pakietów CaptureKit, FilmEngine, DevelopQueue, LibraryStore, LabAssistant, SharedUI z osobnymi targetami testowymi.

**Kryteria akceptacji:**
- [ ] Moduły komunikują się tylko przez publiczne protokoły
- [ ] Każdy pakiet ma target testowy

NFR-12, matryca: architektura"

story "Model danych SwiftData i plan migracji" \
"zadanie techniczne,priorytet: M,obszar: QA/DevOps" "$MVP" "$ME" \
"Implementacja 10 encji z wersjonowanym schematem.

**Kryteria akceptacji:**
- [ ] VersionedSchema i SchemaMigrationPlan
- [ ] Test migracji na czystej instalacji

Matryca: baza danych"

story "Testy snapshotowe potoku obrazu" \
"zadanie techniczne,priorytet: M,obszar: QA/DevOps" "$S1" "$JAN" \
"Regresyjne testy wyników wywołania na zestawie referencyjnych plików DNG.

**Kryteria akceptacji:**
- [ ] Zestaw co najmniej 5 referencyjnych DNG w repozytorium
- [ ] Tolerancja różnic pikseli zdefiniowana w teście

DoD pkt 4"

story "Testy prompt injection i błędnych odpowiedzi LLM" \
"zadanie techniczne,priorytet: M,obszar: AI" "$S2" "$JAN" \
"Testy adwersaryjne Laboranta AI.

**Kryteria akceptacji:**
- [ ] Zestaw złośliwych promptów (np. próby wywołania nieistniejących narzędzi)
- [ ] Niepoprawne argumenty narzędzi są odrzucane
- [ ] Raport wyników w dokumentacji

Rola D"

story "Optymalizacja wydajności i pokrycie testami ≥60%" \
"zadanie techniczne,priorytet: M,obszar: QA/DevOps" "$STAB" "$ME" \
"Refaktoryzacja i profilowanie w Instruments przed code freeze.

**Kryteria akceptacji:**
- [ ] Spełnione NFR-01 do NFR-03
- [ ] Pokrycie logiki biznesowej co najmniej 60%

NFR-01–03, NFR-12"

story "Build w TestFlight i dokumentacja instalacyjna" \
"zadanie techniczne,priorytet: M,obszar: QA/DevOps" "$STAB" "$JAN" \
"Wdrożenie produkcyjne (KM4) w formie publicznego buildu TestFlight.

**Kryteria akceptacji:**
- [ ] Publiczny link TestFlight
- [ ] README z instrukcją budowania projektu ze źródeł

KM4"

echo "Gotowe ✔"
