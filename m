From: Bernd Schubert <bernd-schubert@web.de>
Subject: x86_64: 32bit emulation problems
Date: Mon, 28 Feb 2005 22:08:27 +0100
Message-ID: <200502282208.29263.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5s82-00068f-0f
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 13:08:34 -0800
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D5s80-0006S0-9t
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 13:08:33 -0800
Received: from euklid.pci.uni-heidelberg.de (euklid.pci.uni-heidelberg.de [129.206.21.104])
	by relay.uni-heidelberg.de (8.12.10/8.12.10) with ESMTP id j1SL8pfK004550
	for <nfs@lists.sourceforge.net>; Mon, 28 Feb 2005 22:08:51 +0100 (MET)
Received: from bernd by euklid.pci.uni-heidelberg.de with local (Exim 3.35 #1 (Debian))
	id 1D5s7x-0002X2-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Feb 2005 22:08:29 +0100
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

Sorry, I'm sending it here again, since my first mail, in which I CCed LKML 
and  Andi Kleen was refused by the listserver.


Hi,

I'm just looking into a very strange problem. Some of our systems have 
athlon64 CPUs. Due to our diskless nfs environment we currently still prefer 
a 32bit userspace environment, but would like to be able to use a 64-bit 
chroot environment.

Well, currently there seems to be a stat64()  NFS problem when a x86_64 kernel 
is booted and stat64() comes from a 32bit libc.

Here's just an example:

hitchcock:/home/bernd/src/tests# ./test_stat64 /mnt/test/yp
stat() works fine.


hitchcock:/home/bernd/src/tests# ./test_stat32 /mnt/test/yp
stat for /mnt/test/yp failed 


The test program looks rather simple:

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char **argv)
{
        char *dir;
        struct stat buf;

        dir = argv[1];

        if (stat (dir, &buf) == -1)
                fprintf(stderr, "stat for %s failed \n", dir);
        else
                fprintf(stderr, "stat() works fine.\n");
        return (0);
}


Here are the strace outputs:
=====================

32bit:
------
hitchcock:/home/bernd/src/tests# strace32 ./test_stat32 /mnt/test/yp
execve("./test_stat32", ["./test_stat32", "/mnt/test/yp"], [/* 39 vars */]) = 
0
uname({sys="Linux", node="hitchcock", ...}) = 0
brk(0)                                  = 0x80ad000
brk(0x80ce000)                          = 0x80ce000
stat64("/mnt/test/yp", {st_mode=S_IFDIR|0755, st_size=2704, ...}) = 0
write(2, "stat for /mnt/test/yp failed \n", 30stat for /mnt/test/yp failed 
) = 30
exit_group(0)                           = ?

64bit:
-------
hitchcock:/home/bernd/src/tests# strace ./test_stat64 /mnt/test/yp
execve("./test_stat64", ["./test_stat64", "/mnt/test/yp"], [/* 39 vars */]) = 
0
uname({sys="Linux", node="hitchcock", ...}) = 0
brk(0)                                  = 0x572000
brk(0x593000)                           = 0x593000
stat("/mnt/test/yp", {st_mode=S_IFDIR|0755, st_size=2704, ...}) = 0
write(2, "stat() works fine.\n", 19stat() works fine.
)    = 19
_exit(0)                                = ?



Anyone having an idea whats going on? The ethereal capture also looks pretty 
normal. The kernel of this system is 2.6.9, but it also happens on another 
system with 2.6.11-rc5.
As usual we are using unfs3 for /etc and /var, but for me that looks like a 
client problem. I'm now also pretty sure that its not a problem for a local 
mount point (so a local disk).


Thanks in advance,
 Bernd


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
