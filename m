From: Andrew Savchenko <bircoph@gmail.com>
Subject: Re: [Bug] NFSv4 fails to work without ipv6 kernel module
Date: Tue, 28 Apr 2009 04:43:51 +0400
Message-ID: <200904280444.00206.bircoph@gmail.com>
References: <200904271903.36379.bircoph@gmail.com> <1810FE6E-D2AF-4ED3-BE34-F6117A8D9B46@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart42797522.9c1kmuCoOv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:56446 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbZD1AoM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2009 20:44:12 -0400
Received: by fxm2 with SMTP id 2so247285fxm.37
        for <linux-nfs@vger.kernel.org>; Mon, 27 Apr 2009 17:44:09 -0700 (PDT)
In-Reply-To: <1810FE6E-D2AF-4ED3-BE34-F6117A8D9B46@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart42797522.9c1kmuCoOv
Content-Type: multipart/mixed;
  boundary="Boundary-01=_HFl9JOfi3gwxu8b"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_HFl9JOfi3gwxu8b
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

On Monday 27 April 2009, Chuck Lever wrote:
> On Apr 27, 2009, at 11:03 AM, Andrew Savchenko wrote:
> > Hello,
> >
> > I have ipv6 support as a module (it may be needed in the
> > recent future), but currently I want ipv6 to be disabled on my
> > system, so I blacklisted this module. And here problems
> > begin...
> >
> > NFSv3 works flawlessly:
> > # mount 172.19.0.1:/home/ftp /mnt/nfs/
> >
> > but NFSv4 fails:
> > # mount -t nfs4 172.19.0.1:/ /mnt/nfs/
> > mount.nfs4: Cannot allocate memory
> >
> > After modprobe ipv6 it works:
> > # mount -t nfs4 172.19.0.1:/ /mnt/nfs/
> >
> > I recompiled nfs-utils without ipv6 support, but this doesn't
> > help.
> >
> > Here is my /etc/exports:
> > /home/ftp 172.16.0.0/12
> > (ro,async,crossmnt,no_subtree_check,fsid=3D0,all_squash) \
> >        127.0.0.1/32
> > (ro,async,crossmnt,no_subtree_check,fsid=3D0,all_squash)
> >
> > I use nfs-utils-1.1.5, I tested this on both vanilla linux
> > kernels 2.6.28.7 and 2.6.28.9.
>
> Have you tried this with 2.6.29?

I just tried with vanilla 2.6.29.1. Things became even worse. Now=20
not only NFSv4 fails to mount as usual, but NFSv3 fails too:

# mount 172.19.0.1:/home/ftp /mnt/orionis
mount.nfs: Address family not supported by protocol

And following error appears in kernel log multiple times:
RPC: failed to contact local rpcbind server (errno 5).

I attached strace -f for both mount attempts. The problem is in=20
mount() syscall in both cases, thus somewhere inside the kernel...

With ipv6 module loaded all works fine.

> You can also try building 2.6.28 with CONFIG_SUNRPC_REGISTER_V4
> disabled.

With this option disabled errno 5 (see above) disappeared from=20
logs, but mount fails with the same errors. Yet again, with ipv6=20
module loaded it works ok.

=2D-=20
Best regards,
Andrew

--Boundary-01=_HFl9JOfi3gwxu8b
Content-Type: text/x-log;
  charset="iso 8859-15";
  name="mount.nfs.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="mount.nfs.log"

