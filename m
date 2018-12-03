Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC66DC04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 21:57:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6463520850
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 21:57:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GoEMw2mS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6463520850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725873AbeLCV54 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 16:57:56 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:37055 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725800AbeLCV54 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 16:57:56 -0500
Received: by mail-it1-f195.google.com with SMTP id b5so11135065iti.2;
        Mon, 03 Dec 2018 13:57:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=lDqP1Ip5qcTjHPqygXcvs/+TGuV6f8PRn+PjImc80xw=;
        b=GoEMw2mSvx5Zv3XjQW3ef7GR0FYVGbedi4gQMb3gX+nMgAhlLpF8YKFL4wrcBbaqm6
         zhglmI7xeAg4pKpCiz2tKFm3P/Phqs+rSuKniFieQfQisgYXRs1juSC6IP0Qb5v8gmLB
         jVcTNrxl1TPk0VtJFn/EoshBBW+2E9R82fhH72E/KEyqLMsIhki8bwTeWL9/x3qpHJSz
         02lIc5TQOAqPLZnBF9M+Gi2O8bRiTqjZYO+mOH6Dg1TLkoTp39P4kzICZTklIALtd+mY
         53uI3Pw1cqKHcdmob3awGy6DEN2FisqTVZYkG6QlleWOYgQmvOfbFRfhsFRI52aHBVvt
         MRUg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=lDqP1Ip5qcTjHPqygXcvs/+TGuV6f8PRn+PjImc80xw=;
        b=nDzMMp4lDNIqDKRnT6h+w5WqPfAXmdzxYIVBqrx7G/QfOlUXzPhULY7ZgLMa9tZuQQ
         E/S9Edj6dHtDf9OjedKNUoBM7+k5aevbkK96qzvVEdNN36dAl8mDV5bqEP95U8Hi/V0M
         NUbaH1FaJd9A/ENCTK9HGVnICdfhrkudf4bS5aqiUo4jM2HtkYsQEf/Qs8JD8ZzrGBsG
         TUXzDd/w0AejxwFk873OWy46nB3+rO+Qdprt8h0mlLC6um+rKCWkARThNPi7btvXUYdv
         GbMKoIbYy2ogYVgTr/HEhRwY0l2Abp3sU/twdA1eEBHeagxdBm/dOy6RiI00bRcQh9cB
         Pg8g==
X-Gm-Message-State: AA+aEWY3kQ97BzjCoA6Y2RAxTBM3roNTVUt3BcQCp1AnRypCt0UWcbBx
        bEyK55r41QOZLLPNxvXRT6lyph7r
X-Google-Smtp-Source: AFSGD/WHbm2Jz66d3muawawknWnNAaVSZhZJxrsfKp/PEIb4AtqWWGU2cvuObijcJ24kaBI9hEbffg==
X-Received: by 2002:a02:b719:: with SMTP id g25mr15446411jam.46.1543874274724;
        Mon, 03 Dec 2018 13:57:54 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id y10sm3164703iom.64.2018.12.03.13.57.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 13:57:53 -0800 (PST)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wB3Lvqfn011879;
        Mon, 3 Dec 2018 21:57:52 GMT
Subject: [PATCH v2] svcrdma: Optimize the logic that selects the R_key to
 invalidate
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 03 Dec 2018 16:57:52 -0500
Message-ID: <20181203215547.2153.92661.stgit@klimt.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Make two minor optimizations:

o Select the R_key to invalidate while the CPU cache still contains
  the received RPC Call transport header, rather than waiting until
  we're about to send the RPC Reply.

o Choose Send With Invalidate if there is exactly one distinct R_key
  in the received transport header.

The reason for the second change:

Remote invalidation can invalidate only a single R_key. If the RPC
has multiple R_keys, the Receive completion will wait for the
remote invalidation, and then the RPC completion will wait for the
local invalidations. Waiting twice takes longer.

