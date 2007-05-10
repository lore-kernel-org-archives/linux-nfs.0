From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: And... NFS client patches to support RDMA
Date: Thu, 10 May 2007 09:24:12 -0400
Message-ID: <EXNANE01dqN19bBLmUj000009b2@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hm8dU-0006PS-PA
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 06:24:48 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hm8dW-0006KY-Dm
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 06:24:51 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l4ADOXIZ012548
	for <nfs@lists.sourceforge.net>; Thu, 10 May 2007 06:24:44 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Related to Tom Tucker's mail yesterday, we also have a set of
client patches for NFS/RDMA which are prepared for review. These
patches however are almost entirely new code, since the integration
framework is already there from Chuck Lever's transport switch.
As a result, the diffstat consists of nearly all insertions:

rpc_rdma.h header file containing RPCRDMA protocol header definitions.

 rpc_rdma.h |  116 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 116 insertions(+)

NFS RDMA client implementation

 fs/Kconfig                      |    8 
 include/linux/sunrpc/debug.h    |    5 
 net/sunrpc/Makefile             |    1 
 net/sunrpc/xprtrdma/Makefile    |    3 
 net/sunrpc/xprtrdma/rpc_rdma.c  |  883 ++++++++++++++++++++++
 net/sunrpc/xprtrdma/transport.c |  830 ++++++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c     | 1590 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h |  354 ++++++++
 8 files changed, 3674 insertions(+)

ATM it's not obvious how to break them up into smaller
bits. It may simply make the most sense to view each file
separately, as they are split by function (RPC transport,
RPC/RDMA protocol, and RDMA verbs glue).

So this is basically a heads-up that you'll see these
shortly. We'll be rolling both of them into git btw,
the client is merged up to 2.6.21 at the moment.

Tom.  


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
