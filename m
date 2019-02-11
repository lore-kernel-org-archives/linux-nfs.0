Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B4DFC169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:25:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ADBD0218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:25:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TAwJTZbo"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728011AbfBKQZC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:25:02 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:52137 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728413AbfBKQZC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:25:02 -0500
Received: by mail-it1-f196.google.com with SMTP id y184so21458317itc.1;
        Mon, 11 Feb 2019 08:25:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=7IzWGqmQdHI1sldYEoJdR/CsAgbBLHXvMO+4RjmzO24=;
        b=TAwJTZboK7raHjn4w44aKP4LJiCbHY8WX2DFMjlPTmx7Ky88azj0CsYngY6bhMu2pX
         o8ZMZRjsh23RHp9Nt0GPKG/jsgMAeIB75zlP/H457x+7NUoZj1YabwB48wtNlxlut6Lx
         Gg048MV9eWt4fAWEz4iXc/1SfifD3QJBFx4Et4ZV/4uloL0Swv2ktugS7u+sLGo3wqof
         oODa224tyf9kHs0FGtMst8JOIsv3myDVJN/YsHlrzWYWQ4PXKzt61U8i6Kzj8O1wdi52
         ytZADFZIqsVFcIf67VKl3X7KaoAt95aLpcLCLloqPX6Zo4vc2kzD/VYGI9h7TFVQEhoD
         ga7A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=7IzWGqmQdHI1sldYEoJdR/CsAgbBLHXvMO+4RjmzO24=;
        b=Wzj1Gc5FypzfvqYOTy+adJDfHNo76eo3wxk2OtePGIaO+OqNlxlSDb/xL2q9iwuIbH
         gizmxs+XbnnY7BumRtOpOhxT/b1yPFjkVMVwLV3ea6s90ERiKjiUZxbW01olxidlLojO
         bmV24+hwD9N7xSzlEINXxg0P5yw6mJAPY0phX+1lGdDQiqT0CFr45eqxdH5fzxyDxh4u
         AvXNdBR7YQrXD6vq1p/oXHt6w7LjPwAxohSu8DuXy6IcrMeBiXN3bJcYHYesY8PUGmv2
         GP+TP1qmYEuJvaxf+nQXs6xtfehkaiIVJnyVdqNWrxorfk0dIhFesaA7qViJGysAbFKj
         oeaA==
X-Gm-Message-State: AHQUAuYynUgrNq0jrWjm4lulfHBJYhBMo7DGY/+gPks5P3W6GGkRpAia
        ZaByoFDsptUPP8sRESTflIPxAQ0o
X-Google-Smtp-Source: AHgI3IauaFFnglQpjL35mFLeS72vUZoTZ0BVueZD3knPErknP/FBHlfCbHn6VQKgLbR1wHhs7rLJ0w==
X-Received: by 2002:a6b:3844:: with SMTP id f65mr20267147ioa.179.1549902300295;
        Mon, 11 Feb 2019 08:25:00 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id s10sm4693739ioc.21.2019.02.11.08.24.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:59 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGOw4C029997;
        Mon, 11 Feb 2019 16:24:58 GMT
