From: bnies@bluewin.ch
Subject: ls hangs on NFS share from Apple Xserve
Date: Wed, 8 Sep 2004 10:42:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412EBAA100062E28@mssbzhh-int.msg.bluewin.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4y2d-0006Xo-L6
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 01:42:59 -0700
Received: from mail1.bluewin.ch ([195.186.1.74])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4y2b-0000o9-MN
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 01:42:58 -0700
Received: from mssbzhh-int.msg.bluewin.ch (195.186.4.230) by mail1.bluewin.ch (Bluewin AG 7.0.030.2)
        id 412F8E34001564B5 for nfs@lists.sourceforge.net; Wed, 8 Sep 2004 08:42:43 +0000
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

Hi,

A couple of months ago I reported a bug that occurs with Linux NFS client
and Mac OS X NFS server. Here's the bug report:

http://sourceforge.net/tracker/index.php?func=detail&aid=964204&group_id=14&atid=100014

And here are other docs related to this problem:

http://discussions.info.apple.com/webx?14@5.gRhIaxY5v2O.0@.689495bc
http://discussions.info.apple.com/webx?13@140.HfAHaE8Ew3J.148064@.6897b10d/2
http://groups.google.ch/groups?hl=de&lr=&ie=UTF-8&selm=9c87e8e6.0405280036.16f3c991%40posting.google.com
http://algesten.blogspot.com/2004/07/mac-os-x-server-nfs-unique-cookie-bug.html
http://sources.redhat.com/bugzilla/show_bug.cgi?id=353

Martin Algesten reported that this might be caused by non-unique NFS cookies
in the same READDIRPLUS reply from the Apple NFS server but in our environment
with MacOS X 10.3.5 and SuSE Linux 9.0 (Kernel 2.4.21-243-smp4G, glibc-2.3.2-88)
I cannot confirm this. The NFS cookies are unique in the same READDIRPLUS
reply but not unique during the same NFS session.

We don't have problems accessing the MacOS X 10.3.5 NFS server from our Solaris
clients and also don't have problems with Solaris, Linux and NetApp NFS servers
from Linux clients. 

I assume this is a bug with the Linux Kernel NFS implementation or the glibc
library which provides the getdents64 call that loops. Apple says it's a
Linux bug.

According to SuSE the patch linux-2.4.21-15-seekdir.dif from http://client.linux-nfs.org/Linux-2.4.x/2.4.21/
is already included in their kernel.

Could someone who is familiar with NFS and the Linux NFS or glibc code analyze
and solve this problem? I can provide network traffic and strace logs if
you don't have the equipment to reproduce this problem.

Thanks in advance.

Regards,
Bernd



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
