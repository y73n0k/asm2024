import subprocess
import glob

OPTIMIZATIONS = ["-O0", "-O1", "-O2", "-O3", "-Ofast"]
PICS = glob.glob("pics/*.png")
N = 10


def build(name, optimization):
    subprocess.run(["gcc", "source/main.c", name, optimization, "-lm", "-o", "build/lab"])


def build_asm():
    subprocess.run(["nasm", "-f", "elf64", "source/lab.s", "-o", "build/lab.s.o"])
    build("build/lab.s.o", "-O0")


def build_c(optimization):
    build("source/lab.c", optimization)


def clean():
    subprocess.run(["rm", "-rf", "./build"])
    subprocess.run(["mkdir", "./build"])


def timeit():
    for pic in PICS:
        time = 0.0
        for _ in range(N):
            res = subprocess.run(["./build/lab", pic, pic], stdout=subprocess.PIPE)
            time += float(res.stdout)
        time /= N
        print(pic, f"{time:.10f}")


if __name__ == "__main__":
    build_asm()
    print("asm")
    timeit()

    for optimization in OPTIMIZATIONS:
        build_c(optimization)
        print(f"c: {optimization}")
        timeit()

    clean()