execve("/bin/mount", ["mount", "172.19.0.1:/home/ftp", "/mnt/orionis"], [/* 81 vars */]) = 0
brk(0)                                  = 0x8b4c000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=188643, ...}) = 0
mmap2(NULL, 188643, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7f2c000
close(3)                                = 0
open("/lib/libblkid.so.1", O_RDONLY)    = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\320$\0\0004\0\0\0H"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=40792, ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f2b000
mmap2(NULL, 43672, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7f20000
mmap2(0xb7f29000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x8) = 0xb7f29000
close(3)                                = 0
open("/lib/libuuid.so.1", O_RDONLY)     = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\340\21\0\0004\0\0\0\230"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=13816, ...}) = 0
mmap2(NULL, 16604, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7f1b000
mmap2(0xb7f1e000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2) = 0xb7f1e000
close(3)                                = 0
open("/lib/libc.so.6", O_RDONLY)        = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\200h\1\0004\0\0\0\244"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=1315100, ...}) = 0
mmap2(NULL, 1320560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7dd8000
mmap2(0xb7f15000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13d) = 0xb7f15000
mmap2(0xb7f18000, 9840, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7f18000
close(3)                                = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7dd7000
set_thread_area({entry_number:-1 -> 6, base_addr:0xb7dd7700, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
mprotect(0xb7f15000, 8192, PROT_READ)   = 0
mprotect(0xb7f1e000, 4096, PROT_READ)   = 0
mprotect(0xb7f29000, 4096, PROT_READ)   = 0
mprotect(0x8056000, 4096, PROT_READ)    = 0
mprotect(0xb7f78000, 4096, PROT_READ)   = 0
munmap(0xb7f2c000, 188643)              = 0
brk(0)                                  = 0x8b4c000
brk(0x8b6d000)                          = 0x8b6d000
open("/usr/lib/locale/locale-archive", O_RDONLY|O_LARGEFILE) = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=4915840, ...}) = 0
mmap2(NULL, 2097152, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7bd7000
close(3)                                = 0
umask(022)                              = 022
open("/dev/null", O_RDWR|O_LARGEFILE)   = 3
close(3)                                = 0
getuid32()                              = 0
geteuid32()                             = 0
stat64("172.19.0.1:/home/ftp", 0xbfc77f94) = -1 ENOENT (No such file or directory)
stat64("/sbin/mount.nfs", {st_mode=S_IFREG|S_ISUID|0511, st_size=80316, ...}) = 0
clone(Process 25844 attached (waiting for parent)
Process 25844 resumed (parent 25843 ready)
child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7dd7748) = 25844
[pid 25844] getgid32()                  = 0
[pid 25844] setgid32(0)                 = 0
[pid 25844] getuid32()                  = 0
[pid 25844] setuid32(0)                 = 0
[pid 25844] execve("/sbin/mount.nfs", ["/sbin/mount.nfs", "172.19.0.1:/home/ftp", "/mnt/orionis", "-o", "rw"], [/* 78 vars */]) = 0
[pid 25844] brk(0)                      = 0x93cc000
[pid 25844] access("/etc/ld.so.preload", R_OK) = -1 ENOENT (No such file or directory)
[pid 25844] open("/etc/ld.so.cache", O_RDONLY) = 3
[pid 25844] fstat64(3, {st_mode=S_IFREG|0644, st_size=188643, ...}) = 0
[pid 25844] mmap2(NULL, 188643, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb808a000
[pid 25844] close(3)                    = 0
[pid 25844] open("/usr/lib/libtirpc.so.1", O_RDONLY) = 3
[pid 25844] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\300p\0\0004\0\0\0h"..., 512) = 512
[pid 25844] fstat64(3, {st_mode=S_IFREG|0755, st_size=141648, ...}) = 0
[pid 25844] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb8089000
[pid 25844] mmap2(NULL, 141712, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb8066000
[pid 25844] mmap2(0xb8087000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x21) = 0xb8087000
[pid 25844] close(3)                    = 0
[pid 25844] open("/lib/libnsl.so.1", O_RDONLY) = 3
[pid 25844] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0p1\0\0004\0\0\0|"..., 512) = 512
[pid 25844] fstat64(3, {st_mode=S_IFREG|0755, st_size=79540, ...}) = 0
[pid 25844] mmap2(NULL, 92136, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb804f000
[pid 25844] mmap2(0xb8062000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x12) = 0xb8062000
[pid 25844] mmap2(0xb8064000, 6120, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb8064000
[pid 25844] close(3)                    = 0
[pid 25844] open("/usr/lib/libgssglue.so.1", O_RDONLY) = 3
[pid 25844] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\320\30\0\0004\0\0\0\f"..., 512) = 512
[pid 25844] fstat64(3, {st_mode=S_IFREG|0755, st_size=34332, ...}) = 0
[pid 25844] mmap2(NULL, 33352, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb8046000
[pid 25844] mmap2(0xb804d000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x7) = 0xb804d000
[pid 25844] close(3)                    = 0
[pid 25844] open("/lib/libdl.so.2", O_RDONLY) = 3
[pid 25844] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0000\n\0\0004\0\0\0$"..., 512) = 512
[pid 25844] fstat64(3, {st_mode=S_IFREG|0755, st_size=9604, ...}) = 0
[pid 25844] mmap2(NULL, 12408, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb8042000
[pid 25844] mmap2(0xb8044000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1) = 0xb8044000
[pid 25844] close(3)                    = 0
[pid 25844] open("/lib/libpthread.so.0", O_RDONLY) = 3
[pid 25844] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0PH\0\0004\0\0\0X"..., 512) = 512
[pid 25844] fstat64(3, {st_mode=S_IFREG|0755, st_size=118981, ...}) = 0
[pid 25844] mmap2(NULL, 94688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb802a000
[pid 25844] mmap2(0xb803e000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13) = 0xb803e000
[pid 25844] mmap2(0xb8040000, 4576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb8040000
[pid 25844] close(3)                    = 0
[pid 25844] open("/lib/libc.so.6", O_RDONLY) = 3
[pid 25844] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\200h\1\0004\0\0\0\244"..., 512) = 512
[pid 25844] fstat64(3, {st_mode=S_IFREG|0755, st_size=1315100, ...}) = 0
[pid 25844] mmap2(NULL, 1320560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7ee7000
[pid 25844] mmap2(0xb8024000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13d) = 0xb8024000
[pid 25844] mmap2(0xb8027000, 9840, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb8027000
[pid 25844] close(3)                    = 0
[pid 25844] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7ee6000
[pid 25844] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7ee5000
[pid 25844] set_thread_area({entry_number:-1 -> 6, base_addr:0xb7ee56c0, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
[pid 25844] mprotect(0xb8024000, 8192, PROT_READ) = 0
[pid 25844] mprotect(0xb803e000, 4096, PROT_READ) = 0
[pid 25844] mprotect(0xb8044000, 4096, PROT_READ) = 0
[pid 25844] mprotect(0xb804d000, 4096, PROT_READ) = 0
[pid 25844] mprotect(0xb8062000, 4096, PROT_READ) = 0
[pid 25844] mprotect(0xb8087000, 4096, PROT_READ) = 0
[pid 25844] mprotect(0x805b000, 4096, PROT_READ) = 0
[pid 25844] mprotect(0xb80d6000, 4096, PROT_READ) = 0
[pid 25844] munmap(0xb808a000, 188643)  = 0
[pid 25844] set_tid_address(0xb7ee5708) = 25844
[pid 25844] set_robust_list(0xb7ee5710, 0xc) = 0
[pid 25844] futex(0xbfbd6130, FUTEX_WAKE_PRIVATE, 1) = 0
[pid 25844] rt_sigaction(SIGRTMIN, {0xb802e300, [], SA_SIGINFO}, NULL, 8) = 0
[pid 25844] rt_sigaction(SIGRT_1, {0xb802e740, [], SA_RESTART|SA_SIGINFO}, NULL, 8) = 0
[pid 25844] rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL, 8) = 0
[pid 25844] getrlimit(RLIMIT_STACK, {rlim_cur=8192*1024, rlim_max=RLIM_INFINITY}) = 0
[pid 25844] uname({sys="Linux", node="bircoph", ...}) = 0
[pid 25844] getuid32()                  = 0
[pid 25844] uname({sys="Linux", node="bircoph", ...}) = 0
[pid 25844] brk(0)                      = 0x93cc000
[pid 25844] brk(0x93ed000)              = 0x93ed000
[pid 25844] lstat64("/mnt", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
[pid 25844] lstat64("/mnt/orionis", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
[pid 25844] stat64("/mnt/orionis", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
[pid 25844] socket(PF_NETLINK, SOCK_RAW, 0) = 3
[pid 25844] bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
[pid 25844] getsockname(3, {sa_family=AF_NETLINK, pid=25844, groups=00000000}, [12]) = 0
[pid 25844] time(NULL)                  = 1240874514
[pid 25844] sendto(3, "\24\0\0\0\26\0\1\3\22>\366I\0\0\0\0\0\0\0\0"..., 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
[pid 25844] recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"0\0\0\0\24\0\2\0\22>\366I\364d\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 156
[pid 25844] recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0\22>\366I\364d\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
[pid 25844] close(3)                    = 0
[pid 25844] open("/etc/nsswitch.conf", O_RDONLY) = 3
[pid 25844] fstat64(3, {st_mode=S_IFREG|0644, st_size=508, ...}) = 0
[pid 25844] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb80b8000
[pid 25844] read(3, "# /etc/nsswitch.conf:\n# $Header: "..., 4096) = 508
[pid 25844] read(3, ""..., 4096)        = 0
[pid 25844] close(3)                    = 0
[pid 25844] munmap(0xb80b8000, 4096)    = 0
[pid 25844] open("/etc/ld.so.cache", O_RDONLY) = 3
[pid 25844] fstat64(3, {st_mode=S_IFREG|0644, st_size=188643, ...}) = 0
[pid 25844] mmap2(NULL, 188643, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb808a000
[pid 25844] close(3)                    = 0
[pid 25844] open("/lib/tls/i686/libnss_db.so.2", O_RDONLY) = -1 ENOENT (No such file or directory)
[pid 25844] stat64("/lib/tls/i686", 0xbfbd539c) = -1 ENOENT (No such file or directory)
[pid 25844] open("/lib/tls/libnss_db.so.2", O_RDONLY) = -1 ENOENT (No such file or directory)
[pid 25844] stat64("/lib/tls", 0xbfbd539c) = -1 ENOENT (No such file or directory)
[pid 25844] open("/lib/i686/libnss_db.so.2", O_RDONLY) = -1 ENOENT (No such file or directory)
[pid 25844] stat64("/lib/i686", 0xbfbd539c) = -1 ENOENT (No such file or directory)
[pid 25844] open("/lib/libnss_db.so.2", O_RDONLY) = -1 ENOENT (No such file or directory)
[pid 25844] stat64("/lib", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
[pid 25844] open("/usr/lib/tls/i686/libnss_db.so.2", O_RDONLY) = -1 ENOENT (No such file or directory)
[pid 25844] stat64("/usr/lib/tls/i686", 0xbfbd539c) = -1 ENOENT (No such file or directory)
[pid 25844] open("/usr/lib/tls/libnss_db.so.2", O_RDONLY) = -1 ENOENT (No such file or directory)
[pid 25844] stat64("/usr/lib/tls", 0xbfbd539c) = -1 ENOENT (No such file or directory)
[pid 25844] open("/usr/lib/i686/libnss_db.so.2", O_RDONLY) = -1 ENOENT (No such file or directory)
[pid 25844] stat64("/usr/lib/i686", 0xbfbd539c) = -1 ENOENT (No such file or directory)
[pid 25844] open("/usr/lib/libnss_db.so.2", O_RDONLY) = -1 ENOENT (No such file or directory)
[pid 25844] stat64("/usr/lib", {st_mode=S_IFDIR|0755, st_size=151552, ...}) = 0
[pid 25844] munmap(0xb808a000, 188643)  = 0
[pid 25844] open("/etc/ld.so.cache", O_RDONLY) = 3
[pid 25844] fstat64(3, {st_mode=S_IFREG|0644, st_size=188643, ...}) = 0
[pid 25844] mmap2(NULL, 188643, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb808a000
[pid 25844] close(3)                    = 0
[pid 25844] open("/lib/libnss_files.so.2", O_RDONLY) = 3
[pid 25844] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\20\31\0\0004\0\0\0\204"..., 512) = 512
[pid 25844] fstat64(3, {st_mode=S_IFREG|0755, st_size=38332, ...}) = 0
[pid 25844] mmap2(NULL, 41624, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7eda000
[pid 25844] mmap2(0xb7ee3000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x8) = 0xb7ee3000
[pid 25844] close(3)                    = 0
[pid 25844] mprotect(0xb7ee3000, 4096, PROT_READ) = 0
[pid 25844] munmap(0xb808a000, 188643)  = 0
[pid 25844] open("/etc/rpc", O_RDONLY|O_CLOEXEC) = 3
[pid 25844] fcntl64(3, F_GETFD)         = 0x1 (flags FD_CLOEXEC)
[pid 25844] fstat64(3, {st_mode=S_IFREG|0644, st_size=1615, ...}) = 0
[pid 25844] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb80b8000
[pid 25844] read(3, "#ident\t\"@(#)rpc\t1.11\t95/07/14 SMI"..., 4096) = 1615
[pid 25844] close(3)                    = 0
[pid 25844] munmap(0xb80b8000, 4096)    = 0
[pid 25844] open("/etc/rpc", O_RDONLY|O_CLOEXEC) = 3
[pid 25844] fstat64(3, {st_mode=S_IFREG|0644, st_size=1615, ...}) = 0
[pid 25844] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb80b8000
[pid 25844] read(3, "#ident\t\"@(#)rpc\t1.11\t95/07/14 SMI"..., 4096) = 1615
[pid 25844] close(3)                    = 0
[pid 25844] munmap(0xb80b8000, 4096)    = 0
[pid 25844] socket(PF_NETLINK, SOCK_RAW, 0) = 3
[pid 25844] bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
[pid 25844] getsockname(3, {sa_family=AF_NETLINK, pid=25844, groups=00000000}, [12]) = 0
[pid 25844] time(NULL)                  = 1240874514
[pid 25844] sendto(3, "\24\0\0\0\26\0\1\3\22>\366I\0\0\0\0\0\0\0\0"..., 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
[pid 25844] recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"0\0\0\0\24\0\2\0\22>\366I\364d\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 156
[pid 25844] recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0\22>\366I\364d\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
[pid 25844] close(3)                    = 0
[pid 25844] socket(PF_FILE, 0x80801 /* SOCK_??? */, 0) = 3
[pid 25844] connect(3, {sa_family=AF_FILE, path="/var/run/nscd/socket"...}, 110) = -1 ENOENT (No such file or directory)
[pid 25844] close(3)                    = 0
[pid 25844] socket(PF_FILE, 0x80801 /* SOCK_??? */, 0) = 3
[pid 25844] connect(3, {sa_family=AF_FILE, path="/var/run/nscd/socket"...}, 110) = -1 ENOENT (No such file or directory)
[pid 25844] close(3)                    = 0
[pid 25844] open("/etc/services", O_RDONLY|O_CLOEXEC) = 3
[pid 25844] fstat64(3, {st_mode=S_IFREG|0644, st_size=35989, ...}) = 0
[pid 25844] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb80b8000
[pid 25844] read(3, "# /etc/services\n#\n# Network servi"..., 4096) = 4096
[pid 25844] read(3, " private\t77/tcp\t\t\t\t# any private "..., 4096) = 4096
[pid 25844] close(3)                    = 0
[pid 25844] munmap(0xb80b8000, 4096)    = 0
[pid 25844] socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
[pid 25844] bind(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
[pid 25844] fcntl64(3, F_GETFL)         = 0x2 (flags O_RDWR)
[pid 25844] fcntl64(3, F_SETFL, O_RDWR|O_NONBLOCK) = 0
[pid 25844] connect(3, {sa_family=AF_INET, sin_port=htons(111), sin_addr=inet_addr("127.0.0.1")}, 16) = 0
[pid 25844] fcntl64(3, F_SETFL, O_RDWR) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] getrlimit(RLIMIT_NOFILE, {rlim_cur=5000, rlim_max=5*1024}) = 0
[pid 25844] mmap2(NULL, 249856, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7e9d000
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] getsockname(3, {sa_family=AF_INET, sin_port=htons(50644), sin_addr=inet_addr("127.0.0.1")}, [16]) = 0
[pid 25844] getsockopt(3, SOL_SOCKET, SO_TYPE, [2], [4]) = 0
[pid 25844] gettimeofday({1240874514, 892448}, NULL) = 0
[pid 25844] setsockopt(3, SOL_IP, IP_RECVERR, [1], 4) = 0
[pid 25844] ioctl(3, FIONBIO, [1])      = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] futex(0xb8088668, FUTEX_WAKE_PRIVATE, 1) = 0
[pid 25844] sendto(3, "I\373\304\307\0\0\0\0\0\0\0\2\0\1\206\240\0\0\0\2\0\0\0\3\0\0\0\0\0\0\0\0\0"..., 56, 0, {sa_family=AF_INET, sin_port=htons(111), sin_addr=inet_addr("127.0.0.1")}, 16) = 56
[pid 25844] poll([{fd=3, events=POLLIN}], 1, 3000) = 1 ([{fd=3, revents=POLLIN}])
[pid 25844] recvfrom(3, "I\373\304\307\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\214\346"..., 8800, 0, NULL, NULL) = 28
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] close(3)                    = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
[pid 25844] bind(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
[pid 25844] fcntl64(3, F_GETFL)         = 0x2 (flags O_RDWR)
[pid 25844] fcntl64(3, F_SETFL, O_RDWR|O_NONBLOCK) = 0
[pid 25844] connect(3, {sa_family=AF_INET, sin_port=htons(36070), sin_addr=inet_addr("127.0.0.1")}, 16) = 0
[pid 25844] fcntl64(3, F_SETFL, O_RDWR) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] getsockname(3, {sa_family=AF_INET, sin_port=htons(41189), sin_addr=inet_addr("127.0.0.1")}, [16]) = 0
[pid 25844] getsockopt(3, SOL_SOCKET, SO_TYPE, [2], [4]) = 0
[pid 25844] gettimeofday({1240874514, 894120}, NULL) = 0
[pid 25844] setsockopt(3, SOL_IP, IP_RECVERR, [1], 4) = 0
[pid 25844] ioctl(3, FIONBIO, [1])      = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] futex(0xb8088668, FUTEX_WAKE_PRIVATE, 1) = 0
[pid 25844] sendto(3, "I\373\376O\0\0\0\0\0\0\0\2\0\1\206\270\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 40, 0, {sa_family=AF_INET, sin_port=htons(36070), sin_addr=inet_addr("127.0.0.1")}, 16) = 40
[pid 25844] poll([{fd=3, events=POLLIN}], 1, 3000) = 1 ([{fd=3, revents=POLLIN}])
[pid 25844] recvfrom(3, "I\373\376O\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8800, 0, NULL, NULL) = 24
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
[pid 25844] close(3)                    = 0
[pid 25844] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid 25844] time(NULL)                  = 1240874514
[pid 25844] mount("172.19.0.1:/home/ftp", "/mnt/orionis", "nfs", 0, "addr=172.19.0.1" <unfinished ...>
[pid 25843] wait4(-1, Process 25843 suspended
 <unfinished ...>
[pid 25844] <... mount resumed> )       = -1 EAFNOSUPPORT (Address family not supported by protocol)
[pid 25844] write(2, "mount.nfs: Address family not sup"..., 52mount.nfs: Address family not supported by protocol
) = 52
[pid 25844] exit_group(32)              = ?
Process 25843 resumed
Process 25844 detached
<... wait4 resumed> [{WIFEXITED(s) && WEXITSTATUS(s) == 32}], 0, NULL) = 25844
--- SIGCHLD (Child exited) @ 0 (0) ---
exit_group(32)                          = ?

--Boundary-01=_HFl9JOfi3gwxu8b
Content-Type: text/x-log;
  charset="iso 8859-15";
  name="mount.nfs4.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="mount.nfs4.log"

execve("/bin/mount", ["mount", "-t", "nfs4", "172.19.0.1:/", "/mnt/orionis"], [/* 81 vars */]) = 0
brk(0)                                  = 0x8d0a000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=188643, ...}) = 0
mmap2(NULL, 188643, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7eb7000
close(3)                                = 0
open("/lib/libblkid.so.1", O_RDONLY)    = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\320$\0\0004\0\0\0H"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=40792, ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7eb6000
mmap2(NULL, 43672, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7eab000
mmap2(0xb7eb4000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x8) = 0xb7eb4000
close(3)                                = 0
open("/lib/libuuid.so.1", O_RDONLY)     = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\340\21\0\0004\0\0\0\230"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=13816, ...}) = 0
mmap2(NULL, 16604, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7ea6000
mmap2(0xb7ea9000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2) = 0xb7ea9000
close(3)                                = 0
open("/lib/libc.so.6", O_RDONLY)        = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\200h\1\0004\0\0\0\244"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=1315100, ...}) = 0
mmap2(NULL, 1320560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7d63000
mmap2(0xb7ea0000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13d) = 0xb7ea0000
mmap2(0xb7ea3000, 9840, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7ea3000
close(3)                                = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7d62000
set_thread_area({entry_number:-1 -> 6, base_addr:0xb7d62700, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
mprotect(0xb7ea0000, 8192, PROT_READ)   = 0
mprotect(0xb7ea9000, 4096, PROT_READ)   = 0
mprotect(0xb7eb4000, 4096, PROT_READ)   = 0
mprotect(0x8056000, 4096, PROT_READ)    = 0
mprotect(0xb7f03000, 4096, PROT_READ)   = 0
munmap(0xb7eb7000, 188643)              = 0
brk(0)                                  = 0x8d0a000
brk(0x8d2b000)                          = 0x8d2b000
open("/usr/lib/locale/locale-archive", O_RDONLY|O_LARGEFILE) = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=4915840, ...}) = 0
mmap2(NULL, 2097152, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7b62000
close(3)                                = 0
umask(022)                              = 022
open("/dev/null", O_RDWR|O_LARGEFILE)   = 3
close(3)                                = 0
getuid32()                              = 0
geteuid32()                             = 0
stat64("/sbin/mount.nfs4", {st_mode=S_IFREG|S_ISUID|0511, st_size=80316, ...}) = 0
clone(Process 25962 attached (waiting for parent)
Process 25962 resumed (parent 25961 ready)
child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7d62748) = 25962
[pid 25962] getgid32()                  = 0
[pid 25962] setgid32(0)                 = 0
[pid 25962] getuid32()                  = 0
[pid 25962] setuid32(0)                 = 0
[pid 25962] execve("/sbin/mount.nfs4", ["/sbin/mount.nfs4", "172.19.0.1:/", "/mnt/orionis", "-o", "rw"], [/* 78 vars */]) = 0
[pid 25962] brk(0)                      = 0x8802000
[pid 25962] access("/etc/ld.so.preload", R_OK) = -1 ENOENT (No such file or directory)
[pid 25962] open("/etc/ld.so.cache", O_RDONLY) = 3
[pid 25962] fstat64(3, {st_mode=S_IFREG|0644, st_size=188643, ...}) = 0
[pid 25962] mmap2(NULL, 188643, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7fd3000
[pid 25962] close(3)                    = 0
[pid 25962] open("/usr/lib/libtirpc.so.1", O_RDONLY) = 3
[pid 25962] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\300p\0\0004\0\0\0h"..., 512) = 512
[pid 25962] fstat64(3, {st_mode=S_IFREG|0755, st_size=141648, ...}) = 0
[pid 25962] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fd2000
[pid 25962] mmap2(NULL, 141712, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7faf000
[pid 25962] mmap2(0xb7fd0000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x21) = 0xb7fd0000
[pid 25962] close(3)                    = 0
[pid 25962] open("/lib/libnsl.so.1", O_RDONLY) = 3
[pid 25962] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0p1\0\0004\0\0\0|"..., 512) = 512
[pid 25962] fstat64(3, {st_mode=S_IFREG|0755, st_size=79540, ...}) = 0
[pid 25962] mmap2(NULL, 92136, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7f98000
[pid 25962] mmap2(0xb7fab000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x12) = 0xb7fab000
[pid 25962] mmap2(0xb7fad000, 6120, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7fad000
[pid 25962] close(3)                    = 0
[pid 25962] open("/usr/lib/libgssglue.so.1", O_RDONLY) = 3
[pid 25962] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\320\30\0\0004\0\0\0\f"..., 512) = 512
[pid 25962] fstat64(3, {st_mode=S_IFREG|0755, st_size=34332, ...}) = 0
[pid 25962] mmap2(NULL, 33352, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7f8f000
[pid 25962] mmap2(0xb7f96000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x7) = 0xb7f96000
[pid 25962] close(3)                    = 0
[pid 25962] open("/lib/libdl.so.2", O_RDONLY) = 3
[pid 25962] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0000\n\0\0004\0\0\0$"..., 512) = 512
[pid 25962] fstat64(3, {st_mode=S_IFREG|0755, st_size=9604, ...}) = 0
[pid 25962] mmap2(NULL, 12408, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7f8b000
[pid 25962] mmap2(0xb7f8d000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1) = 0xb7f8d000
[pid 25962] close(3)                    = 0
[pid 25962] open("/lib/libpthread.so.0", O_RDONLY) = 3
[pid 25962] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0PH\0\0004\0\0\0X"..., 512) = 512
[pid 25962] fstat64(3, {st_mode=S_IFREG|0755, st_size=118981, ...}) = 0
[pid 25962] mmap2(NULL, 94688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7f73000
[pid 25962] mmap2(0xb7f87000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13) = 0xb7f87000
[pid 25962] mmap2(0xb7f89000, 4576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7f89000
[pid 25962] close(3)                    = 0
[pid 25962] open("/lib/libc.so.6", O_RDONLY) = 3
[pid 25962] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\200h\1\0004\0\0\0\244"..., 512) = 512
[pid 25962] fstat64(3, {st_mode=S_IFREG|0755, st_size=1315100, ...}) = 0
[pid 25962] mmap2(NULL, 1320560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7e30000
[pid 25962] mmap2(0xb7f6d000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13d) = 0xb7f6d000
[pid 25962] mmap2(0xb7f70000, 9840, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7f70000
[pid 25962] close(3)                    = 0
[pid 25962] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7e2f000
[pid 25962] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7e2e000
[pid 25962] set_thread_area({entry_number:-1 -> 6, base_addr:0xb7e2e6c0, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
[pid 25962] mprotect(0xb7f6d000, 8192, PROT_READ) = 0
[pid 25962] mprotect(0xb7f87000, 4096, PROT_READ) = 0
[pid 25962] mprotect(0xb7f8d000, 4096, PROT_READ) = 0
[pid 25962] mprotect(0xb7f96000, 4096, PROT_READ) = 0
[pid 25962] mprotect(0xb7fab000, 4096, PROT_READ) = 0
[pid 25962] mprotect(0xb7fd0000, 4096, PROT_READ) = 0
[pid 25962] mprotect(0x805b000, 4096, PROT_READ) = 0
[pid 25962] mprotect(0xb801f000, 4096, PROT_READ) = 0
[pid 25962] munmap(0xb7fd3000, 188643)  = 0
[pid 25962] set_tid_address(0xb7e2e708) = 25962
[pid 25962] set_robust_list(0xb7e2e710, 0xc) = 0
[pid 25962] futex(0xbfc1f180, FUTEX_WAKE_PRIVATE, 1) = 0
[pid 25962] rt_sigaction(SIGRTMIN, {0xb7f77300, [], SA_SIGINFO}, NULL, 8) = 0
[pid 25962] rt_sigaction(SIGRT_1, {0xb7f77740, [], SA_RESTART|SA_SIGINFO}, NULL, 8) = 0
[pid 25962] rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL, 8) = 0
[pid 25962] getrlimit(RLIMIT_STACK, {rlim_cur=8192*1024, rlim_max=RLIM_INFINITY}) = 0
[pid 25962] uname({sys="Linux", node="bircoph", ...}) = 0
[pid 25962] getuid32()                  = 0
[pid 25962] uname({sys="Linux", node="bircoph", ...}) = 0
[pid 25962] brk(0)                      = 0x8802000
[pid 25962] brk(0x8823000)              = 0x8823000
[pid 25962] lstat64("/mnt", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
[pid 25962] lstat64("/mnt/orionis", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
[pid 25962] stat64("/mnt/orionis", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
[pid 25962] socket(PF_NETLINK, SOCK_RAW, 0) = 3
[pid 25962] bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
[pid 25962] getsockname(3, {sa_family=AF_NETLINK, pid=25962, groups=00000000}, [12]) = 0
[pid 25962] time(NULL)                  = 1240874661
[pid 25962] sendto(3, "\24\0\0\0\26\0\1\3\245>\366I\0\0\0\0\0\0\0\0"..., 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
[pid 25962] recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"0\0\0\0\24\0\2\0\245>\366Ije\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 156
[pid 25962] recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0\245>\366Ije\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
[pid 25962] close(3)                    = 0
[pid 25962] socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
[pid 25962] bind(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
[pid 25962] connect(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("172.19.0.1")}, 16) = 0
[pid 25962] getsockname(3, {sa_family=AF_INET, sin_port=htons(41750), sin_addr=inet_addr("172.19.0.3")}, [16]) = 0
[pid 25962] time(NULL)                  = 1240874661
[pid 25962] mount("172.19.0.1:/", "/mnt/orionis", "nfs4", 0, "clientaddr=172.19.0.3,addr=172.1"... <unfinished ...>
[pid 25961] wait4(-1, Process 25961 suspended
 <unfinished ...>
[pid 25962] <... mount resumed> )       = -1 ENOMEM (Cannot allocate memory)
[pid 25962] write(2, "mount.nfs4: Cannot allocate memor"..., 35mount.nfs4: Cannot allocate memory
) = 35
[pid 25962] exit_group(32)              = ?
Process 25961 resumed
Process 25962 detached
<... wait4 resumed> [{WIFEXITED(s) && WEXITSTATUS(s) == 32}], 0, NULL) = 25962
--- SIGCHLD (Child exited) @ 0 (0) ---
exit_group(32)                          = ?

--Boundary-01=_HFl9JOfi3gwxu8b--

--nextPart42797522.9c1kmuCoOv
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEABECAAYFAkn2UVAACgkQ2anJBBcsZw3UAACeLbYd4sPA+7EdXGFoZamSeJzr
OxQAn0UWBlMCLYSXxYS73S0vEbRbZNBr
=QXOn
-----END PGP SIGNATURE-----

--nextPart42797522.9c1kmuCoOv--
