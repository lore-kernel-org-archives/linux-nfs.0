Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6883EC282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2101C218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bf2JfG6e"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728582AbfBKQYI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:24:08 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:37235 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726892AbfBKQYI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:24:08 -0500
Received: by mail-it1-f194.google.com with SMTP id b5so27658076iti.2;
        Mon, 11 Feb 2019 08:24:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=fZgPyRvc1j9/SPsWBAybDr2QEQjEDRd2JnXVF0YsEyQ=;
        b=bf2JfG6eeq19bcl3ckrobin89RclydT/d0rWXmPQqhdtdpEuLaxk7pbknvDL7yNuOm
         bvRXcR6M36yUyIsFCoRC16CRIXRG/+DLYPJXtxwXLMXynFuuSTuATZPwc9NAFBQCr8nI
         zmsocqNFHhBUULw/Fvehnt/wQGkKba1v9/i2XGVkX12WvNPn9KDiSy0sgGxM972vqTi7
         5Vs1kMLb5Wq2k54Ay/21lThNbME/hdrOcPO+r7VpEf8hCRWE8zkWxzJS67ttC+kj9+DN
         wQRDeKQCmdXSgpXvBSeaOMA1mG17CPCWPa5XkhwzR8gcb4wL5dzl1nch4NB6FpGc4LtT
         DWGA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=fZgPyRvc1j9/SPsWBAybDr2QEQjEDRd2JnXVF0YsEyQ=;
        b=JaLICLvj3jDIPvdogfnVkUnbSyAJXO1CuhXpVMujYcmIdkCN9iE4toanixqCaCJYdK
         MQOMdYNhBfowm6TdV7NHC+qY3YqbmtVpNOYFUe48uBgoR5+fXZps6SpaO3FN2WgTlQ22
         fugmsfnr3uvdNRniRn/vETYNigwwnZS4E94mosv5U8X4P38NjtV0nqQUsW6KGWn7x7Di
         6E18D9Q6o4BAO1TYd0kmEf2pb7wK1PDFoiJppNKl9KARBeHMfyDYsdkWq3TYAfDBRO8C
         cQS9nw266GCWCtH3z740Yyx3O8qKHgZxlxyohYESEQyifRwQDd9kp9DrbzvpUfUnS+r8
         MpPw==
X-Gm-Message-State: AHQUAub3kbBJchC01RqEgzPjKgORbS8760OsHmh9X+mAdmgoj6AmfoLn
        z8qYoMAgpNOeV0LEg1Ma6yY=
X-Google-Smtp-Source: AHgI3IbG1WBU6OKFAv0F0c21+Y9BzuHmeV8hHSUr2UnBGm8YovURjaaQNKDAKL/JYEvey+HC1zeU5A==
X-Received: by 2002:a02:9b31:: with SMTP id o46mr15970237jak.93.1549902246940;
        Mon, 11 Feb 2019 08:24:06 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id g10sm4982759ioa.67.2019.02.11.08.24.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:06 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGO5sj029967;
        Mon, 11 Feb 2019 16:24:05 GMT
Subject: [PATCH v1 05/23] SUNRPC: Add xdr_stream::rqst field
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:24:05 -0500
Message-ID: <20190211162405.2817.31052.stgit@manet.1015granger.net>
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

Having access to the controlling rpc_rqst means a trace point in the
XDR code can report:

 - the XID
 - the task ID and client ID
 - the p_name of RPC being processed

Subsequent patches will introduce such trace points.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/callback_xdr.c                  |    5 +++--
 fs/nfs/flexfilelayout/flexfilelayout.c |    2 +-
 include/linux/sunrpc/xdr.h             |    8 ++++++--
 net/sunrpc/auth.c                      |    4 ++--
 net/sunrpc/auth_gss/auth_gss.c         |    4 ++--
 net/sunrpc/xdr.c                       |   12 +++++++++---
 net/sunrpc/xprtrdma/backchannel.c      |    2 +-
 net/sunrpc/xprtrdma/rpc_rdma.c         |    4 ++--
 8 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index a87a562..bc7c176 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -943,10 +943,11 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp)
 	};
 	unsigned int nops = 0;
 
-	xdr_init_decode(&xdr_in, &rqstp->rq_arg, rqstp->rq_arg.head[0].iov_base);
+	xdr_init_decode(&xdr_in, &rqstp->rq_arg,
+			rqstp->rq_arg.head[0].iov_base, NULL);
 
 	p = (__be32*)((char *)rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len);
