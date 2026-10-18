# Build with LuaLaTeX (phelanbook.cls needs it for Minion Pro / Myriad Pro)
$pdf_mode = 4;
# The classes live one folder up, in the repo root.
ensure_path('TEXINPUTS', '../');
