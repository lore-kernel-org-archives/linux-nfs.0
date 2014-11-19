Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:63179 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753534AbaKSMvh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 07:51:37 -0500
Received: by mail-qg0-f51.google.com with SMTP id l89so325890qgf.10
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 04:51:36 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/10] sunrpc: add a generic rq_flags field to svc_rqst and move rq_secure to it
Date: Wed, 19 Nov 2014 07:51:14 -0500
Message-Id: <1416401482-2562-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a later patch, we're going to need some atomic bit flags. Since that
field will need to be an unsigned long, we mitigate that space
consumption by migrating some other bitflags to the new field. Start
with the rq_secure flag.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfscache.c            |  4 ++--
 fs/nfsd/nfsfh.c               |  2 +-
 include/linux/sunrpc/svc.h    |  4 ++--
 include/trace/events/sunrpc.h | 17 +++++++++++++----
 net/sunrpc/svc_xprt.c         |  5 ++++-
 5 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 122f69185ef5..83a9694ec485 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -490,7 +490,7 @@ found_entry:
 	/* From the hall of fame of impractical attacks:
 	 * Is this a user who tries to snoop on the cache? */
 	rtn = RC_DOIT;
-	if (!rqstp->rq_secure && rp->c_secure)
+	if (!test_bit(RQ_SECURE, &rqstp->rq_flags) && rp->c_secure)
 		goto out;
 
 	/* Compose RPC reply header */
@@ -579,7 +579,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 	spin_lock(&b->cache_lock);
 	drc_mem_usage += bufsize;
 	lru_put_end(b, rp);
-	rp->c_secure = rqstp->rq_secure;
+	rp->c_secure = test_bit(RQ_SECURE, &rqstp->rq_flags);
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;
 	spin_unlock(&b->cache_lock);
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 88026fc6a981..965b478d50fc 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -86,7 +86,7 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 	int flags = nfsexp_flags(rqstp, exp);
 
 	/* Check if the request originated from a secure port. */
-	if (!rqstp->rq_secure && !(flags & NFSEXP_INSECURE_PORT)) {
+	if (!test_bit(RQ_SECURE, &rqstp->rq_flags) && !(flags & NFSEXP_INSECURE_PORT)) {
 		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 		dprintk("nfsd: request from insecure port %s!\n",
 		        svc_print_addr(rqstp, buf, sizeof(buf)));
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 21678464883a..b60eb7c3f3f7 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -253,8 +253,8 @@ struct svc_rqst {
 	u32			rq_vers;	/* program version */
 	u32			rq_proc;	/* procedure number */
 	u32			rq_prot;	/* IP protocol */
-	unsigned short
-				rq_secure  : 1;	/* secure port */
+#define	RQ_SECURE	(0)			/* secure port */
+	unsigned long		rq_flags;	/* flags field */
 	unsigned short		rq_local   : 1;	/* local request */
 
 	void *			rq_argp;	/* decoded arguments */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 171ca4ff6d99..5eb5f79d9794 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -412,6 +412,10 @@ TRACE_EVENT(xs_tcp_data_recv,
 			__entry->copied, __entry->reclen, __entry->offset)
 );
 
+#define show_rqstp_flags(flags)				\
+	__print_flags(flags, "|",			\
+		{ (1UL << RQ_SECURE),	"RQ_SECURE"})
+
 TRACE_EVENT(svc_recv,
 	TP_PROTO(struct svc_rqst *rqst, int status),
 
@@ -421,16 +425,19 @@ TRACE_EVENT(svc_recv,
 		__field(struct sockaddr *, addr)
 		__field(__be32, xid)
 		__field(int, status)
+		__field(unsigned long, flags)
 	),
 
 	TP_fast_assign(
 		__entry->addr = (struct sockaddr *)&rqst->rq_addr;
 		__entry->xid = status > 0 ? rqst->rq_xid : 0;
 		__entry->status = status;
+		__entry->flags = rqst->rq_flags;
 	),
 
-	TP_printk("addr=%pIScp xid=0x%x status=%d", __entry->addr,
-			be32_to_cpu(__entry->xid), __entry->status)
+	TP_printk("addr=%pIScp xid=0x%x status=%d flags=%s", __entry->addr,
+			be32_to_cpu(__entry->xid), __entry->status,
+			show_rqstp_flags(__entry->flags))
 );
 
 DECLARE_EVENT_CLASS(svc_rqst_status,
@@ -444,6 +451,7 @@ DECLARE_EVENT_CLASS(svc_rqst_status,
 		__field(__be32, xid)
 		__field(int, dropme)
 		__field(int, status)
+		__field(unsigned long, flags)
 	),
 
 	TP_fast_assign(
@@ -451,11 +459,12 @@ DECLARE_EVENT_CLASS(svc_rqst_status,
 		__entry->xid = rqst->rq_xid;
 		__entry->dropme = (int)rqst->rq_dropme;
 		__entry->status = status;
+		__entry->flags = rqst->rq_flags;
 	),
 
-	TP_printk("addr=%pIScp rq_xid=0x%x dropme=%d status=%d",
+	TP_printk("addr=%pIScp rq_xid=0x%x dropme=%d status=%d flags=%s",
 		__entry->addr, be32_to_cpu(__entry->xid), __entry->dropme,
-		__entry->status)
+		__entry->status, show_rqstp_flags(__entry->flags))
 );
 
 DEFINE_EVENT(svc_rqst_status, svc_process,
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 5c71ccb9659d..eaa9263c2d28 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -797,7 +797,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 
 	clear_bit(XPT_OLD, &xprt->xpt_flags);
 
-	rqstp->rq_secure = xprt->xpt_ops->xpo_secure_port(rqstp);
+	if (xprt->xpt_ops->xpo_secure_port(rqstp))
+		set_bit(RQ_SECURE, &rqstp->rq_flags);
+	else
+		clear_bit(RQ_SECURE, &rqstp->rq_flags);
 	rqstp->rq_chandle.defer = svc_defer;
 	rqstp->rq_xid = svc_getu32(&rqstp->rq_arg.head[0]);
 
-- 
2.1.0

