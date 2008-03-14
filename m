From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] lockd: introduce new function to encode private argument
	in SM_MON requests
Date: Fri, 14 Mar 2008 14:26:08 -0400
Message-ID: <20080314182608.30171.60342.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:44937 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083AbYCNS0Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:26:25 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: refactor the encoding of the opaque 16-byte private argument in
xdr_encode_mon().  This will be updated later to support IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   30 ++++++++++++++++++++++++------
 include/linux/lockd/sm_inter.h |    1 +
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index f2507fe..e4d5635 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -218,6 +218,24 @@ static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
 	return xdr_encode_my_id(p, argp);
 }
 
+/*
+ * The "priv" argument may contain private information required
+ * by the SM_MON call. This information will be supplied in the
+ * SM_NOTIFY call.
+ *
+ * Linux provides the raw IP address of the monitored host,
+ * left in network byte order.
+ */
+static __be32 *xdr_encode_priv(__be32 *p, struct nsm_args *argp)
+{
+	*p++ = argp->addr;
+	*p++ = 0;
+	*p++ = 0;
+	*p++ = 0;
+
+	return p;
+}
+
 static int
 xdr_encode_mon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 {
@@ -225,11 +243,10 @@ xdr_encode_mon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
-	/* Surprise - there may even be room for an IPv6 address now */
-	*p++ = argp->addr;
-	*p++ = 0;
-	*p++ = 0;
-	*p++ = 0;
+	p = xdr_encode_priv(p, argp);
+	if (IS_ERR(p))
+		return PTR_ERR(p);
+
 	rqstp->rq_slen = xdr_adjust_iovec(rqstp->rq_svec, p);
 	return 0;
 }
@@ -265,7 +282,8 @@ xdr_decode_stat(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
 #define SM_my_id_sz	(SM_my_name_sz+3)
 #define SM_mon_name_sz	(1+XDR_QUADLEN(SM_MAXSTRLEN))
 #define SM_mon_id_sz	(SM_mon_name_sz+SM_my_id_sz)
-#define SM_mon_sz	(SM_mon_id_sz+4)
+#define SM_priv_sz	(XDR_QUADLEN(SM_PRIV_SIZE))
+#define SM_mon_sz	(SM_mon_id_sz+SM_priv_sz)
 #define SM_monres_sz	2
 #define SM_unmonres_sz	1
 
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
index 22a6458..5a5448b 100644
--- a/include/linux/lockd/sm_inter.h
+++ b/include/linux/lockd/sm_inter.h
@@ -19,6 +19,7 @@
 #define SM_NOTIFY	6
 
 #define SM_MAXSTRLEN	1024
+#define SM_PRIV_SIZE	16
 
 /*
  * Arguments for all calls to statd