Subject: [PATCH v1 15/23] SUNRPC: Use struct xdr_stream when decoding RPC
 Reply header
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:24:58 -0500
Message-ID: <20190211162458.2817.97616.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Modernize and harden the code path that parses an RPC Reply
message.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/auth.h    |   15 ++-
 include/linux/sunrpc/xdr.h     |    1 
 net/sunrpc/auth.c              |   63 ++++++++----
 net/sunrpc/auth_gss/auth_gss.c |  204 ++++++++++++++++++++++------------------
 net/sunrpc/auth_null.c         |   31 +++---
 net/sunrpc/auth_unix.c         |   42 +++++---
 net/sunrpc/clnt.c              |   88 +++++++++--------
 7 files changed, 243 insertions(+), 201 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 96e237f..c51e189 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -134,11 +134,12 @@ struct rpc_credops {
 	int			(*crmarshal)(struct rpc_task *task,
 					     struct xdr_stream *xdr);
 	int			(*crrefresh)(struct rpc_task *);
-	__be32 *		(*crvalidate)(struct rpc_task *, __be32 *);
+	int			(*crvalidate)(struct rpc_task *task,
+					      struct xdr_stream *xdr);
 	int			(*crwrap_req)(struct rpc_task *task,
 					      struct xdr_stream *xdr);
-	int			(*crunwrap_resp)(struct rpc_task *, kxdrdproc_t,
-						void *, __be32 *, void *);
+	int			(*crunwrap_resp)(struct rpc_task *task,
+						 struct xdr_stream *xdr);
 	int			(*crkey_timeout)(struct rpc_cred *);
 	char *			(*crstringify_acceptor)(struct rpc_cred *);
 	bool			(*crneed_reencode)(struct rpc_task *);
@@ -168,12 +169,16 @@ int			rpcauth_get_gssinfo(rpc_authflavor_t,
 void			put_rpccred(struct rpc_cred *);
 int			rpcauth_marshcred(struct rpc_task *task,
 					  struct xdr_stream *xdr);
-__be32 *		rpcauth_checkverf(struct rpc_task *, __be32 *);
+int			rpcauth_checkverf(struct rpc_task *task,
+					  struct xdr_stream *xdr);
 int			rpcauth_wrap_req_encode(struct rpc_task *task,
 						struct xdr_stream *xdr);
 int			rpcauth_wrap_req(struct rpc_task *task,
 					 struct xdr_stream *xdr);
-int			rpcauth_unwrap_resp(struct rpc_task *task, kxdrdproc_t decode, void *rqstp, __be32 *data, void *obj);
+int			rpcauth_unwrap_resp_decode(struct rpc_task *task,
+						   struct xdr_stream *xdr);
+int			rpcauth_unwrap_resp(struct rpc_task *task,
+					    struct xdr_stream *xdr);
 bool			rpcauth_xmit_need_reencode(struct rpc_task *task);
 int			rpcauth_refreshcred(struct rpc_task *);
 void			rpcauth_invalcred(struct rpc_task *);
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index c540419..65af6a2 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -89,6 +89,7 @@ struct xdr_buf {
 
 #define	rpc_auth_null	cpu_to_be32(RPC_AUTH_NULL)
 #define	rpc_auth_unix	cpu_to_be32(RPC_AUTH_UNIX)
+#define	rpc_auth_short	cpu_to_be32(RPC_AUTH_SHORT)
 #define	rpc_auth_gss	cpu_to_be32(RPC_AUTH_GSS)
 
 #define	rpc_call	cpu_to_be32(RPC_CALL)
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index add2135..e786102 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -17,6 +17,8 @@
 #include <linux/sunrpc/gss_api.h>
 #include <linux/spinlock.h>
 
+#include <trace/events/sunrpc.h>
+
 #define RPC_CREDCACHE_DEFAULT_HASHBITS	(4)
 struct rpc_cred_cache {
 	struct hlist_head	*hashtable;
@@ -773,14 +775,6 @@ int rpcauth_marshcred(struct rpc_task *task, struct xdr_stream *xdr)
 	return ops->crmarshal(task, xdr);
 }
 
-__be32 *
-rpcauth_checkverf(struct rpc_task *task, __be32 *p)
-{
-	struct rpc_cred	*cred = task->tk_rqstp->rq_cred;
-
-	return cred->cr_ops->crvalidate(task, p);
-}
-
 /**
  * rpcauth_wrap_req_encode - XDR encode the RPC procedure
  * @task: controlling RPC task
@@ -814,27 +808,52 @@ int rpcauth_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 	return ops->crwrap_req(task, xdr);
 }
 
-static int
-rpcauth_unwrap_req_decode(kxdrdproc_t decode, struct rpc_rqst *rqstp,
-			  __be32 *data, void *obj)
+/**
+ * rpcauth_checkverf - Validate verifier in RPC Reply header
+ * @task: controlling RPC task
+ * @xdr: xdr_stream containing RPC Reply header
+ *
+ * On success, @xdr is updated to point past the verifier and
+ * zero is returned. Otherwise, @xdr is in an undefined state
+ * and a negative errno is returned.
+ */
+int
+rpcauth_checkverf(struct rpc_task *task, struct xdr_stream *xdr)
 {
-	struct xdr_stream xdr;
+	const struct rpc_credops *ops = task->tk_rqstp->rq_cred->cr_ops;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, data, rqstp);
-	return decode(rqstp, &xdr, obj);
+	return ops->crvalidate(task, xdr);
 }
 
+/**
+ * rpcauth_unwrap_resp_decode - Invoke XDR decode function
+ * @task: controlling RPC task
+ * @xdr: stream where the Reply message resides
+ *
+ * Returns zero on success; otherwise a negative errno is returned.
+ */
 int
-rpcauth_unwrap_resp(struct rpc_task *task, kxdrdproc_t decode, void *rqstp,
-		__be32 *data, void *obj)
+rpcauth_unwrap_resp_decode(struct rpc_task *task, struct xdr_stream *xdr)
 {
-	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
+	kxdrdproc_t decode = task->tk_msg.rpc_proc->p_decode;
+
+	return decode(task->tk_rqstp, xdr, task->tk_msg.rpc_resp);
+}
+EXPORT_SYMBOL_GPL(rpcauth_unwrap_resp_decode);
+
+/**
+ * rpcauth_unwrap_resp - Invoke unwrap and decode function for the cred
+ * @task: controlling RPC task
+ * @xdr: stream where the Reply message resides
+ *
+ * Returns zero on success; otherwise a negative errno is returned.
+ */
+int
+rpcauth_unwrap_resp(struct rpc_task *task, struct xdr_stream *xdr)
+{
+	const struct rpc_credops *ops = task->tk_rqstp->rq_cred->cr_ops;
 
-	if (cred->cr_ops->crunwrap_resp)
-		return cred->cr_ops->crunwrap_resp(task, decode, rqstp,
-						   data, obj);
-	/* By default, we decode the arguments normally. */
-	return rpcauth_unwrap_req_decode(decode, rqstp, data, obj);
+	return ops->crunwrap_resp(task, xdr);
 }
 
 bool
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index b333b1b..206788e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1671,59 +1671,62 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
 	return 0;
 }
 
-static __be32 *
-gss_validate(struct rpc_task *task, __be32 *p)
+static int
+gss_validate(struct rpc_task *task, struct xdr_stream *xdr)
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
-	__be32		*seq = NULL;
+	__be32		*p, *seq = NULL;
 	struct kvec	iov;
 	struct xdr_buf	verf_buf;
 	struct xdr_netobj mic;
-	u32		flav,len;
-	u32		maj_stat;
-	__be32		*ret = ERR_PTR(-EIO);
+	u32		len, maj_stat;
+	int		status;
 
-	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
+	p = xdr_inline_decode(xdr, 2 * sizeof(*p));
+	if (!p)
+		goto validate_failed;
+	if (*p++ != rpc_auth_gss)
+		goto validate_failed;
+	len = be32_to_cpup(p);
+	if (len > RPC_MAX_AUTH_SIZE)
+		goto validate_failed;
+	p = xdr_inline_decode(xdr, len);
+	if (!p)
+		goto validate_failed;
 
-	flav = ntohl(*p++);
-	if ((len = ntohl(*p++)) > RPC_MAX_AUTH_SIZE)
-		goto out_bad;
-	if (flav != RPC_AUTH_GSS)
-		goto out_bad;
 	seq = kmalloc(4, GFP_NOFS);
 	if (!seq)
-		goto out_bad;
-	*seq = htonl(task->tk_rqstp->rq_seqno);
+		goto validate_failed;
+	*seq = cpu_to_be32(task->tk_rqstp->rq_seqno);
 	iov.iov_base = seq;
 	iov.iov_len = 4;
 	xdr_buf_from_iov(&iov, &verf_buf);
 	mic.data = (u8 *)p;
 	mic.len = len;
-
-	ret = ERR_PTR(-EACCES);
 	maj_stat = gss_verify_mic(ctx->gc_gss_ctx, &verf_buf, &mic);
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
-	if (maj_stat) {
-		dprintk("RPC: %5u %s: gss_verify_mic returned error 0x%08x\n",
-			task->tk_pid, __func__, maj_stat);
-		goto out_bad;
-	}
+	if (maj_stat)
+		goto bad_mic;
+
 	/* We leave it to unwrap to calculate au_rslack. For now we just
 	 * calculate the length of the verifier: */
 	cred->cr_auth->au_verfsize = XDR_QUADLEN(len) + 2;
+	status = 0;
+out:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %5u %s: gss_verify_mic succeeded.\n",
-			task->tk_pid, __func__);
-	kfree(seq);
-	return p + XDR_QUADLEN(len);
-out_bad:
-	gss_put_ctx(ctx);
-	dprintk("RPC: %5u %s failed ret %ld.\n", task->tk_pid, __func__,
-		PTR_ERR(ret));
 	kfree(seq);
