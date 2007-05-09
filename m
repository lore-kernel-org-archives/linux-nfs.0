From: Tom Tucker <tom@opengridcomputing.com>
Subject: NFS server patches to support RDMA
Date: Wed, 09 May 2007 13:26:49 -0500
Message-ID: <1178735209.9563.32.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlqsT-0006pA-FP
	for nfs@lists.sourceforge.net; Wed, 09 May 2007 11:27:05 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HlqsW-0007c3-2k
	for nfs@lists.sourceforge.net; Wed, 09 May 2007 11:27:08 -0700
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

All:

I have a large set of patches that supports encoding RPC messages on an
RDMA transport in the NFS server. The patches include changes to the
existing SVC infrastructure as well as quite a bit of code in new files.

What is the best way to present these patches for review? We had thought
that we could stage this in a git repository on linux-nfs.org. 

Here's an annotated cumulative diffstat to give you an idea of the
scope...

 include/linux/sunrpc/svcsock.h  |   11
 net/sunrpc/svc.c                |   20
 net/sunrpc/svcsock.c            |  145
 fs/Kconfig                      |    8
 fs/nfsd/nfs3xdr.c               |    2 
 fs/nfsd/nfssvc.c                |   11
 include/linux/sunrpc/debug.h    |   15
 include/linux/sunrpc/svcsock.h  |    1
 net/sunrpc/Makefile             |    2
 net/sunrpc/sunrpc_syms.c        |   10
 net/sunrpc/svc.c                |    2
 net/sunrpc/svcauth_unix.c       |    2
 net/sunrpc/svcsock.c            |   10
 fs/nfs/super.c                  |    2
 include/linux/sunrpc/svc_rdma.h |  264 new
 net/sunrpc/svc_rdma.c           |  287 new
 net/sunrpc/svc_rdma_debug.h     |  393 new
 net/sunrpc/svc_rdma_marshal.c   |  422 new
 net/sunrpc/svc_rdma_recvfrom.c  |  558 new
 net/sunrpc/svc_rdma_sendto.c    |  523 new
 net/sunrpc/svc_rdma_transport.c | 1199 new


Tom



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
