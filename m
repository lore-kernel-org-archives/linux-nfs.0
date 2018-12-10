Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDB70C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 15:20:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 70365208E7
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 15:20:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QkEIf/Pc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70365208E7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727568AbeLJPUU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 10:20:20 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:38599 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727313AbeLJPUT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 10:20:19 -0500
Received: by mail-it1-f195.google.com with SMTP id h65so18679991ith.3;
        Mon, 10 Dec 2018 07:20:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=CwBuNErBIooY6Dzp0Z47ynEPqtf9/ABpNB+nDJdVvzA=;
        b=QkEIf/PcCfdtJl3D2xoaBY0DHEJ7b4Jb055pMAyVTblq6AQliWZMgj5clwFZLRbWvg
         iqnSp9a/VM/hEjbrcKe/noKJtgmW1VKuMrB9vkAWX3uSn5v/onvDuLZ0PY63cDE4rk1m
         5DC77rX9xDwbtDMjy5w8MDb2Ku1Q0CWHRv5GzY1RuEhnwdhXaKa+5IkNFlksN7PiohBK
         c3bbghtJxElJztT1vWJAMvxRLXAEoCSeDhbNQs4WYAjEbVK+A6hLBh+0am0l7FdLvbOB
         GEl2By3jMmJuLL4cgD3gnU/zkv1yRCXQ3QdgEHZUGsMvWjq3iDYByaRq37LITwC6CKSV
         12DA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=CwBuNErBIooY6Dzp0Z47ynEPqtf9/ABpNB+nDJdVvzA=;
        b=C5RG6/jtZB/hdsm7AOV/gCoi7Wodqa2My+eywq67GVjAb0xNUZeTZjEG2gueWEVCNi
         JXIAWF0zQA7XK9nMDuZ9hxKOr9vb3o0RRUmE77ZGUgIv3hzVejUF+lfOU1v6zxByg2YF
         uvRbo7kCguZMjPBwIXOKIkJrUnj9UXk+o66BR9gUiyrBqb1xt6LMbPSPINkH9OcfVXhF
         gt4ieOyf4Ob48VfUXNn6E9ls0fWFmvVmL2vWKGAFBkeHcDxF/Ce3dzNh8kqg0jakuYG8
         zMRy40FvZ1iOnsyjzd9WlaMgjoiT/Tczo91/ZIU4bel0FLDOEEo/QXXT30EwjnzeJBmd
         ACeA==
X-Gm-Message-State: AA+aEWaGolg97KW+xNw8lS53bfGPrIg0JO4NlK2IfJJSOWK/c+VHRFPm
        4M6a0+XBFHNxAig4reiVBVhoyvFn
X-Google-Smtp-Source: AFSGD/VdAmusOGypE1zRJEFMUYtu/5OX86Fe1Euj5mcbbpAYUr4mBQO7udgFR2KDxlwtl9K/4Awl/w==
X-Received: by 2002:a02:a990:: with SMTP id q16mr12172918jam.132.1544455218001;
        Mon, 10 Dec 2018 07:20:18 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id a5sm4235296ioq.74.2018.12.10.07.20.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 07:20:16 -0800 (PST)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAFKFqI030909;
        Mon, 10 Dec 2018 15:20:15 GMT
Subject: [PATCH v3] svcrdma: Optimize the logic that selects the R_key to
 invalidate
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 10:20:15 -0500
Message-ID: <20181210151901.14856.56296.stgit@klimt.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The RPC-over-RDMA version 1 remote invalidation extension requires
the server to select the R_key to invalidate. Make two minor
optimizations to the selection algorithm:

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

Hi Bruce-

This is ready for your for-next branch.

Changes since v2:
- Rebased on v4.20-rc6
- Further clarify the patch description


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

