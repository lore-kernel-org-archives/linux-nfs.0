Return-Path: <SRS0=c+aj=QI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E67EFC282D8
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:57:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9FCC2218AF
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:57:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ECmgZYyA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729876AbfBAT55 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Feb 2019 14:57:57 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:54251 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727097AbfBAT55 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Feb 2019 14:57:57 -0500
Received: by mail-it1-f196.google.com with SMTP id g85so11093341ita.3
        for <linux-nfs@vger.kernel.org>; Fri, 01 Feb 2019 11:57:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=VeF2n/0OclDHtt5kce8li4DO1FAlCL/M4mxGcyP+0eE=;
        b=ECmgZYyAKUJ14ix6qTyNrGVs3XVqTW5zXt2k8M4tvZsWNrJqW7H4MAUf1XgRrWjA86
         94PZ9iSMWbd7VzJuyvyQ/mjzo6PgU8bgiEJ9BgOJx0oR5A5bBeqsfA/dwwjcpNT4c6RC
         UBwaOXJN37/K2DGXZBgnGvVeuM7CdU/zGDTndQIxfb5VqFyvMllUVanSRgIXXBAQ+E09
         5yEFyARwoFgu4jnvN4ckuiMK0MZnImEZSXmpNJNlf3xVh8sId5wA3TTot/qJ9IT/G5E1
         RbeX+jrsUCTWHKYVRUSrK8lLPMzamJU4j2ehxf2+Oo4a9Iv35LaanzfYadRNooKq+xWa
         KuRA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=VeF2n/0OclDHtt5kce8li4DO1FAlCL/M4mxGcyP+0eE=;
        b=RfGk1ZTR7BwcpmDFG3dqJzPlQgcfxDxlFsFoLW/zPjDDY6llslGJC4QdH2ExRlUdcq
         PqRCi8F20qDAmv4zOdxmj/NCpQFvA9JKUDck6Fo9fmTRu33VKekwoD1R5r2lwW+13Rgn
         JmSUS4ucmtgA9I1rlG3454M4a+LhGNc9qE8a3tFKDRzYKBg23jbkluEpn3zn0ebiJZSe
         KA68gz+vUXDJifSVBsqw+WfAxUObVF+TmHuM+PJPSb4o0Ue0iWTwxYIPAEoayIK9e6Vo
         zlglU/BiNg0SBrT3vI8g4k6jCidZ1nj+mjKK9smULAO8rzUrHsusOz2P6GwznEBcyS12
         JIPw==
X-Gm-Message-State: AHQUAuaXKFf08O/tz5QHGVzQaiiw2CtsXI/CJsTj9OdxUBCwFr8/aKBg
        U7Pybx2R8kmV2QrkwUresTA=
X-Google-Smtp-Source: AHgI3IabGztGmcF/Sym69TGS/esYF6Gwi1EglFYcbeXyPFsoBb0lD/8vs0lSUq7Ig7iQ8RSLCnfQlQ==
X-Received: by 2002:a24:ac62:: with SMTP id m34mr2342258iti.129.1549051074555;
        Fri, 01 Feb 2019 11:57:54 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t25sm3280919ioj.17.2019.02.01.11.57.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 11:57:53 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x11Jvrft008708;
        Fri, 1 Feb 2019 19:57:53 GMT