-	return ret;
+	return status;
+
+validate_failed:
+	status = -EIO;
+	goto out;
+bad_mic:
+	dprintk("RPC: %5u %s: gss_verify_mic returned error 0x%08x\n",
+		task->tk_pid, __func__, maj_stat);
+	status = -EACCES;
+	goto out;
 }
 
 static int gss_wrap_req_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
@@ -1921,79 +1924,98 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 	return status;
 }
 
-static inline int
+static int
+gss_unwrap_resp_auth(struct rpc_cred *cred)
+{
+	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize;
+	return 0;
+}
+
+static int
 gss_unwrap_resp_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
-		struct rpc_rqst *rqstp, __be32 **p)
+		      struct rpc_rqst *rqstp, struct xdr_stream *xdr)
 {
-	struct xdr_buf	*rcv_buf = &rqstp->rq_rcv_buf;
-	struct xdr_buf integ_buf;
+	struct xdr_buf integ_buf, *rcv_buf = &rqstp->rq_rcv_buf;
+	u32 data_offset, mic_offset, integ_len, maj_stat;
 	struct xdr_netobj mic;
-	u32 data_offset, mic_offset;
-	u32 integ_len;
-	u32 maj_stat;
-	int status = -EIO;
+	__be32 *p;
 
-	integ_len = ntohl(*(*p)++);
+	p = xdr_inline_decode(xdr, 2 * sizeof(*p));
+	if (unlikely(!p))
+		goto unwrap_failed;
+	integ_len = be32_to_cpup(p++);
 	if (integ_len & 3)
-		return status;
-	data_offset = (u8 *)(*p) - (u8 *)rcv_buf->head[0].iov_base;
+		goto unwrap_failed;
+	data_offset = (u8 *)(p) - (u8 *)rcv_buf->head[0].iov_base;
 	mic_offset = integ_len + data_offset;
 	if (mic_offset > rcv_buf->len)
-		return status;
-	if (ntohl(*(*p)++) != rqstp->rq_seqno)
-		return status;
-
-	if (xdr_buf_subsegment(rcv_buf, &integ_buf, data_offset,
-				mic_offset - data_offset))
-		return status;
+		goto unwrap_failed;
+	if (be32_to_cpup(p) != rqstp->rq_seqno)
+		goto unwrap_failed;
 
+	if (xdr_buf_subsegment(rcv_buf, &integ_buf, data_offset, integ_len))
+		goto unwrap_failed;
 	if (xdr_buf_read_netobj(rcv_buf, &mic, mic_offset))
-		return status;
-
+		goto unwrap_failed;
 	maj_stat = gss_verify_mic(ctx->gc_gss_ctx, &integ_buf, &mic);
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	if (maj_stat != GSS_S_COMPLETE)
-		return status;
+		goto bad_mic;
+
+	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + 2 +
+				   1 + XDR_QUADLEN(mic.len);
 	return 0;
+unwrap_failed:
+	return -EIO;
+bad_mic:
+	dprintk("RPC:       %s: gss_verify_mic returned error 0x%08x\n",
+		__func__, maj_stat);
+	return -EIO;
 }
 
