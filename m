From: "Howie Xu" <howie@vmware.com>
Subject: How to unlock a file if an NFSv3 client dies forever?
Date: Wed, 26 May 2004 01:03:39 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4F28105F70F4324A8723F0C949088941C29A36@pa-exch5.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BStO6-0007u3-25
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 01:03:46 -0700
Received: from mailout1.vmware.com ([65.113.40.130])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BStO5-0001Kq-Ly
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 01:03:45 -0700
Received: from mailout1.vmware.com (mailout1.vmware.com [127.0.0.1])
	by mailout1.vmware.com (Postfix) with ESMTP id 1C82344BB
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 01:03:44 -0700 (PDT)
Received: from mailhost1.vmware.com (mailhost1.vmware.com [10.16.12.135])
	by mailout1.vmware.com (Postfix) with ESMTP id 81C9F44BF
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 01:03:43 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mailhost1.vmware.com (Postfix) with ESMTP id 0BB606FC343
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 01:03:50 -0700 (PDT)
Received: from pa-exch3.vmware.com (pa-exch3.vmware.com [10.16.15.61])
	by mailhost1.vmware.com (Postfix) with ESMTP id F07F96FC341
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 01:03:45 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
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
=20
This is a NFSv3 question: how to unlock a file if one NFS client holds a =
lock
on the file, crashs, and never recovers?
=20
For example, if my linux NFS client holds a write lock on =
/home/howie/README,
then crashes and I reinstall the OS upon rebooting. Does that mean my =
NFS
server will hold this lock on this file *forever*? The NFS locks are
advisory, but my other NFS clients who speak NLM with the same NFS =
server
will not be granted lock for a file no one else ever cares.:(
=20
I don't think Network Status Monitor Protocol will help, as NSM only =
make the
client recover the lock itself once it recovers and retrieves the lock =
from a
previously save lock info file.
=20
Thanks in advance for your time to read this thread.
=20
-howie


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