Subject: [PATCH RFC 05/10] SUNRPC: Use struct xdr_stream when constructing
 RPC Call header
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     simo@redhat.com
Date:   Fri, 01 Feb 2019 14:57:53 -0500
Message-ID: <20190201195753.11389.39375.stgit@manet.1015granger.net>
In-Reply-To: <20190201195538.11389.96106.stgit@manet.1015granger.net>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Modernize and harden the code path that constructs each RPC Call
message.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/auth.h    |   15 ++-
 include/trace/events/sunrpc.h  |   29 ++++++
 net/sunrpc/auth.c              |   56 ++++++++----
 net/sunrpc/auth_gss/auth_gss.c |  191 +++++++++++++++++++---------------------
 net/sunrpc/auth_null.c         |   23 +++--
 net/sunrpc/auth_unix.c         |   61 ++++++++-----
 net/sunrpc/clnt.c              |   66 +++++++-------
 7 files changed, 260 insertions(+), 181 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index eed3cb1..96e237f 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -131,11 +131,12 @@ struct rpc_credops {
 	void			(*crdestroy)(struct rpc_cred *);
 
 	int			(*crmatch)(struct auth_cred *, struct rpc_cred *, int);
-	__be32 *		(*crmarshal)(struct rpc_task *, __be32 *);
+	int			(*crmarshal)(struct rpc_task *task,
+					     struct xdr_stream *xdr);
 	int			(*crrefresh)(struct rpc_task *);
 	__be32 *		(*crvalidate)(struct rpc_task *, __be32 *);
-	int			(*crwrap_req)(struct rpc_task *, kxdreproc_t,
-						void *, __be32 *, void *);
+	int			(*crwrap_req)(struct rpc_task *task,
+					      struct xdr_stream *xdr);
 	int			(*crunwrap_resp)(struct rpc_task *, kxdrdproc_t,
 						void *, __be32 *, void *);
 	int			(*crkey_timeout)(struct rpc_cred *);
@@ -165,9 +166,13 @@ int			rpcauth_get_gssinfo(rpc_authflavor_t,
 void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
 struct rpc_cred *	rpcauth_lookupcred(struct rpc_auth *, int);
 void			put_rpccred(struct rpc_cred *);
-__be32 *		rpcauth_marshcred(struct rpc_task *, __be32 *);
+int			rpcauth_marshcred(struct rpc_task *task,
+					  struct xdr_stream *xdr);
 __be32 *		rpcauth_checkverf(struct rpc_task *, __be32 *);
-int			rpcauth_wrap_req(struct rpc_task *task, kxdreproc_t encode, void *rqstp, __be32 *data, void *obj);
+int			rpcauth_wrap_req_encode(struct rpc_task *task,
+						struct xdr_stream *xdr);
+int			rpcauth_wrap_req(struct rpc_task *task,
+					 struct xdr_stream *xdr);
 int			rpcauth_unwrap_resp(struct rpc_task *task, kxdrdproc_t decode, void *rqstp, __be32 *data, void *obj);
 bool			rpcauth_xmit_need_reencode(struct rpc_task *task);
 int			rpcauth_refreshcred(struct rpc_task *);
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 6276508..2b3f9d1 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -213,6 +213,35 @@
 DEFINE_RPC_QUEUED_EVENT(sleep);
 DEFINE_RPC_QUEUED_EVENT(wakeup);
 
+DECLARE_EVENT_CLASS(rpc_failure,
+
+	TP_PROTO(const struct rpc_task *task),
+
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+	),
+
+	TP_printk("task:%u@%u",
+		__entry->task_id, __entry->client_id)
+);
+
+#define DEFINE_RPC_FAILURE(name)					\
+	DEFINE_EVENT(rpc_failure, rpc_bad_##name,			\
+			TP_PROTO(					\
+				const struct rpc_task *task		\
+			),						\
+			TP_ARGS(task))
+
+DEFINE_RPC_FAILURE(callhdr);
+
 TRACE_EVENT(rpc_stats_latency,
 
 	TP_PROTO(
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 275e84e..add2135 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -756,12 +756,21 @@ struct rpc_cred *
 }
 EXPORT_SYMBOL_GPL(put_rpccred);
 
-__be32 *
-rpcauth_marshcred(struct rpc_task *task, __be32 *p)
+/**
+ * rpcauth_marshcred - Append RPC credential to end of @xdr
+ * @task: controlling RPC task
+ * @xdr: xdr_stream containing initial portion of RPC Call header
+ *
+ * On success, an appropriate verifier is added to @xdr, @xdr is
+ * updated to point past the verifier, and zero is returned.
+ * Otherwise, @xdr is in an undefined state and a negative errno
+ * is returned.
+ */
+int rpcauth_marshcred(struct rpc_task *task, struct xdr_stream *xdr)
 {
-	struct rpc_cred	*cred = task->tk_rqstp->rq_cred;
+	const struct rpc_credops *ops = task->tk_rqstp->rq_cred->cr_ops;
 
-	return cred->cr_ops->crmarshal(task, p);
+	return ops->crmarshal(task, xdr);
 }
 
 __be32 *
@@ -772,26 +781,37 @@ struct rpc_cred *
 	return cred->cr_ops->crvalidate(task, p);
 }
 
-static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
-				   __be32 *data, void *obj)
+/**
+ * rpcauth_wrap_req_encode - XDR encode the RPC procedure
+ * @task: controlling RPC task
+ * @xdr: stream where on-the-wire bytes are to be marshalled
+ *
+ * On success, @xdr contains the encoded and wrapped message.
+ * Otherwise, @xdr is in an undefined state.
+ */
+int rpcauth_wrap_req_encode(struct rpc_task *task, struct xdr_stream *xdr)
 {
-	struct xdr_stream xdr;
+	kxdreproc_t encode = task->tk_msg.rpc_proc->p_encode;
 
-	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, data, rqstp);
-	encode(rqstp, &xdr, obj);
+	encode(task->tk_rqstp, xdr, task->tk_msg.rpc_argp);
+	return 0;
 }
