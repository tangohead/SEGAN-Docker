# SE-FFTNet in a handy Docker container

This is a small repo to make it easier to use SE-FFTNet to clean up audio samples. It wraps the model in Docker, takes in noisy WAV files and outputs cleaned up WAVs.

Requirements:
* Linux (currently, until CUDA for WSL2 is released)
* Docker & Nvidia-docker (tested on 19.03.6)

The container follows the requirements of [SEGAN](https://github.com/santi-pdp/segan). Ideally this would use a Tensorflow Docker image but there are some issues in getting this to run. Instead, it is built on an NVidia CUDA image, specificially [this one](https://hub.docker.com/layers/nvidia/cuda/8.0-cudnn5-devel-ubuntu14.04/images/sha256-645cd33ce9f490907bdfad3787c5e345d2314bc64c49ecfcd848dea028294993?context=explore).

We also need to use the weights provides by SEGAN - you can find these [here](http://veu.talp.cat/segan/release_weights/segan_v1.1.tar.gz). These should be unzipped, with `segan_v1.1` being placed in a directory called `weights`. This should be in the directory you build the container from, with the directory structure looking something like this:

```
SEGAN-Docker/
├── build_gpu.dockerfile
├── repositories/
│   ├── ...
├── weights/
│   ├── segan_v1.1
│   |   ├── SEGAN-41700.data-00000-of-00001
│   |   ├── SEGAN-41700.index
│   |   ├── SEGAN-41700.meta
├── segan/
│   ├── ...
```

## Input and Output

Create two local directories - one for input, one for output. You will need to mount these when you run the container. It should look something like this:

```
output/
input/
├── input_file_1.wav
├── input_file_2.wav
├── input_file_3.wav
```

If you are happy to mount from your clone of this repo, for example, you could use `/path/to/repo/segan/input/` and `/path/to/repo/segan/output/`, and your SEGAN-Docker directory may look like this:

```
SEGAN-Docker/
├── build_gpu.dockerfile
├── output/
├── input/
│   ├── input_file_1.wav
│   ├── input_file_2.wav
│   ├── input_file_3.wav
├── repositories/
│   ├── ...
├── weights/
│   ├── segan_v1.1
│   |   ├── SEGAN-41700.data-00000-of-00001
│   |   ├── SEGAN-41700.index
│   |   ├── SEGAN-41700.meta
├── segan/
│   ├── ...
```

**Note**: Ensure that `output` does not contain a file with the same name as whatever you pass as `input`, or SEGAN may fail to save the file.

## Building and Running the Container

You can build with:

```
docker build -t segan:<version number> -f build_gpu.dockerfile .
```

Put the files you wish to convert in `input`, ensuring they are sampled at 16 KHz. Then run the container, mounting it as below and giving the name of a file for processing `<input file name>` in the `input` directory:

```
docker container run --runtime=nvidia -v <local input path>:/segan/input/ -v <local output path>:/segan/test_clean_results/ -e input_file=<input file name> segan:<version number>
```