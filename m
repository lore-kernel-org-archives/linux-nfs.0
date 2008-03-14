From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] lockd: Fix up incorrect RPC buffer size calculations.
Date: Fri, 14 Mar 2008 14:26:01 -0400
Message-ID: <20080314182601.30171.45055.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:44777 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083AbYCNS0S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:26:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Switch to using the new mon_id encoder function.

Now that we've refactored the encoding of SM_MON requests, we've
discovered that the pre-computed buffer length maximums are
incorrect!

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   39 ++++++++-------------------------------
 1 files changed, 8 insertions(+), 31 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 3935d7b..f2507fe 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -149,6 +149,9 @@ nsm_create(void)
 
 /*
  * XDR functions for NSM.
+ *
+ * See http://www.opengroup.org/ for details on the Network
+ * Status Monitor wire protocol.
  */
 
 static __be32 *xdr_encode_nsm_string(__be32 *p, char *string)
@@ -215,37 +218,10 @@ static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
 	return xdr_encode_my_id(p, argp);
 }
 
-static __be32 *
-xdr_encode_common(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
-{
-	char	buffer[20], *name;
-
-	/*
-	 * Use the dotted-quad IP address of the remote host as
-	 * identifier. Linux statd always looks up the canonical
-	 * hostname first for whatever remote hostname it receives,
-	 * so this works alright.
-	 */
-	if (nsm_use_hostnames) {
-		name = argp->mon_name;
-	} else {
-		sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(argp->addr));
-		name = buffer;
-	}
-	if (!(p = xdr_encode_string(p, name))
-	 || !(p = xdr_encode_string(p, utsname()->nodename)))
-		return ERR_PTR(-EIO);
-	*p++ = htonl(argp->prog);
-	*p++ = htonl(argp->vers);
-	*p++ = htonl(argp->proc);
-
-	return p;
-}
-
 static int
 xdr_encode_mon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 {
-	p = xdr_encode_common(rqstp, p, argp);
+	p = xdr_encode_mon_id(p, argp);
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
@@ -261,7 +237,7 @@ xdr_encode_mon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 static int
 xdr_encode_unmon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 {
-	p = xdr_encode_common(rqstp, p, argp);
+	p = xdr_encode_mon_id(p, argp);
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 	rqstp->rq_slen = xdr_adjust_iovec(rqstp->rq_svec, p);
@@ -286,8 +262,9 @@ xdr_decode_stat(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
 }
 
 #define SM_my_name_sz	(1+XDR_QUADLEN(SM_MAXSTRLEN))
-#define SM_my_id_sz	(3+1+SM_my_name_sz)
-#define SM_mon_id_sz	(1+XDR_QUADLEN(20)+SM_my_id_sz)
+#define SM_my_id_sz	(SM_my_name_sz+3)
+#define SM_mon_name_sz	(1+XDR_QUADLEN(SM_MAXSTRLEN))
+#define SM_mon_id_sz	(SM_mon_name_sz+SM_my_id_sz)
 #define SM_mon_sz	(SM_mon_id_sz+4)
 #define SM_monres_sz	2
 #define SM_unmonres_sz	1

