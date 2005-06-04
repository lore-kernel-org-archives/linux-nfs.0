From: Christoph Bartoschek <bartoschek@or.uni-bonn.de>
Subject: Unknown error 525 from getdents from a connection to an AIX nfs server
Date: Sat, 4 Jun 2005 13:41:11 +0200
Message-ID: <200506041341.11421.bartoschek@or.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DeX1i-0002m7-5o
	for nfs@lists.sourceforge.net; Sat, 04 Jun 2005 04:41:18 -0700
Received: from [131.220.141.99] (helo=brical.or.uni-bonn.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DeX1f-0007Ec-Dz
	for nfs@lists.sourceforge.net; Sat, 04 Jun 2005 04:41:18 -0700
Received: from wse04.or.uni-bonn.de (unknown [131.220.141.100])
	by brical.or.uni-bonn.de (Postfix) with ESMTP id 9A5FD2AA1
	for <nfs@lists.sourceforge.net>; Sat,  4 Jun 2005 14:47:18 +0200 (CEST)
Received: from certa.vlsi.uni-bonn.de (certa-en0.vlsi.uni-bonn.de [192.168.143.187])
	by wse04.or.uni-bonn.de (Postfix) with ESMTP id 06CAEE98F
	for <nfs@lists.sourceforge.net>; Sat,  4 Jun 2005 13:41:21 +0200 (CEST)
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

Hi,

I have the problem that rm does not work reliable over the nfs connection to 
our AIX nfs server. If one deletes a whole directoy recursively one gets an 
"Unknown error 525". All files but the directory itself are deleted. 

The error can be reproduced as follows:

bartosch@feiler:/fs/data/bartosch/temp> mkdir testdir
bartosch@feiler:/fs/data/bartosch/temp> touch testdir/a
bartosch@feiler:/fs/data/bartosch/temp> rm -rf testdir
rm: reading directory `testdir': Unknown error 525
bartosch@feiler:/fs/data/bartosch/temp> rm -rf testdir
bartosch@feiler:/fs/data/bartosch/temp>

strace says that the error message comes from getdents. 

This is the output of strace on rm showing the important parts:

..
lstat(".", {st_mode=S_IFDIR|S_ISGID|0755, st_size=288, ...}) = 0
open(".", O_RDONLY|O_NONBLOCK|O_DIRECTORY) = 4
fstat(4, {st_mode=S_IFDIR|S_ISGID|0755, st_size=288, ...}) = 0
fcntl(4, F_SETFD, FD_CLOEXEC)           = 0
getdents64(4, /* 3 entries */, 512)     = 72
unlink("a")                             = 0
getdents64(4, 0x50e1c8, 512)            = -1 ETOOSMALL (Unknown error 525)
close(4)                                = 0
open("/usr/share/locale/en_US/LC_MESSAGES/coreutils.mo", O_RDONLY) = -1 ENOENT 
(No such file or directory)
open("/usr/share/locale/en/LC_MESSAGES/coreutils.mo", O_RDONLY) = -1 ENOENT 
(No such file or directory)
write(2, "rm: ", 4rm: )                     = 4
write(2, "reading directory `testdir\'", 27reading directory `testdir') = 27
...
write(2, ": Unknown error 525", 19: Unknown error 525)     = 19
...

You can see that  getdents returns ETOOSMALL which is the error.

The client machine feiler is has an AMD opteron 64bit  CPU runnning  Linux 
kernel:

Linux feiler 2.4.21-286-smp #1 SMP Sun Apr 3 05:18:39 UTC 2005 x86_64 x86_64 
x86_64 GNU/Linux

We get the same error from a machine with a newer kernel:

Linux maximator 2.6.4-52-smp #1 SMP Wed Apr 7 01:58:54 UTC 2004 x86_64 x86_64 
x86_64 GNU/Linux

Or one with a very new one:

Linux castell.vlsi.uni-bonn.de 2.6.11-APIC-ID #1 SMP Tue May 24 11:31:43 CEST 
2005 x86_64 x86_64 x86_64 GNU/Linux

Even on 32bit machines this error occurs

Linux inzadi-en0 2.4.21-231-smp #1 SMP Mon Jun 28 15:04:14 UTC 2004 i686 
unknown

The Server is an AIX 4.3.3 machine: AIX cook 3 4 0045B0AA4C00


How can I get rid of this problem?  If you need more information I will 
provide it for you.

Greets,
Christoph Bartoschek


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
