#!/bin/bash
shortTime=0.1
longTime=$(echo 3*$shortTime | bc)
longSign="–"
shortSign="·"
word=""
beep=false
light=false

# krótki sygnał
function short {
  # wypisanie na stdout
  echo -n $shortSign

  # dźwięk i mignięcie diodą (dla Raspberry Pi)
  if [[ $light || $beep ]]; then
    if $beep; then
      exec 3>&2             # w 3 zapisz dawny stderr
      exec 2>/dev/null      # wycisz na chwilę stderr
      (speaker-test -t sine -f 500 >/dev/null) & pid=$!
    fi

    if $light; then
       gpio -g write 21 1
    fi

    sleep $shortTime

    if $beep; then
      kill -9 $pid
      exec 2>&3 3>&-       # przywróć stderr i zamknij strumień 3
    fi
    if $light; then
       gpio -g write 21 0
    fi

    sleep $shortTime
  fi
}

# długi sygnał
function long {
  # wypisanie na stdout
  echo -n $longSign

  # dźwięk i mignięcie diodą (dla Raspberry Pi)
  if [[ $light || $beep ]]; then
    if $beep; then
      exec 3>&2            # w 3 zapisz dawny stderr
      exec 2>/dev/null     # wycisz na chwilę stderr
      (speaker-test -t sine -f 500 >/dev/null) & pid=$!
    fi
    if $light; then
       gpio -g write 21 1
    fi

    sleep $longTime

    if $beep; then
      kill -9 $pid
      exec 2>&3 3>&-        # przywróć stderr i zamknij strumień 3
    fi
    if $light; then
       gpio -g write 21 0
    fi

    sleep $shortTime
  fi
}

# pomoc
function help {
printf "Składnia: ./morse.sh [OPCJE] [TEKST DO ZAMIANY]

TEKST w kodzie morse'a wysyłany na standardowe wyjście.

  -b, --beep               odtworzenie dźwięku
  -d, --diode              miganie diodą (dla Raspberry Pi, wymaga gpio)
  -f, --file-read          odczyt z pliku (wymaga ścieżki do pliku)
  -h, --help               wyświetlenie niniejszej pomocy
  -l, --long               zmiana znaku długiego sygnału na podany
  -s, --short              zmiana znaku krótkiego sygnału na podany
  -w, --file-write         zapis do pliku (wymaga ścieżki do pliku)

Przykład:

  ./morse.sh -f IN -w OUT -l = -s o
      Wczytanie danych z pliku IN i zapisanie ich reprezentacji w kodzie morse'a do pliku OUT
      Długie sygnały są reprezentowane przez =, a krótkie przez o\n"

  exit 0
}

# reprezentacja poszczególnych liter w kodzie morse'a
function alphabet {
  case "$letter" in
    [AĄ])short; long; echo -n " "
      ;;
    B)long; short; short; short; echo -n " "
      ;;
    [CĆ])long; short; long; short; echo -n " "
      ;;
    D)long; short; short; echo -n " "
      ;;
    [EĘ])short; echo -n " "
      ;;
    F)short; short; long; short; echo -n " "
      ;;
    G)long; long; short; echo -n " "
      ;;
    H)short; short; short; short; echo -n " "
      ;;
    I)short; short; echo -n " "
      ;;
    J)short; long; long; long; echo -n " "
      ;;
    K)long; short; long; echo -n " "
      ;;
    [LŁ])short; long; short; short; echo -n " "
      ;;
    M)long; long; echo -n " "
      ;;
    [NŃ])long; short; echo -n " "
      ;;
    [OÓ])long; long; long; echo -n " "
      ;;
    P)short; long; long; short; echo -n " "
      ;;
    Q)long; long; short; long; echo -n " "
      ;;
    R)short; long; short; echo -n " "
      ;;
    [SŚ])short; short; short; echo -n " "
      ;;
    T)long; echo -n " "
      ;;
    U)short; short; long; echo -n " "
      ;;
    V)short; short; short; long; echo -n " "
      ;;
    W)short; long; long; echo -n " "
      ;;
    X)long; short; short; long; echo -n " "
      ;;
    Y)long; short; long; long; echo -n " "
      ;;
    [ZŻŹ])long; long; short; short; echo -n " "
      ;;
    [" "])echo ""
      if [[ $beep || $light ]]; then
        sleep $(echo 2*$shortTime | bc) #2 są później
      fi;;
  esac

  if [[ $beep || $light ]]; then
    sleep $(echo 2*$shortTime | bc)
  fi
}

# wyświetlenie pomocy, jeśli brak argumentów
if [ "$*" == "" ]; then
  help
fi

# ODCZYT OPCJI
TEMP=`getopt -o bdf:hl:s:w: \
         --long beep,diode,file-read:,help,long:,short:,file-write: \
         --  "$@"`

eval set -- "$TEMP"

 while true; do
    case "$1" in
      -b | --beep ) beep=true; shift ;; # odtwarzanie dźwięku
      -d | --diode ) # miganie diodą (dla Raspberry Pi)
          command -v gpio >/dev/null && gpio -g mode 21 out && light=true || echo "Brak gpio, nie można zamigać." >&2; shift ;; # sprawdza, czy gpio istnieje
      -f | --file-read ) # odczyt z pliku
          if [ -r "$2" ]; then # jeśli plik istnieje i można go czytać
            exec <"$2"
            read word
          else
            printf "Nie można odczytać pliku %s.\nSprawdź czy plik istnieje i czy posiadasz uprawnienia do jego odczytu.\n" "$2" >&2
            exit 1
          fi
        shift 2 ;;
      -h | --help ) help;;
      -l | --long ) longSign=$2; shift 2 ;; # znak długi
      -s | --short ) shortSign=$2; shift 2;; # znak krótki
      -w | --file-write ) # zapis do pliku
          printf "zapis do pliku %s\n" "$2"
          exec 1>&$2
          shift 2 ;;
      -- ) shift; break ;;
      * ) break ;;
    esac
  done

# REPREZENTACJA W KODZIE MORSE'A
if [ "$word" == "" ]; then word="$1"; fi    # wczytanie słowa, o ile nie wczytane z pliku
i=1
while (($i <= ${#word})); do
  letter=$(expr substr "$word" $i 1 | tr [:lower:]ąćęłóńśżź [:upper:]ĄĆĘŁÓŃŚŻŹ) # podział słowa na litery, zamiana na duże litery
  alphabet            # wypisanie reprezentacji litery w kodzie morse'a
  i=$(($i+1))
done
echo ""

if $light; then
  gpio -g mode 21 in   # zablokowanie pinu – dla Raspberry Pi
fi

exit 0

# © Anna Panfil 2020
