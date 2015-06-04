Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35474 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbbFDV1C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 17:27:02 -0400
Received: by igbzc4 with SMTP id zc4so1250362igb.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 14:27:01 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] SUNRPC: Fix a backchannel race
Date: Thu,  4 Jun 2015 17:26:53 -0400
Message-Id: <1433453213-13466-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1433453213-13466-5-git-send-email-trond.myklebust@primarydata.com>
References: <1433453213-13466-1-git-send-email-trond.myklebust@primarydata.com>
 <1433453213-13466-2-git-send-email-trond.myklebust@primarydata.com>
 <1433453213-13466-3-git-send-email-trond.myklebust@primarydata.com>
 <1433453213-13466-4-git-send-email-trond.myklebust@primarydata.com>
 <1433453213-13466-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to allow the server to send a new request immediately after we've
replied to the previous one. Right now, there is a window between the
send and the release of the old request in rpc_put_task(), where the
server could send us a new backchannel RPC call, and we have no
request to service it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprt.h   |  3 ++-
 net/sunrpc/backchannel_rqst.c | 37 ++++++++++++++++++++++++-------------
 net/sunrpc/svc.c              |  6 +++++-
 3 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8b93ef53df3c..bc9c39d6d30d 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -212,7 +212,8 @@ struct rpc_xprt {
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct svc_serv		*bc_serv;       /* The RPC service which will */
 						/* process the callback */
-	unsigned int		bc_alloc_count;	/* Total number of preallocs */
+	int			bc_alloc_count;	/* Total number of preallocs */
+	atomic_t		bc_free_slots;
 	spinlock_t		bc_pa_lock;	/* Protects the preallocated
 						 * items */
 	struct list_head	bc_pa_list;	/* List of preallocated
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 1baa41099469..9825ff0f91d6 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -37,16 +37,18 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 static inline int xprt_need_to_requeue(struct rpc_xprt *xprt)
 {
-	return xprt->bc_alloc_count > 0;
+	return xprt->bc_alloc_count < atomic_read(&xprt->bc_free_slots);
 }
 
 static inline void xprt_inc_alloc_count(struct rpc_xprt *xprt, unsigned int n)
 {
+	atomic_add(n, &xprt->bc_free_slots);
 	xprt->bc_alloc_count += n;
 }
 
 static inline int xprt_dec_alloc_count(struct rpc_xprt *xprt, unsigned int n)
 {
+	atomic_sub(n, &xprt->bc_free_slots);
 	return xprt->bc_alloc_count -= n;
 }
 
@@ -232,9 +234,15 @@ static struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt, __be32 xid)
 	struct rpc_rqst *req = NULL;
 
 	dprintk("RPC:       allocate a backchannel request\n");
-	if (list_empty(&xprt->bc_pa_list))
+	if (atomic_read(&xprt->bc_free_slots) <= 0)
 		goto not_found;
-
+	if (list_empty(&xprt->bc_pa_list)) {
+		req = xprt_alloc_bc_req(xprt, GFP_ATOMIC);
+		if (!req)
+			goto not_found;
+		/* Note: this 'free' request adds it to xprt->bc_pa_list */
+		xprt_free_bc_request(req);
+	}
 	req = list_first_entry(&xprt->bc_pa_list, struct rpc_rqst,
 				rq_bc_pa_list);
 	req->rq_reply_bytes_recvd = 0;
@@ -260,11 +268,21 @@ void xprt_free_bc_request(struct rpc_rqst *req)
 
 	req->rq_connect_cookie = xprt->connect_cookie - 1;
 	smp_mb__before_atomic();
-	WARN_ON_ONCE(!test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state));
 	clear_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
 	smp_mb__after_atomic();
 
-	if (!xprt_need_to_requeue(xprt)) {
+	/*
+	 * Return it to the list of preallocations so that it
+	 * may be reused by a new callback request.
+	 */
+	spin_lock_bh(&xprt->bc_pa_lock);
+	if (xprt_need_to_requeue(xprt)) {
+		list_add_tail(&req->rq_bc_pa_list, &xprt->bc_pa_list);
+		xprt->bc_alloc_count++;
+		req = NULL;
+	}
+	spin_unlock_bh(&xprt->bc_pa_lock);
+	if (req != NULL) {
 		/*
 		 * The last remaining session was destroyed while this
 		 * entry was in use.  Free the entry and don't attempt
@@ -275,14 +293,6 @@ void xprt_free_bc_request(struct rpc_rqst *req)
 		xprt_free_allocation(req);
 		return;
 	}
-
-	/*
-	 * Return it to the list of preallocations so that it
-	 * may be reused by a new callback request.
-	 */
-	spin_lock_bh(&xprt->bc_pa_lock);
-	list_add_tail(&req->rq_bc_pa_list, &xprt->bc_pa_list);
-	spin_unlock_bh(&xprt->bc_pa_lock);
 }
 
 /*
@@ -326,6 +336,7 @@ void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied)
 
 	spin_lock(&xprt->bc_pa_lock);
 	list_del(&req->rq_bc_pa_list);
+	xprt->bc_alloc_count--;
 	spin_unlock(&xprt->bc_pa_lock);
 
 	req->rq_private_buf.len = copied;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 51c8cad5e765..b47f02f60b9c 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1351,6 +1351,7 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	struct kvec	*argv = &rqstp->rq_arg.head[0];
 	struct kvec	*resv = &rqstp->rq_res.head[0];
 	struct rpc_task *task;
+	int proc_error;
 	int error;
 
 	dprintk("svc: %s(%p)\n", __func__, req);
@@ -1382,7 +1383,10 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	svc_getnl(argv);	/* CALLDIR */
 
 	/* Parse and execute the bc call */
-	if (!svc_process_common(rqstp, argv, resv)) {
+	proc_error = svc_process_common(rqstp, argv, resv);
+
+	atomic_inc(&req->rq_xprt->bc_free_slots);
+	if (!proc_error) {
 		/* Processing error: drop the request */
 		xprt_free_bc_request(req);
 		return 0;
-- 
2.4.2

