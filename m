From: Moritz Kiese <mbk@mytum.de>
Subject: rpc.mountd: getfh failed: Operation not permitted (longish)
Date: Fri, 7 Apr 2006 17:08:18 +0200 (CEST)
Message-ID: <Pine.BSO.4.63.0604071647220.880@wodka.lkn.ei.tum.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FRsZS-0008DG-Id
	for nfs@lists.sourceforge.net; Fri, 07 Apr 2006 08:08:22 -0700
Received: from mailrelay2.lrz-muenchen.de ([129.187.254.102])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FRsZQ-0004Od-EE
	for nfs@lists.sourceforge.net; Fri, 07 Apr 2006 08:08:22 -0700
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Greetings,

this one started to itch badly in the last couple of days: One of our main 
NFS servers (arak) starts to refuse automounts to some of our clients (in 
this case aperol) --- while these clients are (at least seemingly) 
randomly selected, once they are the only thing that helps is

 	* exportfs -va or -rv
 	* restarting the nfsserver process

Sometimes it takes months for this to reappear (fairly constant over 
kernel revisions ;), some other times (like today) I had to restart the 
nfsd for the third time...

The kernel version is SuSEs flavour of 2.6.5 on 9.1.
NFS Utils version is 1.0.6

/etc/exports:
/export/home    10.152.4.0/255.255.255.0(rw,async) 10.152.4.1(rw,async,no_root_squash)
/export/home2   10.152.4.0/255.255.255.0(rw,async) 10.152.13.0/255.255.255.0(rw,async) 10.152.4.1(rw,async,no_root_squash)
/export2        10.152.4.0/255.255.255.0(rw,async) 10.152.13.0/255.255.255.0(rw,async) 10.152.4.1(rw,async,no_root_squash)

/etc/fstab:
/dev/sda2            /                    reiserfs   acl,user_xattr        1 1
/dev/sda1            swap                 swap       pri=42                0 0
/dev/sdb1            /export              reiserfs   usrquota,nosuid       1 2
devpts               /dev/pts             devpts     mode=0620,gid=5       0 0
proc                 /proc                proc       defaults              0 0
usbfs                /proc/bus/usb        usbfs      noauto                0 0
sysfs                /sys                 sysfs      noauto                0 0
/dev/cdrecorder      /media/cdrecorder    subfs      fs=cdfss,ro,procuid,nosuid,nodev,exec,iocharset=utf8 0 0
/dev/fd0             /media/floppy        subfs      fs=floppyfss,procuid,nodev,nosuid,sync 0 0

/var/log/messages says:
Apr  7 16:42:50 arak rpc.mountd: getfh failed: Operation not permitted
Apr  7 16:42:50 arak rpc.mountd: authenticated mount request from aperol.lkn.ei.tum.de:678 for /export/home/hartmann (/export/home)
Apr  7 16:42:50 arak rpc.mountd: getfh failed: Operation not permitted
Apr  7 16:42:50 arak rpc.mountd: authenticated mount request from aperol.lkn.e-technik.tu-muenchen.de:680 for /export/home/hartmann (/export/home)