-	xdr_init_encode(&xdr_out, &rqstp->rq_res, p);
+	xdr_init_encode(&xdr_out, &rqstp->rq_res, p, NULL);
 
 	status = decode_compound_hdr_arg(&xdr_in, &hdr_arg);
 	if (status == htonl(NFS4ERR_RESOURCE))
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 63abe70..32701b6 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2036,7 +2036,7 @@ static void ff_layout_encode_iostats_array(struct xdr_stream *xdr,
 
 	dprintk("%s: Begin\n", __func__);
 
-	xdr_init_encode(&tmp_xdr, &tmp_buf, NULL);
+	xdr_init_encode(&tmp_xdr, &tmp_buf, NULL, NULL);
 
 	ff_layout_encode_ioerr(&tmp_xdr, args, ff_args);
 	ff_layout_encode_iostats_array(&tmp_xdr, args, ff_args);
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 2ec1280..787939d 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -217,6 +217,8 @@ struct xdr_stream {
 	struct kvec scratch;	/* Scratch buffer */
 	struct page **page_ptr;	/* pointer to the current page */
 	unsigned int nwords;	/* Remaining decode buffer length */
+
+	struct rpc_rqst *rqst;	/* For debugging */
 };
 
 /*
@@ -227,7 +229,8 @@ typedef void	(*kxdreproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 typedef int	(*kxdrdproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 		void *obj);
 
-extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
+extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf,
+			    __be32 *p, struct rpc_rqst *rqst);
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
 extern void xdr_commit_encode(struct xdr_stream *xdr);
 extern void xdr_truncate_encode(struct xdr_stream *xdr, size_t len);
@@ -235,7 +238,8 @@ typedef int	(*kxdrdproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
 		unsigned int base, unsigned int len);
 extern unsigned int xdr_stream_pos(const struct xdr_stream *xdr);
-extern void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
+extern void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf,
+			    __be32 *p, struct rpc_rqst *rqst);
 extern void xdr_init_decode_pages(struct xdr_stream *xdr, struct xdr_buf *buf,
 		struct page **pages, unsigned int len);
 extern void xdr_set_scratch_buffer(struct xdr_stream *xdr, void *buf, size_t buflen);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index f3023bb..8dfab61 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -798,7 +798,7 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 {
 	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, data);
+	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, data, rqstp);
 	encode(rqstp, &xdr, obj);
 }
 
@@ -823,7 +823,7 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 {
 	struct xdr_stream xdr;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, data);
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, data, rqstp);
 	return decode(rqstp, &xdr, obj);
 }
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 1531b02..a42672e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1722,7 +1722,7 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 {
 	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, p);
+	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, p, rqstp);
 	encode(rqstp, &xdr, obj);
 }
 
@@ -1998,7 +1998,7 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 {
 	struct xdr_stream xdr;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p, rqstp);
 	return decode(rqstp, &xdr, obj);
 }
 
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index f302c6e..345f08b 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -483,6 +483,7 @@ unsigned int xdr_stream_pos(const struct xdr_stream *xdr)
  * @xdr: pointer to xdr_stream struct
  * @buf: pointer to XDR buffer in which to encode data
  * @p: current pointer inside XDR buffer
+ * @rqst: pointer to controlling rpc_rqst, for debugging
  *
  * Note: at the moment the RPC client only passes the length of our
  *	 scratch buffer in the xdr_buf's header kvec. Previously this
@@ -491,7 +492,8 @@ unsigned int xdr_stream_pos(const struct xdr_stream *xdr)
  *	 of the buffer length, and takes care of adjusting the kvec
  *	 length for us.
  */
-void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
+void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p,
+		     struct rpc_rqst *rqst)
 {
 	struct kvec *iov = buf->head;
 	int scratch_len = buf->buflen - buf->page_len - buf->tail[0].iov_len;
@@ -513,6 +515,7 @@ void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 		buf->len += len;
 		iov->iov_len += len;
 	}
+	xdr->rqst = rqst;
 }
 EXPORT_SYMBOL_GPL(xdr_init_encode);
 
@@ -819,8 +822,10 @@ static bool xdr_set_next_buffer(struct xdr_stream *xdr)
  * @xdr: pointer to xdr_stream struct
  * @buf: pointer to XDR buffer from which to decode data
  * @p: current pointer inside XDR buffer
+ * @rqst: pointer to controlling rpc_rqst, for debugging
  */
-void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
+void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p,
+		     struct rpc_rqst *rqst)
 {
 	xdr->buf = buf;
 	xdr->scratch.iov_base = NULL;
@@ -836,6 +841,7 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 		xdr->nwords -= p - xdr->p;
 		xdr->p = p;
 	}
+	xdr->rqst = rqst;
 }
 EXPORT_SYMBOL_GPL(xdr_init_decode);
 
@@ -854,7 +860,7 @@ void xdr_init_decode_pages(struct xdr_stream *xdr, struct xdr_buf *buf,
 	buf->page_len =  len;
 	buf->buflen =  len;
 	buf->len = len;
-	xdr_init_decode(xdr, buf, NULL);
+	xdr_init_decode(xdr, buf, NULL, NULL);
 }
 EXPORT_SYMBOL_GPL(xdr_init_decode_pages);
 
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 0de9b3e..98c1e43 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -123,7 +123,7 @@ static int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 
 	rpcrdma_set_xdrlen(&req->rl_hdrbuf, 0);
 	xdr_init_encode(&req->rl_stream, &req->rl_hdrbuf,
-			req->rl_rdmabuf->rg_base);
+			req->rl_rdmabuf->rg_base, rqst);
 
 	p = xdr_reserve_space(&req->rl_stream, 28);
 	if (unlikely(!p))
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 7774aee..6c1fb27 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -748,7 +748,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	rpcrdma_set_xdrlen(&req->rl_hdrbuf, 0);
 	xdr_init_encode(xdr, &req->rl_hdrbuf,
-			req->rl_rdmabuf->rg_base);
+			req->rl_rdmabuf->rg_base, rqst);
 
 	/* Fixed header fields */
 	ret = -EMSGSIZE;
@@ -1329,7 +1329,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 
 	/* Fixed transport header fields */
 	xdr_init_decode(&rep->rr_stream, &rep->rr_hdrbuf,
-			rep->rr_hdrbuf.head[0].iov_base);
+			rep->rr_hdrbuf.head[0].iov_base, NULL);
 	p = xdr_inline_decode(&rep->rr_stream, 4 * sizeof(*p));
 	if (unlikely(!p))
 		goto out_shortreply;

