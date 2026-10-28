# PUL — şahsy pul dolandyryşy

PUL, diňe bir adamyň özüne hyzmat edýän şahsy maliýe programmasy. Ähli
maglumatlar **enjamyň ýerli saklaýjysynda** (local storage) saklanýar:
internet, hasap ýa-da bulut synhronizasiýasy gerek däl.

## Esasy aýratynlyklar

- **Boş ledger bilen başlaýar** — programma hiç haçan nusgalyk (demo)
  maglumat goşmaýar. Ilkinji amaly özüňiz goşýarsyňyz.
- **Bir setirde jemi balans** 
- **Çalt goş** — tegelek düwmeler (0,5 / 1 / 5 / 10 / 15 / 20 /
  50) bilen mukdary, aşakyndaky kategoriýalar bilen ýerini saýlap, iki
  basyş bilen çykdajyny ýazyp bilersiňiz.
- **Girdeji / çykdajy yzarlamak** — kategoriýalar, bellikler we seneler
  bilen.
- **Aýlyk statistika** — bu aý, geçen aý we 3 aýlyk çykdajy paýlaşylyşy.
- **Giňeldilen hasabat** — soňky 6 aýyň grafikasy, öňki döwür bilen
  deňeşdirme we iň köp çykdajy edilen kategoriýalar.
- **Öz kategoriýalaryň** — ady, reňki we simgesi bilen girdeji ýa-da çykdajy
  kategoriýasyny goşup, üýtgedip we pozup bilersiňiz.
- **Göni baş sahypa** — programma açylanda onboarding däl-de, esasy ekran
  görkezilýär.
- **Öz hasaplaýjy** — goşmak, aýyrmak, köpeltmek, bölmek.
- **Balansy gizlemek** — ekranyň önünde balans görünmeli däl.
- **Ätiýaçlyk** — ähli amallaryňyzy klipboarda kopyalap, soňra gaýtadan
  getirip bilersiňiz (JSON).

## Gurluşy

```
lib/
├── app.dart                       # MaterialApp we bloc provider
├── app_dependencies.dart          # use case-leriň ýerleşişi
├── core/
│   ├── theme/                     # reňkler we tema
│   └── utils/                     # pul / sen formatterleri, hasaplaýjy
└── features/finance/
    ├── data/
    │   ├── backup/                # ätiýaçlyk (backup) codec
    │   ├── datasources/           # local storage (SharedPreferences)
    │   ├── models/                # JSON modelleri
    │   └── repositories/
    ├── domain/
    │   ├── entities/              # MoneyTransaction, TransactionCategory ...
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        ├── bloc/                  # FinanceBloc
        ├── pages/                 # dashboard, amallar, sazlamalar
        └── widgets/
```

## Ýerli saklaýjy

| Açary | Ýerleşişi |
| --- | --- |
| Amallar | `pul.transactions.v1` — JSON list |
| Balans görnüşi | `pul.balanceHidden.v1` |
| Öz kategoriýalar | `pul.customCategories.v1` |

`FinanceLocalDataSource` ähli ýazmalary bir wagtda geçirýär (write queue), şoňa
görä iki çalt amal biri-birini ýok etmeýär. Ýazmak başartmasa, ýalňyş mesajy
görkezilýär — maglumat ýitirilen ýaly görünmeýär.

Ätiýaçlyk JSON-y amallaryňyz bilen birlikde öz kategoriýalaryňyzy hem saklaýar.

Öňki wersiýalaryň seed eden nusgalyk amallary (`seed-` bilen başlanýan id)
programyň birinji gezek açylanda awtomatik ýok edilýär; öz goşan amallyňyz
gyzdyrylmaýar.

## Gelişdirme

```bash
flutter pub get
flutter run            # ýa-da: flutter run -d windows
flutter analyze
flutter test
```

## Testler

- `test/finance_local_data_source_test.dart` — ýerli saklaýjyş, boş başlangyç,
  ýazmak / okamak / öçürmek, köne demo maglumatlaryň arassalanyşy.
- `test/ledger_backup_codec_test.dart` — ätiýaçlygyň okalmagy we ýazylyşy.
- `test/widget_test.dart` — dashboard, boş ledger, ýatda saklamak.
- `test/formatters_test.dart`, `test/calculator_engine_test.dart` — kömekçiler.
