# Build with LuaLaTeX (phelanlab.cls needs it for Minion Pro / Myriad Pro)
$pdf_mode = 4;

# After the build, copy the PDF to the submission filename
# (fill in both names: e.g. phelan-lab06.pdf -> Phelan Micro Lab 06.pdf)
END {
    use File::Copy;
    copy('phelan-labNN.pdf', 'Phelan Circuits Lab NN.pdf') if -e 'phelan-labNN.pdf';
}
