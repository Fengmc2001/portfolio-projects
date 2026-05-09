# Metronome Motion and Synchronization Analysis

A Python/OpenCV project for extracting metronome motion from video, estimating BPM from angular time-series data, and visualizing synchronization between two metronomes and a supporting board.

This project was developed as a video-based physical motion analysis exercise. It combines image processing, color-based object detection, centroid extraction, angle calculation, peak detection, and time-series analysis.

## Overview

The project contains two main analysis scripts:

- `kadai4.py`: estimates the BPM of a single metronome from video.
- `kadai6.py`: tracks two metronomes and a supporting board, then visualizes their angular motion for synchronization analysis.

The implementation uses HSV color thresholding to isolate target regions, image moments to estimate centroids, and geometric angle calculation to convert object positions into angular time-series data.

## Repository Location

```text
portfolio-projects/
└── metronome-synchronization-analysis/
    ├── README.md
    └── src/
        ├── kadai4.py
        ├── kadai6.py
        ├── extract.py
        └── extracttest.py
```

## Main Features

### Single-metronome BPM estimation

`kadai4.py` processes a metronome video and estimates the BPM by:

1. reading video frames with OpenCV;
2. converting each frame from BGR to HSV;
3. extracting the colored metronome marker using HSV thresholding;
4. applying a median filter to reduce noise;
5. computing the centroid with image moments;
6. calculating the angular displacement from a fixed pivot point;
7. detecting peaks in the angle signal;
8. estimating the period and BPM from peak intervals.

### Two-metronome synchronization analysis

`kadai6.py` analyzes two metronomes and a supporting board. It detects:

- metronome 1 marker;
- metronome 2 marker;
- board marker.

The script tracks the centroids of these objects, calculates their angles frame by frame, overlays the measured angles on the video, and saves a short annotated output video.

## File Description

### `src/kadai4.py`

Main script for single-metronome analysis. It estimates the BPM from angular motion using `scipy.signal.find_peaks`.

### `src/kadai6.py`

Main script for synchronization analysis. It detects two metronomes and a board, calculates their angular motion, and saves an annotated output video.

### `src/extract.py`

A basic extraction script used for centroid and angle extraction practice.

### `src/extracttest.py`

A small frame-extraction test script used to save sample frames from a video.

## Requirements

Recommended environment:

- Python 3.x
- OpenCV
- NumPy
- Matplotlib
- SciPy

Install dependencies:

```bash
pip install opencv-python numpy matplotlib scipy
```

## Input Videos

The scripts expect local video files such as:

```text
4623044_kadai4.MP4
4623044_kadai6.MP4
sample.MP4
```

These video files are not included in this repository. Place the required videos in the same directory as the corresponding script, or modify the video path in the script.

## How to Run

Move into the source directory:

```bash
cd metronome-synchronization-analysis/src
```

Run the single-metronome BPM analysis:

```bash
python3 kadai4.py
```

Run the synchronization analysis:

```bash
python3 kadai6.py
```

### Notes on execution

- Press `Esc` to stop preview windows if they are shown.
- The HSV thresholds and pivot coordinates are manually tuned for the recorded videos.
- For stable BPM estimation, the video should contain at least one full oscillation period. Longer videos generally improve peak detection stability.
- In `kadai6.py`, `START_FRAME` is used to skip noisy initial frames where hands or irrelevant objects may appear.

## Example Result

For the single-metronome analysis, the script prints values similar to:

```text
fps = 59.94
average_peak_interval (frame) = 80.00
T = 1.3347 [s]
Estimated BPM = 89.91
```

For synchronization analysis, the script prints or overlays frame-by-frame angle values such as:

```text
M1 Angle: -5.96
M2 Angle: -9.32
Board Angle: 18.38
```

## Technical Keywords

- OpenCV
- HSV color segmentation
- centroid extraction
- image moments
- angular motion analysis
- peak detection
- BPM estimation
- synchronization visualization
- physical motion analysis

## Portfolio Usage

Suggested short description for a portfolio page:

> A Python/OpenCV video analysis project that extracts metronome motion from recorded video, estimates BPM from angular time-series data, and visualizes synchronization between two metronomes and a supporting board.

## Future Improvements

- make HSV thresholds configurable from a JSON file;
- separate video I/O, detection, and analysis logic;
- export angle time-series data as CSV;
- add automatic pivot calibration;
- improve object tracking robustness;
- add plots for synchronization phase analysis;
- refactor into reusable Python modules.

## License

For personal academic portfolio use. A formal license can be added later if this project is made reusable.
