import nibabel as nib
import numpy as np


def load_and_binarize_nii(path, threshold=0.5):
    """
    Load a NIfTI image and binarize it using a threshold.
    """
    img = nib.load(path)
    data = img.get_fdata()
    binary = (data > threshold).astype(np.uint8)
    return binary