This change improves the throughput of large I/Os by a few percent,
and has no effect on smaller I/Os.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Posting one more time for review.

Changes since v1:
- Patch description updates suggested by ttalpey@microsoft.com
- Continuous testing on 4.20-rc4 and -rc5


 include/linux/sunrpc/svc_rdma.h         |    1 
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   63 +++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c   |   53 ++++++--------------------
 3 files changed, 77 insertions(+), 40 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index e6e2691..7e22681 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -135,6 +135,7 @@ struct svc_rdma_recv_ctxt {
 	u32			rc_byte_len;
 	unsigned int		rc_page_count;
 	unsigned int		rc_hdr_count;
+	u32			rc_inv_rkey;
 	struct page		*rc_pages[RPCSVC_MAXPAGES];
 };
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index b24d5b8..828b149 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -485,6 +485,68 @@ static __be32 *xdr_check_reply_chunk(__be32 *p, const __be32 *end)
 	return p;
 }
 
+/* RPC-over-RDMA Version One private extension: Remote Invalidation.
+ * Responder's choice: requester signals it can handle Send With
+ * Invalidate, and responder chooses one R_key to invalidate.
+ *
+ * If there is exactly one distinct R_key in the received transport
+ * header, set rc_inv_rkey to that R_key. Otherwise, set it to zero.
+ *
+ * Perform this operation while the received transport header is
+ * still in the CPU cache.
+ */
+static void svc_rdma_get_inv_rkey(struct svcxprt_rdma *rdma,
+				  struct svc_rdma_recv_ctxt *ctxt)
+{
+	__be32 inv_rkey, *p;
+	u32 i, segcount;
+
+	ctxt->rc_inv_rkey = 0;
+
+	if (!rdma->sc_snd_w_inv)
+		return;
+
+	inv_rkey = xdr_zero;
+	p = ctxt->rc_recv_buf;
+	p += rpcrdma_fixed_maxsz;
+
+	/* Read list */
+	while (*p++ != xdr_zero) {
+		p++;	/* position */
+		if (inv_rkey == xdr_zero)
+			inv_rkey = *p;
+		else if (inv_rkey != *p)
+			return;
+		p += 4;
+	}
+
+	/* Write list */
+	while (*p++ != xdr_zero) {
+		segcount = be32_to_cpup(p++);
+		for (i = 0; i < segcount; i++) {
+			if (inv_rkey == xdr_zero)
+				inv_rkey = *p;
+			else if (inv_rkey != *p)
+				return;
+			p += 4;
+		}
+	}
+
+	/* Reply chunk */
+	if (*p++ != xdr_zero) {
+		segcount = be32_to_cpup(p++);
+		for (i = 0; i < segcount; i++) {
+			if (inv_rkey == xdr_zero)
+				inv_rkey = *p;
+			else if (inv_rkey != *p)
+				return;
+			p += 4;
+		}
+	}
+
+	ctxt->rc_inv_rkey = be32_to_cpu(inv_rkey);
+}
+
 /* On entry, xdr->head[0].iov_base points to first byte in the
  * RPC-over-RDMA header.
  *
@@ -746,6 +808,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		svc_rdma_recv_ctxt_put(rdma_xprt, ctxt);
 		return ret;
 	}
+	svc_rdma_get_inv_rkey(rdma_xprt, ctxt);
 
 	p += rpcrdma_fixed_maxsz;
 	if (*p != xdr_zero)
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 8602a5f..d48bc6d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -484,32 +484,6 @@ static void svc_rdma_get_write_arrays(__be32 *rdma_argp,
 		*reply = NULL;
 }
 
-/* RPC-over-RDMA Version One private extension: Remote Invalidation.
- * Responder's choice: requester signals it can handle Send With
- * Invalidate, and responder chooses one rkey to invalidate.
- *
- * Find a candidate rkey to invalidate when sending a reply.  Picks the
- * first R_key it finds in the chunk lists.
- *
- * Returns zero if RPC's chunk lists are empty.
- */
-static u32 svc_rdma_get_inv_rkey(__be32 *rdma_argp,
-				 __be32 *wr_lst, __be32 *rp_ch)
-{
-	__be32 *p;
-
-	p = rdma_argp + rpcrdma_fixed_maxsz;
-	if (*p != xdr_zero)
-		p += 2;
-	else if (wr_lst && be32_to_cpup(wr_lst + 1))
-		p = wr_lst + 2;
-	else if (rp_ch && be32_to_cpup(rp_ch + 1))
-		p = rp_ch + 2;
-	else
-		return 0;
-	return be32_to_cpup(p);
-}
-
 static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
 				 struct svc_rdma_send_ctxt *ctxt,
 				 struct page *page,