+EXPORT_SYMBOL_GPL(rpcauth_wrap_req_encode);
 
-int
-rpcauth_wrap_req(struct rpc_task *task, kxdreproc_t encode, void *rqstp,
-		__be32 *data, void *obj)
+/**
+ * rpcauth_wrap_req - XDR encode and wrap the RPC procedure
+ * @task: controlling RPC task
+ * @xdr: stream where on-the-wire bytes are to be marshalled
+ *
+ * On success, @xdr contains the encoded and wrapped message,
+ * and zero is returned. Otherwise, @xdr is in an undefined
+ * state and a negative errno is returned.
+ */
+int rpcauth_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 {
-	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
+	const struct rpc_credops *ops = task->tk_rqstp->rq_cred->cr_ops;
 
-	if (cred->cr_ops->crwrap_req)
-		return cred->cr_ops->crwrap_req(task, encode, rqstp, data, obj);
-	/* By default, we encode the arguments normally. */
-	rpcauth_wrap_req_encode(encode, rqstp, data, obj);
-	return 0;
+	return ops->crwrap_req(task, xdr);
 }
 
 static int
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 4b52e2b..b333b1b 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1526,18 +1526,20 @@ static void gss_pipe_free(struct gss_pipe *p)
 }
 
 /*
-* Marshal credentials.
-* Maybe we should keep a cached credential for performance reasons.
-*/
-static __be32 *
-gss_marshal(struct rpc_task *task, __be32 *p)
+ * Marshal credentials.
+ *
+ * The expensive part is computing the verifier. We can't cache a
+ * pre-computed version of the verifier because the seqno, which
+ * is different every time, is included in the MIC.
+ */
+static int gss_marshal(struct rpc_task *task, struct xdr_stream *xdr)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_cred *cred = req->rq_cred;
 	struct gss_cred	*gss_cred = container_of(cred, struct gss_cred,
 						 gc_base);
 	struct gss_cl_ctx	*ctx = gss_cred_get_ctx(cred);
-	__be32		*cred_len;
+	__be32		*p, *cred_len;
 	u32             maj_stat = 0;
 	struct xdr_netobj mic;
 	struct kvec	iov;
@@ -1545,7 +1547,13 @@ static void gss_pipe_free(struct gss_pipe *p)
 
 	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
 
-	*p++ = htonl(RPC_AUTH_GSS);
+	/* Credential */
+
+	p = xdr_reserve_space(xdr, 7 * sizeof(*p) +
+			      ctx->gc_wire_ctx.len);
+	if (!p)
+		goto out_put_ctx;
+	*p++ = rpc_auth_gss;
 	cred_len = p++;
 
 	spin_lock(&ctx->gc_seq_lock);
