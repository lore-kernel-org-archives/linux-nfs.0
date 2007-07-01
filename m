From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 09/10] rdma: makefile
Date: Sun, 01 Jul 2007 18:12:44 -0500
Message-ID: <20070701231244.29354.72883.stgit@dell3.ogc.int>
References: <20070701230258.29354.89949.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I58as-00036w-VS
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 16:12:42 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I58aw-0003MO-2t
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 16:12:42 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 56B8C7C758
	for <nfs@lists.sourceforge.net>; Sun,  1 Jul 2007 18:12:44 -0500 (CDT)
In-Reply-To: <20070701230258.29354.89949.stgit@dell3.ogc.int>
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


Add the NFSD_RDMA module to the sunrpc makefile.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/Makefile |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 8ebfc4d..a683d6a 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -13,3 +13,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprt
 	    sunrpc_syms.o cache.o rpc_pipe.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
+
+obj-$(CONFIG_NFSD_RDMA) += svcrdma.o
+svcrdma-y := svc_rdma.o svc_rdma_transport.o \
+	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
