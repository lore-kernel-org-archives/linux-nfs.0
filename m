From: "Iain Irwin-Powell" <iain@cinesite.co.uk>
Subject: NFS Performance Between SGI Servers and Linux Clients
Date: Thu, 22 May 2003 17:32:22 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <008601c3207f$b8bfd160$0b00430a@granger>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from scanman.cinesite.co.uk ([193.203.81.129])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19It3A-00023m-00
	for <nfs@lists.sourceforge.net>; Thu, 22 May 2003 09:36:16 -0700
Received: from sirius.cinesite.co.uk (sirius.cinesite.co.uk [10.66.0.23])
	by scanman.cinesite.co.uk (8.9.3/8.9.3) with ESMTP id RAA17330
	for <nfs@lists.sourceforge.net>; Thu, 22 May 2003 17:35:43 +0100 (BST)
Received: from sirius (sirius.cinesite.co.uk [127.0.0.1])
	by sirius.cinesite.co.uk (Postfix) with ESMTP id 349A4BFFC
	for <nfs@lists.sourceforge.net>; Thu, 22 May 2003 17:35:43 +0100 (BST)
Received: from granger (shirley.cinesite.co.uk [10.65.1.5])
	by sirius.cinesite.co.uk (Postfix) with ESMTP id 9C234BFFB
	for <nfs@lists.sourceforge.net>; Thu, 22 May 2003 17:35:42 +0100 (BST)
To: <nfs@lists.sourceforge.net>
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


Does anyone have any ideas about this?

We have been experiencing a number of issues regarding NFS serving on
SGI IRIX (6.5.19) servers which now appear to point back to Linux NFS
clients.

The server is an Origin 2000, quad processors, 1.5GB memory, serving
over Gigabit. This can be reproduced on connections whether or not they
are using jumbo frames. The disks that are served are hardware RAID3
capable of around 80-90MB/s (tested and optimised not theoretical). 

Under certain circumstances will get a load average of 8 (or how ever
many nfsd's are running). The server itself is not that busy. Most of
the nfsd's show as sleeping but they are obviously waiting for
something.

Further investigation revealed that this situation arises when a Linux
client opens many files in quick succession (doing
open-read-close,open-read-close). We tend to use files in the range
3MB-13MB in size generally.

If we do the same test on an SGI client there is very little impact on
the load average.

We can recreate this by doing (on the client);

find . -type -f -print -exec grep jsdhgkhjfdk {} \;

The same effect appears to happen on Linux servers as well. A single
Linux client doing this will make the load average creep up towards 2.5.

Linux Version 2.4.20
nfs-utils-1.0.1-1
exports are exported with -32bitclients

Looking a bit deeper in a packet trace when the grep is running, Linux
seems to issue 16 read requests (16KB) at a time whilst an SGI will only
issue between 2 and 4. May or may not be relevant.

This information has also been passed back to SGI who are looking at it.

Packet traces and more detail is available if anyone wants them.

Any ideas or suggestions would be welcome.

******************************************************************
Iain Irwin-Powell (AKA Iain Powell)
Senior Systems Administrator
Cinesite Europe Limited
9 Carlisle Street
London
W1D 3BP
 
T: +442079734000
DDI: +442079734053
*******************************************************************
It's not broken, it just doesn't work the way you expected.
*******************************************************************




-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