-static inline int
+static int
 gss_unwrap_resp_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
-		struct rpc_rqst *rqstp, __be32 **p)
-{
-	struct xdr_buf  *rcv_buf = &rqstp->rq_rcv_buf;
-	u32 offset;
-	u32 opaque_len;
-	u32 maj_stat;
-	int status = -EIO;
-
-	opaque_len = ntohl(*(*p)++);
-	offset = (u8 *)(*p) - (u8 *)rcv_buf->head[0].iov_base;
+		     struct rpc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct xdr_buf *rcv_buf = &rqstp->rq_rcv_buf;
+	struct kvec *head = rqstp->rq_rcv_buf.head;
+	unsigned int savedlen = rcv_buf->len;
+	u32 offset, opaque_len, maj_stat;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 2 * sizeof(*p));
+	if (unlikely(!p))
+		goto unwrap_failed;
+	opaque_len = be32_to_cpup(p++);
+	offset = (u8 *)(p) - (u8 *)head->iov_base;
 	if (offset + opaque_len > rcv_buf->len)
-		return status;
-	/* remove padding: */
+		goto unwrap_failed;
 	rcv_buf->len = offset + opaque_len;
 
 	maj_stat = gss_unwrap(ctx->gc_gss_ctx, offset, rcv_buf);
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	if (maj_stat != GSS_S_COMPLETE)
-		return status;
-	if (ntohl(*(*p)++) != rqstp->rq_seqno)
-		return status;
-
-	return 0;
-}
+		goto bad_unwrap;
+	/* gss_unwrap decrypted the sequence number */
+	if (be32_to_cpup(p++) != rqstp->rq_seqno)
+		goto unwrap_failed;
 
