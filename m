From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH 2.6.3] Add write throttling to NFS client
Date: Sun, 29 Feb 2004 22:52:11 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07B9C@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, <Shantanu.Goel@lehman.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AxhLx-0007MO-Jm
	for nfs@lists.sourceforge.net; Sun, 29 Feb 2004 22:56:37 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AxhHy-0003XG-3y
	for nfs@lists.sourceforge.net; Sun, 29 Feb 2004 22:52:30 -0800
To: <trond.myklebust@fys.uio.no>, "Shantanu Goel" <sgoel01@yahoo.com>
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

> If you need to sort everything by pid (...and I'm not=20
> convinced that is
> such a great idea) then you can do it by adding 1 extra=20
> linked list in the
> struct rpc_task to act as the head of the pid list... No need for any
> fragile allocation of extra structures from inside
> __rpc_add_wait_queue().

i agree.

i'd rather keep __rpc_add_wait_queue and __rpc_remove_wait_queue
as simple as possible.  more complexity here will significantly
impact the per-op overhead, especially if we're holding the BKL
and/or other spinlocks when these are called.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
