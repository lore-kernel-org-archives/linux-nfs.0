From: dju` <dju.ml@elegiac.net>
Subject: large files: strange behaviour
Date: Sat, 30 Oct 2004 13:21:55 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41837953.5040802@elegiac.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CNrIz-0007n2-IC
	for nfs@lists.sourceforge.net; Sat, 30 Oct 2004 04:21:57 -0700
Received: from postfix4-2.free.fr ([213.228.0.176])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CNrIy-0004Qr-MX
	for nfs@lists.sourceforge.net; Sat, 30 Oct 2004 04:21:57 -0700
To: nfs@lists.sourceforge.net
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

Hello,

I'm experiencing issues when copying large files over NFS. I want to 
copy ~700mb files (ok, movies) from a NFS client to a NFS server. I'm 
using a 100mbits lan.

If I use konqueror for doing this, I can see the progress bar behaving 
strangely:
from 0% to 60% (on 700mb), copying goes at a 30Mb/s speed, which is 
impossible with fast ethernet. at 60%, the speed decreases dramatically 
and generally, ends by saying "waiting" at ~65% (~450mb). 30sec after, a 
popup tells me "Can't write on /foo".

Sometimes it works, but i get "waiting..." at 99% for a minute or so, 
though the file is entirely copied, then the copy window closes itself.

If i use cp, i get "stale nfs file handle".

NFS Server config:

Gentoo Linux
2.6.9-gentoo-r1 kernel (nptl)
/etc/exports: (rw,sync)
RPCMOUNTDOPTS="-p 32323 -N 2"
fs type is ext3
eth0: negotiated 100baseTx-FD, link ok
nfs-utils-1.0.6-r4

NFS client config:

Gentoo Linux
2.6.9-ck1 (nptl)
mount options: rw,hard,intr,tcp,nfsvers=3,rsize=8192,wsize=8192

i've tried other rsize and wsize settings, but it didn't change anything.

any help please? Thanks for feedback.
-- 
--dju`


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