-static int
-gss_unwrap_req_decode(kxdrdproc_t decode, struct rpc_rqst *rqstp,
-		      __be32 *p, void *obj)
-{
-	struct xdr_stream xdr;
+	/* gss_unwrap redacts the opaque blob from the head iovec.
+	 * rcv_buf has changed, thus the stream needs to be reset.
+	 */
+	xdr_init_decode(xdr, rcv_buf, p, rqstp);
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p, rqstp);
-	return decode(rqstp, &xdr, obj);
+	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + 2 +
+				   XDR_QUADLEN(savedlen - rcv_buf->len);
+	return 0;
+unwrap_failed:
+	return -EIO;
+bad_unwrap:
+	dprintk("RPC:       %s: gss_unwrap returned error 0x%08x\n",
+		__func__, maj_stat);
+	return -EIO;
 }
 
 static bool
@@ -2037,39 +2059,33 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 }
 
 static int
-gss_unwrap_resp(struct rpc_task *task,
-		kxdrdproc_t decode, void *rqstp, __be32 *p, void *obj)
+gss_unwrap_resp(struct rpc_task *task, struct xdr_stream *xdr)
 {
-	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
+	struct rpc_rqst *rqstp = task->tk_rqstp;
+	struct rpc_cred *cred = rqstp->rq_cred;
 	struct gss_cred *gss_cred = container_of(cred, struct gss_cred,
 			gc_base);
 	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
-	__be32		*savedp = p;
-	struct kvec	*head = ((struct rpc_rqst *)rqstp)->rq_rcv_buf.head;
-	int		savedlen = head->iov_len;
-	int             status = -EIO;
+	int status = -EIO;
 
 	if (ctx->gc_proc != RPC_GSS_PROC_DATA)
 		goto out_decode;
 	switch (gss_cred->gc_service) {
 	case RPC_GSS_SVC_NONE:
+		status = gss_unwrap_resp_auth(cred);
 		break;
 	case RPC_GSS_SVC_INTEGRITY:
-		status = gss_unwrap_resp_integ(cred, ctx, rqstp, &p);
-		if (status)
-			goto out;
+		status = gss_unwrap_resp_integ(cred, ctx, rqstp, xdr);
 		break;
 	case RPC_GSS_SVC_PRIVACY:
-		status = gss_unwrap_resp_priv(cred, ctx, rqstp, &p);
-		if (status)
-			goto out;
+		status = gss_unwrap_resp_priv(cred, ctx, rqstp, xdr);
 		break;
 	}
-	/* take into account extra slack for integrity and privacy cases: */
-	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + (p - savedp)
-						+ (savedlen - head->iov_len);
+	if (status)
+		goto out;
+
 out_decode:
-	status = gss_unwrap_req_decode(decode, rqstp, p, obj);
+	status = rpcauth_unwrap_resp_decode(task, xdr);
 out:
 	gss_put_ctx(ctx);
 	dprintk("RPC: %5u %s returning %d\n",
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index 797f8472..bf96975 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -86,25 +86,19 @@
 	return 0;
 }
 
-static __be32 *
-nul_validate(struct rpc_task *task, __be32 *p)
+static int
+nul_validate(struct rpc_task *task, struct xdr_stream *xdr)
 {
-	rpc_authflavor_t	flavor;
-	u32			size;
-
-	flavor = ntohl(*p++);
-	if (flavor != RPC_AUTH_NULL) {
-		printk("RPC: bad verf flavor: %u\n", flavor);
-		return ERR_PTR(-EIO);
-	}
-
-	size = ntohl(*p++);
-	if (size != 0) {
-		printk("RPC: bad verf size: %u\n", size);
-		return ERR_PTR(-EIO);
-	}
-
-	return p;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 2 * sizeof(*p));
+	if (!p)
+		return -EIO;
+	if (*p++ != rpc_auth_null)
+		return -EIO;
+	if (*p != xdr_zero)
+		return -EIO;
+	return 0;
 }
 
 const struct rpc_authops authnull_ops = {
@@ -134,6 +128,7 @@ struct rpc_auth null_auth = {
 	.crwrap_req	= rpcauth_wrap_req_encode,
 	.crrefresh	= nul_refresh,
 	.crvalidate	= nul_validate,
+	.crunwrap_resp	= rpcauth_unwrap_resp_decode,
 };
 
 static
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 1d5b7ed..5ea84a9 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -160,29 +160,32 @@
 	return 0;
 }
 
