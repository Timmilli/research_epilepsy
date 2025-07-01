from scripts.common import load_and_binarize_nii


def get_patient_results(df, output_files):
    patient_detected = 0
    patient_forgotten = []
    control_detected = 0
    control_forgotten = []

    for file_path in output_files:
        total = int(load_and_binarize_nii(file_path).sum())
        part_id = file_path.split('/')[-2]
        group = df["group"]["sub-00" + f"{int(part_id.split('_')[-1]):03}"]

        if group == "hc":
            if total == 0:
                control_detected += 1
            else:
                control_forgotten.append([part_id, total])
        elif group == "fcd":
            if total > 0:
                patient_detected += 1
            else:
                patient_forgotten.append([part_id, total])

    return patient_detected, patient_forgotten, control_detected, control_forgotten
