from typing import List
import cv2
from PIL import Image
from multiprocessing import Pool

from paint import paint
from resize_video import resize

def read_frames(path: str):
    cam = cv2.VideoCapture(path)
    frames = []
    count = 0

    while True:
        ret, frame = cam.read()

        if not ret:
            break

        count += 1
        print(f'Frame: {count}')
        frames.append(Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)))
    
    cam.release()
    cv2.destroyAllWindows()
    return frames


if __name__ == "__main__":
    resize('cats.mp4', 'resized.mp4')
    frames = read_frames('resized.mp4')
    brushes = [2, 4, 8, 16, 32]

    with Pool(5) as p:
        res = p.map(paint, frames)

    if len(res) > 0:
        res[0].save(f'res.gif', save_all=True, append_images=res[1:], optimize=False, duration=100, loop=0)