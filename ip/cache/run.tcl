clear -all;
analyze -sv12 cache.sv;
elaborate -extract_covergroup;
clock -infer
reset -expression rst
prove -bg -all
