Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41333 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754500Ab1H2VVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Aug 2011 17:21:42 -0400
From: Joe Perches <joe@perches.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:38 -0700
Message-Id: <8a6378b3fef105983db001fb720c84b669491439.1314650069.git.joe@perches.com>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   10 ++--------
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    2 --
 net/sunrpc/backchannel_rqst.c         |    9 +++------
 net/sunrpc/clnt.c                     |    3 ---
 net/sunrpc/rpc_pipe.c                 |    3 +--
 net/sunrpc/rpcb_clnt.c                |    2 --
 net/sunrpc/xprtrdma/svc_rdma.c        |    8 ++------
 net/sunrpc/xprtrdma/transport.c       |    5 +----
 net/sunrpc/xprtrdma/verbs.c           |   14 --------------
 net/sunrpc/xprtsock.c                 |    5 +----
 10 files changed, 10 insertions(+), 51 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 9576f35..911987e 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -865,11 +865,8 @@ krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
 	dprintk("%s: entered\n", __func__);
 
 	hmac = crypto_alloc_hash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(hmac)) {
-		dprintk("%s: error %ld, allocating hash '%s'\n",
-			__func__, PTR_ERR(hmac), kctx->gk5e->cksum_name);
+	if (IS_ERR(hmac))
 		return PTR_ERR(hmac);
-	}
 
 	desc.tfm = hmac;
 	desc.flags = 0;
@@ -932,11 +929,8 @@ krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
 	dprintk("%s: entered, seqnum %u\n", __func__, seqnum);
 
 	hmac = crypto_alloc_hash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(hmac)) {
-		dprintk("%s: error %ld, allocating hash '%s'\n",
-			__func__, PTR_ERR(hmac), kctx->gk5e->cksum_name);
+	if (IS_ERR(hmac))
 		return PTR_ERR(hmac);
-	}
 
 	desc.tfm = hmac;
 	desc.flags = 0;
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 8c67890..61de04c 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -440,8 +440,6 @@ context_derive_keys_rc4(struct krb5_ctx *ctx)
 	 */
 	hmac = crypto_alloc_hash(ctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(hmac)) {
-		dprintk("%s: error %ld allocating hash '%s'\n",
-			__func__, PTR_ERR(hmac), ctx->gk5e->cksum_name);
 		err = PTR_ERR(hmac);
 		goto out_err;
 	}
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 91eaa26..1074d8e 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -106,10 +106,8 @@ int xprt_setup_backchannel(struct rpc_xprt *xprt, unsigned int min_reqs)
 	for (i = 0; i < min_reqs; i++) {
 		/* Pre-allocate one backchannel rpc_rqst */
 		req = kzalloc(sizeof(struct rpc_rqst), GFP_KERNEL);
-		if (req == NULL) {
-			printk(KERN_ERR "Failed to create bc rpc_rqst\n");
+		if (req == NULL)
 			goto out_free;
-		}
 
 		/* Add the allocated buffer to the tmp list */
 		dprintk("RPC:       adding req= %p\n", req);
@@ -121,10 +119,9 @@ int xprt_setup_backchannel(struct rpc_xprt *xprt, unsigned int min_reqs)
 
 		/* Preallocate one XDR receive buffer */
 		page_rcv = alloc_page(GFP_KERNEL);
-		if (page_rcv == NULL) {
-			printk(KERN_ERR "Failed to create bc receive xbuf\n");
+		if (page_rcv == NULL)
 			goto out_free;
-		}
+
 		xbufp = &req->rq_rcv_buf;
 		xbufp->head[0].iov_base = page_address(page_rcv);
 		xbufp->head[0].iov_len = PAGE_SIZE;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c5347d2..e10709a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1058,8 +1058,6 @@ call_allocate(struct rpc_task *task)
 	if (req->rq_buffer != NULL)
 		return;
 
-	dprintk("RPC: %5u rpc_buffer allocation failed\n", task->tk_pid);
-
 	if (RPC_IS_ASYNC(task) || !fatal_signal_pending(current)) {
 		task->tk_action = call_allocate;
 		rpc_delay(task, HZ>>4);
@@ -1163,7 +1161,6 @@ call_bind_status(struct rpc_task *task)
 
 	switch (task->tk_status) {
 	case -ENOMEM:
-		dprintk("RPC: %5u rpcbind out of memory\n", task->tk_pid);
 		rpc_delay(task, HZ >> 2);
 		goto retry_timeout;
 	case -EACCES:
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index b181e34..0395311 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -485,9 +485,8 @@ static int __rpc_create_common(struct inode *dir, struct dentry *dentry,
 		rpc_inode_setowner(inode, private);
 	d_add(dentry, inode);
 	return 0;
+
 out_err:
-	printk(KERN_WARNING "%s: %s failed to allocate inode for dentry %s\n",
-			__FILE__, __func__, dentry->d_name.name);
 	dput(dentry);
 	return -ENOMEM;
 }
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index e45d2fb..4d8be9a 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -671,8 +671,6 @@ void rpcb_getport_async(struct rpc_task *task)
 	map = kzalloc(sizeof(struct rpcbind_args), GFP_ATOMIC);
 	if (!map) {
 		status = -ENOMEM;
-		dprintk("RPC: %5u %s: no memory available\n",
-			task->tk_pid, __func__);
 		goto bailout_release_client;
 	}
 	map->r_prog = clnt->cl_prog;
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 09af4fa..18fe984 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -267,10 +267,8 @@ int svc_rdma_init(void)
 						0,
 						SLAB_HWCACHE_ALIGN,
 						NULL);
-	if (!svc_rdma_map_cachep) {
-		printk(KERN_INFO "Could not allocate map cache.\n");
+	if (!svc_rdma_map_cachep)
 		goto err0;
-	}
 
 	/* Create the temporary context cache */
 	svc_rdma_ctxt_cachep =
@@ -279,10 +277,8 @@ int svc_rdma_init(void)
 				  0,
 				  SLAB_HWCACHE_ALIGN,
 				  NULL);
-	if (!svc_rdma_ctxt_cachep) {
-		printk(KERN_INFO "Could not allocate WR ctxt cache.\n");
+	if (!svc_rdma_ctxt_cachep)
 		goto err1;
-	}
 
 	/* Register RDMA with the SVC transport switch */
 	svc_reg_xprt_class(&svc_rdma_class);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index b446e10..772a481 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -285,11 +285,8 @@ xprt_setup_rdma(struct xprt_create *args)
 	xprt = xprt_alloc(args->net, sizeof(struct rpcrdma_xprt),
 			xprt_rdma_slot_table_entries,
 			xprt_rdma_slot_table_entries);
-	if (xprt == NULL) {
-		dprintk("RPC:       %s: couldn't allocate rpcrdma_xprt\n",
-			__func__);
+	if (xprt == NULL)
 		return ERR_PTR(-ENOMEM);
-	}
 
 	/* 60 second timeout, no retries */
 	xprt->timeout = &xprt_rdma_default_timeout;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 28236ba..937b51d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -471,8 +471,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	ia->ri_pd = ib_alloc_pd(ia->ri_id->device);
 	if (IS_ERR(ia->ri_pd)) {
 		rc = PTR_ERR(ia->ri_pd);
-		dprintk("RPC:       %s: ib_alloc_pd() failed %i\n",
-			__func__, rc);
 		goto out2;
 	}
 
@@ -1009,8 +1007,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 	/* allocate 1, 4 and 5 in one shot */
 	p = kzalloc(len, GFP_KERNEL);
 	if (p == NULL) {
-		dprintk("RPC:       %s: req_t/rep_t/pad kzalloc(%zd) failed\n",
-			__func__, len);
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1046,8 +1042,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 							 RPCRDMA_MAX_SEGS);
 			if (IS_ERR(r->r.frmr.fr_mr)) {
 				rc = PTR_ERR(r->r.frmr.fr_mr);
-				dprintk("RPC:       %s: ib_alloc_fast_reg_mr"
-					" failed %i\n", __func__, rc);
 				goto out;
 			}
 			r->r.frmr.fr_pgl =
@@ -1074,8 +1068,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 				&fa);
 			if (IS_ERR(r->r.fmr)) {
 				rc = PTR_ERR(r->r.fmr);
-				dprintk("RPC:       %s: ib_alloc_fmr"
-					" failed %i\n", __func__, rc);
 				goto out;
 			}
 			list_add(&r->mw_list, &buf->rb_mws);