@@ -1554,12 +1562,14 @@ static void gss_pipe_free(struct gss_pipe *p)
 	if (req->rq_seqno == MAXSEQ)
 		goto out_expired;
 
-	*p++ = htonl((u32) RPC_GSS_VERSION);
-	*p++ = htonl((u32) ctx->gc_proc);
-	*p++ = htonl((u32) req->rq_seqno);
-	*p++ = htonl((u32) gss_cred->gc_service);
+	*p++ = cpu_to_be32(RPC_GSS_VERSION);
+	*p++ = cpu_to_be32(ctx->gc_proc);
+	*p++ = cpu_to_be32(req->rq_seqno);
+	*p++ = cpu_to_be32(gss_cred->gc_service);
 	p = xdr_encode_netobj(p, &ctx->gc_wire_ctx);
-	*cred_len = htonl((p - (cred_len + 1)) << 2);
+	*cred_len = cpu_to_be32((p - (cred_len + 1)) << 2);
+
+	/* Verifier */
 
 	/* We compute the checksum for the verifier over the xdr-encoded bytes
 	 * starting with the xid and ending at the end of the credential: */
@@ -1567,27 +1577,27 @@ static void gss_pipe_free(struct gss_pipe *p)
 	iov.iov_len = (u8 *)p - (u8 *)iov.iov_base;
 	xdr_buf_from_iov(&iov, &verf_buf);
 
-	/* set verifier flavor*/
-	*p++ = htonl(RPC_AUTH_GSS);
-
+	p = xdr_reserve_space(xdr, sizeof(*p));
+	if (!p)
+		goto out_put_ctx;
+	*p++ = rpc_auth_gss;
 	mic.data = (u8 *)(p + 1);
 	maj_stat = gss_get_mic(ctx->gc_gss_ctx, &verf_buf, &mic);
-	if (maj_stat == GSS_S_CONTEXT_EXPIRED) {
+	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		goto out_expired;
-	} else if (maj_stat != 0) {
-		pr_warn("gss_marshal: gss_get_mic FAILED (%d)\n", maj_stat);
-		task->tk_status = -EIO;
+	else if (maj_stat != 0)
+		goto out_put_ctx;
+	if (xdr_stream_encode_opaque_inline(xdr, (void **)&p, mic.len) < 0)
 		goto out_put_ctx;
-	}
-	p = xdr_encode_opaque(p, NULL, mic.len);
 	gss_put_ctx(ctx);
-	return p;
+	return 0;
 out_expired:
+	gss_put_ctx(ctx);
 	clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
-	task->tk_status = -EKEYEXPIRED;
+	return -EKEYEXPIRED;
 out_put_ctx:
 	gss_put_ctx(ctx);
-	return NULL;
+	return -EMSGSIZE;
 }
 
 static int gss_renew_cred(struct rpc_task *task)
@@ -1716,61 +1726,45 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
 	return ret;
 }
 
