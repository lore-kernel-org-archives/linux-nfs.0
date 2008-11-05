From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/18] NSM: Generate "priv" argument to NSMPROC_MON when
	nsm_handle is created
Date: Wed, 05 Nov 2008 12:20:27 -0500
Message-ID: <20081105172027.6773.94970.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34109 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbYKERUx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:20:53 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Construct the "priv" cookie when the nsm_handle is created, and pass
that to NSMPROC_MON's XDR encoder, instead of creating the "priv"
cookie in the encoder at call time.

This patch should not cause a behavioral change: the contents of the
cookie remain the same for the time being.

Collect NSM XDR data type definitions in the same header as NLM XDR
data type definitions, since lockd uses NSM XDR data types too.  The
nlm_reboot data structure, for example, is used in both lockd and in
the NSM implementation.

The new definition of nsm_private is placed in xdr.h, and the
definition of SM_PRIV_SIZE is placed in the same header.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   30 +++++++++++++++++++-----------
 include/linux/lockd/lockd.h    |    1 +
 include/linux/lockd/sm_inter.h |    1 -
 include/linux/lockd/xdr.h      |    6 ++++++
 4 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index d245856..efbb2ea 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -31,7 +31,7 @@ enum {
 };
 
 struct nsm_args {
-	__be32			addr;		/* remote address */
+	struct nsm_private	*priv;
 	u32			prog;		/* RPC callback info */
 	u32			vers;
 	u32			proc;
@@ -84,7 +84,7 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 	struct rpc_clnt	*clnt;
 	int		status;
 	struct nsm_args	args = {
-		.addr		= nsm_addr_in(nsm)->sin_addr.s_addr,
+		.priv		= &nsm->sm_priv,
 		.prog		= NLM_PROGRAM,
 		.vers		= 3,
 		.proc		= NLMPROC_NSM_NOTIFY,
@@ -175,6 +175,20 @@ int nsm_unmonitor(struct nlm_host *host)
 	return status;
 }
 
+/*
+ * Construct a unique cookie to identify this nsm_handle.  It is
+ * passed to our statd via NSMPROC_MON, and returned via
+ * NLMPROC_SM_NOTIFY, in the "priv" field of these requests.
+ *
+ * Linux provides the raw IP address of the monitored host,
+ * left in network byte order.
+ */
+static void nsm_init_private(struct nsm_handle *nsm)
+{
+	__be32 *p = (__be32 *)&nsm->sm_priv.data;
+	*p = nsm_addr_in(nsm)->sin_addr.s_addr;
+}
+
 /**
  * nsm_find - Find or create a cached nsm_handle
  * @sap: pointer to socket address of handle to find
@@ -251,6 +265,7 @@ retry:
 	nsm->sm_name = (char *) (nsm + 1);
 	memcpy(nsm->sm_name, hostname, hostname_len);
 	nsm->sm_name[hostname_len] = '\0';
+	nsm_init_private(nsm);
 	nlm_display_address((struct sockaddr *)&nsm->sm_addr,
 				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
 	atomic_set(&nsm->sm_count, 1);
@@ -335,18 +350,11 @@ static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
  * The "priv" argument may contain private information required
  * by the NSMPROC_MON call. This information will be supplied in the
  * NLMPROC_SM_NOTIFY call.
- *
- * Linux provides the raw IP address of the monitored host,
- * left in network byte order.
  */
 static __be32 *xdr_encode_priv(__be32 *p, struct nsm_args *argp)
 {
-	*p++ = argp->addr;
-	*p++ = 0;
-	*p++ = 0;
-	*p++ = 0;
-
-	return p;
+	return xdr_encode_opaque_fixed(p, argp->priv->data,
+						sizeof(argp->priv->data));
 }
 
 static int
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index d8fa8d3..6178fcc 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -82,6 +82,7 @@ struct nsm_handle {
 	size_t			sm_addrlen;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
+	struct nsm_private	sm_priv;
 	char			sm_addrbuf[LOCKD_ADDRBUF_SIZE];
 };
 
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
index da72872..7f22d6f 100644
--- a/include/linux/lockd/sm_inter.h
+++ b/include/linux/lockd/sm_inter.h
@@ -10,6 +10,5 @@
 #define LINUX_LOCKD_SM_INTER_H
 
 #define SM_MAXSTRLEN	1024
-#define SM_PRIV_SIZE	16
 
 #endif /* LINUX_LOCKD_SM_INTER_H */
diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
index d6b3a80..6b51992 100644
--- a/include/linux/lockd/xdr.h
+++ b/include/linux/lockd/xdr.h
@@ -13,6 +13,12 @@
 #include <linux/nfs.h>
 #include <linux/sunrpc/xdr.h>
 
+#define SM_PRIV_SIZE		16
+
+struct nsm_private {
+	unsigned char		data[SM_PRIV_SIZE];
+};
+
 struct svc_rqst;
 
 #define NLM_MAXCOOKIELEN    	32

