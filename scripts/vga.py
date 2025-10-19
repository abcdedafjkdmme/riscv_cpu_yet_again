from PIL import Image
import numpy as np

time_ns = 0
clock_freq_mhz = 25.175
tick_len_us = 1 / clock_freq_mhz
tick_len_ns = tick_len_us * 1e3

x_size_tot = 800
x_size_pixels = 640
x_front_porch = 16
x_sync_pulse = 96
x_back_porch = 48

y_size_tot = 525
y_size_pixels = 480
y_front_porch = 10
y_sync_pulse = 2
y_back_porch = 33

img = Image.open("test_image.jpg")
img_matrix = np.array(img)
img_rgb = img.convert('RGB')

h_sync = 1
v_sync = 1

for i in range(3):
  for y in range(y_size_tot):
    is_y_vis = False
    if(y < y_size_pixels):
      # visible area
      is_y_vis = True
      v_sync = 1
    elif y < y_size_pixels + y_front_porch:
      # front porch
      v_sync = 1
    elif y < y_size_pixels + y_front_porch + y_sync_pulse:
      #sync pulse
      v_sync = 0
    else:
      #back porch
      v_sync = 1 
    for x in range(x_size_tot):
      r , g , b = (0,0,0)
      if(x < x_size_pixels):
        # visible area
        h_sync = 1
        if(is_y_vis):
          r , g , b = img_rgb.getpixel((x,y))
      elif x < x_size_pixels + x_front_porch:
        # front porch
        h_sync = 1
      elif x < x_size_pixels + x_front_porch + x_sync_pulse:
        #sync pulse
        h_sync = 0
      else:
        #back porch
        h_sync = 1


      r_bin_str = "{0:08b}".format(r)
      g_bin_str = "{0:08b}".format(g)
      b_bin_str = "{0:08b}".format(b)
      print(f'{int(time_ns)} ns: {h_sync} {v_sync} {r_bin_str} {g_bin_str} {b_bin_str}')
      time_ns = time_ns + tick_len_ns