-static __be32 *
-unx_validate(struct rpc_task *task, __be32 *p)
+static int
+unx_validate(struct rpc_task *task, struct xdr_stream *xdr)
 {
-	rpc_authflavor_t	flavor;
-	u32			size;
-
-	flavor = ntohl(*p++);
-	if (flavor != RPC_AUTH_NULL &&
-	    flavor != RPC_AUTH_UNIX &&
-	    flavor != RPC_AUTH_SHORT) {
-		printk("RPC: bad verf flavor: %u\n", flavor);
-		return ERR_PTR(-EIO);
-	}
+	__be32 *p;
+	u32 size;
 
-	size = ntohl(*p++);
-	if (size > RPC_MAX_AUTH_SIZE) {
-		printk("RPC: giant verf size: %u\n", size);
-		return ERR_PTR(-EIO);
+	p = xdr_inline_decode(xdr, 2 * sizeof(*p));
+	if (!p)
+		return -EIO;
+	switch (*p++) {
+	case rpc_auth_null:
+	case rpc_auth_unix:
+	case rpc_auth_short:
+		break;
+	default:
+		return -EIO;
 	}
-	task->tk_rqstp->rq_cred->cr_auth->au_rslack = (size >> 2) + 2;
-	p += (size >> 2);
+	size = be32_to_cpup(p);
+	if (size > RPC_MAX_AUTH_SIZE)
+		return -EIO;
+	p = xdr_inline_decode(xdr, size);
+	if (!p)
+		return -EIO;
 
-	return p;
+	task->tk_rqstp->rq_cred->cr_auth->au_rslack = (size >> 2) + 2;
+	return 0;
 }
 
 int __init rpc_init_authunix(void)
@@ -223,4 +226,5 @@ struct rpc_auth		unix_auth = {
 	.crwrap_req	= rpcauth_wrap_req_encode,
 	.crrefresh	= unx_refresh,
 	.crvalidate	= unx_validate,
+	.crunwrap_resp	= rpcauth_unwrap_resp_decode,
 };
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e973508..803e931 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -79,7 +79,8 @@
 
 static int	rpc_encode_header(struct rpc_task *task,
 				  struct xdr_stream *xdr);
-static __be32	*rpc_decode_header(struct rpc_task *task);
+static int	rpc_decode_header(struct rpc_task *task,
+				  struct xdr_stream *xdr);
 static int	rpc_ping(struct rpc_clnt *clnt);
 
 static void rpc_register_client(struct rpc_clnt *clnt)
@@ -2251,12 +2252,11 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 	struct rpc_rqst	*req = task->tk_rqstp;
-	kxdrdproc_t	decode = task->tk_msg.rpc_proc->p_decode;
-	__be32		*p;
+	struct xdr_stream xdr;
 
 	dprint_status(task);
 
-	if (!decode) {
+	if (!task->tk_msg.rpc_proc->p_decode) {
 		task->tk_action = rpc_exit_task;
 		return;
 	}
@@ -2292,29 +2292,27 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 		goto out_retry;
 	}
 
-	p = rpc_decode_header(task);
-	if (IS_ERR(p)) {
-		if (p == ERR_PTR(-EAGAIN))
-			goto out_retry;
+	xdr_init_decode(&xdr, &req->rq_rcv_buf,
+			req->rq_rcv_buf.head[0].iov_base, req);
+	switch (rpc_decode_header(task, &xdr)) {
+	case 0:
+		task->tk_action = rpc_exit_task;
+		task->tk_status = rpcauth_unwrap_resp(task, &xdr);
+		dprintk("RPC: %5u %s result %d\n",
+			task->tk_pid, __func__, task->tk_status);
 		return;
-	}
-	task->tk_action = rpc_exit_task;
-
-	task->tk_status = rpcauth_unwrap_resp(task, decode, req, p,
-					      task->tk_msg.rpc_resp);
-
-	dprintk("RPC: %5u call_decode result %d\n", task->tk_pid,
-			task->tk_status);
-	return;
+	case -EAGAIN:
 out_retry:
-	task->tk_status = 0;
-	/* Note: rpc_decode_header() may have freed the RPC slot */
-	if (task->tk_rqstp == req) {
-		xdr_free_bvec(&req->rq_rcv_buf);
-		req->rq_reply_bytes_recvd = req->rq_rcv_buf.len = 0;
-		if (task->tk_client->cl_discrtry)
-			xprt_conditional_disconnect(req->rq_xprt,
-					req->rq_connect_cookie);
+		task->tk_status = 0;
+		/* Note: rpc_decode_header() may have freed the RPC slot */
+		if (task->tk_rqstp == req) {
+			xdr_free_bvec(&req->rq_rcv_buf);
+			req->rq_reply_bytes_recvd = 0;
+			req->rq_rcv_buf.len = 0;
+			if (task->tk_client->cl_discrtry)
+				xprt_conditional_disconnect(req->rq_xprt,
+							    req->rq_connect_cookie);
+		}
 	}
 }
 
@@ -2347,14 +2345,12 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	return error;
 }
 