@@ -1089,8 +1081,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 			r->r.mw = ib_alloc_mw(ia->ri_pd);
 			if (IS_ERR(r->r.mw)) {
 				rc = PTR_ERR(r->r.mw);
-				dprintk("RPC:       %s: ib_alloc_mw"
-					" failed %i\n", __func__, rc);
 				goto out;
 			}
 			list_add(&r->mw_list, &buf->rb_mws);
@@ -1116,8 +1106,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 			len = 4096;
 		req = kmalloc(len, GFP_KERNEL);
 		if (req == NULL) {
-			dprintk("RPC:       %s: request buffer %d alloc"
-				" failed\n", __func__, i);
 			rc = -ENOMEM;
 			goto out;
 		}
@@ -1137,8 +1125,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 		len = cdata->inline_rsize + sizeof(struct rpcrdma_rep);
 		rep = kmalloc(len, GFP_KERNEL);
 		if (rep == NULL) {
-			dprintk("RPC:       %s: reply buffer %d alloc failed\n",
-				__func__, i);
 			rc = -ENOMEM;
 			goto out;
 		}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d7f97ef..911494a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2515,11 +2515,8 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 
 	xprt = xprt_alloc(args->net, sizeof(*new), slot_table_size,
 			max_slot_table_size);
-	if (xprt == NULL) {
-		dprintk("RPC:       xs_setup_xprt: couldn't allocate "
-				"rpc_xprt\n");
+	if (xprt == NULL)
 		return ERR_PTR(-ENOMEM);
-	}
 
 	new = container_of(xprt, struct sock_xprt, xprt);
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
-- 
1.7.6.405.gc1be0

