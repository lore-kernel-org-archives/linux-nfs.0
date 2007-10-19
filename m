From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 09/10] rdma: makefile
Date: Fri, 19 Oct 2007 16:56:28 -0500
Message-ID: <20071019215628.31937.88846.stgit@dell3.ogc.int>
References: <20071019215304.31937.28876.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IizpP-0006v2-7a
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:56:23 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IizpU-00035u-IK
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:56:28 -0700
In-Reply-To: <20071019215304.31937.28876.stgit@dell3.ogc.int>
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
index e37aa99..73038ac 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -14,3 +14,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprt
 	    svc_xprt.o
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
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
