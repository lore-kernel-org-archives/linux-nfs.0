From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: ps -aux hangs on [nfsd]
Date: Thu, 27 Jan 2005 11:57:04 +0100
Message-ID: <41F8C900.90404@bio.ifi.lmu.de>
References: <41DE6CF9.6030100@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: NFS NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cu7L0-0001Kb-8f
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 02:57:22 -0800
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cu7Kp-0004U1-Kh
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 02:57:22 -0800
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <41DE6CF9.6030100@bio.ifi.lmu.de>
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

Ok, it happened again and I did a "strace -f ps -aux". I can see
ps -aux going through almost all of the /proc/<pid> directories
for nfsd pids, but not all. On the 16th of the 18 nfsd pids, instead
of opening /proc/15600/cmdline, it opens /etc/passwd and then goes
into a look opening and closing /etc/passwd all over again.

Here are the relevant portions of the strace log, maybe someone
has an idea what could go wrong here.

The pids/proc dirs for the nfsd are 15585-15602. Things go wrong
on pid 15600.

Currently, this happens with the latest SuSE kernel for SuSE 9.2
(2.6.8 plus SuSE patches).


17054 stat64("/proc/15599", {st_mode=S_IFDIR|0555, st_size=0, ...}) = 0
17054 open("/proc/15599/stat", O_RDONLY) = 6
17054 read(6, "15599 (nfsd) S 1 1 1 0 -1 104864"..., 1023) = 125
17054 close(6)                          = 0
17054 open("/proc/15599/status", O_RDONLY) = 6
17054 read(6, "Name:\tnfsd\nState:\tS (sleeping)\nS"..., 1023) = 348
17054 close(6)                          = 0
17054 open("/proc/15599/cmdline", O_RDONLY) = 6
17054 read(6, "", 2047)                 = 0
17054 close(6)                          = 0
17054 write(1, "root     15599  0.0  0.0     0  "..., 70) = 70
17054 stat64("/proc/15600", {st_mode=S_IFDIR|0555, st_size=0, ...}) = 0
17054 open("/proc/15600/stat", O_RDONLY) = 6
17054 read(6, "15600 (nfsd) S 1 1 1 0 -1 104864"..., 1023) = 125
17054 close(6)                          = 0
17054 open("/proc/15600/status", O_RDONLY) = 6
17054 read(6, "Name:\tnfsd\nState:\tS (sleeping)\nS"..., 1023) = 373
17054 close(6)                          = 0
17054 open("/etc/passwd", O_RDONLY)     = 6
   ===> here it should open /proc/16000/cmdline, not passwd <===

17054 fcntl64(6, F_GETFD)               = 0
17054 fcntl64(6, F_SETFD, FD_CLOEXEC)   = 0
17054 _llseek(6, 0, [0], SEEK_CUR)      = 0
17054 fstat64(6, {st_mode=S_IFREG|0644, st_size=1704, ...}) = 0
17054 mmap2(NULL, 1704, PROT_READ, MAP_SHARED, 6, 0) = 0xb7dd3000
17054 _llseek(6, 1704, [1704], SEEK_SET) = 0
17054 fstat64(6, {st_mode=S_IFREG|0644, st_size=1704, ...}) = 0
17054 munmap(0xb7dd3000, 1704)          = 0
17054 close(6)                          = 0
17054 open("/etc/passwd", O_RDONLY)     = 6
17054 fcntl64(6, F_GETFD)               = 0
17054 fcntl64(6, F_SETFD, FD_CLOEXEC)   = 0
17054 _llseek(6, 0, [0], SEEK_CUR)      = 0
17054 fstat64(6, {st_mode=S_IFREG|0644, st_size=1704, ...}) = 0
17054 mmap2(NULL, 1704, PROT_READ, MAP_SHARED, 6, 0) = 0xb7dd3000
17054 _llseek(6, 1704, [1704], SEEK_SET) = 0
17054 fstat64(6, {st_mode=S_IFREG|0644, st_size=1704, ...}) = 0
17054 munmap(0xb7dd3000, 1704)          = 0
17054 close(6)                          = 0
17054 open("/etc/passwd", O_RDONLY)     = 6
...
and so on.

After doing this about 100 times, the strace change a bit:
17054 open("/etc/passwd", O_RDONLY)     = 6
17054 fcntl64(6, F_GETFD)               = 0
17054 fcntl64(6, F_SETFD, FD_CLOEXEC)   = 0
17054 _llseek(6, 0, [0], SEEK_CUR)      = 0
17054 fstat64(6, {st_mode=S_IFREG|0644, st_size=1704, ...}) = 0
17054 mmap2(NULL, 1704, PROT_READ, MAP_SHARED, 6, 0) = 0xb7dd3000
17054 _llseek(6, 1704, [1704], SEEK_SET) = 0
17054 fstat64(6, {st_mode=S_IFREG|0644, st_size=1704, ...}) = 0
17054 munmap(0xb7dd3000, 1704)          = 0
17054 close(6)                          = 0
17054 mremap(0xb7d53000, 331776, 335872, MREMAP_MAYMOVE) = 0xb7d53000
17054 open("/etc/passwd", O_RDONLY)     = 6
...

I.e., the "mremap" occurs. These commands (with the mremap) now loop forever,
and every about 50 times a little variation occurs:

...
17054 munmap(0xb7dd3000, 1704)          = 0
17054 close(6)                          = 0
17054 mremap(0xb7d53000, 405504, 405504, MREMAP_MAYMOVE) = 0xb7d53000
17054 socket(PF_UNIX, SOCK_STREAM, 0)   = 6
17054 connect(6, {sa_family=AF_UNIX, path="/var/run/.nscd_socket"}, 110) = -1 ENOENT 
(No such file or directory)
17054 close(6)                          = 0
17054 open("/etc/passwd", O_RDONLY)     = 6
...

Anyone any ideas? I also did a "ls -laR" for all the nfsd dirs in /proc
as well as find+cat on these dirs, so all contents from /proc are logged
in case you need some more information...

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
