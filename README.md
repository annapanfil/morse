# MORSE
## Projekt zaliczeniowy na laboratoria z systemów operacyjnych

### Działanie
Skrypt zamienia tekst na kod morse’a.

### Składnia
`./morse.sh [OPCJE] [TEKST DO ZAMIANY]`

### Wyjście
TEKST w kodzie morse'a

### Dostępne flagi
  |                       |                                             |
  |:----------------------|:--------------------------------------------|
  |`-b, --beep`           |odtworzenie dźwięku                          |
  |`-d, --diode`          |miganie diodą (dla Raspberry Pi, wymaga gpio)|
  |`-f, --file-read`      |odczyt z pliku (wymaga ścieżki do pliku)     |
  |`-h, --help`           |wyświetlenie pomocy                          |
  |`-l, --long`           |zmiana znaku długiego sygnału na podany      |
  |`-s, --short`          |zmiana znaku krótkiego sygnału na podany     |
  |`-w, --file-write     `|zapis do pliku (wymaga ścieżki do pliku)     |  

### Przykład:
`./morse.sh -f IN -w OUT -l = -s o`

  Wczytanie danych z pliku IN i zapisanie ich reprezentacji w kodzie morse'a do pliku OUT
  Długie sygnały są reprezentowane przez =, a krótkie przez o

© Anna Panfil 2020
