From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: Re: exportfs operations hang
Date: 03 Jul 2003 09:57:59 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1057244279.23711.18.camel@mosix>
References: <1055879177.10166.3.camel@mosix>  <3EEF914A.8030000@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-yAZovz/oWhO/kSJGo1EA"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Y5Vy-0006cr-00
	for <nfs@lists.sourceforge.net>; Thu, 03 Jul 2003 07:56:50 -0700
To: Steve Dickson <SteveD@RedHat.com>
In-Reply-To: <3EEF914A.8030000@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-yAZovz/oWhO/kSJGo1EA
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I finally got an opportunity to reproduce the result of exportfs..
attached is the strace output..


I previously had a problem that an incorrectly set broadcast address was
causing rpc.mountd to 'stop functioning' when alot of new machines mount
in a short amount of time..  Anyway, the only thing that showed up in
the log, was a heartbeat message (string2msg) that was actually noting a
problem on the system.. anyway, i noted the same log message from when i
did the exportfs.

I did email the heartbeat mailinglist, but they did not have any
definitive answer as to what the message meant to me, but said that it
was not a heartbeat error which i believe.

As a possible avenue of troubleshooting, when i do exportfs, i do it
like this::

exportfs -o rw,async @vss_grp:/export/vss/db/mv22

I did some examination of my netgroups file, and found a few things..

