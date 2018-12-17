Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F675C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 647662133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lQHo/D1H"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388311AbeLQQlW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:41:22 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:35468 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388223AbeLQQlW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:41:22 -0500
Received: by mail-it1-f195.google.com with SMTP id p197so20943325itp.0;
        Mon, 17 Dec 2018 08:41:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=mMDbUnOSo+R5e+BESpDss6CE0mI2T44DAW3eI1MfElE=;
        b=lQHo/D1HJaF6na26B/seOWYSW9bGAX208Ngm1MCXo1vUsMHI81uJkUE2rDWMGyDAzj
         IFJLFy76AG6QRTDy5yIhu5r/Z8x5EtpxjzwnD058YZxsQuC2LzDx09v60wvfsMVH68H7
         TKtj3bybJm8JE/bxc+dtRtLSJtiYNm0SEpkKMPsfzA/lPsKBMdWulBV2uigc/zOybWts
         B+92opa6Rs6Ah9oc05RhQf8AH/5fIeTpbbWq4javyhFKVs12NJtrRCrRevt3/WqXW4gi
         OI650TucKvuAhu8WgY7fXuvgZCg2GYu7zks+g7+Hbzz/MBrCFfN4jbMIcLK/G2zGWsB2
         se3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=mMDbUnOSo+R5e+BESpDss6CE0mI2T44DAW3eI1MfElE=;
        b=fZPYlL7GIqnu1hV5f+d6Lbk9EkqOTP+OAOvED7mhHHR1x3/Er0ZNXVdO9ooFXlfu0V
         6zHV/1o20qhuLU4VlWTEx4zlaLA+p1Www5vbBWKdCGz6v6PaQb47YcvSHGlB9+R28Cxj
         9PiZve/YFLB4/0i5CoUI/WTfC+JpGxPiQLbcPJ6rctxSlbj9a5Q23NfNOUTBT9ixDT6h
         Z7ThHZIrM4KavE/n0fKrRyeYXDE4/2wZmkGzJq8t5aimhaGYsCyLKSbRaj0VFK+ISYcG
         kRBAsX13EjM6dggJZwzsOKDUzNd/PJ7GhvKHR41bZAv9IeKWtIAK6H32EyX6fuDLIl7V
         IHBQ==
X-Gm-Message-State: AA+aEWbfK3uKkYtwQFgpTtEhgxx8CUTrHk+Uu8eTjivDMUXwkJP/mQPj
        1UwVKwuQ0Hqjnq2LTrEdSlt42Zyu
X-Google-Smtp-Source: AFSGD/Whui8Z4VVuXf2ieO0v7nF28ZPmzxsqM8eWqRpp+Sx8EUlq6DEJ7+K/hu/2RcvBGqbov27KDA==
X-Received: by 2002:a24:e44:: with SMTP id 65mr11386214ite.154.1545064880048;
        Mon, 17 Dec 2018 08:41:20 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u9sm5421111iol.77.2018.12.17.08.41.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:41:19 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGfIgw018645;
        Mon, 17 Dec 2018 16:41:18 GMT
Subject: [PATCH v4 22/30] xprtrdma: Trace mapping, alloc, and dereg failures
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:41:18 -0500
Message-ID: <20181217164118.24133.40400.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
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
index 64672d0..b46e2f9 100644
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