-static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
-				__be32 *p, void *obj)
-{
-	struct xdr_stream xdr;
-
-	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, p, rqstp);
-	encode(rqstp, &xdr, obj);
-}
-
-static inline int
-gss_wrap_req_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
-		   kxdreproc_t encode, struct rpc_rqst *rqstp,
-		   __be32 *p, void *obj)
+static int gss_wrap_req_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
+			      struct rpc_task *task, struct xdr_stream *xdr)
 {
-	struct xdr_buf	*snd_buf = &rqstp->rq_snd_buf;
-	struct xdr_buf	integ_buf;
-	__be32          *integ_len = NULL;
+	struct rpc_rqst *rqstp = task->tk_rqstp;
+	struct xdr_buf integ_buf, *snd_buf = &rqstp->rq_snd_buf;
 	struct xdr_netobj mic;
-	u32		offset;
-	__be32		*q;
-	struct kvec	*iov;
-	u32             maj_stat = 0;
-	int		status = -EIO;
+	__be32 *p, *integ_len;
+	u32 offset, maj_stat;
 
+	p = xdr_reserve_space(xdr, 2 * sizeof(*p));
+	if (!p)
+		goto wrap_failed;
 	integ_len = p++;
-	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
-	*p++ = htonl(rqstp->rq_seqno);
+	*p = cpu_to_be32(rqstp->rq_seqno);
 
-	gss_wrap_req_encode(encode, rqstp, p, obj);
+	if (rpcauth_wrap_req_encode(task, xdr))
+		goto wrap_failed;
 
+	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	if (xdr_buf_subsegment(snd_buf, &integ_buf,
 				offset, snd_buf->len - offset))
-		return status;
-	*integ_len = htonl(integ_buf.len);
+		goto wrap_failed;
+	*integ_len = cpu_to_be32(integ_buf.len);
 
-	/* guess whether we're in the head or the tail: */
-	if (snd_buf->page_len || snd_buf->tail[0].iov_len)
-		iov = snd_buf->tail;
-	else
-		iov = snd_buf->head;
-	p = iov->iov_base + iov->iov_len;
+	p = xdr_reserve_space(xdr, 0);
+	if (!p)
+		goto wrap_failed;
 	mic.data = (u8 *)(p + 1);
-
 	maj_stat = gss_get_mic(ctx->gc_gss_ctx, &integ_buf, &mic);
-	status = -EIO; /* XXX? */
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	else if (maj_stat)
-		return status;
-	q = xdr_encode_opaque(p, NULL, mic.len);
-
-	offset = (u8 *)q - (u8 *)p;
-	iov->iov_len += offset;
-	snd_buf->len += offset;
+		goto wrap_failed;
+	/* Check that the trailing MIC fit in the buffer, after the fact */
+	if (xdr_stream_encode_opaque_inline(xdr, (void **)&p, mic.len) < 0)
+		goto wrap_failed;
 	return 0;
+wrap_failed:
+	return -EMSGSIZE;
 }
 
 static void
@@ -1821,61 +1815,63 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 	return -EAGAIN;
 }
 
-static inline int
-gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
-		  kxdreproc_t encode, struct rpc_rqst *rqstp,
-		  __be32 *p, void *obj)
+static int gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
+			     struct rpc_task *task, struct xdr_stream *xdr)
 {
+	struct rpc_rqst *rqstp = task->tk_rqstp;
 	struct xdr_buf	*snd_buf = &rqstp->rq_snd_buf;
-	u32		offset;
-	u32             maj_stat;
+	u32		pad, offset, maj_stat;
 	int		status;
-	__be32		*opaque_len;
+	__be32		*p, *opaque_len;
 	struct page	**inpages;
 	int		first;
-	int		pad;
 	struct kvec	*iov;
-	char		*tmp;
 
+	status = -EIO;
+	p = xdr_reserve_space(xdr, 2 * sizeof(*p));
+	if (!p)
+		goto wrap_failed;
 	opaque_len = p++;
-	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
-	*p++ = htonl(rqstp->rq_seqno);
+	*p = cpu_to_be32(rqstp->rq_seqno);
 
-	gss_wrap_req_encode(encode, rqstp, p, obj);
+	if (rpcauth_wrap_req_encode(task, xdr))
+		goto wrap_failed;
 
 	status = alloc_enc_pages(rqstp);
-	if (status)
-		return status;
+	if (unlikely(status))
+		goto wrap_failed;
 	first = snd_buf->page_base >> PAGE_SHIFT;
 	inpages = snd_buf->pages + first;
 	snd_buf->pages = rqstp->rq_enc_pages;
 	snd_buf->page_base -= first << PAGE_SHIFT;
 	/*
-	 * Give the tail its own page, in case we need extra space in the
-	 * head when wrapping:
+	 * Move the tail into its own page, in case gss_wrap needs
+	 * more space in the head when wrapping.
 	 *
-	 * call_allocate() allocates twice the slack space required
-	 * by the authentication flavor to rq_callsize.
-	 * For GSS, slack is GSS_CRED_SLACK.
+	 * Still... Why can't gss_wrap just slide the tail down?
 	 */
 	if (snd_buf->page_len || snd_buf->tail[0].iov_len) {
+		char *tmp;
+
 		tmp = page_address(rqstp->rq_enc_pages[rqstp->rq_enc_pages_num - 1]);
 		memcpy(tmp, snd_buf->tail[0].iov_base, snd_buf->tail[0].iov_len);
 		snd_buf->tail[0].iov_base = tmp;
 	}
+	status = -EIO;
+	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	maj_stat = gss_wrap(ctx->gc_gss_ctx, offset, snd_buf, inpages);
 	/* slack space should prevent this ever happening: */
-	BUG_ON(snd_buf->len > snd_buf->buflen);
-	status = -EIO;
+	if (unlikely(snd_buf->len > snd_buf->buflen))
+		goto wrap_failed;
 	/* We're assuming that when GSS_S_CONTEXT_EXPIRED, the encryption was
 	 * done anyway, so it's safe to put the request on the wire: */
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	else if (maj_stat)
-		return status;
+		goto wrap_failed;
 
-	*opaque_len = htonl(snd_buf->len - offset);
-	/* guess whether we're in the head or the tail: */
+	*opaque_len = cpu_to_be32(snd_buf->len - offset);
+	/* guess whether the pad goes into the head or the tail: */
 	if (snd_buf->page_len || snd_buf->tail[0].iov_len)
 		iov = snd_buf->tail;
 	else
@@ -1887,37 +1883,36 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 	snd_buf->len += pad;
 
 	return 0;
+wrap_failed:
+	return status;
 }
 
