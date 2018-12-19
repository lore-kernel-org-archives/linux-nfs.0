Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF1D5C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 86F3E217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NAEJqS4C"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728726AbeLSQAJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 11:00:09 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:50835 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726652AbeLSQAI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 11:00:08 -0500
Received: by mail-it1-f194.google.com with SMTP id z7so10405012iti.0;
        Wed, 19 Dec 2018 08:00:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=zTVAECQNkrqbJM2MfZaEh7QPrxOcciLsx5hGleKHDGo=;
        b=NAEJqS4CG0MY7cc8EHG68hvvXl348nKRFQKkRyXtpp4VzpSWpp2wjphFmZ/jxuLcqA
         m5NdP5/+trBMbrlNkjWWiZ2cCUVw510TpZDenB/9VnnEblmVKwLTOumjRkv70u1m2jOx
         /XAsxICGp6FPAssbMmQqzVwNL9BxSDxcAV1H68GHQKOBAwEDRSPcsGtm2/rhuuKEP5C/
         7U8NviFKQiTK1DQ/rVtsHOKfzf3WWkyLiD/0YIzKNneNdOEO5H/BooWRRoWyTYaUasgL
         v351Eh5ot7ZFVGjs7QYs8g+9XhjiyAZXuOIkhX7KOjbRdxjdS184BBpUoe3rTZyn+3Ed
         xDhg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=zTVAECQNkrqbJM2MfZaEh7QPrxOcciLsx5hGleKHDGo=;
        b=mEmFKlIM8lgiNI3eaXav4PrRRX1xZeOczIq4rW5+6S6yWdelC8D1eT8h2uwF+VH2nX
         MlJvS6caB3t7aJ0hA+TEmyqe4oMZ9Zr1Z9Jem37Ku5IZUQkG0lXHXZfwX0H/tK0HwMWk
         rnvy8VDxQhZV5k0QjNRCVhXJTaF/Cl5VuYd+Zo4vIPydUV3L6D/CJX++yCsO6aX7ft9h
         fQUd++93CUDq+XDmvF5bhAzwDNnIX3n6/ubIu1ONwJRqN3j0+ecOG93nkEzi6qX3l2/p
         8KKXYpiqjKGe4LxBaU1NwKougbnd6RkVT8+UC+SRQYdkdK/63OR7WpB8yLotb7oTOuKx
         UtcA==
X-Gm-Message-State: AA+aEWYtlq80h+9ub5H6M0QJAqk+FLdt2VTT80bczrwO1H4NUWvtgpJ8
        aNVKKdvqvLHW8cjwypsAp+mNvwO0
X-Google-Smtp-Source: AFSGD/WaDhFep2sOtEbY3mem54ym9p/oSgh6ah2mBZxaXRl5RBlHccIOnso7n+eF1lyiaJDIH+d1Qg==
X-Received: by 2002:a24:7349:: with SMTP id y70mr6964286itb.48.1545235207428;
        Wed, 19 Dec 2018 08:00:07 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v74sm3962634ita.27.2018.12.19.08.00.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 08:00:06 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJG06bo025832;
        Wed, 19 Dec 2018 16:00:06 GMT
Subject: [PATCH v5 22/30] xprtrdma: Trace mapping, alloc, and dereg failures
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 11:00:06 -0500
Message-ID: <20181219160006.11602.94984.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

These are rare, but can be helpful at tracking down DMAR and other
problems.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |  136 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c |   12 +---
 net/sunrpc/xprtrdma/rpc_rdma.c |    2 -
 net/sunrpc/xprtrdma/verbs.c    |    4 +
 4 files changed, 144 insertions(+), 10 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 3d068bb..ce528d5 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -10,6 +10,7 @@
 #if !defined(_TRACE_RPCRDMA_H) || defined(TRACE_HEADER_MULTI_READ)
 #define _TRACE_RPCRDMA_H
 
+#include <linux/scatterlist.h>
 #include <linux/tracepoint.h>
 #include <trace/events/rdma.h>
 
@@ -663,12 +664,147 @@
 DEFINE_FRWR_DONE_EVENT(xprtrdma_wc_li);
 DEFINE_FRWR_DONE_EVENT(xprtrdma_wc_li_wake);
 
