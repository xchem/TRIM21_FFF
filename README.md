
# TRIM21 FFF

## 2. Setup the Target for FFF with HIPPO and BulkDock

- [x] Define merging opportunities by creating tags of LHS hits in Fragalysis

> use all fragments

- [x] Download target from Fragalysis and place the .zip archive in the repo
- [x] Setup target in BulkDock 

```bash
cp -v TRIM21.zip $BULK/TARGETS
cd $BULK
python -m bulkdock extract TRIM21
python -m bulkdock setup TRIM21
```

- [x] Copy the `aligned_files` directory from `$BULK/TARGETS/TRIM21/aligned_files` into this repository

```bash
cd - 
cp -rv $BULK/TARGETS/TRIM21/aligned_files .
```

## 3. Compound Design

- [ ] run the notebook `hippo/1_merge_prep.ipynb`

### Fragmenstein

For each merging hypothesis (i.e. iter1)

- [ ] go to the fragmenstein subdirectory `cd fragmenstein`
- [ ] queue fragmenstein job 

```bash
sbatch --job-name "TRIM21_iter1_fragmenstein" --mem 16000 $HOME2/slurm/run_bash_with_conda.sh run_fragmenstein.sh iter1
```

This will create outputs in the chosen iter1 subdirectory:

- **`iter1_fstein_bulkdock_input.csv`: use this for BulkDock placement**
- `output`: fragmenstein merge poses in subdirectories
- `output.sdf`: fragmenstein merge ligand conformers
- `output.csv`: fragmenstein merge metadata

- [ ] placement with bulkdock

```bash
cp -v iter1_fstein_bulkdock_input.csv $BULK/INPUTS/TRIM21_iter1_fstein.csv
cd $BULK
python -m bulkdock place TRIM21 INPUTS/TRIM21_iter1_fstein.csv
```

- [ ] monitor placements (until complete)

```bash
python -m bulkdock status
```

To loop indefinitely:

```bash
watch python -m bulkdock status
```

- [ ] export Fragalysis SDF

```bash
python -m bulkdock to-fragalysis TRIM21 OUTPUTS/SDF_FILE iter1_fstein
```

- [ ] Copy back to this repository

```bash
cd -
cp -v $BULK/OUTPUTS/TRIM21_iter1*fstein*fragalysis.sdf .
```

### Fragment Knitwork

Running Fragment Knitting currently requires access to a specific VM known as `graph-sw-2`. If you don't have access, skip this section

- [ ] `git add`, `commit` and `push` the contents of `aligned_files` and `knitwork` to the repository
- [ ] `git clone` the repository on `graph-sw-2`
- [ ] navigate to the `knitwork` subdirectory

Then, for each merging hypothesis:

- [ ] Run the "fragment" step of FragmentKnitwork: `./run_fragment.sh iter1`
- [ ] Run the pure "knitting" step of FragmentKnitwork: `./run_knitwork_pure.sh iter1`
- [ ] Run the impure "knitting" step of FragmentKnitwork: `./run_knitwork_impure.sh iter1`
- [ ] Create the BulkDock inputs: `python to_bulkdock.py iter1`
- [ ] `git add`, `commit` and `push` the CSVs created by the previous step
- [ ] back on `cepheus-slurm` pull the latest changes
- [ ] Run BulkDock placement as for Fragmenstein above

```bash
cp -v iter1_knitwork_pure.csv $BULK/INPUTS/TRIM21_iter1_knitwork_pure.csv
cp -v iter1_knitwork_impure.csv $BULK/INPUTS/TRIM21_iter1_knitwork_impure.csv
cd $BULK
python -m bulkdock place TRIM21 INPUTS/TRIM21_iter1_knitwork_pure.csv
python -m bulkdock place TRIM21 INPUTS/TRIM21_iter1_knitwork_impure.csv
```

### Summary tables / figures

**CREATE NOTEBOOK**

- [ ] Export Fragalysis SDF

```bash
cd $BULK
python -m bulkdock to-fragalysis TRIM21 OUTPUTS/SDF_FILE iter1_knit_pure
python -m bulkdock to-fragalysis TRIM21 OUTPUTS/SDF_FILE iter1_knit_impure
```

- [ ] Copy back to this repository

```bash
cd -
cp -v $BULK/OUTPUTS/TRIM21_iter1*knitwork*fragalysis.sdf .
```

## 4. Scaffold selection

Once merges have been generated for a given merging hypothesis, they should be sanity checked in some or all of the following ways:

- [ ] [Fragalysis curation](https://fragalysis.readthedocs.io/en/latest/rhs.html#how-to-curate-select-compounds-in-fragalysis) -> curation CSVs
- [ ] Chemistry review -> syndirella manual input CSV
- [ ] Syndirella retrosynthesis check (documentation pending)

- [ ] Modify and run the notebook `hippo/2_scaffold_selection.ipynb`. This will generate the syndirella inputs

- [ ] Queue the syndirella jobs (for each merging hypothesis/iteration)

```bash
cd syndirella
./submit_elabs.sh iter1
```

- [ ] Check the elabs with the notebook `hippo/3_check_elabs.ipynb`.

- [ ] Queue the job to load all the elabs into the HIPPO database

- [ ] Inspect the outputs

## 5. Syndirella elaboration

**INCREASE MEMORY ALLOCATION**

## 6. HIPPO

### Load elaborations
### Quote reactants
### Solve routes
### Calculate interactions
### Generate random recipes
### Score random recipes
### Optimise best recipes
### Create proposal web page

## 7. Review & order

### Review chemistry
### Order reactants

## Getting the latest version of the scripts

If the scripts in your forked copy are out of date you can fetch them by synchronising them with the template repository. First add the template remote and fetch it:

```bash
git remote add template https://github.com/xchem/FFF_Template.git
git fetch template
```

Then merge the changes. **You will likely need to resolve some conflicts, so only do this if you are familiar with git!**

```bash
git merge template/main
```
