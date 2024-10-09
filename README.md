Files with prefix "nb_" are jupyter notebooks.

There are original observation folders named as per ObsID

The same folders inside nicer/bootstrap_folder contain period estimations made by bootstrap python script. 

lcfile.txt contains the path of all the lightcurves generated for each ObsID. It can be given to ftools for quick run. 

Scripts used for NICER analysis, all scripts save a log file inside individual observation folders.
| Script Name                 | Description                                                     |
|-----------------------------|-----------------------------------------------------------------|
| `download_files.sh`          | Downloading observation batch                                  |
| `lc_efold.sh`               | Epoch folding with manual input of known period                 |
| `lc_file_combine.sh`        | Script to gather paths of all light curves inside observation folders |
| `run_barrycorr_day.sh`      | Run barycenter correction on cleaned event files (Day)          |
| `run_barrycorr_night.sh`    | Run barycenter correction on cleaned event files (Night)        |
| `run_nicer.sh`              | Run `nicerl2` task to generate cleaned event files              |
| `run_nicerl3_lc_day.sh`     | Run `nicerl3-lc` task to generate light curve with desired binning (Day) |
| `run_nicerl3_lc_night.sh`   | Run `nicerl3-lc` task to generate light curve with desired binning (Night) |
| `run_nicerl3_lc_night_binned.sh` | Run `nicerl3-lc` on observation for different energy bins

Notebooks Used in the Analysis
| Notebook Name                 | Description                                                     |
|-----------------------------|-----------------------------------------------------------------|
| `nb_bootstrap_error.ipynb`          | Predicting period using bootstrap method. Outputs best fit period and max chi-sq as text file inside `bootstrap_error` folder with respected obsID folder dynamically created.                               |
| `nb_bootstrap_reportin.ipynb`               | Plotting variation of period with iteration using best fit period texts generated from previous script                 |
| `nb_folding_pulse_fraction.ipynb`        | Epoch folding using python and RMS Pulsed fraction computation|
| `nb_rms_phase_resolved_deviation.ipynb`        | Computing RMS deviation in each phase. Contains own implementation and Aru implementation. Outputs png to `rms_calc` folder |
