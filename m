From: Donald Mcknight <donald.mcknight@sbcglobal.net>
Subject: NFSD Help
Date: Fri, 21 Oct 2005 06:50:34 -0700 (PDT)
Message-ID: <20051021135034.44113.qmail@web81509.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESxIH-0007Xp-3G
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 06:50:49 -0700
Received: from web81509.mail.yahoo.com ([206.190.37.112])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1ESxIE-0008MC-KX
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 06:50:49 -0700
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

Having issue getting nfs to start,  I am following the
howto and have not encounterd this before.

Below is the information asked for when reporting a
problem.  Let me know what else you need.

Any help is appreciated,

Thanks

Donald McKnight

NFS-UTILS Version:
*  net-fs/nfs-utils
      Latest version available: 1.0.6-r6
      Latest version installed: 1.0.6-r6
      Size of downloaded files: 259 kB
      Homepage:    http://nfs.sourceforge.net/
      Description: NFS client and server daemons
      License:     GPL-2

KERNEL Version:
linux-2.6.12-gentoo-r10

NFSD SERVER:
Linux daddy 2.6.12-gentoo-r10 #1 SMP Fri Sep 16
17:51:57 CDT 2005 x86_64 AMD Opteron(tm) Processor 246
AuthenticAMD GNU/Linux
192.168.13.25/255.255.255.0

CLIENT:
Slackware 10.1
Linux cactus 2.4.29 #2 Thu Jan 20 16:20:24 PST 2005
i686 unknown unknown GNU/Linux
192.168.13.20/255.255.255.0

COPY of EXPORTS from NFS SERVER:
# /etc/exports: NFS file systems being exported.  See
exports(5).
# /               master(rw) trusty(rw,no_root_squash)
/mnt/usb1     =20
192.168.13.20/255.255.255.0(rw,sync,no_root_squash)=20
#/mnt/usb2      192.168.13.20(rw,sync)=20
#/mnt/usb3      192.168.13.20(rw,sync)=20


RPCINFO SERVER:
daddy src # rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  42261  status
    100024    1   tcp  32820  status
    100005    1   udp    950  mountd
    100005    1   tcp    953  mountd
    100005    2   udp    950  mountd
    100005    2   tcp    953  mountd
    100005    3   udp    950  mountd
    100005    3   tcp    953  mountd


RPCINFO Client:
root@cactus:~# rpcinfo -p cactus
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100021    4   udp  32768  nlockmgr

