Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1FFBC282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 22:08:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 58D9921855
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 22:08:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TLtt+lqg"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726218AbfAYWIe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 17:08:34 -0500
Received: from mail-pl1-f196.google.com ([209.85.214.196]:38502 "EHLO
        mail-pl1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726362AbfAYWId (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 17:08:33 -0500
Received: by mail-pl1-f196.google.com with SMTP id e5so5160649plb.5
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2019 14:08:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=eDcjBfoFH77H/Yd3Lfj4enA12DblobVDgCTIAlysjus=;
        b=TLtt+lqgOGgFzwMvkn7+SGf5CNMyy4APxO3sUlatb1uy9vki2y5MyXIyYKk4V3lEcx
         1I26FXN3mpgmNCyfu245PCIGXM4hpMNtaDIrJH677Q36a0zENhTAY6o5GqIHEqtuCgKw
         uYWOxmXI4mT7vTVtRey03dRpxHBKQTZ5wABpVWkcvGHVsQKdx3LW20DyGO9bm7vtRJjw
         9QrW9G74ci0lolgVoJ2Y9QxElPJJS+r9pfvs9JPvV3tNG/FXynPGRGRH72ILoss7pMvR
         rOIrxgePwtLpnMgC28tMg3gwhLYcaFl4h8U4rZkSkrYKKAQYUjYq2Ogn2DontHeeu/qR
         l3vg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=eDcjBfoFH77H/Yd3Lfj4enA12DblobVDgCTIAlysjus=;
        b=CC1tBlugvOY0qY+pVrMATbrKHl64fgdpnWIQVokJ0CK2skVvGshSsBNM/H003qSMyZ
         b2HSpZTqWcmHizJTQiBPjv4KpIYfbxBE28T9dG7JiPoNuZnVPUvJj/9HvNfqic6ic4QF
         BGUtKH07w+DPuYctP2x+7mryvVmR/LFZBdJfBziWJImh/4PcetKOkuDSATaQIlrtLsni
         o/cnEG8MuDFrrbuLJLBOT4JCAUWTBlTJZQ175+qtMGDyNp6guRFI+v17v0FHVXl8L1Vo
         fkiVRJk/wJwu+PE77GHKjO21qXZpY1TAYQ8wPfQ4HdXtg9FbNeLxGK5Xr6xtmHeHMQvj
         UD5Q==
X-Gm-Message-State: AJcUuke2aSSxO/U621VSl5TRU5leUY/aTl/dkEQY1MIl6hUEu90+YLJi
        2hl3eo9L2FvWac+d/DWjPToMCcz2
X-Google-Smtp-Source: ALg8bN6uU5IKBDZWcSl2OOtmJP3zQ0Dx5fldqY2RPxI7h4L2eblw4An75Hb7SrohTFwIuOII9rwnuA==
X-Received: by 2002:a17:902:8541:: with SMTP id d1mr12934783plo.205.1548454112699;
        Fri, 25 Jan 2019 14:08:32 -0800 (PST)
Received: from seurat.1015granger.net ([148.87.23.44])
        by smtp.gmail.com with ESMTPSA id f67sm41884654pff.29.2019.01.25.14.08.31
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 14:08:32 -0800 (PST)
Subject: [PATCH RFC 1/5] SUNRPC: Add xdr_stream::rqst field
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Fri, 25 Jan 2019 17:08:11 -0500
Message-ID: <154845407139.70638.10715577662014117251.stgit@seurat.1015granger.net>
In-Reply-To: <154845390550.70638.13083502621745566898.stgit@seurat.1015granger.net>
References: <154845390550.70638.13083502621745566898.stgit@seurat.1015granger.net>
User-Agent: StGit/unknown-version
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
index a87a56273407..bc7c1766a2be 100644
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
index 63abe705f4ca..32701b6a9566 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2036,7 +2036,7 @@ ff_layout_encode_layoutreturn(struct xdr_stream *xdr,
 
 	dprintk("%s: Begin\n", __func__);
 
-	xdr_init_encode(&tmp_xdr, &tmp_buf, NULL);
+	xdr_init_encode(&tmp_xdr, &tmp_buf, NULL, NULL);
 
 	ff_layout_encode_ioerr(&tmp_xdr, args, ff_args);
 	ff_layout_encode_iostats_array(&tmp_xdr, args, ff_args);
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 2ec128060239..787939d13643 100644
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
@@ -235,7 +238,8 @@ extern int xdr_restrict_buflen(struct xdr_stream *xdr, int newbuflen);
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
index f3023bbc0b7f..8dfab6119e6a 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -798,7 +798,7 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 {
 	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, data);
+	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, data, rqstp);
 	encode(rqstp, &xdr, obj);
 }
 
@@ -823,7 +823,7 @@ rpcauth_unwrap_req_decode(kxdrdproc_t decode, struct rpc_rqst *rqstp,
 {
 	struct xdr_stream xdr;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, data);
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, data, rqstp);
 	return decode(rqstp, &xdr, obj);
 }
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 1531b0219344..a42672e81792 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1722,7 +1722,7 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 {
 	struct xdr_stream xdr;
 
-	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, p);
+	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, p, rqstp);
 	encode(rqstp, &xdr, obj);
 }
 
@@ -1998,7 +1998,7 @@ gss_unwrap_req_decode(kxdrdproc_t decode, struct rpc_rqst *rqstp,
 {
 	struct xdr_stream xdr;
 
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p, rqstp);
 	return decode(rqstp, &xdr, obj);
 }
 
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index f302c6eb8779..345f08b634ee 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -483,6 +483,7 @@ EXPORT_SYMBOL_GPL(xdr_stream_pos);
  * @xdr: pointer to xdr_stream struct
  * @buf: pointer to XDR buffer in which to encode data
  * @p: current pointer inside XDR buffer
+ * @rqst: pointer to controlling rpc_rqst, for debugging
  *
  * Note: at the moment the RPC client only passes the length of our
  *	 scratch buffer in the xdr_buf's header kvec. Previously this
@@ -491,7 +492,8 @@ EXPORT_SYMBOL_GPL(xdr_stream_pos);
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
index 0de9b3e63770..98c1e43eb7b1 100644
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
index 7774aee7c013..6c1fb270f127 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -748,7 +748,7 @@ rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst)
 
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