+TRACE_EVENT(xprtrdma_frwr_alloc,
+	TP_PROTO(
+		const struct rpcrdma_mr *mr,
+		int rc
+	),
+
+	TP_ARGS(mr, rc),
+
+	TP_STRUCT__entry(
+		__field(const void *, mr)
+		__field(int, rc)
+	),
+
+	TP_fast_assign(
+		__entry->mr = mr;
+		__entry->rc	= rc;
+	),
+
+	TP_printk("mr=%p: rc=%d",
+		__entry->mr, __entry->rc
+	)
+);
+
+TRACE_EVENT(xprtrdma_frwr_dereg,
+	TP_PROTO(
+		const struct rpcrdma_mr *mr,
+		int rc
+	),
+
+	TP_ARGS(mr, rc),
+
+	TP_STRUCT__entry(
+		__field(const void *, mr)
+		__field(u32, handle)
+		__field(u32, length)
+		__field(u64, offset)
+		__field(u32, dir)
+		__field(int, rc)
+	),
+
+	TP_fast_assign(
+		__entry->mr = mr;
+		__entry->handle = mr->mr_handle;
+		__entry->length = mr->mr_length;
+		__entry->offset = mr->mr_offset;
+		__entry->dir    = mr->mr_dir;
+		__entry->rc	= rc;
+	),
+
+	TP_printk("mr=%p %u@0x%016llx:0x%08x (%s): rc=%d",
+		__entry->mr, __entry->length,
+		(unsigned long long)__entry->offset, __entry->handle,
+		xprtrdma_show_direction(__entry->dir),
+		__entry->rc
+	)
+);
+
+TRACE_EVENT(xprtrdma_frwr_sgerr,
+	TP_PROTO(
+		const struct rpcrdma_mr *mr,
+		int sg_nents
+	),
+
+	TP_ARGS(mr, sg_nents),
+
+	TP_STRUCT__entry(
+		__field(const void *, mr)
+		__field(u64, addr)
+		__field(u32, dir)
+		__field(int, nents)
+	),
+
+	TP_fast_assign(
+		__entry->mr = mr;
+		__entry->addr = mr->mr_sg->dma_address;
+		__entry->dir = mr->mr_dir;
+		__entry->nents = sg_nents;
+	),
+
+	TP_printk("mr=%p dma addr=0x%llx (%s) sg_nents=%d",
+		__entry->mr, __entry->addr,
+		xprtrdma_show_direction(__entry->dir),
+		__entry->nents
+	)
+);
+
+TRACE_EVENT(xprtrdma_frwr_maperr,
+	TP_PROTO(
+		const struct rpcrdma_mr *mr,
+		int num_mapped
+	),
+
+	TP_ARGS(mr, num_mapped),
+
+	TP_STRUCT__entry(
+		__field(const void *, mr)
+		__field(u64, addr)
+		__field(u32, dir)
+		__field(int, num_mapped)
+		__field(int, nents)
+	),
+
+	TP_fast_assign(
+		__entry->mr = mr;
+		__entry->addr = mr->mr_sg->dma_address;
+		__entry->dir = mr->mr_dir;
+		__entry->num_mapped = num_mapped;
+		__entry->nents = mr->mr_nents;
+	),
+
+	TP_printk("mr=%p dma addr=0x%llx (%s) nents=%d of %d",
+		__entry->mr, __entry->addr,
+		xprtrdma_show_direction(__entry->dir),
+		__entry->num_mapped, __entry->nents
+	)
+);
+
 DEFINE_MR_EVENT(localinv);
 DEFINE_MR_EVENT(map);
 DEFINE_MR_EVENT(unmap);
 DEFINE_MR_EVENT(remoteinv);
 DEFINE_MR_EVENT(recycle);
 
+TRACE_EVENT(xprtrdma_dma_maperr,
+	TP_PROTO(
+		u64 addr
+	),
+
+	TP_ARGS(addr),
+
+	TP_STRUCT__entry(
+		__field(u64, addr)
+	),
+
+	TP_fast_assign(
+		__entry->addr = addr;
+	),
+
+	TP_printk("dma addr=0x%llx\n", __entry->addr)
+);
+
 /**
  ** Reply events
  **/
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 1f508f4..8a0f1a6 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -113,8 +113,7 @@ void frwr_release_mr(struct rpcrdma_mr *mr)
 
 	rc = ib_dereg_mr(mr->frwr.fr_mr);
 	if (rc)
-		pr_err("rpcrdma: final ib_dereg_mr for %p returned %i\n",
-		       mr, rc);
+		trace_xprtrdma_frwr_dereg(mr, rc);
 	kfree(mr->mr_sg);
 	kfree(mr);
 }
@@ -177,8 +176,7 @@ int frwr_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
 
 out_mr_err:
 	rc = PTR_ERR(frwr->fr_mr);
-	dprintk("RPC:       %s: ib_alloc_mr status %i\n",
-		__func__, rc);
+	trace_xprtrdma_frwr_alloc(mr, rc);
 	return rc;
 
 out_list_err:
@@ -465,15 +463,13 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 	return seg;
 
 out_dmamap_err:
-	pr_err("rpcrdma: failed to DMA map sg %p sg_nents %d\n",
-	       mr->mr_sg, i);
 	frwr->fr_state = FRWR_IS_INVALID;
+	trace_xprtrdma_frwr_sgerr(mr, i);
 	rpcrdma_mr_put(mr);
 	return ERR_PTR(-EIO);
 
 out_mapmr_err:
-	pr_err("rpcrdma: failed to map mr %p (%d/%d)\n",
-	       frwr->fr_mr, n, mr->mr_nents);
+	trace_xprtrdma_frwr_maperr(mr, n);
 	rpcrdma_mr_recycle(mr);
 	return ERR_PTR(-EIO);
 }
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 54fbd70..062aee9 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -665,7 +665,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 out_mapping_err:
 	rpcrdma_unmap_sendctx(sc);
-	pr_err("rpcrdma: Send mapping error\n");
+	trace_xprtrdma_dma_maperr(sge[sge_no].addr);
 	return false;
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 85c51b8..719b69c 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1392,8 +1392,10 @@ struct rpcrdma_regbuf *
 					    (void *)rb->rg_base,
 					    rdmab_length(rb),
 					    rb->rg_direction);
-	if (ib_dma_mapping_error(device, rdmab_addr(rb)))
+	if (ib_dma_mapping_error(device, rdmab_addr(rb))) {
+		trace_xprtrdma_dma_maperr(rdmab_addr(rb));
 		return false;
+	}
 
 	rb->rg_device = device;
 	rb->rg_iov.lkey = ia->ri_pd->local_dma_lkey;

