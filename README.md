# FFF_Template

To use this repository:

1. Use this template to create a new repository
1. Clone the newly repository on IRIS
1. Follow the steps indicated below

## 1. Dependencies

Skip this section if you have run a FFF campaign with this template before

### Pre-requisites

- [ ] Get SSH access to `cepheus-slurm.diamond.ac.uk`. You may need to tunnel via `ssh.diamond.ac.uk`

- [ ] Create a working directory (and symbolic link for convenience): 

```bash
DATA=/opt/xchem-fragalysis-2
mkdir -pv $DATA/YOUR_NICKNAME
ln -s $DATA/YOUR_NICKNAME $HOME/YOUR_NICKNAME
```

- [ ] Install conda

```bash
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
CONDA_PREFIX=$HOME/YOUR_NICKNAME/conda
bash Miniforge3-$(uname)-$(uname -m).sh -p $CONDA_PREFIX -b
source $CONDA_PREFIX/etc/profile.d/conda.sh
```

- [ ] Activate @mwinokan's environment:

```bash
conda activate $DATA/maxwin/conda/envs/py312
```

- [ ] Configure Jupyter (you will be prompted to set a password)

```bash
bash $DATA/maxwin/slurm/notebook.sh -p 9500 -d YOUR_NICKNAME -cd conda -jc $DATA/YOUR_NICKNAME/jupyter_slurm -ce py312 -ajc -js
```

- [ ] Submit a jupyter notebook job (will expire every 8 days)

```bash
sbatch --job-name notebook -p gpu --exclusive $DATA/maxwin/slurm/notebook.sh -p 9500 -d YOUR_NICKNAME -cd conda -jc $DATA/YOUR_NICKNAME/jupyter_slurm -ce py312 -ajc
```

- [ ] Check which IP address your job is running on, using the job ID from the submitted job:

```bash
rq -j JOB_ID --long
```

- [ ] log out of cepheus-slurm and log back in while forwarding the correct port, e.g. the below will assumes your job is running on `192.168.222.22` with port `9500` and will allow you to access the notebook at `localhost:8080` from a browser:

```bash
ssh -L 8080:192.168.222.22:9500 cepheus-slurm.diamond.ac.uk
```

- [ ] For Fragment Knitwork access to the `graph-sw2` VM is via bastion and needs to be requested from @mwinokan

### Checklist

- [ ] you can ssh to IRIS (cepheus-slurm.diamond.ac.uk)
- [ ] you can connect to a Jupyter notebook on IRIS
- [ ] you can run `python -m bulkdock status` from the BulkDock directory
- [ ] you can `import hippo` from a notebook
- [ ] you can run `fragmenstein --help`
- [ ] you can ssh to the graph-sw2 VM (optional, only for Knitwork)
- [ ] you can run `syndirella --help`

## 2. Setup the Target for FFF with HIPPO and BulkDock

- [ ] Define merging opportunities by creating tags of LHS hits in Fragalysis
- [ ] Download target from Fragalysis and place the .zip archive in the repo
- [ ] Setup target in BulkDock 

```bash
cp -v TARGET_NAME.zip $BULK/TARGETS
cd $BULK
python -m bulkdock extract TARGET_NAME
python -m bulkdock setup TARGET_NAME
```

- [ ] Copy the `aligned_files` directory from `$BULK/TARGETS/TARGET_NAME/aligned_files` into this repository

```bash
cd - 
cp -rv $BULK/TARGETS/TARGET_NAME/aligned_files .
```

## 3. Compound Design

- [ ] run the notebook `hippo/1_merge_prep.ipynb`

### Fragmenstein

For each merging hypothesis (i.e. HYPOTHESIS_NICKNAME)

- [ ] go to the fragmenstein subdirectory `cd fragmenstein`
- [ ] queue fragmenstein job 

