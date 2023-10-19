# Bwrapbox

Linux sandboxing utility on top of [Blubblewrap](https://github.com/containers/bubblewrap).

This tool enhances bwrap by adding ways to limit process group resources such as:
- Memory usage
- CPU usage
- Time

The Linux kernel must have support for [cgroup v2](https://docs.kernel.org/admin-guide/cgroup-v2.html).

## Installation

First make sure you have:
- [libseccomp](https://github.com/seccomp/libseccomp) installed along with its development files.
= [blubblewrap](https://github.com/containers/bubblewrap) installed.

```sh
make
sudo make install PREFIX=/usr/local
```

## Options

This tool basically it introduces the following new options that are configured before calling `bwrap`:

```
usage: bwrapbox [OPTIONS...] [--] COMMAND [ARGS...]

    --help                       Print this help
    --cgroup NAME                The cgroup name to run
    --cgroup-overwrite           Kill and destroy cgroup in case it already exists
    --climit VAR VALUE           Set cgroup limit (sum of all processes in cgroup)
    --rlimit VAR VALUE           Set resource limit (per process)
    --setuid VALUE               Set UID before running bwrap
    --setgid VALUE               Set GID before running bwrap
    --setgid VALUE               Set GID before running bwrap
```

Plus you can pass all options supported by `bwrap`.

## Example of advanced usage

The following example creates a sandbox mirroring the root filesystem,
with many resources limitations and runs `bash` as `nobody` user:

```sh
sudo ./bwrapbox \
  --cgroup sandbox.bwrapbox \
  --cgroup-overwrite \
  --climit cgroup.max.descendants 32 \
  --climit cgroup.max.depth 32 \
  --climit pids.max 32 \
  --climit cpu.weight.nice 5 \
  --climit memory.swap.max 0 \
  --climit memory.high 50331648 \
  --climit memory.max 67108864 \
  --climit time.high 601000000 \
  --climit time.max 602000000 \
  --rlimit cpu.max 600 \
  --rlimit fsize.max 33554432 \
  --rlimit data.max 67108864 \
  --rlimit stack.max 8388608 \
  --rlimit core.max 0 \
  --rlimit nproc.max 32 \
  --rlimit nofile.max 1024 \
  --rlimit memlock.max 67108864 \
  --rlimit as.high 50331648 \
  --rlimit as.max 67108864 \
  --rlimit sigpending.max 64 \
  --rlimit msgqueue.max 0 \
  --rlimit nice.max 5 \
  --rlimit rtprio.max 0 \
  --rlimit rttime.max 0 \
  --setuid 99 \
  --setgid 99 \
  --size 16777216 \
  --tmpfs / \
  --dev /dev \
  --proc /proc \
  --ro-bind /usr /usr \
  --ro-bind /etc /etc \
  --ro-bind /sys /sys \
  --perms 1777 \
  --size 16777216 \
  --tmpfs /tmp \
  --dir /run \
  --symlink /usr/lib /lib \
  --symlink /usr/lib /lib64 \
  --symlink /usr/bin /bin \
  --symlink /run /var/run \
  --remount-ro / \
  --unshare-ipc \
  --unshare-pid \
  --unshare-net \
  --unshare-uts \
  --unshare-user \
  --clearenv \
  --setenv TERM linux \
  --setenv PATH /bin:/usr/bin \
  --setenv HOME /nobody \
  --setenv USER nobody \
  --setenv LOGNAME nobody \
  --chdir / \
  --die-with-parent \
  --as-pid-1 \
  --new-session \
  bash
```

If you want to also use [seccomp](https://www.kernel.org/doc/html/latest/userspace-api/seccomp_filter.html?highlight=seccomp)
to filter potentially dangerous Linux syscalls, include the option:
```sh
--seccomp 5 5<seccomp-filter.bpf \
```