-static noinline __be32 *
-rpc_decode_header(struct rpc_task *task)
+static noinline int
+rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 {
 	struct rpc_clnt *clnt = task->tk_client;
-	struct kvec *iov = &task->tk_rqstp->rq_rcv_buf.head[0];
-	int len = task->tk_rqstp->rq_rcv_buf.len >> 2;
-	__be32	*p = iov->iov_base;
 	int error = -EACCES;
+	__be32 *p;
 
 	/* RFC-1014 says that the representation of XDR data must be a
 	 * multiple of four bytes
@@ -2363,25 +2359,26 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	 */
 	if (task->tk_rqstp->rq_rcv_buf.len & 3)
 		goto out_badlen;
-	if ((len -= 3) < 0)
-		goto out_unparsable;
 
+	p = xdr_inline_decode(xdr, 3 * sizeof(*p));
+	if (!p)
+		goto out_unparsable;
 	p++;	/* skip XID */
 	if (*p++ != rpc_reply)
 		goto out_unparsable;
 	if (*p++ != rpc_msg_accepted)
 		goto out_msg_denied;
 
-	p = rpcauth_checkverf(task, p);
-	if (IS_ERR(p))
+	error = rpcauth_checkverf(task, xdr);
+	if (error)
 		goto out_verifier;
 
-	len = p - (__be32 *)iov->iov_base - 1;
-	if (len < 0)
+	p = xdr_inline_decode(xdr, sizeof(*p));
+	if (!p)
 		goto out_unparsable;
-	switch (*p++) {
+	switch (*p) {
 	case rpc_success:
-		return p;
+		return 0;
 	case rpc_prog_unavail:
 		trace_rpc__prog_unavail(task);
 		error = -EPFNOSUPPORT;
@@ -2406,11 +2403,11 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	if (task->tk_garb_retry) {
 		task->tk_garb_retry--;
 		task->tk_action = call_encode;
-		return ERR_PTR(-EAGAIN);
+		return -EAGAIN;
 	}
 out_err:
 	rpc_exit(task, error);
-	return ERR_PTR(error);
+	return error;
 
 out_badlen:
 	trace_rpc__unparsable(task);
@@ -2424,10 +2421,12 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 
 out_verifier:
 	trace_rpc_bad_verifier(task);
-	error = PTR_ERR(p);
 	goto out_garbage;
 
 out_msg_denied:
+	p = xdr_inline_decode(xdr, sizeof(*p));
+	if (!p)
+		goto out_unparsable;
 	switch (*p++) {
 	case rpc_auth_error:
 		break;
@@ -2441,6 +2440,9 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 		goto out_err;
 	}
 
+	p = xdr_inline_decode(xdr, sizeof(*p));
+	if (!p)
+		goto out_unparsable;
 	switch (*p++) {
 	case rpc_autherr_rejectedcred:
 	case rpc_autherr_rejectedverf:
@@ -2454,7 +2456,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 		/* Ensure we obtain a new XID! */
 		xprt_release(task);
 		task->tk_action = call_reserve;
-		return ERR_PTR(-EAGAIN);
+		return -EAGAIN;
 	case rpc_autherr_badcred:
 	case rpc_autherr_badverf:
 		/* possibly garbled cred/verf? */
@@ -2463,7 +2465,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 		task->tk_garb_retry--;
 		trace_rpc__bad_creds(task);
 		task->tk_action = call_encode;
-		return ERR_PTR(-EAGAIN);
+		return -EAGAIN;
 	case rpc_autherr_tooweak:
 		trace_rpc__auth_tooweak(task);
 		pr_warn("RPC: server %s requires stronger authentication.\n",

