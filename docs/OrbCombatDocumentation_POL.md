# OrbCombat — Pełna Dokumentacja Projektu

## Spis Treści
1. [Opis Projektu](#opis-projektu)
2. [Stos Technologiczny](#stos-technologiczny)
3. [Struktura Projektu](#struktura-projektu)
4. [Ekrany](#ekrany)
5. [Typy Orbów](#typy-orbów)
6. [Efekty Statusu](#efekty-statusu)
7. [Systemy Główne](#systemy-główne)
8. [Autoloady](#autoloady)
9. [Komponenty UI](#komponenty-ui)
10. [Zewnętrzne API](#zewnętrzne-api)
11. [Lokalna Baza Danych](#lokalna-baza-danych)
12. [Sklep i Kapelusze](#sklep-i-kapelusze)
13. [Eksport na Android](#eksport-na-android)

---

## Opis Projektu

OrbCombat to symulator walk oparty na fizyce, stworzony w Godot 4 na system Android. Dwa orby walczą autonomicznie na arenie, odbijając się od ścian i siebie nawzajem. Każdy typ orba posiada unikalne statystyki i specjalną zdolność. Gracz obstawia monety na wynik walki i może kupować kosmetyczne kapelusze w sklepie.

---

## Stos Technologiczny

| Komponent | Technologia |
|---|---|
| Silnik | Godot 4 |
| Język | GDScript |
| Platforma | Android (APK) |
| Lokalna baza danych | Godot FileAccess (`user://stats.txt`) |
| Zewnętrzne API | randomuser.me REST API |
| Kontrola wersji | Git / GitHub |

---

## Struktura Projektu

```
res://
├── Fighters/
│   ├── ball.gd              # Bazowy skrypt orba
│   ├── ball.tscn            # Bazowa scena orba
│   └── orbs/
│       ├── fire_orb.gd / fire_orb.tscn
│       ├── ice_orb.gd / ice_orb.tscn
│       ├── slime_orb.gd / slime_orb.tscn
│       ├── sword_orb.gd / sword_orb.tscn
│       ├── boom_ball.gd / boom_ball.tscn
│       └── puffer_orb.gd / puffer_orb.tscn
├── Conditions/
│   ├── burn.gd              # Efekt statusu: podpalenie
│   └── freeze.gd            # Efekt statusu: zamrożenie
├── Effects/
│   ├── explosion.tscn       # Wizualny efekt wybuchu
│   └── death_particle.tscn  # Cząsteczki śmierci
├── Hats/
│   └── (tekstury kapeluszy)
├── Shop/
│   ├── shop.tscn / shop.gd
│   └── hat_panel.tscn / hat_panel.gd
├── UI/
│   └── orb_card.tscn        # Karta statystyk pojedynczego orba
├── Abilities/
│   └── weapon.gd            # Logika broni Sword Orba
├── game_state.gd            # Autoload: dane między scenami
├── player_stats.gd          # Autoload: trwałe statystyki gracza
├── hats.gd                  # Autoload: definicje kapeluszy
├── main_menu.tscn
├── fighter_select.tscn
└── game.tscn
```

---

## Ekrany

### 1. Menu Główne (`main_menu.tscn`)
Punkt wejścia aplikacji. Wyświetla tytuł gry i przycisk "Graj" prowadzący do ekranu wyboru wojownika.

---

### 2. Wybór Wojownika (`fighter_select.tscn`)
Pozwala graczowi skonfigurować walkę przed jej rozpoczęciem.

**Funkcje:**
- Dwa przyciski `OptionButton` do wyboru typów orbów
- Zabezpieczenie przed wybraniem tego samego orba dwa razy (wyskakujące okno `AcceptDialog`)
- `OptionButton` do wyboru, na którego wojownika gracz obstawia
- `SpinBox` do ustawienia kwoty zakładu (max = aktualne monety gracza)
- Przycisk do sklepu
- Pasek statystyk z monetami, wygranymi i przegraanymi

---

### 3. Sklep (`shop.tscn`)
Przewijana lista kapeluszy do kupienia.

**Funkcje:**
- Dynamicznie generuje jeden panel na każdy kapelusz zdefiniowany w `Hats.HATS`
- Każdy panel pokazuje podgląd, nazwę, cenę i jeden przycisk akcji
- Przycisk akcji cyklicznie zmienia stan: **Kup** → **Załóż** → **Zdejmij**
- Zakup odejmuje monety z `PlayerStats`
- Pasek statystyk
- Przycisk resetowania statystyk z oknem potwierdzenia

---

### 4. Gra (`game.tscn`)
Główny ekran walki.

**Struktura sceny:**
```
Game (Control)
├── WorldBorders (Node2D) — arena, centrowana na ekranie w trakcie działania
│   ├── LeftPanel / RightPanel — panele statystyk orbów
│   └── 4x StaticBody2D — ściany kolizji
├── Fighters (Node2D) — tu są dodawane orby
├── CanvasLayer
│   ├── GameOverPanel
│   └── StatsBar
├── Background
└── WorldEnvironment
```

**Kluczowe odpowiedzialności:**
- Centrowanie areny: `$WorldBorders.position = (screen_size - arena_size) / 2`
- Tworzenie wybranych wojowników z `GameState`
- Przypisywanie drużyn (`"one"` / `"two"`) i nazw wojownikom
- Podłączenie sygnału `name_loaded` do zapisania nazw po odpowiedzi API
- Nakładanie kapelusza na wojownika, na którego gracz obstawił
- Wykrywanie końca gry przez sprawdzanie żywych orbów w grupie `"ball"`
- Rozliczanie zakładu i wyświetlanie panelu końca gry

---

### 5. Panel Końca Gry (`GameOverPanel` w `game.tscn`)
Wyświetlany gdy jedna lub obie drużyny nie mają żywych orbów. Pokazuje wynik, rozlicza zakład i oferuje przycisk "Zagraj ponownie".

---

## Typy Orbów

Wszystkie orby rozszerzają `ball.gd` i nadpisują `use_ability(target)`.

| Orb | Zdrowie | Obrażenia | Rozmiar | Prędkość | Specjalna Zdolność |
|-----|---------|-----------|---------|----------|--------------------|
| Ball | 100 | 10 | 1.0 | 600 | Brak |
| Fire Orb | 80 | 0 | 0.8 | 600 | Nakładające się podpalenie |
| Ice Orb | 100 | 6 | 1.1 | 600 | Zamraża cel na 3 takty |
| Slime Orb | 100 | 8 | 1.2 | 450 | Dzieli się na 2 po śmierci (maks. 3 generacje) |
| Sword Orb | 120 | 5 | 1.0 | 600 | Obracający się miecz zadaje 15 dmg z odrzutem |
| Boom Ball | 120 | 8 | 1.1 | 600 | Wybucha co 10 taktów, 25 dmg w promieniu |
| Puffer Orb | 100 | 5/15 | 0.6/2.0 | 600 | Puchnie co 5s: rozmiar x2, obrażenia x3 |

---

### Fire Orb
Wstrzykuje węzeł `Burn` na cel przy każdym trafieniu. Kolejne trafienia dokładają kolejne poziomy. Nie zadaje bezpośrednich obrażeń przy kolizji (`damage = 0`).

### Ice Orb
Wstrzykuje węzeł `Freeze` na cel. Resetuje czas trwania do 3 taktów jeśli cel jest już zamrożony. Ruch jest "ślizgający się" dzięki interpolacji prędkości. Przyjmuje 2 obrażenia przy każdym odbiciu (od ścian i orbów).

### Slime Orb
Nadpisuje `take_damage` z flagą `is_dying` zapobiegającą podwójnej śmierci. Po śmierci tworzy 2 dzieci przez `duplicate()` z następną generacją. Dzieci dziedziczą imię rodzica z sufiksem rzymskim i mają `skip_name_fetch = true`.

**Generacje:**
| Gen | Zdrowie | Obrażenia | Rozmiar | Prędkość |
|-----|---------|-----------|---------|----------|
| 0 | 100 | 8 | 1.2 | 450 |
| 1 | 50 | 4 | 1.0 | 600 |
| 2 | 25 | 2 | 0.6 | 750 |

### Sword Orb
Węzeł `Pivot` obraca się każdą klatką. `Weapon` (Area2D) jest przesunięty od środka, by orbitować wokół orba. Jedno boolean cooldown zapobiega wielokrotnym trafieniom. Miecz jest ukryty i wyłączony podczas zamrożenia orba.

### Boom Ball
Liczy takty (1 na sekundę) w `_physics_process`. W takcie 10 tworzy `explosion.tscn`, przekazuje `self` jako `source` aby zapobiec samoobrażeniom, a następnie resetuje licznik. Eksplozja to `Area2D` z animacją implozji (zaczyna od pełnego rozmiaru, kurczy się do 0.5) która natychmiastowo zadaje obrażenia wszystkim orbom w środku oprócz źródła.

### Puffer Orb
Automatycznie przełącza stan napuszenia. Eksportuje `normal_texture` i `puff_texture` zamieniane przy zmianie stanu. Zdolność uruchamia się tylko gdy orb nie jest napuszony i nie jest na cooldownie.

---

## Efekty Statusu

Efekty statusu to samodzielne skrypty `Node` wstrzykiwane jako dzieci celu w czasie rzeczywistym.

### Podpalenie (`burn.gd`)
| Właściwość | Wartość |
|---|---|
| Częstotliwość | Co 1 sekundę |
| Obrażenia na takt | Równe liczbie poziomów |
| Kumulacja | Tak — każde trafienie Fire Orba dodaje 1 poziom |
| Sprzątanie | Usuwany gdy rodzic ginie |

### Zamrożenie (`freeze.gd`)
| Właściwość | Wartość |
|---|---|
| Czas trwania | 3 takty (po 1 sekundzie każdy) |
| Efekt | `speed = 0`, `velocity = Vector2.ZERO` |
| Interakcja z mieczem | Miecz Sword Orba ukryty i wyłączony |
| Sprzątanie | Przywraca oryginalną prędkość i wektorem, następnie `queue_free()` |

---

## Systemy Główne

### System Kolizji (`ball.gd`)

Używa `static var handled_this_frame` — listy współdzielonej przez wszystkie instancje orbów, czyszczonej każdą klatką fizyki. Każda kolizja generuje posortowaną parę ID z instancji obu orbów, tak że A→B i B→A mapują się na ten sam wpis. Pierwszy orb wykrywający kolizję obsługuje obrażenia i zdolności dla obu stron oraz ustawia obu jako niewrażliwych.

```
Wykryto kolizję
→ Generuj posortowane ID kolizji
→ Jeśli ID nie ma w handled_this_frame:
    → Zadaj obrażenia (obu stronom)
    → Zastosuj zdolności (obu stronom)
    → Ustaw obu jako niewrażliwych
    → Dodaj ID do handled_this_frame
→ Oblicz kierunek odpychania + losowy kąt
→ Ustaw prędkość
```

Zamrożone orby nie zadają obrażeń (sprawdzane przez `get_node_or_null("Freeze")` przed zadaniem obrażeń).

### Naprowadzanie
Po każdym odbiciu od ściany prędkość jest lekko kierowana w stronę najbliższego wroga:
```gdscript
velocity = velocity.lerp(direction_to_enemy * speed, STEERING_STRENGTH)
```

### Pobieranie Imienia
Każdy orb wykonuje asynchroniczne żądanie `HTTPRequest` w `_ready` do randomuser.me. Po sukcesie ustawia `name` na zwrócone imię i emituje `name_loaded`. Pomijane jeśli `skip_name_fetch = true` (używane przez dzieci Slime Orba).

### Śmierć
Tworzy `deathParticle` w pozycji światowej, następnie `queue_free()`. Cząsteczki śmierci są dodawane do `get_tree().current_scene` żeby chwilę przetrwały po usunięciu orba.

---

## Autoloady

### `game_state.gd`
| Zmienna | Typ | Opis |
|---|---|---|
| `fighter_one` | String | Ścieżka sceny wojownika 1 |
| `fighter_two` | String | Ścieżka sceny wojownika 2 |
| `bet_on` | String | `"one"` lub `"two"` |
| `bet_amount` | int | Postawione monety |

### `player_stats.gd`
| Zmienna | Domyślna | Opis |
|---|---|---|
| `coins` | 100 | Aktualne saldo |
| `wins` | 0 | Łączna liczba wygranych |
| `losses` | 0 | Łączna liczba przegranych |
| `owned_hats` | `[]` | Kupione kapelusze |
| `equipped_hat` | `""` | Aktualnie założony kapelusz |

| Metoda | Efekt |
|---|---|
| `add_win(bet)` | `wins += 1`, `coins += bet * 2` |
| `add_loss(bet)` | `losses += 1`, `coins -= bet` |
| `add_draw(bet)` | `coins += bet` (zwrot) |
| `buy_hat(id, price)` | Odejmuje cenę, dodaje do posiadanych |
| `equip_hat(id)` | Ustawia założony (przekaż `""` żeby zdjąć) |
| `reset_stats()` | Resetuje wszystko do wartości domyślnych |

### `hats.gd`
Słownik wszystkich dostępnych kapeluszy. Dodanie nowego kapelusza wymaga tylko nowego wpisu tutaj.

---

## Komponenty UI

### Pasek Statystyk (`stats_bar.gd`)
Górny pasek pokazujący monety, wygrane i przegrane. Odczytuje `PlayerStats` każdą klatką. Działa na każdym panelu z dowolnym podzbiorem trzech etykiet.

### Panele Boczne (`stats_panel.gd`)
Jeden panel na drużynę obok areny. Rozszerza `VBoxContainer`. Dynamicznie tworzy jedną `orb_card` na każdego żywego orba. Karty są przebudowywane tylko gdy zmienia się liczba orbów; wartości aktualizują się każdą klatką.

### Karta Orba (`orb_card.tscn`)
Pokazuje imię, HP, obrażenia, prędkość i podgląd sprite'a pojedynczego orba. Wszystkie wartości ustawiane przez `stats_panel.gd`.

### Panel Kapelusza (`hat_panel.gd`)
Jeden przycisk akcji obsługuje wszystkie stany: Kup / Załóż / Zdejmij. Po zmianie stanu odświeża wszystkie siostrzane panele.

### OrbUI (`orb_ui.gd`)
Dziecko każdej sceny orba. Wyświetla etykietę z imieniem i pasek zdrowia bezpośrednio pod orbem. Przeciwdziała skalowaniu rodzica żeby UI pozostało stałego rozmiaru pikselowego niezależnie od rozmiaru orba.

---

## Zewnętrzne API

**Dostawca:** [randomuser.me](https://randomuser.me)  
**Cel:** Przypisanie losowych imion orbom przy tworzeniu  
**Koszt:** Bezpłatne, bez klucza API

**Endpoint:**
```
GET https://randomuser.me/api/?inc=name&noinfo&nat=US,GB,AU,CA,PL,DE,FR,SE,CZ,CH
```

**Narodowości:** USA, Wielka Brytania, Australia, Kanada, Polska, Niemcy, Francja, Szwecja, Czechy, Szwajcaria — wszystkie z alfabetem łacińskim, aby uniknąć problemów z renderowaniem tekstu RTL.

**Przepływ:**
1. Orb się tworzy → `fetch_name()` wywoływane w `_ready`
2. Tworzony węzeł `HTTPRequest`, dodawany jako dziecko, wysyłane żądanie
3. Po odpowiedzi → wyodrębniane imię → ustawiane `name` → emitowany `name_loaded`
4. `game.gd` zapisuje imię przez podłączoną lambdę do użycia na ekranie końca gry

**Dzieci Slime Orba** pomijają pobieranie i używają: `"ImięRodzica II"`, `"ImięRodzica III"`

---

## Lokalna Baza Danych

Plik: `user://stats.txt` (Android: prywatny katalog wewnętrzny aplikacji)

**Format (jedna wartość na linię):**
```
100            ← monety
6              ← wygrane
9              ← przegrane
tophat,cap     ← posiadane kapelusze (oddzielone przecinkami)
tophat         ← założony kapelusz (pusty string jeśli brak)
```

Tworzony automatycznie przy pierwszym zapisie. Wczytywany w `player_stats.gd _ready()`.

---

## Sklep i Kapelusze

Kapelusze to kosmetyczne przedmioty kupowane za monety. Założony kapelusz pojawia się na wojowniku, na którego gracz obstawił. Nakładany przez ustawienie tekstury węzła `Sprite2D` o nazwie `Hat` obecnego w każdej scenie orba (domyślnie bez tekstury).

**Ekonomia monet:**
| Zdarzenie | Monety |
|---|---|
| Saldo startowe | 100 |
| Wygrana | +zakład × 2 |
| Przegrana | -zakład |
| Remis | +zakład (zwrot) |

---

## Eksport na Android

| Ustawienie | Wartość |
|---|---|
| Format eksportu | APK |
| Minimalne SDK | 24 |
| Docelowe SDK | 35 |
| Architektura | arm64-v8a |
| Rozdzielczość viewport | 480 × 854 |
| Tryb rozciągania | canvas_items |
| Aspekt rozciągania | expand |
| Orientacja | Pionowa |

**Podpisywanie:** APK release podpisywany keystore'em wygenerowanym przez `keytool`. Keystore nie jest commitowany do repozytorium.

**Dystrybucja:** APK instalowany ręcznie. Użytkownicy muszą włączyć "Instalowanie z nieznanych źródeł" w ustawieniach Androida.