-static int
-gss_wrap_req(struct rpc_task *task,
-	     kxdreproc_t encode, void *rqstp, __be32 *p, void *obj)
+static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 	struct gss_cred	*gss_cred = container_of(cred, struct gss_cred,
 			gc_base);
 	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
-	int             status = -EIO;
+	int status;
 
 	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
+	status = -EIO;
 	if (ctx->gc_proc != RPC_GSS_PROC_DATA) {
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
 		 */
-		gss_wrap_req_encode(encode, rqstp, p, obj);
-		status = 0;
+		status = rpcauth_wrap_req_encode(task, xdr);
 		goto out;
 	}
 	switch (gss_cred->gc_service) {
 	case RPC_GSS_SVC_NONE:
-		gss_wrap_req_encode(encode, rqstp, p, obj);
-		status = 0;
+		status = rpcauth_wrap_req_encode(task, xdr);
 		break;
 	case RPC_GSS_SVC_INTEGRITY:
-		status = gss_wrap_req_integ(cred, ctx, encode, rqstp, p, obj);
+		status = gss_wrap_req_integ(cred, ctx, task, xdr);
 		break;
 	case RPC_GSS_SVC_PRIVACY:
-		status = gss_wrap_req_priv(cred, ctx, encode, rqstp, p, obj);
+		status = gss_wrap_req_priv(cred, ctx, task, xdr);
 		break;
 	}
 out:
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index d0ceac5..797f8472 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -59,15 +59,21 @@
 /*
  * Marshal credential.
  */
-static __be32 *
-nul_marshal(struct rpc_task *task, __be32 *p)
+static int
+nul_marshal(struct rpc_task *task, struct xdr_stream *xdr)
 {
-	*p++ = htonl(RPC_AUTH_NULL);
-	*p++ = 0;
-	*p++ = htonl(RPC_AUTH_NULL);
-	*p++ = 0;
-
-	return p;
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 4 * sizeof(*p));
+	if (!p)
+		return -EMSGSIZE;
+	/* Credential */
+	*p++ = rpc_auth_null;
+	*p++ = xdr_zero;
+	/* Verifier */
+	*p++ = rpc_auth_null;
+	*p   = xdr_zero;
+	return 0;
 }
 
 /*
@@ -125,6 +131,7 @@ struct rpc_auth null_auth = {
 	.crdestroy	= nul_destroy_cred,
 	.crmatch	= nul_match,
 	.crmarshal	= nul_marshal,
+	.crwrap_req	= rpcauth_wrap_req_encode,
 	.crrefresh	= nul_refresh,
 	.crvalidate	= nul_validate,
 };
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index fc8a591..1d5b7ed 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -99,37 +99,55 @@
  * Marshal credentials.
  * Maybe we should keep a cached credential for performance reasons.
  */