1. there are host entries in netgroup that do not exist in host (because
the hosts are no longer online, and when they cleaned out hosts, they
didn't clean netgroup.

2. there are a couple cases of inherited groups (the vss_grp calls 4
other groups, and some of those groups are also calling subgroups). I
believe that there is no more than 2 levels of groups.. I was unsure if
this would have an effect..

------

Action that I immediately took was to clear out the old hosts, and
verify that all hosts existed in /etc/hosts or in dns (if the netgroup
called the FQDN.

Thanks for your help,
Matt
mschilli@vss.fsi.com


On Tue, 2003-06-17 at 17:08, Steve Dickson wrote:
> Here does strace say its hanging?
> 
> SteveD.
> 
> Matt Schillinger wrote:
> 
> >Hello,
> >
> >I am having reproducible problems with exportfs.
> >
> >When I try to run exportfs or exportfs -u, it simply stalls and never
> >drops back to commandline.. if i CTRL+C, i see that (in the case of an
> >exportfs) the mountpoint is still not shared. In the case of an exportfs
> >-u, If i CTRL+C it, the mountpoint IS still shared.  I do not know what
> >is causing the problem.. the only workaround that I have found is to
> >restart nfsd.. Is there something in rmtab/xtab/etab that could cause an
> >exportfs hangup?
> >
> >I am using 64 threads, and am having no thread utilization issues
> >according to /proc/net/rpc/nfsd
> >
> >Has anyone else had this problem?
> >
> >Thanks for your help
> >  
> >
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU Hosting Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
> INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
-- 
Matt Schillinger
System Administrator
FlightSafety International
mschilli@vss.fsi.com
314-551-8403


--=-yAZovz/oWhO/kSJGo1EA
Content-Disposition: attachment; filename=exportfs.outstrace
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; name=exportfs.outstrace; charset=UTF-8

execve("/usr/sbin/exportfs", ["exportfs", "-o", "rw,async", "@vss_grp:/expo=
rt/vss/db/qa_release"], [/* 24 vars */]) =3D 0
uname({sys=3D"Linux", node=3D"thor", ...})  =3D 0
brk(0)                                  =3D 0x8054a24
open("/etc/ld.so.preload", O_RDONLY)    =3D -1 ENOENT (No such file or dire=
ctory)
open("/etc/ld.so.cache", O_RDONLY)      =3D 3
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D48048, ...}) =3D 0
old_mmap(NULL, 48048, PROT_READ, MAP_PRIVATE, 3, 0) =3D 0x40014000
close(3)                                =3D 0
open("/lib/libc.so.6", O_RDONLY)        =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\300Y\1"..., 512) =
=3D 512
fstat64(3, {st_mode=3DS_IFREG|0755, st_size=3D1292588, ...}) =3D 0
old_mmap(NULL, 1298244, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) =3D 0x40020=
000
old_mmap(0x40156000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3,=
 0x136000) =3D 0x40156000
old_mmap(0x4015b000, 8004, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_=
ANONYMOUS, -1, 0) =3D 0x4015b000
close(3)                                =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4015d000
munmap(0x40014000, 48048)               =3D 0
getpid()                                =3D 11001
rt_sigaction(SIGUSR1, {0x804d04c, [USR1], SA_RESTORER|SA_RESTART, 0x4004856=
8}, {SIG_DFL}, 8) =3D 0
rt_sigaction(SIGUSR2, {0x804d04c, [USR2], SA_RESTORER|SA_RESTART, 0x4004856=
8}, {SIG_DFL}, 8) =3D 0
brk(0)                                  =3D 0x8054a24
brk(0x8055a24)                          =3D 0x8055a24
brk(0)                                  =3D 0x8055a24
brk(0x8056000)                          =3D 0x8056000
open("/etc/exports", O_RDONLY)          =3D 3
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D24, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40014000
read(3, "/mnt/test\tloki(rw,sync)\n", 4096) =3D 24
lstat64("/mnt", {st_mode=3DS_IFDIR|0755, st_size=3D4096, ...}) =3D 0
lstat64("/mnt/test", {st_mode=3DS_IFDIR|0755, st_size=3D4096, ...}) =3D 0
gettimeofday({1057187230, 776032}, NULL) =3D 0
getpid()                                =3D 11001
open("/etc/resolv.conf", O_RDONLY)      =3D 4
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D128, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40015000
read(4, "; generated by /sbin/dhclient-sc"..., 4096) =3D 128
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x40015000, 4096)                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/nsswitch.conf", O_RDONLY)    =3D 4
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D1722, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40015000
read(4, "#\n# /etc/nsswitch.conf\n#\n# An ex"..., 4096) =3D 1722
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x40015000, 4096)                =3D 0
open("/etc/ld.so.cache", O_RDONLY)      =3D 4
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D48048, ...}) =3D 0
old_mmap(NULL, 48048, PROT_READ, MAP_PRIVATE, 4, 0) =3D 0x4015e000
close(4)                                =3D 0
open("/lib/libnss_files.so.2", O_RDONLY) =3D 4
read(4, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\20\35\0"..., 512) =
=3D 512
fstat64(4, {st_mode=3DS_IFREG|0755, st_size=3D49929, ...}) =3D 0
old_mmap(NULL, 47056, PROT_READ|PROT_EXEC, MAP_PRIVATE, 4, 0) =3D 0x4016a00=
0
old_mmap(0x40175000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 4, =
0xa000) =3D 0x40175000
close(4)                                =3D 0
munmap(0x4015e000, 48048)               =3D 0
open("/etc/host.conf", O_RDONLY)        =3D 4
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D17, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40015000
read(4, "order hosts,bind\n", 4096)     =3D 17
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x40015000, 4096)                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40015000
read(4, "# Do not remove the following li"..., 4096) =3D 289
close(4)                                =3D 0
munmap(0x40015000, 4096)                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40015000
read(4, "# Do not remove the following li"..., 4096) =3D 289
close(4)                                =3D 0
munmap(0x40015000, 4096)                =3D 0
brk(0)                                  =3D 0x8056000
brk(0x8057000)                          =3D 0x8057000
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40015000
read(4, "# Do not remove the following li"..., 4096) =3D 289
close(4)                                =3D 0
munmap(0x40015000, 4096)                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40015000
read(4, "# Do not remove the following li"..., 4096) =3D 289
close(4)                                =3D 0
munmap(0x40015000, 4096)                =3D 0
read(3, "", 4096)                       =3D 0
read(3, "", 4096)                       =3D 0
close(3)                                =3D 0
munmap(0x40014000, 4096)                =3D 0
brk(0)                                  =3D 0x8057000
brk(0x8058000)                          =3D 0x8058000
open("/var/lib/nfs/etab", O_RDONLY)     =3D 3
rt_sigaction(SIGALRM, {0x804cb8c, [], SA_RESTORER, 0x40048568}, {SIG_DFL}, =
8) =3D 0
alarm(10)                               =3D 0
fcntl64(3, F_SETLKW, {type=3DF_RDLCK, whence=3DSEEK_SET, start=3D0, len=3D0=
}) =3D 0
alarm(0)                                =3D 10
rt_sigaction(SIGALRM, {SIG_DFL}, NULL, 8) =3D 0
open("/var/lib/nfs/etab", O_RDONLY)     =3D 4
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D442, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40014000
read(4, "/mnt/test\tloki(rw,sync,wdelay,hi"..., 4096) =3D 442
brk(0)                                  =3D 0x8058000
brk(0x8059000)                          =3D 0x8059000
lstat64("/mnt", {st_mode=3DS_IFDIR|0755, st_size=3D4096, ...}) =3D 0
lstat64("/mnt/test", {st_mode=3DS_IFDIR|0755, st_size=3D4096, ...}) =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 5
connect(5, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(5)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 5
fcntl64(5, F_GETFD)                     =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(5, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40015000
read(5, "# Do not remove the following li"..., 4096) =3D 289
close(5)                                =3D 0
munmap(0x40015000, 4096)                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 5
connect(5, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(5)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 5
fcntl64(5, F_GETFD)                     =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(5, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40015000
read(5, "# Do not remove the following li"..., 4096) =3D 289
close(5)                                =3D 0
munmap(0x40015000, 4096)                =3D 0
lstat64("/export", {st_mode=3DS_IFDIR|0755, st_size=3D160, ...}) =3D 0
lstat64("/export/terrex_prototyping", {st_mode=3DS_IFDIR|0755, st_size=3D13=
6, ...}) =3D 0
lstat64("/export", {st_mode=3DS_IFDIR|0755, st_size=3D160, ...}) =3D 0
lstat64("/export/vss", {st_mode=3DS_IFDIR|0755, st_size=3D72, ...}) =3D 0
lstat64("/export/vss/db", {st_mode=3DS_IFDIR|0755, st_size=3D104, ...}) =3D=
 0
lstat64("/export/vss/db/mv22", {st_mode=3DS_IFDIR|0755, st_size=3D312, ...}=
) =3D 0
brk(0)                                  =3D 0x8059000
brk(0x805a000)                          =3D 0x805a000
read(4, "", 4096)                       =3D 0
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x40014000, 4096)                =3D 0
close(3)                                =3D 0
open("/var/lib/nfs/rmtab", O_RDONLY)    =3D 3
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D4090, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40014000
read(3, "aaaa:/export/imagery:0x00000002\n"..., 4096) =3D 4090
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x40015000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x40015000, 4096)                =3D 0
open("/etc/ld.so.cache", O_RDONLY)      =3D 4
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D48048, ...}) =3D 0
old_mmap(NULL, 48048, PROT_READ, MAP_PRIVATE, 4, 0) =3D 0x4015e000
close(4)                                =3D 0
open("/lib/libnss_nis.so.2", O_RDONLY)  =3D 4
read(4, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\0\34\0"..., 512) =
=3D 512
fstat64(4, {st_mode=3DS_IFREG|0755, st_size=3D40954, ...}) =3D 0
old_mmap(NULL, 33616, PROT_READ|PROT_EXEC, MAP_PRIVATE, 4, 0) =3D 0x4001500=
0
old_mmap(0x4001d000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 4, =
0x8000) =3D 0x4001d000
close(4)                                =3D 0
open("/lib/libnsl.so.1", O_RDONLY)      =3D 4
read(4, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\260:\0"..., 512) =
=3D 512
fstat64(4, {st_mode=3DS_IFREG|0755, st_size=3D90721, ...}) =3D 0
old_mmap(NULL, 88672, PROT_READ|PROT_EXEC, MAP_PRIVATE, 4, 0) =3D 0x4017600=
0
old_mmap(0x40189000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 4, =
0x12000) =3D 0x40189000
old_mmap(0x4018a000, 6752, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_=
ANONYMOUS, -1, 0) =3D 0x4018a000
close(4)                                =3D 0
munmap(0x4015e000, 48048)               =3D 0
uname({sys=3D"Linux", node=3D"thor", ...})  =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
brk(0)                                  =3D 0x805a000
brk(0x805f000)                          =3D 0x805f000
gettimeofday({1057187230, 788089}, NULL) =3D 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
getpid()                                =3D 11001
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1001), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\"\377;\33\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\"\377;\33\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1002), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\r\350I\240\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\r\350I\240\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1003), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "u\210\'4\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "u\210\'4\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1004), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, ")\321\225<\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ")\321\225<\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1005), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "[\210\233\326\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "[\210\233\326\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 112
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1006), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "$\226\200J\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 88, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "$\226\200J\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1007), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\20\2i\253\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\20\2i\253\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1008), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "|\351h\222\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "|\351h\222\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1009), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "~E\30\230\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "~E\30\230\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 60
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1010), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, ":\364\23\3\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ":\364\23\3\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 252
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1011), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "ELs!\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0\0"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "ELs!\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 372
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1012), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, ")\31\336\327\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 92, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 92
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ")\31\336\327\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 296
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1013), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\2\377\206A\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\2\377\206A\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 128
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1014), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "p,\6#\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0\0"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "p,\6#\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 208
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1015), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "]|\6\333\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "]|\6\333\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 196
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1016), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "g\233\3609\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 92, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 92
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "g\233\3609\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 92
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1017), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "7_l\221\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "7_l\221\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 80
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1018), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "J\304\244@\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "J\304\244@\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 296
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1019), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "d\245!R\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "d\245!R\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 308
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1020), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "l\242\321\240\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "l\242\321\240\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1021), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "zi\315\267\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "zi\315\267\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 244
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1022), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "`\362o\361\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "`\362o\361\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(1023), sin_addr=3Dinet_addr=
("0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "v73\313\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 88,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "v73\313\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(600), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "?\222\261A\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "?\222\261A\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(601), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "k\322\234x\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 88, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "k\322\234x\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
brk(0)                                  =3D 0x805f000
brk(0x8060000)                          =3D 0x8060000
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(602), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\t)/\255\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\t)/\255\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(603), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "+\304?\224\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "+\304?\224\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(604), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "-\265jP\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "-\265jP\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(605), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, " w*\370\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, " w*\370\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 112
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(606), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\177\376\225\321\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0"..., 88, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\177\376\225\321\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(607), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\177L*\334\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\177L*\334\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(608), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\27\201\201\322\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0"..., 76,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\27\201\201\322\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(609), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "~T|)\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0\0"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "~T|)\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 60
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(610), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "V\350&\300\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "V\350&\300\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 252
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(611), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "22I0\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0\0"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "22I0\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 372
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(612), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "|:\336\220\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 92, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 92
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "|:\336\220\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 296
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(613), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\4Q\1\315\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\4Q\1\315\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 128
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(614), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "#\26\37$\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "#\26\37$\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 208
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(615), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "l(\261\216\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "l(\261\216\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 196
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(616), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\177y\316\'\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 92,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 92
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\177y\316\'\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 92
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(617), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, ";\337\361)\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ";\337\361)\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 80
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(618), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\26\307<S\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\26\307<S\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 296
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(619), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\200<\234\'\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\200<\234\'\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 308
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(620), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\37\34\t=3D\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 8=
4, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("1=
98.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\37\34\t=3D\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,=
 8800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_add=
r("198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(621), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "t|\370H\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "t|\370H\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 244
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(622), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "F\rh\316\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "F\rh\316\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(623), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "+h\241\266\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 88, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "+h\241\266\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(624), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "/l\210\316\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "/l\210\316\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(625), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "-\341\275\350\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 88,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "-\341\275\350\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
brk(0)                                  =3D 0x8060000
brk(0x8061000)                          =3D 0x8061000
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(626), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "H9n\343\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "H9n\343\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 64
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(627), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, ";EVx\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0\0"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ";EVx\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 112
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(628), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "*\n\36\244\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 88, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "*\n\36\244\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(629), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "BC6\6\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0\0"..., 76,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "BC6\6\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(630), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "i#\363r\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 76,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "i#\363r\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(631), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\2>Z\307\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\2>Z\307\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 60
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(632), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "/a\342\345\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "/a\342\345\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 252
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(633), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "${u\1\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0\0"..., 76,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "${u\1\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 372
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(634), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "Kl\32\314\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 92,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 92
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "Kl\32\314\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 296
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(635), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "0\271\233W\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "0\271\233W\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 64
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(636), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "A\221\250\306\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 88,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "A\221\250\306\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 64
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(637), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "WeKm\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0\0"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "WeKm\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 64
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(638), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "R\250Y\267\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 88, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "R\250Y\267\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 64
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
brk(0)                                  =3D 0x8061000
brk(0x8062000)                          =3D 0x8062000
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(639), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "Q\200\33\v\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "Q\200\33\v\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(640), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\3W\314^\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\3W\314^\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(641), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\6y\224w\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\6y\224w\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 112
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(642), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "(\214\24\216\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 88, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "(\214\24\216\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(643), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "w\23@u\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "w\23@u\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(644), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "ax\313\225\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "ax\313\225\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(645), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "H\222\300\360\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "H\222\300\360\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 60
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(646), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "2L\316\205\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "2L\316\205\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 252
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(647), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "m\17@\351\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 76,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "m\17@\351\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 372
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(648), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "M\330<;\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 92,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 92
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "M\330<;\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 296
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(649), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "+9\310\370\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "+9\310\370\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(650), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "6;\313\v\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 88, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "6;\313\v\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(651), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\3\352\343<\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\3\352\343<\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(652), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\30\211\3215\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 88, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\30\211\3215\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
brk(0)                                  =3D 0x8062000
brk(0x8063000)                          =3D 0x8063000
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(653), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\17\250NH\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\17\250NH\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(654), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "(\265#H\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "(\265#H\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(655), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "/\356t\36\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "/\356t\36\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 112
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(656), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "Mx@\321\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 88,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "Mx@\321\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(657), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "m^Y\33\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "m^Y\33\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(658), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "!Sq\306\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 76,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "!Sq\306\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(659), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\21\277f\21\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\21\277f\21\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 60
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(660), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\20\n\376;\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\20\n\376;\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 252
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(661), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\rf\271\272\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 76,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\rf\271\272\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 372
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(662), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\35\347V+\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 92,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 92
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\35\347V+\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 296
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(663), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\f\373\267\5\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\f\373\267\5\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 128
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(664), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\16\220\330\t\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\16\220\330\t\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 208
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(665), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "C\313\270\243\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "C\313\270\243\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 196
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(666), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\"$3$\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0\0"..., 92,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 92
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\"$3$\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 92
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(667), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\177\267\325\222\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\177\267\325\222\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 80
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(668), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\\D\255\361\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\\D\255\361\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 296
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(669), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "Z\356_U\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "Z\356_U\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 308
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(670), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\35g\250^\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\35g\250^\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 52
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(671), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\5\343_\321\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\5\343_\321\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 244
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(672), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "#\242\217\232\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "#\242\217\232\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(673), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D -1 EADDRINUSE (Address already in use)
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(674), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\1\rC\273\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 88,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\1\rC\273\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
brk(0)                                  =3D 0x8063000
brk(0x8064000)                          =3D 0x8064000
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(675), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\31\227j\256\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\31\227j\256\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(676), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "yD\265\330\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 88, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "yD\265\330\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(677), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "~\226\266\217\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "~\226\266\217\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
socket(PF_UNIX, SOCK_STREAM, 0)         =3D 4
connect(4, {sin_family=3DAF_UNIX, path=3D"/var/run/.nscd_socket"}, 110) =3D=
 -1 ENOENT (No such file or directory)
close(4)                                =3D 0
open("/etc/hosts", O_RDONLY)            =3D 4
fcntl64(4, F_GETFD)                     =3D 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         =3D 0
fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D289, ...}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D 0x4001e000
read(4, "# Do not remove the following li"..., 4096) =3D 289
read(4, "", 4096)                       =3D 0
close(4)                                =3D 0
munmap(0x4001e000, 4096)                =3D 0
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(678), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "O\354`2\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "O\354`2\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 56
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(679), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\36\351<Q\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 80,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\36\351<Q\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 112
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(680), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "/\200\371\320\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 88,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 88
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "/\200\371\320\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(681), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "3\364\355P\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "3\364\355P\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(682), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "_\336\"9\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "_\336\"9\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 152
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(683), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "b\242\347M\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "b\242\347M\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 60
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(684), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "+%\267\264\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "+%\267\264\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 252
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(685), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "0\276\25\203\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 76, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 76
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "0\276\25\203\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 372
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(686), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "s\6y\264\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 92, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 92
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "s\6y\264\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 296
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "6\234;\366\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "6\234;\366\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 128
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(688), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "<\203\16\247\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "<\203\16\247\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 208
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(689), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "1\"\237H\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0"..., 80, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 80
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "1\"\237H\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 196
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(690), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, ">3R\335\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 92,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 92
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">3R\335\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 92
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(691), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "Z\2535\214\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "Z\2535\214\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 80
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(692), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\26\370\325\362\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\26\370\325\362\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8=
800, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr(=
"198.51.27.42")}}, [16]) =3D 296
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(693), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "\4\v\343\252\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 84, =
0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198.=
51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, "\4\v\343\252\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 88=
00, 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("=
198.51.27.42")}}, [16]) =3D 308
close(5)                                =3D 0
open("/etc/netgroup", O_RDONLY)         =3D -1 ENOENT (No such file or dire=
ctory)
open("/var/yp/binding/vss.fsi.com.2", O_RDONLY) =3D 4
readv(4, [{"\377\377", 2}, {"\1\0\0\0\3063\33*\2\257\0\0", 12}], 2) =3D 14
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) =3D 5
bind(5, {sin_family=3DAF_INET, sin_port=3Dhtons(694), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0
ioctl(5, 0x5421, [1])                   =3D 0
setsockopt(5, SOL_IP, IP_RECVERR, [1], 4) =3D 0
fcntl64(5, F_SETFD, FD_CLOEXEC)         =3D 0
close(4)                                =3D 0
sendto(5, "N\262\204\310\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0"..., 84,=
 0, {sin_family=3DAF_INET, sin_port=3Dhtons(687), sin_addr=3Dinet_addr("198=
.51.27.42")}}, 16) =3D 84
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dloki\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32772), sin_addr=3Dinet_addr("198.51.27.=
49")}}, [16]) =3D 149
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, 5000) =3D 1
recvfrom(5, ">>>\nt=3Dstatus\nst=3Dactive\nsrc=3Dthor\n"..., 8800, 0, {sin_=
family=3DAF_INET, sin_port=3Dhtons(32774), sin_addr=3Dinet_addr("198.51.27.=
48")}}, [16]) =3D 150
poll([{fd=3D5, events=3DPOLLIN}], 1, 5000)  =3D -1 EINTR (Interrupted syste=
m call)
--- SIGINT (Interrupt) ---
+++ killed by SIGINT +++

--=-yAZovz/oWhO/kSJGo1EA--



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
