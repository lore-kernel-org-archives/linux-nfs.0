From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 09/10] rdma: makefile
Date: Mon, 20 Aug 2007 11:58:20 -0500
Message-ID: <20070820165820.15938.86958.stgit@dell3.ogc.int>
References: <20070820165635.15938.57184.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INAa6-00020u-8Y
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:58:22 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INAaA-0003NF-6Z
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:58:26 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 4E97E7C7BD
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:58:20 -0500 (CDT)
In-Reply-To: <20070820165635.15938.57184.stgit@dell3.ogc.int>
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
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