-static __be32 *
-unx_marshal(struct rpc_task *task, __be32 *p)
+static int
+unx_marshal(struct rpc_task *task, struct xdr_stream *xdr)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 	struct rpc_cred	*cred = task->tk_rqstp->rq_cred;
-	__be32		*base, *hold;
+	__be32		*p, *cred_len, *gidarr_len;
 	int		i;
 	struct group_info *gi = cred->cr_cred->group_info;
 
-	*p++ = htonl(RPC_AUTH_UNIX);
-	base = p++;
-	*p++ = htonl(jiffies/HZ);
-
-	/*
-	 * Copy the UTS nodename captured when the client was created.
-	 */
-	p = xdr_encode_array(p, clnt->cl_nodename, clnt->cl_nodelen);
-
-	*p++ = htonl((u32) from_kuid(&init_user_ns, cred->cr_cred->fsuid));
-	*p++ = htonl((u32) from_kgid(&init_user_ns, cred->cr_cred->fsgid));
-	hold = p++;
+	/* Credential */
+
+	p = xdr_reserve_space(xdr, 3 * sizeof(*p));
+	if (!p)
+		goto marshal_failed;
+	*p++ = rpc_auth_unix;
+	cred_len = p++;
+	*p++ = xdr_zero;	/* stamp */
+	if (xdr_stream_encode_opaque(xdr, clnt->cl_nodename,
+				     clnt->cl_nodelen) < 0)
+		goto marshal_failed;
+	p = xdr_reserve_space(xdr, 3 * sizeof(*p));
+	if (!p)
+		goto marshal_failed;
+	*p++ = cpu_to_be32(from_kuid(&init_user_ns, cred->cr_cred->fsuid));
+	*p++ = cpu_to_be32(from_kgid(&init_user_ns, cred->cr_cred->fsgid));
+
+	gidarr_len = p++;
 	if (gi)
 		for (i = 0; i < UNX_NGROUPS && i < gi->ngroups; i++)
-			*p++ = htonl((u32) from_kgid(&init_user_ns, gi->gid[i]));
-	*hold = htonl(p - hold - 1);		/* gid array length */
-	*base = htonl((p - base - 1) << 2);	/* cred length */
+			*p++ = cpu_to_be32(from_kgid(&init_user_ns,
+						     gi->gid[i]));
+	*gidarr_len = cpu_to_be32(p - gidarr_len - 1);
+	*cred_len = cpu_to_be32((p - cred_len - 1) << 2);
+	p = xdr_reserve_space(xdr, (p - gidarr_len - 1) << 2);
+	if (!p)
+		goto marshal_failed;
+
+	/* Verifier */
+
+	p = xdr_reserve_space(xdr, 2 * sizeof(*p));
+	if (!p)
+		goto marshal_failed;
+	*p++ = rpc_auth_null;
+	*p   = xdr_zero;
 
-	*p++ = htonl(RPC_AUTH_NULL);
-	*p++ = htonl(0);
+	return 0;
 
