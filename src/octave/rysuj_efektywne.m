#! /usr/bin/octave -qf
pwd()
pr_efekt = {"../ampl/progowe/wyniki/pr_efektywne.txt",
            "../ampl/progowe/wyniki/pr_efektywne_szczeg.txt"};

sw_efekt = {"../ampl/s_wazona/wyniki/sw_efektywne.txt",
            "../ampl/s_wazona/wyniki/sw_efektywne_szczeg.txt"};

rysuj_wyniki(pr_efekt, sw_efekt);
print -dpng -r300 "-S800,600" efekt.png;
pause()