STRACE from Starting rpc.nfsd
strace /usr/sbin/rpc.nfsd 8
execve("/usr/sbin/rpc.nfsd", ["/usr/sbin/rpc.nfsd",
"8"], [/* 34 vars */]) =3D 0
uname({sys=3D"Linux", node=3D"daddy", ...}) =3D 0
brk(0)                                  =3D 0x502000
mmap(NULL, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2aaaaaac0000
access("/etc/ld.so.preload", R_OK)      =3D -1 ENOENT
(No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      =3D 3
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D112341, ...})
=3D 0
mmap(NULL, 112341, PROT_READ, MAP_PRIVATE, 3, 0) =3D
0x2aaaaaac1000
close(3)                                =3D 0
open("/lib/libc.so.6", O_RDONLY)        =3D 3
read(3,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\315"...,
640) =3D 640
lseek(3, 624, SEEK_SET)                 =3D 624
read(3,
"\4\0\0\0\20\0\0\0\1\0\0\0GNU\0\0\0\0\0\2\0\0\0\4\0\0\0"...,
32) =3D 32
fstat(3, {st_mode=3DS_IFREG|0755, st_size=3D1256224, ...})
=3D 0
mmap(NULL, 2250120, PROT_READ|PROT_EXEC,
MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0x2aaaaabc1000
mprotect(0x2aaaaacdd000, 1086856, PROT_NONE) =3D 0
mmap(0x2aaaaaddc000, 24576, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x11b000) =3D
0x2aaaaaddc000
mmap(0x2aaaaade2000, 17800, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D
0x2aaaaade2000
close(3)                                =3D 0
mprotect(0x2aaaaaddc000, 12288, PROT_READ) =3D 0
mprotect(0x2aaaaabbf000, 4096, PROT_READ) =3D 0
munmap(0x2aaaaaac1000, 112341)          =3D 0
open("/dev/urandom", O_RDONLY)          =3D 3
read(3, "\361\225\321pg}\33\337", 8)    =3D 8
close(3)                                =3D 0
brk(0)                                  =3D 0x502000
brk(0x523000)                           =3D 0x523000
open("/etc/nsswitch.conf", O_RDONLY)    =3D 3
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D503, ...}) =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2aaaaaac1000
read(3, "# /etc/nsswitch.conf:\n# $Header:"..., 4096)
=3D 503
read(3, "", 4096)                       =3D 0
close(3)                                =3D 0
munmap(0x2aaaaaac1000, 4096)            =3D 0
open("/etc/ld.so.cache", O_RDONLY)      =3D 3
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D112341, ...})
=3D 0
mmap(NULL, 112341, PROT_READ, MAP_PRIVATE, 3, 0) =3D
0x2aaaaaac1000
close(3)                                =3D 0
open("/lib64/tls/x86_64/libnss_db.so.2", O_RDONLY) =3D
-1 ENOENT (No such file or directory)
stat("/lib64/tls/x86_64", 0x7fffffd47f50) =3D -1 ENOENT
(No such file or directory)
open("/lib64/tls/libnss_db.so.2", O_RDONLY) =3D -1
ENOENT (No such file or directory)
stat("/lib64/tls", 0x7fffffd47f50)      =3D -1 ENOENT
(No such file or directory)
open("/lib64/x86_64/libnss_db.so.2", O_RDONLY) =3D -1
ENOENT (No such file or directory)
stat("/lib64/x86_64", 0x7fffffd47f50)   =3D -1 ENOENT
(No such file or directory)
open("/lib64/libnss_db.so.2", O_RDONLY) =3D -1 ENOENT
(No such file or directory)
stat("/lib64", {st_mode=3DS_IFDIR|0755, st_size=3D4096,
...}) =3D 0
open("/usr/lib64/tls/x86_64/libnss_db.so.2", O_RDONLY)
=3D -1 ENOENT (No such file or directory)
stat("/usr/lib64/tls/x86_64", 0x7fffffd47f50) =3D -1
ENOENT (No such file or directory)
open("/usr/lib64/tls/libnss_db.so.2", O_RDONLY) =3D -1
ENOENT (No such file or directory)
stat("/usr/lib64/tls", 0x7fffffd47f50)  =3D -1 ENOENT
(No such file or directory)
open("/usr/lib64/x86_64/libnss_db.so.2", O_RDONLY) =3D
-1 ENOENT (No such file or directory)
stat("/usr/lib64/x86_64", 0x7fffffd47f50) =3D -1 ENOENT
(No such file or directory)
open("/usr/lib64/libnss_db.so.2", O_RDONLY) =3D -1
ENOENT (No such file or directory)
stat("/usr/lib64", {st_mode=3DS_IFDIR|0755,
st_size=3D36864, ...}) =3D 0
munmap(0x2aaaaaac1000, 112341)          =3D 0
open("/etc/ld.so.cache", O_RDONLY)      =3D 3
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D112341, ...})
=3D 0
mmap(NULL, 112341, PROT_READ, MAP_PRIVATE, 3, 0) =3D
0x2aaaaaac1000
close(3)                                =3D 0
open("/lib/libnss_files.so.2", O_RDONLY) =3D 3
read(3,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0
#\0\0\0"..., 640) =3D 640
lseek(3, 624, SEEK_SET)                 =3D 624
read(3,
"\4\0\0\0\20\0\0\0\1\0\0\0GNU\0\0\0\0\0\2\0\0\0\4\0\0\0"...,
32) =3D 32
fstat(3, {st_mode=3DS_IFREG|0755, st_size=3D44384, ...}) =3D
0
mmap(NULL, 1090856, PROT_READ|PROT_EXEC,
MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0x2aaaaade7000
mprotect(0x2aaaaadf1000, 1049896, PROT_NONE) =3D 0
mmap(0x2aaaaaef0000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x9000) =3D
0x2aaaaaef0000
close(3)                                =3D 0
munmap(0x2aaaaaac1000, 112341)          =3D 0
open("/etc/services", O_RDONLY)         =3D 3
fcntl(3, F_GETFD)                       =3D 0
fcntl(3, F_SETFD, FD_CLOEXEC)           =3D 0
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D29366, ...}) =3D
0
mmap(NULL, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2aaaaaac1000
read(3, "# /etc/services\n#\n# Network serv"..., 4096)
=3D 4096
read(3, "E service\n# private\t77/udp\nvettc"...,
4096) =3D 4096
read(3, "ge Access Protocol\nimap\t\t143/udp"...,
4096) =3D 4096
read(3, "tix\t361/tcp\t\t\t\t# Semantix\nsemant"...,
4096) =3D 4096
read(3, "3com-amp3\t629/tcp\n3com-amp3\t629/"...,
4096) =3D 4096
read(3, "cisco SNMP TCP port\nsnmp-tcp-por"..., 4096)
=3D 4096
close(3)                                =3D 0
munmap(0x2aaaaaac1000, 4096)            =3D 0
chdir("/var/lib/nfs")                   =3D 0
open("/dev/null", O_RDWR)               =3D 3
dup2(3, 0)                              =3D 0
dup2(3, 1)                              =3D 1
dup2(3, 2)                              =3D 2
getrlimit(RLIMIT_NOFILE, {rlim_cur=3D1024,
rlim_max=3D1024}) =3D 0
close(1023)                             =3D -1 EBADF
(Bad file descriptor)
close(1022)                             =3D -1 EBADF
(Bad file descriptor)
close(1021)                             =3D -1 EBADF
(Bad file descriptor)
close(1020)                             =3D -1 EBADF
(Bad file descriptor)
close(1019)                             =3D -1 EBADF
(Bad file descriptor)
close(1018)                             =3D -1 EBADF
(Bad file descriptor)
close(1017)                             =3D -1 EBADF
(Bad file descriptor)
close(1016)                             =3D -1 EBADF
(Bad file descriptor)
close(1015)                             =3D -1 EBADF
(Bad file descriptor)
close(1014)                             =3D -1 EBADF
(Bad file descriptor)
close(1013)                             =3D -1 EBADF
(Bad file descriptor)
close(1012)                             =3D -1 EBADF
(Bad file descriptor)
close(1011)                             =3D -1 EBADF
(Bad file descriptor)
close(1010)                             =3D -1 EBADF
(Bad file descriptor)
close(1009)                             =3D -1 EBADF
(Bad file descriptor)
close(1008)                             =3D -1 EBADF
(Bad file descriptor)
close(1007)                             =3D -1 EBADF
(Bad file descriptor)
close(1006)                             =3D -1 EBADF
(Bad file descriptor)
close(1005)                             =3D -1 EBADF
(Bad file descriptor)
close(1004)                             =3D -1 EBADF
(Bad file descriptor)
close(1003)                             =3D -1 EBADF
(Bad file descriptor)
close(1002)                             =3D -1 EBADF
(Bad file descriptor)
close(1001)                             =3D -1 EBADF
(Bad file descriptor)
close(1000)                             =3D -1 EBADF
(Bad file descriptor)
close(999)                              =3D -1 EBADF
(Bad file descriptor)
close(998)                              =3D -1 EBADF
(Bad file descriptor)
close(997)                              =3D -1 EBADF
(Bad file descriptor)
close(996)                              =3D -1 EBADF
(Bad file descriptor)
close(995)                              =3D -1 EBADF
(Bad file descriptor)
close(994)                              =3D -1 EBADF
(Bad file descriptor)
close(993)                              =3D -1 EBADF
(Bad file descriptor)
close(992)                              =3D -1 EBADF
(Bad file descriptor)
close(991)                              =3D -1 EBADF
(Bad file descriptor)
close(990)                              =3D -1 EBADF
(Bad file descriptor)
close(989)                              =3D -1 EBADF
(Bad file descriptor)
close(988)                              =3D -1 EBADF
(Bad file descriptor)
close(987)                              =3D -1 EBADF
(Bad file descriptor)
close(986)                              =3D -1 EBADF
(Bad file descriptor)
close(985)                              =3D -1 EBADF
(Bad file descriptor)
close(984)                              =3D -1 EBADF
(Bad file descriptor)
close(983)                              =3D -1 EBADF
(Bad file descriptor)
close(982)                              =3D -1 EBADF
(Bad file descriptor)
close(981)                              =3D -1 EBADF
(Bad file descriptor)
close(980)                              =3D -1 EBADF
(Bad file descriptor)
close(979)                              =3D -1 EBADF
(Bad file descriptor)
close(978)                              =3D -1 EBADF
(Bad file descriptor)
close(977)                              =3D -1 EBADF
(Bad file descriptor)
close(976)                              =3D -1 EBADF
(Bad file descriptor)
close(975)                              =3D -1 EBADF
(Bad file descriptor)
close(974)                              =3D -1 EBADF
(Bad file descriptor)
close(973)                              =3D -1 EBADF
(Bad file descriptor)
close(972)                              =3D -1 EBADF
(Bad file descriptor)
close(971)                              =3D -1 EBADF
(Bad file descriptor)
close(970)                              =3D -1 EBADF
(Bad file descriptor)
close(969)                              =3D -1 EBADF
(Bad file descriptor)
close(968)                              =3D -1 EBADF
(Bad file descriptor)
close(967)                              =3D -1 EBADF
(Bad file descriptor)
close(966)                              =3D -1 EBADF
(Bad file descriptor)
close(965)                              =3D -1 EBADF
(Bad file descriptor)
close(964)                              =3D -1 EBADF
(Bad file descriptor)
close(963)                              =3D -1 EBADF
(Bad file descriptor)
close(962)                              =3D -1 EBADF
(Bad file descriptor)
close(961)                              =3D -1 EBADF
(Bad file descriptor)
close(960)                              =3D -1 EBADF
(Bad file descriptor)
close(959)                              =3D -1 EBADF
(Bad file descriptor)
close(958)                              =3D -1 EBADF
(Bad file descriptor)
close(957)                              =3D -1 EBADF
(Bad file descriptor)
close(956)                              =3D -1 EBADF
(Bad file descriptor)
close(955)                              =3D -1 EBADF
(Bad file descriptor)
close(954)                              =3D -1 EBADF
(Bad file descriptor)
close(953)                              =3D -1 EBADF
(Bad file descriptor)
close(952)                              =3D -1 EBADF
(Bad file descriptor)
close(951)                              =3D -1 EBADF
(Bad file descriptor)
close(950)                              =3D -1 EBADF
(Bad file descriptor)
close(949)                              =3D -1 EBADF
(Bad file descriptor)
close(948)                              =3D -1 EBADF
(Bad file descriptor)
close(947)                              =3D -1 EBADF
(Bad file descriptor)
close(946)                              =3D -1 EBADF
(Bad file descriptor)
close(945)                              =3D -1 EBADF
(Bad file descriptor)
close(944)                              =3D -1 EBADF
(Bad file descriptor)
close(943)                              =3D -1 EBADF
(Bad file descriptor)
close(942)                              =3D -1 EBADF
(Bad file descriptor)
close(941)                              =3D -1 EBADF
(Bad file descriptor)
close(940)                              =3D -1 EBADF
(Bad file descriptor)
close(939)                              =3D -1 EBADF
(Bad file descriptor)
close(938)                              =3D -1 EBADF
(Bad file descriptor)
close(937)                              =3D -1 EBADF
(Bad file descriptor)
close(936)                              =3D -1 EBADF
(Bad file descriptor)
close(935)                              =3D -1 EBADF
(Bad file descriptor)
close(934)                              =3D -1 EBADF
(Bad file descriptor)
close(933)                              =3D -1 EBADF
(Bad file descriptor)
close(932)                              =3D -1 EBADF
(Bad file descriptor)
close(931)                              =3D -1 EBADF
(Bad file descriptor)
close(930)                              =3D -1 EBADF
(Bad file descriptor)
close(929)                              =3D -1 EBADF
(Bad file descriptor)
close(928)                              =3D -1 EBADF
(Bad file descriptor)
close(927)                              =3D -1 EBADF
(Bad file descriptor)
close(926)                              =3D -1 EBADF
(Bad file descriptor)
close(925)                              =3D -1 EBADF
(Bad file descriptor)
close(924)                              =3D -1 EBADF
(Bad file descriptor)
close(923)                              =3D -1 EBADF
(Bad file descriptor)
close(922)                              =3D -1 EBADF
(Bad file descriptor)
close(921)                              =3D -1 EBADF
(Bad file descriptor)
close(920)                              =3D -1 EBADF
(Bad file descriptor)
close(919)                              =3D -1 EBADF
(Bad file descriptor)
close(918)                              =3D -1 EBADF
(Bad file descriptor)
close(917)                              =3D -1 EBADF
(Bad file descriptor)
close(916)                              =3D -1 EBADF
(Bad file descriptor)
close(915)                              =3D -1 EBADF
(Bad file descriptor)
close(914)                              =3D -1 EBADF
(Bad file descriptor)
close(913)                              =3D -1 EBADF
(Bad file descriptor)
close(912)                              =3D -1 EBADF
(Bad file descriptor)
close(911)                              =3D -1 EBADF
(Bad file descriptor)
close(910)                              =3D -1 EBADF
(Bad file descriptor)
close(909)                              =3D -1 EBADF
(Bad file descriptor)
close(908)                              =3D -1 EBADF
(Bad file descriptor)
close(907)                              =3D -1 EBADF
(Bad file descriptor)
close(906)                              =3D -1 EBADF
(Bad file descriptor)
close(905)                              =3D -1 EBADF
(Bad file descriptor)
close(904)                              =3D -1 EBADF
(Bad file descriptor)
close(903)                              =3D -1 EBADF
(Bad file descriptor)
close(902)                              =3D -1 EBADF
(Bad file descriptor)
close(901)                              =3D -1 EBADF
(Bad file descriptor)
close(900)                              =3D -1 EBADF
(Bad file descriptor)
close(899)                              =3D -1 EBADF
(Bad file descriptor)
close(898)                              =3D -1 EBADF
(Bad file descriptor)
close(897)                              =3D -1 EBADF
(Bad file descriptor)
close(896)                              =3D -1 EBADF
(Bad file descriptor)
close(895)                              =3D -1 EBADF
(Bad file descriptor)
close(894)                              =3D -1 EBADF
(Bad file descriptor)
close(893)                              =3D -1 EBADF
(Bad file descriptor)
close(892)                              =3D -1 EBADF
(Bad file descriptor)
close(891)                              =3D -1 EBADF
(Bad file descriptor)
close(890)                              =3D -1 EBADF
(Bad file descriptor)
close(889)                              =3D -1 EBADF
(Bad file descriptor)
close(888)                              =3D -1 EBADF
(Bad file descriptor)
close(887)                              =3D -1 EBADF
(Bad file descriptor)
close(886)                              =3D -1 EBADF
(Bad file descriptor)
close(885)                              =3D -1 EBADF
(Bad file descriptor)
close(884)                              =3D -1 EBADF
(Bad file descriptor)
close(883)                              =3D -1 EBADF
(Bad file descriptor)
close(882)                              =3D -1 EBADF
(Bad file descriptor)
close(881)                              =3D -1 EBADF
(Bad file descriptor)
close(880)                              =3D -1 EBADF
(Bad file descriptor)
close(879)                              =3D -1 EBADF
(Bad file descriptor)
close(878)                              =3D -1 EBADF
(Bad file descriptor)
close(877)                              =3D -1 EBADF
(Bad file descriptor)
close(876)                              =3D -1 EBADF
(Bad file descriptor)
close(875)                              =3D -1 EBADF
(Bad file descriptor)
close(874)                              =3D -1 EBADF
(Bad file descriptor)
close(873)                              =3D -1 EBADF
(Bad file descriptor)
close(872)                              =3D -1 EBADF
(Bad file descriptor)
close(871)                              =3D -1 EBADF
(Bad file descriptor)
close(870)                              =3D -1 EBADF
(Bad file descriptor)
close(869)                              =3D -1 EBADF
(Bad file descriptor)
close(868)                              =3D -1 EBADF
(Bad file descriptor)
close(867)                              =3D -1 EBADF
(Bad file descriptor)
close(866)                              =3D -1 EBADF
(Bad file descriptor)
close(865)                              =3D -1 EBADF
(Bad file descriptor)
close(864)                              =3D -1 EBADF
(Bad file descriptor)
close(863)                              =3D -1 EBADF
(Bad file descriptor)
close(862)                              =3D -1 EBADF
(Bad file descriptor)
close(861)                              =3D -1 EBADF
(Bad file descriptor)
close(860)                              =3D -1 EBADF
(Bad file descriptor)
close(859)                              =3D -1 EBADF
(Bad file descriptor)
close(858)                              =3D -1 EBADF
(Bad file descriptor)
close(857)                              =3D -1 EBADF
(Bad file descriptor)
close(856)                              =3D -1 EBADF
(Bad file descriptor)
close(855)                              =3D -1 EBADF
(Bad file descriptor)
close(854)                              =3D -1 EBADF
(Bad file descriptor)
close(853)                              =3D -1 EBADF
(Bad file descriptor)
close(852)                              =3D -1 EBADF
(Bad file descriptor)
close(851)                              =3D -1 EBADF
(Bad file descriptor)
close(850)                              =3D -1 EBADF
(Bad file descriptor)
close(849)                              =3D -1 EBADF
(Bad file descriptor)
close(848)                              =3D -1 EBADF
(Bad file descriptor)
close(847)                              =3D -1 EBADF
(Bad file descriptor)
close(846)                              =3D -1 EBADF
(Bad file descriptor)
close(845)                              =3D -1 EBADF
(Bad file descriptor)
close(844)                              =3D -1 EBADF
(Bad file descriptor)
.........
.........
open("/proc/fs/nfsd/threads", O_WRONLY) =3D -1 ENOENT
(No such file or directory)
open("/proc/fs/nfs/threads", O_WRONLY)  =3D -1 ENOENT
(No such file or directory)
nfsservctl(0, 0x7fffffd47fe0, 0)        =3D -1 ENOSYS
(Function not implemented)
time([1129901404])                      =3D 1129901404
open("/etc/localtime", O_RDONLY)        =3D 3
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D1279, ...}) =3D
0
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D1279, ...}) =3D
0
mmap(NULL, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2aaaaaac1000
read(3,
"TZif\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\5\0\0\0\5\0"...,
4096) =3D 1279
close(3)                                =3D 0
munmap(0x2aaaaaac1000, 4096)            =3D 0
stat("/etc/localtime", {st_mode=3DS_IFREG|0644,
st_size=3D1279, ...}) =3D 0
stat("/etc/localtime", {st_mode=3DS_IFREG|0644,
st_size=3D1279, ...}) =3D 0
stat("/etc/localtime", {st_mode=3DS_IFREG|0644,
st_size=3D1279, ...}) =3D 0
getpid()                                =3D 25891
socket(PF_FILE, SOCK_DGRAM, 0)          =3D 3
fcntl(3, F_SETFD, FD_CLOEXEC)           =3D 0
connect(3, {sa_family=3DAF_FILE, path=3D"/dev/log"}, 16) =3D
-1 EPROTOTYPE (Protocol wrong type for socket)
close(3)                                =3D 0
socket(PF_FILE, SOCK_STREAM, 0)         =3D 3
fcntl(3, F_SETFD, FD_CLOEXEC)           =3D 0
connect(3, {sa_family=3DAF_FILE, path=3D"/dev/log"}, 16) =3D
0
sendto(3, "<27>Oct 21 08:30:04 nfsd[25891]:"..., 66,
MSG_NOSIGNAL, NULL, 0) =3D 66
close(3)                                =3D 0
exit_group(1)                           =3D ?





-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
