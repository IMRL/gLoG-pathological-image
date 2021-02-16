# gLoG-pathological-image
This work is an implementation of the algorithm (gLoG shape filter) proposed in [1], which is used to detect blobs (cell neuclei) in histo-pathological images, especially to locate the centers of the blobs. The detected blob centers can be used as markers for a contrained watershed-based segmentation method. 

The proposed gLoG shape filters in [1] have also been implemented by the third-party developers (https://digitalslidearchive.github.io/HistomicsTK/authors.html). Readers might also refer to their gLoG implementation at https://digitalslidearchive.github.io/HistomicsTK/_modules/histomicstk/filters/shape/glog.html. 

Please cite our work if you use our code in your work, thank you!

Cheers!


[1] Hui Kong, Hatice Cinar Akakin, and Sanjay E. Sarma. "A generalized Laplacian of Gaussian filter for blob detection and its applications." IEEE transactions on cybernetics 43, no. 6 (2013): 1719-1733.
