from typing import Tuple
import cv2
 
def resize(in_path: str, out_path: str, size: Tuple[int, int] = (512, 512)):
    cap = cv2.VideoCapture(in_path)
    
    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    out = cv2.VideoWriter(out_path, fourcc, 5, size)
    
    while True:
        ret, frame = cap.read()
        if ret == True:
            b = cv2.resize(frame, size, fx=0, fy=0, interpolation = cv2.INTER_CUBIC)
            out.write(b)
        else:
            break
        
    cap.release()
    out.release()
    cv2.destroyAllWindows()