```bash
sbatch --job-name "TARGET_NAME_HYPOTHESIS_NICKNAME_fragmenstein" --mem 16000 $HOME2/slurm/run_bash_with_conda.sh run_fragmenstein.sh HYPOTHESIS_NICKNAME
```

This will create outputs in the chosen HYPOTHESIS_NICKNAME subdirectory:

- **`HYPOTHESIS_NICKNAME_fstein_bulkdock_input.csv`: use this for BulkDock placement**
- `output`: fragmenstein merge poses in subdirectories
- `output.sdf`: fragmenstein merge ligand conformers
- `output.csv`: fragmenstein merge metadata

- [ ] placement with bulkdock

```bash
cp -v HYPOTHESIS_NICKNAME_fstein_bulkdock_input.csv $BULK/INPUTS/TARGET_NAME_HYPOTHESIS_NICKNAME_fstein.csv
cd $BULK
python -m bulkdock place TARGET_NAME INPUTS/TARGET_NAME_HYPOTHESIS_NICKNAME_fstein.csv
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
python -m bulkdock to-fragalysis TARGET_NAME OUTPUTS/SDF_FILE HYPOTHESIS_NICKNAME_fstein
```

- [ ] Copy back to this repository

```bash
cd -
cp -v $BULK/OUTPUTS/TARGET_NAME_HYPOTHESIS_NICKNAME*fstein*fragalysis.sdf .
```

### Fragment Knitwork

Running Fragment Knitting currently requires access to a specific VM known as `graph-sw-2`. If you don't have access, skip this section

- [ ] `git add`, `commit` and `push` the contents of `aligned_files` and `knitwork` to the repository
- [ ] `git clone` the repository on `graph-sw-2`
- [ ] navigate to the `knitwork` subdirectory

Then, for each merging hypothesis:

- [ ] Run the "fragment" step of FragmentKnitwork: `./run_fragment.sh HYPOTHESIS_NICKNAME`
- [ ] Run the pure "knitting" step of FragmentKnitwork: `./run_knitwork_pure.sh HYPOTHESIS_NICKNAME`
- [ ] Run the impure "knitting" step of FragmentKnitwork: `./run_knitwork_impure.sh HYPOTHESIS_NICKNAME`
- [ ] Create the BulkDock inputs: `python to_bulkdock.py HYPOTHESIS_NICKNAME`
- [ ] `git add`, `commit` and `push` the CSVs created by the previous step
- [ ] back on `cepheus-slurm` pull the latest changes
- [ ] Run BulkDock placement as for Fragmenstein above

```bash
cp -v HYPOTHESIS_NICKNAME_knitwork_pure.csv $BULK/INPUTS/TARGET_NAME_HYPOTHESIS_NICKNAME_knitwork_pure.csv
cp -v HYPOTHESIS_NICKNAME_knitwork_impure.csv $BULK/INPUTS/TARGET_NAME_HYPOTHESIS_NICKNAME_knitwork_impure.csv
cd $BULK
python -m bulkdock place TARGET_NAME INPUTS/TARGET_NAME_HYPOTHESIS_NICKNAME_knitwork_pure.csv
python -m bulkdock place TARGET_NAME INPUTS/TARGET_NAME_HYPOTHESIS_NICKNAME_knitwork_impure.csv
```

### Summary tables / figures

**CREATE NOTEBOOK**

- [ ] Export Fragalysis SDF

```bash
cd $BULK
python -m bulkdock to-fragalysis TARGET_NAME OUTPUTS/SDF_FILE HYPOTHESIS_NICKNAME_knit_pure
python -m bulkdock to-fragalysis TARGET_NAME OUTPUTS/SDF_FILE HYPOTHESIS_NICKNAME_knit_impure
```

- [ ] Copy back to this repository

```bash
cd -
cp -v $BULK/OUTPUTS/TARGET_NAME_HYPOTHESIS_NICKNAME*knitwork*fragalysis.sdf .
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
./submit_elabs.sh HYPOTHESIS_NICKNAME
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
