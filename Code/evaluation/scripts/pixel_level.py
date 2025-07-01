import numpy as np
import matplotlib.pyplot as plt
from miseval import (
    calc_Sensitivity,
    calc_Specificity,
    calc_DSC,
)
import glob
import os
import csv
import argparse
from scripts.common import load_and_binarize_nii


def compute_confusion_elements(gt, pred):
    """
    Compute TP, TN, FP, FN.
    """
    TP = np.sum((gt == 1) & (pred == 1))
    TN = np.sum((gt == 0) & (pred == 0))
    FP = np.sum((gt == 0) & (pred == 1))
    FN = np.sum((gt == 1) & (pred == 0))
    return TP, TN, FP, FN


def compute_metrics(gt, pred):
    """
    Compute metrics with MISeval 1.0.0 and manual NumPy.
    """
    # MISeval v1.0.0 metrics
    sensitivity = calc_Sensitivity(gt, pred)
    specificity = calc_Specificity(gt, pred)
    dice = calc_DSC(gt, pred)

    # Manual confusion matrix for precision and accuracy
    TP = np.sum((gt == 1) & (pred == 1))
    TN = np.sum((gt == 0) & (pred == 0))
    FP = np.sum((gt == 0) & (pred == 1))
    FN = np.sum((gt == 1) & (pred == 0))

    precision = TP / (TP + FP) if (TP + FP) else 0.0
    accuracy = (TP + TN) / (TP + TN + FP + FN) if (TP + TN + FP + FN) else 0.0

    return [
        sensitivity,
        specificity,
        dice,
        precision,
        accuracy
    ]


def get_part_id(file_path):
    return file_path.split('/')[-2]


def evaluate(ground_truth_files, prediction_files):
    all_sensitivity = []
    all_specificity = []
    all_dice = []
    all_precision = []
    all_accuracy = []

    with open('results.csv', 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["participant_id", "sensitivity", "specificity",
                        "dice", "precision", "accuracy", "note"])

        for i in range(max(len(ground_truth_files), len(prediction_files))):
            if ground_truth_files[i] == "":
                row = [get_part_id(prediction_files[i]), "n/a", "n/a", "n/a",
                       "n/a", "n/a", "missing ground_truth"]
            elif prediction_files[i] == "":
                row = [get_part_id(ground_truth_files[i]), "n/a", "n/a", "n/a",
                       "n/a", "n/a", "missing prediction"]
            else:
                gt = load_and_binarize_nii(ground_truth_files[i])
                pred = load_and_binarize_nii(prediction_files[i])

                if gt.shape != pred.shape:
                    raise ValueError(
                        f"Shape mismatch: {gt.shape} vs {pred.shape}")

                row = [get_part_id(ground_truth_files[i])]

                results = compute_metrics(gt, pred)
                all_sensitivity.append(results[0])
                all_specificity.append(results[1])
                all_dice.append(results[2])
                all_precision.append(results[3])
                all_accuracy.append(results[4])

                row.append(results)

            writer.writerow(row)

    mean_sensitivity = sum(all_sensitivity) / len(all_sensitivity)
    mean_specificity = sum(all_specificity) / len(all_specificity)
    mean_dice = sum(all_dice) / len(all_dice)
    mean_precision = sum(all_precision) / len(all_precision)
    mean_accuracy = sum(all_accuracy) / len(all_accuracy)
    return mean_sensitivity, mean_specificity, mean_dice, mean_precision, mean_accuracy


def get_pixel_results(df, input_files, output_files):
    return evaluate(input_files, output_files)
