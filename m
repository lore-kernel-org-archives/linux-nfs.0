From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/23] SUNRPC: Fix return type of svc_addr_len()
Date: Thu, 05 Mar 2009 16:31:31 -0500
Message-ID: <20090305213130.21342.26849.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:35601 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbZCEVcs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:32:48 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The svc_addr_len() helper function can return a negative errno value,
but its return type is size_t, which is unsigned.

The RDMA transport code passes this return value directly to memset(),
without checking first if it's negative.  This could cause memset() to
clobber a large piece of memory if svc_addr_len() has returned an
error.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_xprt.h          |    3 ++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   16 ++++++++++++++--
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 879c701..088d81f 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -114,7 +114,7 @@ static inline unsigned short svc_addr_port(struct sockaddr *sa)
 	return ret;
 }
 
-static inline size_t svc_addr_len(struct sockaddr *sa)
+static inline int svc_addr_len(const struct sockaddr *sa)
 {
 	switch (sa->sa_family) {
 	case AF_INET:
@@ -122,6 +122,7 @@ static inline size_t svc_addr_len(struct sockaddr *sa)
 	case AF_INET6:
 		return sizeof(struct sockaddr_in6);
 	}
+
 	return -EAFNOSUPPORT;
 }
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 3d810e7..d1ec6f9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -546,6 +546,7 @@ static void handle_connect_req(struct rdma_cm_id *new_cma_id, size_t client_ird)
 	struct svcxprt_rdma *listen_xprt = new_cma_id->context;
 	struct svcxprt_rdma *newxprt;
 	struct sockaddr *sa;
+	int len;
 
 	/* Create a new transport */
 	newxprt = rdma_create_xprt(listen_xprt->sc_xprt.xpt_server, 0);
@@ -563,9 +564,20 @@ static void handle_connect_req(struct rdma_cm_id *new_cma_id, size_t client_ird)
 
 	/* Set the local and remote addresses in the transport */
 	sa = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.dst_addr;
-	svc_xprt_set_remote(&newxprt->sc_xprt, sa, svc_addr_len(sa));
+	len = svc_addr_len(sa);
+	if (len < 0) {
+		dprintk("svcrdma: dst_addr has a bad address family\n");
+		return;
+	}
+	svc_xprt_set_remote(&newxprt->sc_xprt, sa, len);
+
 	sa = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.src_addr;
-	svc_xprt_set_local(&newxprt->sc_xprt, sa, svc_addr_len(sa));
+	len = svc_addr_len(sa);
+	if (len < 0) {
+		dprintk("svcrdma: src_addr has a bad address family\n");
+		return;
+	}
+	svc_xprt_set_local(&newxprt->sc_xprt, sa, len);
 
 	/*
 	 * Enqueue the new transport on the accept queue of the listening

