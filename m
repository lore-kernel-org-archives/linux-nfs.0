Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58870 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab1GRNko (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jul 2011 09:40:44 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd: turn on reply cache for NFSv4
Date: Mon, 18 Jul 2011 09:40:39 -0400
Message-Id: <1310996439-14640-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1310996439-14640-1-git-send-email-bfields@redhat.com>
References: <1310996439-14640-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

It's sort of ridiculous that we've never had a working reply cache for
NFSv4.

On the other hand, we may still not: our current reply cache is likely
not very good, especially in the TCP case (which is the only case that
matters for v4).  What we really need here is some serious testing.

Anyway, here's a start.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/cache.h            |    2 +-
 fs/nfsd/nfs4proc.c         |   32 ++++++++++++++++++++++----------
 fs/nfsd/nfs4xdr.c          |   11 +++++++++++
 fs/nfsd/nfscache.c         |    3 ++-
 fs/nfsd/nfssvc.c           |   26 +++++++++++++++-----------
 fs/nfsd/xdr4.h             |    3 +++
 include/linux/sunrpc/svc.h |    1 +
 7 files changed, 55 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index d892be6..93cc9d3 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -69,7 +69,7 @@ enum {
 
 int	nfsd_reply_cache_init(void);
 void	nfsd_reply_cache_shutdown(void);
-int	nfsd_cache_lookup(struct svc_rqst *, int);
+int	nfsd_cache_lookup(struct svc_rqst *);
 void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
 
 #ifdef CONFIG_NFSD_V4
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7ef1b27..e807776 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1007,6 +1007,15 @@ struct nfsd4_operation {
 	nfsd4op_func op_func;
 	u32 op_flags;
 	char *op_name;
+	/*
+	 * We use the DRC for compounds containing non-idempotent
+	 * operations, *except* those that are 4.1-specific (since
+	 * sessions provide their own EOS), and except for stateful
+	 * operations other than setclientid and setclientid_confirm
+	 * (since sequence numbers provide EOS for open, lock, etc in
+	 * the v4.0 case).
+	 */
+	bool op_cacheresult;
 };
 
 static struct nfsd4_operation nfsd4_ops[];
@@ -1051,6 +1060,11 @@ static inline struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
 	return &nfsd4_ops[op->opnum];
 }
 
+bool nfsd4_cache_this_op(struct nfsd4_op *op)
+{
+	return OPDESC(op)->op_cacheresult;
+}
+
 static bool need_wrongsec_check(struct svc_rqst *rqstp)
 {
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
@@ -1240,6 +1254,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_CREATE] = {
 		.op_func = (nfsd4op_func)nfsd4_create,
 		.op_name = "OP_CREATE",
+		.op_cacheresult = true,
 	},
 	[OP_DELEGRETURN] = {
 		.op_func = (nfsd4op_func)nfsd4_delegreturn,
@@ -1257,6 +1272,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_LINK] = {
 		.op_func = (nfsd4op_func)nfsd4_link,
 		.op_name = "OP_LINK",
+		.op_cacheresult = true,
 	},
 	[OP_LOCK] = {
 		.op_func = (nfsd4op_func)nfsd4_lock,
@@ -1330,10 +1346,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_REMOVE] = {
 		.op_func = (nfsd4op_func)nfsd4_remove,
 		.op_name = "OP_REMOVE",
+		.op_cacheresult = true,
 	},
 	[OP_RENAME] = {
 		.op_name = "OP_RENAME",
 		.op_func = (nfsd4op_func)nfsd4_rename,
+		.op_cacheresult = true,
 	},
 	[OP_RENEW] = {
 		.op_func = (nfsd4op_func)nfsd4_renew,
@@ -1359,16 +1377,19 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_SETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_setattr,
 		.op_name = "OP_SETATTR",
+		.op_cacheresult = true,
 	},
 	[OP_SETCLIENTID] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
 		.op_name = "OP_SETCLIENTID",
+		.op_cacheresult = true,
 	},
 	[OP_SETCLIENTID_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid_confirm,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
 		.op_name = "OP_SETCLIENTID_CONFIRM",
+		.op_cacheresult = true,
 	},
 	[OP_VERIFY] = {
 		.op_func = (nfsd4op_func)nfsd4_verify,
@@ -1377,6 +1398,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_WRITE] = {
 		.op_func = (nfsd4op_func)nfsd4_write,
 		.op_name = "OP_WRITE",
+		.op_cacheresult = true,
 	},
 	[OP_RELEASE_LOCKOWNER] = {
 		.op_func = (nfsd4op_func)nfsd4_release_lockowner,
@@ -1447,16 +1469,6 @@ static const char *nfsd4_op_name(unsigned opnum)
 #define nfsd4_voidres			nfsd4_voidargs
 struct nfsd4_voidargs { int dummy; };
 
-/*
- * TODO: At the present time, the NFSv4 server does not do XID caching
- * of requests.  Implementing XID caching would not be a serious problem,
- * although it would require a mild change in interfaces since one
- * doesn't know whether an NFSv4 request is idempotent until after the
- * XDR decode.  However, XID caching totally confuses pynfs (Peter
- * Astrand's regression testsuite for NFSv4 servers), which reuses
- * XID's liberally, so I've left it unimplemented until pynfs generates
- * better XID's.
- */
 static struct svc_procedure		nfsd_procedures4[2] = {
 	[NFSPROC4_NULL] = {
 		.pc_func = (svc_procfunc) nfsd4_proc_null,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c43f560..c8bf405 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -52,6 +52,7 @@
 #include "xdr4.h"
 #include "vfs.h"
 #include "state.h"
+#include "cache.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
@@ -1466,6 +1467,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	DECODE_HEAD;
 	struct nfsd4_op *op;
 	struct nfsd4_minorversion_ops *ops;
+	bool cachethis = false;
 	int i;
 
 	/*
@@ -1547,7 +1549,16 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 			argp->opcnt = i+1;
 			break;
 		}
+		/*
+		 * We'll try to cache the result in the DRC if any one
+		 * op in the compound wants to be cached:
+		 */
+		cachethis |= nfsd4_cache_this_op(op);
 	}
+	/* Sessions make the DRC unnecessary: */
+	if (argp->minorversion)
+		cachethis = false;
+	argp->rqstp->rq_cachetype = cachethis ? RC_REPLBUFF : RC_NOCACHE;
 
 	DECODE_TAIL;
 }
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 4666a20..2cbac34 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -118,7 +118,7 @@ hash_refile(struct svc_cacherep *rp)
  * Note that no operation within the loop may sleep.
  */
 int
-nfsd_cache_lookup(struct svc_rqst *rqstp, int type)
+nfsd_cache_lookup(struct svc_rqst *rqstp)
 {
 	struct hlist_node	*hn;
 	struct hlist_head 	*rh;
@@ -128,6 +128,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp, int type)
 				vers = rqstp->rq_vers,
 				proc = rqstp->rq_proc;
 	unsigned long		age;
+	int type = rqstp->rq_cachetype;
 	int rtn;
 
 	rqstp->rq_cacherep = NULL;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index bb8397f..dc5a1bf 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -570,8 +570,22 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 				rqstp->rq_vers, rqstp->rq_proc);
 	proc = rqstp->rq_procinfo;
 
