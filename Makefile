# Default path to NVIDIA CUDA (providing libraries, nvcc, etc)
CUDAPATH=/usr/local/cuda

# Try to locate CUDA if it's not in the default path
ifneq ("$(wildcard $(CUDAPATH))","")
# The default PATH is good - nothing else to do
else ifneq ("$(wildcard /usr/local/cuda-7.5)","")
CUDAPATH=/usr/local/cuda-7.5
else ifneq ("$(wildcard /usr/local/cuda-7.0)","")
CUDAPATH=/usr/local/cuda-7.0
else ifneq ("$(wildcard /usr/local/cuda-6.5)","")
CUDAPATH=/usr/local/cuda-6.5
else ifneq ("$(wildcard /opt/cuda)","")
CUDAPATH=/opt/cuda
endif


# Have this point to an old enough gcc (for nvcc)
GCCPATH=/usr

NVCC=${CUDAPATH}/bin/nvcc
CCPATH=${GCCPATH}/bin


all: gpu_burn

NVCCFLAGS=-gencode=arch=compute_20,code=sm_20 -gencode=arch=compute_30,code=sm_30 -gencode=arch=compute_35,code=compute_35 -gencode=arch=compute_37,code=compute_37 -gencode=arch=compute_50,code=sm_50 -gencode=arch=compute_52,code=sm_52 -I. -I${CUDAPATH}/include --fatbin

gpu_burn.cuda_kernel: compare.cu Makefile
	PATH=.:${CCPATH}:${PATH} ${NVCC} ${NVCCFLAGS} compare.cu -o $@

gpu_burn: gpu_burn.cuda_kernel gpu_burn-drv.cpp
	g++ -o gpu_burn gpu_burn-drv.cpp -O3 -I${CUDAPATH}/include -lcuda -L${CUDAPATH}/lib64 -L${CUDAPATH}/lib -L/usr/local/cuda/lib64 -L/usr/local/cuda/targets/x86_64-linux/lib/stubs/ -Wl,-rpath=${CUDAPATH}/lib64 -Wl,-rpath=${CUDAPATH}/lib -lcublas -lcudart


clean:
	rm -f gpu_burn.cuda_kernel gpu_burn