@@ -672,7 +646,7 @@ static void svc_rdma_save_io_pages(struct svc_rqst *rqstp,
  *
  * RDMA Send is the last step of transmitting an RPC reply. Pages
  * involved in the earlier RDMA Writes are here transferred out
- * of the rqstp and into the ctxt's page array. These pages are
+ * of the rqstp and into the sctxt's page array. These pages are
  * DMA unmapped by each Write completion, but the subsequent Send
  * completion finally releases these pages.
  *
@@ -680,32 +654,31 @@ static void svc_rdma_save_io_pages(struct svc_rqst *rqstp,
  * - The Reply's transport header will never be larger than a page.
  */
 static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
-				   struct svc_rdma_send_ctxt *ctxt,
-				   __be32 *rdma_argp,
+				   struct svc_rdma_send_ctxt *sctxt,
+				   struct svc_rdma_recv_ctxt *rctxt,
 				   struct svc_rqst *rqstp,
 				   __be32 *wr_lst, __be32 *rp_ch)
 {
 	int ret;
 
 	if (!rp_ch) {
-		ret = svc_rdma_map_reply_msg(rdma, ctxt,
+		ret = svc_rdma_map_reply_msg(rdma, sctxt,
 					     &rqstp->rq_res, wr_lst);
 		if (ret < 0)
 			return ret;
 	}
 
-	svc_rdma_save_io_pages(rqstp, ctxt);
+	svc_rdma_save_io_pages(rqstp, sctxt);
 
-	ctxt->sc_send_wr.opcode = IB_WR_SEND;
-	if (rdma->sc_snd_w_inv) {
-		ctxt->sc_send_wr.ex.invalidate_rkey =
-			svc_rdma_get_inv_rkey(rdma_argp, wr_lst, rp_ch);
-		if (ctxt->sc_send_wr.ex.invalidate_rkey)
-			ctxt->sc_send_wr.opcode = IB_WR_SEND_WITH_INV;
+	if (rctxt->rc_inv_rkey) {
+		sctxt->sc_send_wr.opcode = IB_WR_SEND_WITH_INV;
+		sctxt->sc_send_wr.ex.invalidate_rkey = rctxt->rc_inv_rkey;
+	} else {
+		sctxt->sc_send_wr.opcode = IB_WR_SEND;
 	}
 	dprintk("svcrdma: posting Send WR with %u sge(s)\n",
-		ctxt->sc_send_wr.num_sge);
-	return svc_rdma_send(rdma, &ctxt->sc_send_wr);
+		sctxt->sc_send_wr.num_sge);
+	return svc_rdma_send(rdma, &sctxt->sc_send_wr);
 }
 
 /* Given the client-provided Write and Reply chunks, the server was not
@@ -809,7 +782,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	}
 
 	svc_rdma_sync_reply_hdr(rdma, sctxt, svc_rdma_reply_hdr_len(rdma_resp));
-	ret = svc_rdma_send_reply_msg(rdma, sctxt, rdma_argp, rqstp,
+	ret = svc_rdma_send_reply_msg(rdma, sctxt, rctxt, rqstp,
 				      wr_lst, rp_ch);
 	if (ret < 0)
 		goto err1;