The strace -f of rpc.mountd:
0065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\254\1\0\0\1\0\0\0\0\0\0\6aperol\3lkn\te-techni"..., 
53, 0) = 53
10065 gettimeofday({1144420970, 548182}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [243])         = 0
10065 recvfrom(7, 
"\375\254\205\200\0\1\0\1\0\3\0\5\6aperol\3lkn\te-techn"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 243
10065 close(7)                          = 0
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<13>Apr  7 16:42:50 rpc.mountd: "..., 145, 0) = 145
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 stat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 stat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 nfsservctl(0x8, 0xbfffd3dc, 0x8059a80) = -1 EPERM (Operation not 
permitted)
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<12>Apr  7 16:42:50 rpc.mountd: "..., 69, 0) = 69
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 write(6, 
"\200\0\0\0343#\252\336\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0"..., 32) = 32
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "", 4000)                 = 0
10065 close(6)                          = 0
10065 select(1024, [3 4], NULL, NULL, NULL) = 1 (in [4])
10065 accept(4, {sa_family=AF_INET, sin_port=htons(674), 
sin_addr=inet_addr("10.152.4.5")}, [16]) = 6
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "\200\0\0d3gC\204\0\0\0\0\0\0\0\2\0\1\206\245\0\0\0\3\0"..., 
4000) = 104
10065 open("/etc/hosts.allow", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=2639, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.allow\n# See `man tc"..., 4096) = 2639
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 open("/etc/hosts.deny", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=149, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.deny\n# See `man tcp"..., 4096) = 149
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/var/lib/nfs/etab", {st_mode=S_IFREG|0644, st_size=1334, 
...}) = 0
10065 lstat64("/export", {st_mode=S_IFDIR|0755, st_size=160, ...}) = 0
10065 lstat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 lstat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\255\1\0\0\1\0\0\0\0\0\0\0015\0014\003152\00210\7i"..., 
41, 0) = 41
10065 gettimeofday({1144420970, 561738}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [296])         = 0
10065 recvfrom(7, 
"\375\255\205\200\0\1\0\2\0\3\0\5\0015\0014\003152\0021"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 296
10065 close(7)                          = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\256\1\0\0\1\0\0\0\0\0\0\6aperol\3lkn\2ei\3tum\2d"..., 
38, 0) = 38
10065 gettimeofday({1144420970, 562811}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [228])         = 0
10065 recvfrom(7, 
"\375\256\205\200\0\1\0\1\0\3\0\5\6aperol\3lkn\2ei\3tum"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 228
10065 close(7)                          = 0
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<13>Apr  7 16:42:50 rpc.mountd: "..., 130, 0) = 130
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 stat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 stat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 nfsservctl(0x8, 0xbfffd3dc, 0x8059a80) = -1 EPERM (Operation not 
permitted)
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<12>Apr  7 16:42:50 rpc.mountd: "..., 69, 0) = 69
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 write(6, 
"\200\0\0\0343gC\204\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 32) = 32
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "", 4000)                 = 0
10065 close(6)                          = 0
10065 select(1024, [3 4], NULL, NULL, NULL) = 1 (in [4])
10065 accept(4, {sa_family=AF_INET, sin_port=htons(676), 
sin_addr=inet_addr("10.152.4.5")}, [16]) = 6
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "\200\0\0dY\231 s\0\0\0\0\0\0\0\2\0\1\206\245\0\0\0\3\0"..., 
4000) = 104
10065 open("/etc/hosts.allow", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=2639, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.allow\n# See `man tc"..., 4096) = 2639
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 open("/etc/hosts.deny", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=149, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.deny\n# See `man tcp"..., 4096) = 149
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/var/lib/nfs/etab", {st_mode=S_IFREG|0644, st_size=1334, 
...}) = 0
10065 lstat64("/export", {st_mode=S_IFDIR|0755, st_size=160, ...}) = 0
10065 lstat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 lstat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\257\1\0\0\1\0\0\0\0\0\0\0015\0014\003152\00210\7i"..., 
41, 0) = 41
10065 gettimeofday({1144420970, 576371}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [296])         = 0
10065 recvfrom(7, 
"\375\257\205\200\0\1\0\2\0\3\0\5\0015\0014\003152\0021"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 296
10065 close(7)                          = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\260\1\0\0\1\0\0\0\0\0\0\6aperol\3lkn\te-techni"..., 
53, 0) = 53
10065 gettimeofday({1144420970, 577460}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [243])         = 0
10065 recvfrom(7, 
"\375\260\205\200\0\1\0\1\0\3\0\5\6aperol\3lkn\te-techn"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 243
10065 close(7)                          = 0
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<13>Apr  7 16:42:50 rpc.mountd: "..., 145, 0) = 145
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 stat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 stat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 nfsservctl(0x8, 0xbfffd3dc, 0x8059a80) = -1 EPERM (Operation not 
permitted)
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<12>Apr  7 16:42:50 rpc.mountd: "..., 69, 0) = 69
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 write(6, "\200\0\0\34Y\231 
s\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 32) = 32
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "", 4000)                 = 0
10065 close(6)                          = 0
10065 select(1024, [3 4], NULL, NULL, NULL) = 1 (in [4])
10065 accept(4, {sa_family=AF_INET, sin_port=htons(678), 
sin_addr=inet_addr("10.152.4.5")}, [16]) = 6
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "\200\0\0dN\361\251\f\0\0\0\0\0\0\0\2\0\1\206\245\0\0\0"..., 
4000) = 104
10065 open("/etc/hosts.allow", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=2639, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.allow\n# See `man tc"..., 4096) = 2639
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 open("/etc/hosts.deny", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=149, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.deny\n# See `man tcp"..., 4096) = 149
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/var/lib/nfs/etab", {st_mode=S_IFREG|0644, st_size=1334, 
...}) = 0
10065 lstat64("/export", {st_mode=S_IFDIR|0755, st_size=160, ...}) = 0
10065 lstat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 lstat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\261\1\0\0\1\0\0\0\0\0\0\0015\0014\003152\00210\7i"..., 
41, 0) = 41
10065 gettimeofday({1144420970, 591121}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [296])         = 0
10065 recvfrom(7, 
"\375\261\205\200\0\1\0\2\0\3\0\5\0015\0014\003152\0021"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 296
10065 close(7)                          = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\262\1\0\0\1\0\0\0\0\0\0\6aperol\3lkn\2ei\3tum\2d"..., 
38, 0) = 38
10065 gettimeofday({1144420970, 592160}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [228])         = 0
10065 recvfrom(7, 
"\375\262\205\200\0\1\0\1\0\3\0\5\6aperol\3lkn\2ei\3tum"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 228
10065 close(7)                          = 0
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<13>Apr  7 16:42:50 rpc.mountd: "..., 130, 0) = 130
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 stat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 stat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 nfsservctl(0x8, 0xbfffd3dc, 0x8059a80) = -1 EPERM (Operation not 
permitted)
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<12>Apr  7 16:42:50 rpc.mountd: "..., 69, 0) = 69
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 write(6, 
"\200\0\0\34N\361\251\f\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0"..., 32) = 32
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "", 4000)                 = 0
10065 close(6)                          = 0
10065 select(1024, [3 4], NULL, NULL, NULL) = 1 (in [4])
10065 accept(4, {sa_family=AF_INET, sin_port=htons(680), 
sin_addr=inet_addr("10.152.4.5")}, [16]) = 6
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "\200\0\0d\31D8\242\0\0\0\0\0\0\0\2\0\1\206\245\0\0\0\3"..., 
4000) = 104
10065 open("/etc/hosts.allow", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=2639, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.allow\n# See `man tc"..., 4096) = 2639
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 open("/etc/hosts.deny", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=149, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.deny\n# See `man tcp"..., 4096) = 149
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/var/lib/nfs/etab", {st_mode=S_IFREG|0644, st_size=1334, 
...}) = 0
10065 lstat64("/export", {st_mode=S_IFDIR|0755, st_size=160, ...}) = 0
10065 lstat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 lstat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\263\1\0\0\1\0\0\0\0\0\0\0015\0014\003152\00210\7i"..., 
41, 0) = 41
10065 gettimeofday({1144420970, 605630}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [296])         = 0
10065 recvfrom(7, 
"\375\263\205\200\0\1\0\2\0\3\0\5\0015\0014\003152\0021"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 296
10065 close(7)                          = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\264\1\0\0\1\0\0\0\0\0\0\6aperol\3lkn\te-techni"..., 
53, 0) = 53
10065 gettimeofday({1144420970, 606660}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [243])         = 0
10065 recvfrom(7, 
"\375\264\205\200\0\1\0\1\0\3\0\5\6aperol\3lkn\te-techn"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 243
10065 close(7)                          = 0
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<13>Apr  7 16:42:50 rpc.mountd: "..., 145, 0) = 145
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 stat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 stat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 nfsservctl(0x8, 0xbfffd3dc, 0x8059a80) = -1 EPERM (Operation not 
permitted)
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<12>Apr  7 16:42:50 rpc.mountd: "..., 69, 0) = 69
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 write(6, 
"\200\0\0\34\31D8\242\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 32) = 32
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "", 4000)                 = 0
10065 close(6)                          = 0
10065 select(1024, [3 4], NULL, NULL, NULL) = 1 (in [4])
10065 accept(4, {sa_family=AF_INET, sin_port=htons(682), 
sin_addr=inet_addr("10.152.4.5")}, [16]) = 6
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, 
"\200\0\0d\17\362\253\36\0\0\0\0\0\0\0\2\0\1\206\245\0\0"..., 4000) = 104
10065 open("/etc/hosts.allow", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=2639, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.allow\n# See `man tc"..., 4096) = 2639
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 open("/etc/hosts.deny", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=149, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.deny\n# See `man tcp"..., 4096) = 149
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/var/lib/nfs/etab", {st_mode=S_IFREG|0644, st_size=1334, 
...}) = 0
10065 lstat64("/export", {st_mode=S_IFDIR|0755, st_size=160, ...}) = 0
10065 lstat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 lstat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\265\1\0\0\1\0\0\0\0\0\0\0015\0014\003152\00210\7i"..., 
41, 0) = 41
10065 gettimeofday({1144420970, 620107}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [296])         = 0
10065 recvfrom(7, 
"\375\265\205\200\0\1\0\2\0\3\0\5\0015\0014\003152\0021"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 296
10065 close(7)                          = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\266\1\0\0\1\0\0\0\0\0\0\6aperol\3lkn\2ei\3tum\2d"..., 
38, 0) = 38
10065 gettimeofday({1144420970, 621138}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [228])         = 0
10065 recvfrom(7, 
"\375\266\205\200\0\1\0\1\0\3\0\5\6aperol\3lkn\2ei\3tum"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 228
10065 close(7)                          = 0
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<13>Apr  7 16:42:50 rpc.mountd: "..., 130, 0) = 130
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 stat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 stat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 nfsservctl(0x8, 0xbfffd3dc, 0x8059a80) = -1 EPERM (Operation not 
permitted)
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<12>Apr  7 16:42:50 rpc.mountd: "..., 69, 0) = 69
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 write(6, 
"\200\0\0\34\17\362\253\36\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0"..., 32) = 32
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "", 4000)                 = 0
10065 close(6)                          = 0
10065 select(1024, [3 4], NULL, NULL, NULL) = 1 (in [4])
10065 accept(4, {sa_family=AF_INET, sin_port=htons(684), 
sin_addr=inet_addr("10.152.4.5")}, [16]) = 6
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "\200\0\0dJv\202:\0\0\0\0\0\0\0\2\0\1\206\245\0\0\0\3\0"..., 
4000) = 104
10065 open("/etc/hosts.allow", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=2639, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.allow\n# See `man tc"..., 4096) = 2639
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 open("/etc/hosts.deny", O_RDONLY) = 7
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=149, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "# /etc/hosts.deny\n# See `man tcp"..., 4096) = 149
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/var/lib/nfs/etab", {st_mode=S_IFREG|0644, st_size=1334, 
...}) = 0
10065 lstat64("/export", {st_mode=S_IFDIR|0755, st_size=160, ...}) = 0
10065 lstat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 lstat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\267\1\0\0\1\0\0\0\0\0\0\0015\0014\003152\00210\7i"..., 
41, 0) = 41
10065 gettimeofday({1144420970, 634581}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [296])         = 0
10065 recvfrom(7, 
"\375\267\205\200\0\1\0\2\0\3\0\5\0015\0014\003152\0021"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 296
10065 close(7)                          = 0
10065 open("/etc/hosts", O_RDONLY)      = 7
10065 fcntl64(7, F_GETFD)               = 0
10065 fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
10065 fstat64(7, {st_mode=S_IFREG|0644, st_size=688, ...}) = 0
10065 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 
-1, 0) = 0x40018000
10065 read(7, "#\n# hosts         This file desc"..., 4096) = 688
10065 read(7, "", 4096)                 = 0
10065 close(7)                          = 0
10065 munmap(0x40018000, 4096)          = 0
10065 stat64("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=114, ...}) 
= 0
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
10065 connect(7, {sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, 28) = 0
10065 send(7, "\375\270\1\0\0\1\0\0\0\0\0\0\6aperol\3lkn\te-techni"..., 
53, 0) = 53
10065 gettimeofday({1144420970, 635767}, NULL) = 0
10065 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
10065 ioctl(7, FIONREAD, [243])         = 0
10065 recvfrom(7, 
"\375\270\205\200\0\1\0\1\0\3\0\5\6aperol\3lkn\te-techn"..., 1024, 0, 
{sa_family=AF_INET, sin_port=htons(53), 
sin_addr=inet_addr("10.156.33.53")}, [16]) = 243
10065 close(7)                          = 0
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<13>Apr  7 16:42:50 rpc.mountd: "..., 145, 0) = 145
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 stat64("/export/home/hartmann", {st_mode=S_IFDIR|0755, 
st_size=13088, ...}) = 0
10065 stat64("/export/home", {st_mode=S_IFDIR|0755, st_size=1312, ...}) = 
0
10065 nfsservctl(0x8, 0xbfffd3dc, 0x8059a80) = -1 EPERM (Operation not 
permitted)
10065 time([1144420970])                = 1144420970
10065 rt_sigaction(SIGPIPE, {0x400f8f60, [], 0}, {SIG_IGN}, 8) = 0
10065 send(5, "<12>Apr  7 16:42:50 rpc.mountd: "..., 69, 0) = 69
10065 rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
10065 write(6, 
"\200\0\0\34Jv\202:\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 32) = 32
10065 select(1024, [3 4 6], NULL, NULL, NULL) = 1 (in [6])
10065 poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
10065 read(6, "", 4000)                 = 0
10065 close(6)                          = 0
10065 select(1024, [3 4], NULL, NULL, NULL) = ? ERESTARTNOHAND (To be 
restarted)
10065 --- SIGTERM (Terminated) @ 0 (0) ---
10065 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 6
10065 --- SIGCONT (Continued) @ 0 (0) ---
10065 ioctl(6, 0x8912, 0xbfffcf80)      = 0
10065 ioctl(6, 0x8913, 0xbfffcf88)      = 0
10065 close(6)                          = 0

I'd be glad about any ideas on this...

Best regards,
 	Moritz.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
