import nibabel as nib
import numpy as np
from nilearn import datasets

# Define mapping from atlas labels to major lobes
# (based on Harvard-Oxford Cortical Structural Atlas)
lobe_mapping = {
    # Frontal
    'Frontal Pole': 'FL',
    'Superior Frontal Gyrus': 'FL',
    'Middle Frontal Gyrus': 'FL',
    'Inferior Frontal Gyrus, pars triangularis': 'FL',
    'Inferior Frontal Gyrus, pars opercularis': 'FL',
    'Precentral Gyrus': 'FL',
    'Frontal Medial Cortex': 'FL',
    'Frontal Orbital Cortex': 'FL',
    'Paracingulate Gyrus': 'FL',
    'Subcallosal Cortex': 'FL',
    'Cingulate Gyrus, anterior division': 'FL',
    'Cingulate Gyrus, posterior division': 'FL',
    'Juxtapositional Lobule Cortex': 'FL',
    'Olfactory Cortex': 'FL',

    # Parietal
    'Postcentral Gyrus': 'PL',
    'Superior Parietal Lobule': 'PL',
    'Supramarginal Gyrus': 'PL',
    'Angular Gyrus': 'PL',
    'Precuneous Cortex': 'PL',

    # Temporal
    'Superior Temporal Gyrus': 'TL',
    'Middle Temporal Gyrus': 'TL',
    'Inferior Temporal Gyrus': 'TL',
    'Temporal Pole': 'TL',
    'Heschl’s Gyrus (includes H1 and H2)': 'TL',
    'Planum Temporale': 'TL',
    'Planum Polare': 'TL',

    # Occipital
    'Occipital Pole': 'OL',
    'Lateral Occipital Cortex, superior division': 'OL',
    'Lateral Occipital Cortex, inferior division': 'OL',
    'Cuneal Cortex': 'OL',
    'Lingual Gyrus': 'OL',
    ' intracalcarine Cortex': 'OL',
    # sometimes in occipital or temporal depending on atlas
    'Occipital Fusiform Gyrus': 'OL',

    # Insular
    'Insular Cortex': 'IL',
}


def get_region_result_for_one_mask(mask_file, atlas_data, labels):
    # Load lesion mask (already in MNI space)
    lesion_nii = nib.load(mask_file)
    lesion_data = lesion_nii.get_fdata()

    # Threshold to binarize (if needed)
    lesion_bin = (lesion_data > 0.5).astype(np.uint8)

    # Get overlap between lesion and atlas
    overlap = atlas_data[lesion_bin == 1]

    # Most frequent region index
    unique, counts = np.unique(overlap, return_counts=True)
    if len(counts) == 0:
        return "Unknown", "Unknown"
    region_index = unique[np.argmax(counts)]

    # Look up region name and map to lobe
    if region_index < len(labels):
        region_name = labels[int(region_index)]
        lobe_name = lobe_mapping.get(region_name, "Unknown")
    else:
        lobe_name = "Unknown"

    # Get voxel coordinates of lesion
    coords = np.column_stack(np.where(lesion_bin == 1))

    # Transform to world coordinates (in mm)
    mm_coords = nib.affines.apply_affine(lesion_nii.affine, coords)

    # Average x-coordinate tells hemisphere
    mean_x = np.mean(mm_coords[:, 0])
    hemisphere = 'R' if mean_x > 0 else 'L'

    return lobe_name, hemisphere


def get_region_results(df, output_files):
    # Load Harvard-Oxford atlas
    atlas_ho = datasets.fetch_atlas_harvard_oxford('cort-maxprob-thr25-1mm')
    atlas_img = atlas_ho.maps
    atlas_data = atlas_img.get_fdata()
    labels = atlas_ho.labels

    control_lobe_situated = 0
    control_lobe_missed = []
    control_hemisphere_situated = 0
    control_hemisphere_missed = []

    patient_lobe_situated = 0
    patient_lobe_missed = []
    patient_hemisphere_situated = 0
    patient_hemisphere_missed = []

    for file_path in output_files:
        part_id = file_path.split('/')[-2]
        group = df["group"]["sub-00" + f"{int(part_id.split('_')[-1]):03}"]
        actual_hemisphere = df["hemisphere"]["sub-00" +
                                             f"{int(part_id.split('_')[-1]):03}"]
        actual_lobe = df["lobe"]["sub-00" +
                                 f"{int(part_id.split('_')[-1]):03}"]

        lobe, hemisphere = get_region_result_for_one_mask(
            file_path, atlas_data, labels)

        if group == "hc":
            if lobe == "Unknown":
                control_lobe_situated += 1
            else:
                control_lobe_missed.append([part_id, lobe, actual_lobe])
            if hemisphere == "Unknown":
                control_hemisphere_situated += 1
            else:
                control_hemisphere_missed.append(
                    [part_id, hemisphere, actual_hemisphere])

        else:
            if len(actual_lobe.split(',')) == 2:
                if lobe == actual_lobe.split(',')[0] or lobe == actual_lobe.split(',')[1]:
                    patient_lobe_situated += 1
            elif lobe == actual_lobe:
                patient_lobe_situated += 1
            else:
                patient_lobe_missed.append([part_id, lobe, actual_lobe])
            if hemisphere == actual_hemisphere:
                patient_hemisphere_situated += 1
            else:
                patient_hemisphere_missed.append(
                    [part_id, hemisphere, actual_hemisphere])

    return control_lobe_situated, control_lobe_missed, control_hemisphere_situated, control_hemisphere_missed, patient_lobe_situated, patient_lobe_missed, patient_hemisphere_situated, patient_hemisphere_missed