+	/*
+	 * Give the xdr decoder a chance to change this if it wants
+	 * (necessary in the NFSv4.0 compound case)
+	 */
+	rqstp->rq_cachetype = proc->pc_cachetype;
+	/* Decode arguments */
+	xdr = proc->pc_decode;
+	if (xdr && !xdr(rqstp, (__be32*)rqstp->rq_arg.head[0].iov_base,
+			rqstp->rq_argp)) {
+		dprintk("nfsd: failed to decode arguments!\n");
+		*statp = rpc_garbage_args;
+		return 1;
+	}
+
 	/* Check whether we have this call in the cache. */
-	switch (nfsd_cache_lookup(rqstp, proc->pc_cachetype)) {
+	switch (nfsd_cache_lookup(rqstp)) {
 	case RC_INTR:
 	case RC_DROPIT:
 		return 0;
@@ -581,16 +595,6 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 		/* do it */
 	}
 
-	/* Decode arguments */
-	xdr = proc->pc_decode;
-	if (xdr && !xdr(rqstp, (__be32*)rqstp->rq_arg.head[0].iov_base,
-			rqstp->rq_argp)) {
-		dprintk("nfsd: failed to decode arguments!\n");
-		nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
-		*statp = rpc_garbage_args;
-		return 1;
-	}
-
 	/* need to grab the location to store the status, as
 	 * nfsv4 does some encoding while processing 
 	 */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 351348c..d2a8d044 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -457,6 +457,8 @@ struct nfsd4_op {
 	struct nfs4_replay *			replay;
 };
 
+bool nfsd4_cache_this_op(struct nfsd4_op *);
+
 struct nfsd4_compoundargs {
 	/* scratch variables for XDR decode */
 	__be32 *			p;
@@ -479,6 +481,7 @@ struct nfsd4_compoundargs {
 	u32				opcnt;
 	struct nfsd4_op			*ops;
 	struct nfsd4_op			iops[8];
+	int				cachetype;
 };
 
 struct nfsd4_compoundres {
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index ea29330..2f1e518 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -273,6 +273,7 @@ struct svc_rqst {
 	/* Catering to nfsd */
 	struct auth_domain *	rq_client;	/* RPC peer info */
 	struct auth_domain *	rq_gssclient;	/* "gss/"-style peer info */
+	int			rq_cachetype;
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
 	int			rq_splice_ok;   /* turned off in gss privacy
 						 * to prevent encrypting page
-- 
1.7.4.1