-	return p;
+marshal_failed:
+	return -EMSGSIZE;
 }
 
 /*
@@ -202,6 +220,7 @@ struct rpc_auth		unix_auth = {
 	.crdestroy	= unx_destroy_cred,
 	.crmatch	= unx_match,
 	.crmarshal	= unx_marshal,
+	.crwrap_req	= rpcauth_wrap_req_encode,
 	.crrefresh	= unx_refresh,
 	.crvalidate	= unx_validate,
 };
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c4203f6..83549c4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -77,7 +77,8 @@
 static void	call_connect(struct rpc_task *task);
 static void	call_connect_status(struct rpc_task *task);
 
-static __be32	*rpc_encode_header(struct rpc_task *task);
+static int	rpc_encode_header(struct rpc_task *task,
+				  struct xdr_stream *xdr);
 static __be32	*rpc_verify_header(struct rpc_task *task);
 static int	rpc_ping(struct rpc_clnt *clnt);
 
@@ -1728,10 +1729,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 rpc_xdr_encode(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
-	kxdreproc_t	encode;
-	__be32		*p;
-
-	dprint_status(task);
+	struct xdr_stream xdr;
 
 	xdr_buf_init(&req->rq_snd_buf,
 		     req->rq_buffer,
@@ -1740,18 +1738,13 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 		     req->rq_rbuffer,
 		     req->rq_rcvsize);
 
-	p = rpc_encode_header(task);
-	if (p == NULL)
+	req->rq_snd_buf.head[0].iov_len = 0;
+	xdr_init_encode(&xdr, &req->rq_snd_buf,
+			req->rq_snd_buf.head[0].iov_base, req);
+	if (rpc_encode_header(task, &xdr))
 		return;
 
-	encode = task->tk_msg.rpc_proc->p_encode;
-	if (encode == NULL)
-		return;
-
-	task->tk_status = rpcauth_wrap_req(task, encode, req, p,
-			task->tk_msg.rpc_argp);
-	if (task->tk_status == 0)
-		xprt_request_prepare(req);
+	task->tk_status = rpcauth_wrap_req(task, &xdr);
 }
 
 /*
@@ -1762,6 +1755,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 {
 	if (!rpc_task_need_encode(task))
 		goto out;
+	dprint_status(task);
 	/* Encode here so that rpcsec_gss can use correct sequence number. */
 	rpc_xdr_encode(task);
 	/* Did the encode result in an error condition? */
@@ -1779,6 +1773,8 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 			rpc_exit(task, task->tk_status);
 		}
 		return;
+	} else {
+		xprt_request_prepare(task->tk_rqstp);
 	}
 
 	/* Add task to reply queue before transmission to avoid races */
@@ -2322,25 +2318,33 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	}
 }
 
-static __be32 *
-rpc_encode_header(struct rpc_task *task)
+static int
+rpc_encode_header(struct rpc_task *task, struct xdr_stream *xdr)
 {
 	struct rpc_clnt *clnt = task->tk_client;
 	struct rpc_rqst	*req = task->tk_rqstp;
-	__be32		*p = req->rq_svec[0].iov_base;
-
-	/* FIXME: check buffer size? */
-
-	*p++ = req->rq_xid;		/* XID */
-	*p++ = htonl(RPC_CALL);		/* CALL */
-	*p++ = htonl(RPC_VERSION);	/* RPC version */
-	*p++ = htonl(clnt->cl_prog);	/* program number */
-	*p++ = htonl(clnt->cl_vers);	/* program version */
-	*p++ = htonl(task->tk_msg.rpc_proc->p_proc);	/* procedure */
-	p = rpcauth_marshcred(task, p);
-	if (p)
-		req->rq_slen = xdr_adjust_iovec(&req->rq_svec[0], p);
-	return p;
+	__be32 *p;
+	int error;
+
+	error = -EMSGSIZE;
+	p = xdr_reserve_space(xdr, RPC_CALLHDRSIZE << 2);
+	if (!p)
+		goto out_fail;
+	*p++ = req->rq_xid;
+	*p++ = rpc_call;
+	*p++ = rpc_version;
+	*p++ = cpu_to_be32(clnt->cl_prog);
+	*p++ = cpu_to_be32(clnt->cl_vers);
+	*p   = cpu_to_be32(task->tk_msg.rpc_proc->p_proc);
+
+	error = rpcauth_marshcred(task, xdr);
+	if (error < 0)
+		goto out_fail;
+	return 0;
+out_fail:
+	trace_rpc_bad_callhdr(task);
+	rpc_exit(task, error);
+	return error;
 }
 
 static __be32 *

