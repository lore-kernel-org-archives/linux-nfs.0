From: "Brandon D. Valentine" <brandon@dvalentine.com>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Fri, 27 Aug 2004 18:34:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040827233431.GC57703@brandon.dvalentine.com>
References: <20040827212244.GA57703@brandon.dvalentine.com> <1093642565.5758.108.camel@lade.trondhjem.org> <1093643490.5758.120.camel@lade.trondhjem.org> <20040827233235.GB57703@brandon.dvalentine.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3MwIy2ne0vdjdPXF"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0qGe-0002MK-Qb
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 16:36:24 -0700
Received: from mail.michaelchaney.com ([207.65.84.68] helo=daphne.michaelchaney.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C0qGd-0001eb-Ri
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 16:36:24 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20040827233235.GB57703@brandon.dvalentine.com>
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


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

And of course I didn't actually attach the strace output file so here it
comes.  Sorry for the extra message.

Thanks,

Brandon D. Valentine
-- 
brandon@dvalentine.com                           http://www.geekpunk.net
Pseudo-Random Googlism:  brandon is going for his counts

--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mount.strace"

execve("/bin/mount", ["mount", "-t", "nfs", "reef:/export/reef/httpd/", "/mnt/temp/"], [/* 27 vars */]) = 0
uname({sysname="Linux", nodename="scylla.structbio.vanderbilt.edu", release="2.6.8.1", version="#5 SMP Wed Aug 25 16:09:17 CDT 2004", machine="i686"}) = 0
brk(0)                                  = 0x805c000
open("/etc/ld.so.preload", O_RDONLY)    = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_dev=makedev(3, 2), st_ino=4256539, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=144, st_size=71507, st_atime=2004/08/27-18:24:59, st_mtime=2004/08/26-10:03:26, st_ctime=2004/08/26-10:03:26}) = 0
old_mmap(NULL, 71507, PROT_READ, MAP_PRIVATE, 3, 0) = 0x40000000
close(3)                                = 0
open("/lib/tls/libc.so.6", O_RDONLY)    = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\300\273"..., 512) = 512
fstat64(3, {st_dev=makedev(3, 2), st_ino=20972881, st_mode=S_IFREG|0755, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=2848, st_size=1455084, st_atime=2004/08/27-18:24:59, st_mtime=2004/05/11-08:20:12, st_ctime=2004/08/20-04:02:55}) = 0
old_mmap(0x747000, 1158124, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x747000
old_mmap(0x85c000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 0x115000) = 0x85c000
old_mmap(0x860000, 7148, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x860000
close(3)                                = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x40012000
mprotect(0x85c000, 8192, PROT_READ)     = 0
mprotect(0x743000, 4096, PROT_READ)     = 0
set_thread_area({entry_number:-1 -> 6, base_addr:0x40012460, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
munmap(0x40000000, 71507)               = 0
brk(0)                                  = 0x805c000
brk(0x807d000)                          = 0x807d000
brk(0)                                  = 0x807d000
open("/usr/lib/locale/locale-archive", O_RDONLY|O_LARGEFILE) = 3
fstat64(3, {st_dev=makedev(3, 2), st_ino=25166981, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=78568, st_size=40246896, st_atime=2004/08/27-18:22:19, st_mtime=2004/08/19-15:00:54, st_ctime=2004/08/19-15:00:54}) = 0
mmap2(NULL, 2097152, PROT_READ, MAP_PRIVATE, 3, 0) = 0x40013000
close(3)                                = 0
umask(022)                              = 022
open("/dev/null", O_RDWR|O_LARGEFILE)   = 3
close(3)                                = 0
getuid32()                              = 0
geteuid32()                             = 0
lstat64("/etc/mtab", {st_dev=makedev(3, 2), st_ino=4256572, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=645, st_atime=2004/08/27-18:22:19, st_mtime=2004/08/27-18:09:34, st_ctime=2004/08/27-18:09:34}) = 0
stat64("/sbin/mount.nfs", 0xbffff730)   = -1 ENOENT (No such file or directory)
uname({sysname="Linux", nodename="scylla.structbio.vanderbilt.edu", release="2.6.8.1", version="#5 SMP Wed Aug 25 16:09:17 CDT 2004", machine="i686"}) = 0
gettimeofday({1093649099, 827523}, NULL) = 0
getpid()                                = 6904
open("/etc/resolv.conf", O_RDONLY)      = 3
fstat64(3, {st_dev=makedev(3, 2), st_ino=5146370, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=78, st_atime=2004/08/27-18:22:15, st_mtime=2004/08/19-15:17:43, st_ctime=2004/08/19-15:17:43}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x40213000
read(3, "search structbio.vanderbilt.edu\n"..., 4096) = 78
read(3, "", 4096)                       = 0
close(3)                                = 0
munmap(0x40213000, 4096)                = 0
socket(PF_FILE, SOCK_STREAM, 0)         = 3
connect(3, {sa_family=AF_FILE, path="/var/run/nscd/socket"}, 110) = -1 ENOENT (No such file or directory)
close(3)                                = 0
open("/etc/nsswitch.conf", O_RDONLY)    = 3
fstat64(3, {st_dev=makedev(3, 2), st_ino=4195335, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=1718, st_atime=2004/08/27-18:22:19, st_mtime=2004/08/19-15:30:34, st_ctime=2004/08/19-15:30:34}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x40213000
read(3, "#\n# /etc/nsswitch.conf\n#\n# An ex"..., 4096) = 1718
read(3, "", 4096)                       = 0
close(3)                                = 0
munmap(0x40213000, 4096)                = 0
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_dev=makedev(3, 2), st_ino=4256539, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=144, st_size=71507, st_atime=2004/08/27-18:24:59, st_mtime=2004/08/26-10:03:26, st_ctime=2004/08/26-10:03:26}) = 0
old_mmap(NULL, 71507, PROT_READ, MAP_PRIVATE, 3, 0) = 0x40213000
close(3)                                = 0
open("/lib/libnss_files.so.2", O_RDONLY) = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0`\33\0\000"..., 512) = 512
fstat64(3, {st_dev=makedev(3, 2), st_ino=25167015, st_mode=S_IFREG|0755, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=104, st_size=50944, st_atime=2004/08/27-18:24:59, st_mtime=2004/05/11-08:20:08, st_ctime=2004/08/19-15:00:56}) = 0
old_mmap(NULL, 45724, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x40225000
old_mmap(0x4022f000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 0x9000) = 0x4022f000
close(3)                                = 0
mprotect(0x4022f000, 4096, PROT_READ)   = 0
munmap(0x40213000, 71507)               = 0
open("/etc/host.conf", O_RDONLY)        = 3
fstat64(3, {st_dev=makedev(3, 2), st_ino=4194451, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=17, st_atime=2004/08/27-18:22:15, st_mtime=2000/07/23-10:06:54, st_ctime=2004/08/19-15:00:37}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x40213000
read(3, "order hosts,bind\n", 4096)     = 17
read(3, "", 4096)                       = 0
close(3)                                = 0
munmap(0x40213000, 4096)                = 0
open("/etc/hosts", O_RDONLY)            = 3
fcntl64(3, F_GETFD)                     = 0
fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
fstat64(3, {st_dev=makedev(3, 2), st_ino=5146368, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=203, st_atime=2004/08/27-18:22:15, st_mtime=2004/08/19-15:17:43, st_ctime=2004/08/19-15:17:43}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x40213000
read(3, "# Do not remove the following li"..., 4096) = 203
read(3, "", 4096)                       = 0
close(3)                                = 0
munmap(0x40213000, 4096)                = 0
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_dev=makedev(3, 2), st_ino=4256539, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=144, st_size=71507, st_atime=2004/08/27-18:24:59, st_mtime=2004/08/26-10:03:26, st_ctime=2004/08/26-10:03:26}) = 0
old_mmap(NULL, 71507, PROT_READ, MAP_PRIVATE, 3, 0) = 0x40213000
close(3)                                = 0
open("/lib/libnss_nis.so.2", O_RDONLY)  = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\300\33"..., 512) = 512
fstat64(3, {st_dev=makedev(3, 2), st_ino=25167020, st_mode=S_IFREG|0755, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=88, st_size=43528, st_atime=2004/08/27-18:24:59, st_mtime=2004/05/11-08:20:08, st_ctime=2004/08/19-15:00:56}) = 0
old_mmap(NULL, 37440, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x40231000
old_mmap(0x40239000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 0x7000) = 0x40239000
close(3)                                = 0
open("/lib/libnsl.so.1", O_RDONLY)      = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0pZq\000"..., 512) = 512
fstat64(3, {st_dev=makedev(3, 2), st_ino=25402408, st_mode=S_IFREG|0755, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=192, st_size=96248, st_atime=2004/08/27-18:24:59, st_mtime=2004/05/11-08:20:07, st_ctime=2004/08/20-04:03:03}) = 0
old_mmap(0x712000, 84192, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x712000
old_mmap(0x723000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 0x11000) = 0x723000
old_mmap(0x725000, 6368, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x725000
close(3)                                = 0
mprotect(0x723000, 4096, PROT_READ)     = 0
mprotect(0x40239000, 4096, PROT_READ)   = 0
munmap(0x40213000, 71507)               = 0
uname({sysname="Linux", nodename="scylla.structbio.vanderbilt.edu", release="2.6.8.1", version="#5 SMP Wed Aug 25 16:09:17 CDT 2004", machine="i686"}) = 0
open("/var/yp/binding/structbio.2", O_RDONLY) = 3
readv(3, [{"\377\377", 2}, {"\1\0\0\0\240\201\212\370\3U\0\0", 12}], 2) = 14
gettimeofday({1093649099, 830821}, NULL) = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 4
bind(4, {sa_family=AF_INET, sin_port=htons(720), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
ioctl(4, FIONBIO, [1])                  = 0
setsockopt(4, SOL_IP, IP_RECVERR, [1], 4) = 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         = 0
close(3)                                = 0
sendto(4, "LH!\371\0\0\0\0\0\0\0\2\0\1\206\244\0\0\0\2\0\0\0\3\0\0"..., 80, 0, {sa_family=AF_INET, sin_port=htons(853), sin_addr=inet_addr("160.129.138.248")}, 16) = 80
poll([{fd=4, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
recvfrom(4, "LH!\371\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"..., 8800, 0, {sa_family=AF_INET, sin_port=htons(853), sin_addr=inet_addr("160.129.138.248")}, [16]) = 140
close(4)                                = 0
time(NULL)                              = 1093649099
socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 3
bind(3, {sa_family=AF_INET, sin_port=htons(721), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
connect(3, {sa_family=AF_INET, sin_port=htons(111), sin_addr=inet_addr("160.129.138.217")}, 16) = 0
write(3, "\200\0\0008\10\217\226\357\0\0\0\0\0\0\0\2\0\1\206\240"..., 60) = 60
poll([{fd=3, events=POLLIN, revents=POLLIN}], 1, 60000) = 1
read(3, "\200\0\0\34\10\217\226\357\0\0\0\1\0\0\0\0\0\0\0\0\0\0"..., 400) = 32
close(3)                                = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
bind(3, {sa_family=AF_INET, sin_port=htons(722), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
ioctl(3, FIONBIO, [1])                  = 0
setsockopt(3, SOL_IP, IP_RECVERR, [1], 4) = 0
sendto(3, "\16\203\177\r\0\0\0\0\0\0\0\2\0\1\206\240\0\0\0\2\0\0\0"..., 56, 0, {sa_family=AF_INET, sin_port=htons(111), sin_addr=inet_addr("160.129.138.217")}, 16) = 56
poll([{fd=3, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
recvfrom(3, "\16\203\177\r\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 400, 0, {sa_family=AF_INET, sin_port=htons(111), sin_addr=inet_addr("160.129.138.217")}, [16]) = 28
close(3)                                = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
bind(3, {sa_family=AF_INET, sin_port=htons(723), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
ioctl(3, FIONBIO, [1])                  = 0
setsockopt(3, SOL_IP, IP_RECVERR, [1], 4) = 0
sendto(3, "7Ee\330\0\0\0\0\0\0\0\2\0\1\206\240\0\0\0\2\0\0\0\3\0\0"..., 56, 0, {sa_family=AF_INET, sin_port=htons(111), sin_addr=inet_addr("160.129.138.217")}, 16) = 56
poll([{fd=3, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
recvfrom(3, "7Ee\330\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\10"..., 400, 0, {sa_family=AF_INET, sin_port=htons(111), sin_addr=inet_addr("160.129.138.217")}, [16]) = 28
close(3)                                = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
bind(3, {sa_family=AF_INET, sin_port=htons(724), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
ioctl(3, FIONBIO, [1])                  = 0
setsockopt(3, SOL_IP, IP_RECVERR, [1], 4) = 0
sendto(3, "K\236#\v\0\0\0\0\0\0\0\2\0\1\206\243\0\0\0\3\0\0\0\0\0"..., 40, 0, {sa_family=AF_INET, sin_port=htons(2049), sin_addr=inet_addr("160.129.138.217")}, 16) = 40
poll([{fd=3, events=POLLIN, revents=POLLIN}], 1, 3000) = 1
recvfrom(3, "K\236#\v\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\2\0\0\0"..., 400, 0, {sa_family=AF_INET, sin_port=htons(2049), sin_addr=inet_addr("160.129.138.217")}, [16]) = 32
close(3)                                = 0
close(3)                                = -1 EBADF (Bad file descriptor)
write(2, "mount to NFS server \'reef\' faile"..., 33) = 33
write(2, ": server is down.\n", 18)     = 18
exit_group(32)                          = ?

--3MwIy2ne0vdjdPXF--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
