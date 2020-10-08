FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu14.04

ENV input_file default_input_file

WORKDIR /segan/

# This is an unfortunate hack which allows the container to use apt-get
# Unfortunately, the default Nvidia repositories use HTTPS and ubuntu14.04
# can't meet requirements anymore it seems. So instead we have to change the 
# repos to be HTTP
# https://github.com/NVIDIA/nvidia-docker/issues/714
RUN rm /etc/apt/sources.list.d/cuda.list
COPY repositories/cuda.list /etc/apt/sources.list.d/
RUN rm /etc/apt/sources.list.d/nvidia-ml.list
COPY repositories/nvidia-ml.list /etc/apt/sources.list.d/
RUN cat /etc/apt/sources.list.d/cuda.list

# Update the package mirrors and install 
RUN apt-get update 
RUN apt-get -y install curl python python-dev

# Install pip
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python get-pip.py

# Copy our repository (Could actually just do the repo fix above internally)
COPY segan/ .
COPY weights/segan_v1.1 ./segan_weights_v1.1

RUN pip install -r requirements.txt

CMD [ "sh", "-c", "python main.py --init_noise_std 0. --save_path segan_weights_v1.1 --batch_size 100 --g_nl prelu --weights SEGAN-41700 --test_wav /segan/input/${input_file} --clean_save_path /segan/output/" ]
