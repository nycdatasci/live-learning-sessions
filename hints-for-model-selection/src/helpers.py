import numpy as np
import pickle
import os

def ravel_images(img_ary):
    """Creates a 2D array with each row a flattened 2D image
    
    Parameters:
      - img_ary: A list or array where each element is itself a 
                 2D image to be flattened to 1D
                 
    Returns: A 2D array where each row is one of the original 
             image elements and each column represents a pixel. 
    """
    return np.vstack([np.array(im).ravel() for im in img_ary])


def save_object(object_, fp, force_overwrite = False):
    """Save the object we want to grab quickly in the LLS
    
    Parameters:
      - object_ (any object): The object to be saved
      - fp (string): File path to save the object to
      - force_overwrite (bool): Whether or not to prompt user if file exists
      
    Returns: File path if successful, None if not. 
    
    """
    # Check if file already exists and if we should let user know
    if os.path.exists(fp) and (not force_overwrite):
        print(f"Filepath {fp} already exists.")
        rewrite = input(f"Rewrite anyway? ([y] or n): ")
        if str(rewrite).strip().lower() in ['n','no']:
            return fp
    try:
        with open(fp, 'wb') as fout:
            pickle.dump(object_, fout)
            return fp
    except Exception as e:
        print(f"Error {e} occurred while trying to write pickle file {fp}.")
        return None
    
    
def open_object(fp):
    """Open the object we want to grab quickly in the LLS
    
    Parameters:
      - fp (string): File path to save the object to
      
    Returns: Saved object if successful, None if not. 
    
    """
    try:
        with open(fp, 'rb') as fin:
            return pickle.load(fin)
    except Exception as e:
        print(f"Error {e} occurred while trying to open pickle file {fp}.")
        return None
            