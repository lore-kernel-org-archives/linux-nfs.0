From: Gavin Hamill <gdh@acentral.co.uk>
Subject: Re: lockd / statd fun (sorry)
Date: Tue, 27 Apr 2004 16:47:26 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404271647.27029.gdh@acentral.co.uk>
References: <200404231137.29216.gdh@acentral.co.uk> <20040427134343.GB1330@acentral.co.uk> <20040427153200.GC6836@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BIUo3-0003B8-Sw
	for nfs@lists.sourceforge.net; Tue, 27 Apr 2004 08:47:35 -0700
Received: from pop.nation-net.com
	([194.200.209.13] helo=pop.walshsimmons.co.uk ident=foobar)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1BIUo2-0000WP-Tk
	for nfs@lists.sourceforge.net; Tue, 27 Apr 2004 08:47:35 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040427153200.GC6836@suse.de>
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

On Tuesday 27 April 2004 16:32, Olaf Kirch wrote:
> On Tue, Apr 27, 2004 at 02:43:43PM +0100, Gavin Hamill wrote:
> > OK, I'm assuming here that statd is only run by the machine  running nfsd
> > and exporting filesystems, and /usr/sbin/rpc.statd is definately in the
> > process list
>
> No, statd needs to run on the client as well.

Right, now we're moving in the right direction. when I run statd on the 
clients, I see no errors on the console or system logs, but the statd process 
does not appear in 'ps fawx' output (as it does on the server.)

An strace from '/sbin/rpc.statd' one of the clients is:

execve("/sbin/rpc.statd", ["/sbin/rpc.statd"], [/* 11 vars */]) = 0
uname({sys="Linux", node="cc", ...})    = 0
brk(0)                                  = 0x80505c8
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x40017000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or 
directory)
open("/etc/ld.so.preload", O_RDONLY)    = -1 ENOENT (No such file or 
directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=30964, ...}) = 0
old_mmap(NULL, 30964, PROT_READ, MAP_PRIVATE, 3, 0) = 0x40018000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or 
directory)
open("/lib/libnsl.so.1", O_RDONLY)      = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0000<\0\000"..., 512) = 
512
fstat64(3, {st_mode=S_IFREG|0644, st_size=73528, ...}) = 0
old_mmap(NULL, 84864, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x40020000
old_mmap(0x40032000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 
0x11000) = 0x40032000
old_mmap(0x40033000, 7040, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|
MAP_ANONYMOUS, -1, 0) = 0x40033000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or 
directory)
open("/lib/libc.so.6", O_RDONLY)        = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\200^\1"..., 512) = 
512
fstat64(3, {st_mode=S_IFREG|0644, st_size=1243792, ...}) = 0
old_mmap(NULL, 1253956, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x40035000
old_mmap(0x4015d000, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 
0x127000) = 0x4015d000
old_mmap(0x40165000, 8772, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|
MAP_ANONYMOUS, -1, 0) = 0x40165000
close(3)                                = 0
munmap(0x40018000, 30964)               = 0
getrlimit(RLIMIT_NOFILE, {rlim_cur=1024, rlim_max=1024}) = 0
pipe([3, 4])                            = 0
fork()                                  = 598
close(4)                                = 0
read(3, 0xbffffdc7, 1)                  = ? ERESTARTSYS (To be restarted)
--- SIGCHLD (Child exited) @ 0 (0) ---
read(3, "", 1)                          = 0
exit_group(1)                           = ?

Not very revealing :/

The whole of /var  on the clients is initially held on a ramdisk, so they have 
read/write access. Some of the larger 'less variable' parts of var are 
symlinked to the NFS-rootfs, but /var/lib/nfs isn't one of those parts :/

I'm just about out of ideas on this one, and am ready to just mount the 
NFS-root with the 'nolock' option - this works, and lets openoffice's setup 
run (it requires locking..) but again, it's just 'a fix' and not The 
Solution.

Cheers,
Gavin.


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
