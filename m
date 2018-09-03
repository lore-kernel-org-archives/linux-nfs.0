Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:53779 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726314AbeICTun (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:43 -0400
Received: by mail-it0-f68.google.com with SMTP id p79-v6so1560636itp.3
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:03 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.01
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:01 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/27] SUNRPC: The transmitted message must lie in the RPCSEC window of validity
Date: Mon,  3 Sep 2018 11:29:12 -0400
Message-Id: <20180903152936.24325-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-3-trond.myklebust@hammerspace.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a message has been encoded using RPCSEC_GSS, the server is
maintaining a window of sequence numbers that it considers valid.
The client should normally be tracking that window, and needs to
verify that the sequence number used by the message being transmitted
still lies inside the window of validity.

So far, we've been able to assume this condition would be realised
automatically, since the server has been encoding the message only
after taking the socket lock. Once we change that condition, we
will need the explicit check.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/auth.h     |  2 ++
 include/linux/sunrpc/auth_gss.h |  1 +
 net/sunrpc/auth.c               | 10 ++++++++
 net/sunrpc/auth_gss/auth_gss.c  | 41 +++++++++++++++++++++++++++++++++
 net/sunrpc/clnt.c               |  3 +++
 net/sunrpc/xprt.c               |  7 ++++++
 6 files changed, 64 insertions(+)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 58a6765c1c5e..2c97a3933ef9 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -157,6 +157,7 @@ struct rpc_credops {
 	int			(*crkey_timeout)(struct rpc_cred *);
 	bool			(*crkey_to_expire)(struct rpc_cred *);
 	char *			(*crstringify_acceptor)(struct rpc_cred *);
+	bool			(*crneed_reencode)(struct rpc_task *);
 };
 
 extern const struct rpc_authops	authunix_ops;
@@ -192,6 +193,7 @@ __be32 *		rpcauth_marshcred(struct rpc_task *, __be32 *);
 __be32 *		rpcauth_checkverf(struct rpc_task *, __be32 *);
 int			rpcauth_wrap_req(struct rpc_task *task, kxdreproc_t encode, void *rqstp, __be32 *data, void *obj);
 int			rpcauth_unwrap_resp(struct rpc_task *task, kxdrdproc_t decode, void *rqstp, __be32 *data, void *obj);
+bool			rpcauth_xmit_need_reencode(struct rpc_task *task);
 int			rpcauth_refreshcred(struct rpc_task *);
 void			rpcauth_invalcred(struct rpc_task *);
 int			rpcauth_uptodatecred(struct rpc_task *);
diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 0c9eac351aab..30427b729070 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -70,6 +70,7 @@ struct gss_cl_ctx {
 	refcount_t		count;
 	enum rpc_gss_proc	gc_proc;
 	u32			gc_seq;
+	u32			gc_seq_xmit;
 	spinlock_t		gc_seq_lock;
 	struct gss_ctx		*gc_gss_ctx;
 	struct xdr_netobj	gc_wire_ctx;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 305ecea92170..59df5cdba0ac 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -817,6 +817,16 @@ rpcauth_unwrap_resp(struct rpc_task *task, kxdrdproc_t decode, void *rqstp,
 	return rpcauth_unwrap_req_decode(decode, rqstp, data, obj);
 }
 
+bool
+rpcauth_xmit_need_reencode(struct rpc_task *task)
+{
+	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
+
+	if (!cred || !cred->cr_ops->crneed_reencode)
+		return false;
+	return cred->cr_ops->crneed_reencode(task);
+}
+
 int
 rpcauth_refreshcred(struct rpc_task *task)
 {
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 21c0aa0a0d1d..c898a7c75e84 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1984,6 +1984,46 @@ gss_unwrap_req_decode(kxdrdproc_t decode, struct rpc_rqst *rqstp,
 	return decode(rqstp, &xdr, obj);
 }
 
+static bool
+gss_seq_is_newer(u32 new, u32 old)
+{
+	return (s32)(new - old) > 0;
+}
+
+static bool
+gss_xmit_need_reencode(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_cred *cred = req->rq_cred;
+	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
+	u32 win, seq_xmit;
+	bool ret = true;
+
+	if (!ctx)
+		return true;
+
+	if (gss_seq_is_newer(req->rq_seqno, READ_ONCE(ctx->gc_seq)))
+		goto out;
+
+	seq_xmit = READ_ONCE(ctx->gc_seq_xmit);
+	while (gss_seq_is_newer(req->rq_seqno, seq_xmit)) {
+		u32 tmp = seq_xmit;
+
+		seq_xmit = cmpxchg(&ctx->gc_seq_xmit, tmp, req->rq_seqno);
+		if (seq_xmit == tmp) {
+			ret = false;
+			goto out;
+		}
+	}
+
+	win = ctx->gc_win;
+	if (win > 0)
+		ret = !gss_seq_is_newer(req->rq_seqno, seq_xmit - win);
+out:
+	gss_put_ctx(ctx);
+	return ret;
+}
+
 static int
 gss_unwrap_resp(struct rpc_task *task,
 		kxdrdproc_t decode, void *rqstp, __be32 *p, void *obj)
@@ -2052,6 +2092,7 @@ static const struct rpc_credops gss_credops = {
 	.crunwrap_resp		= gss_unwrap_resp,
 	.crkey_timeout		= gss_key_timeout,
 	.crstringify_acceptor	= gss_stringify_acceptor,
+	.crneed_reencode	= gss_xmit_need_reencode,
 };
 
 static const struct rpc_credops gss_nullops = {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4f1ec8013332..d41b5ac1d4e8 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2184,6 +2184,9 @@ call_status(struct rpc_task *task)
 		/* shutdown or soft timeout */
 		rpc_exit(task, status);
 		break;
+	case -EBADMSG:
+		task->tk_action = call_transmit;
+		break;
 	default:
 		if (clnt->cl_chatty)
 			printk("%s: RPC call returned error %d\n",
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 6aa09edc9567..3973e10ea2bd 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1014,6 +1014,13 @@ void xprt_transmit(struct rpc_task *task)
 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
 
 	if (!req->rq_reply_bytes_recvd) {
+
+		/* Verify that our message lies in the RPCSEC_GSS window */
+		if (!req->rq_bytes_sent && rpcauth_xmit_need_reencode(task)) {
+			task->tk_status = -EBADMSG;
+			return;
+		}
+
 		if (list_empty(&req->rq_list) && rpc_reply_expected(task)) {
 			/*
 			 * Add to the list only if we're expecting a reply
-- 
2.17.1
