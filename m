Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF20FC5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 70D012086D
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tsQU8ER2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70D012086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727511AbeLJQbI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:31:08 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:46682 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727451AbeLJQbI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:31:08 -0500
Received: by mail-io1-f68.google.com with SMTP id v10so9190237ios.13;
        Mon, 10 Dec 2018 08:31:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=o1MlYIRFwPyp7DNS7RLx2cApmpxtnADbp+obdGkNuL8=;
        b=tsQU8ER2BLQA/AfP1g/PmsA3Bz6NtmwaFJeZnNpNpe80lKES2xSzG8AgvhRRWnmWoN
         zvXLpjifrPTUI+Sd/r4QjwJ1U1RT28wvQXwlcUHqpqBoa/gVEWFF+85w8x+SlBYnqYPj
         zUeF7j5IEaAD1/ommN9cR9ys98xGpWKJxdJ2Dp3IG/ddjUL60kQ1usekICs8ns9mHsed
         kiW08FQKBHox/qZtHSbRbHd/5ahK/Ld+vYvcR69SM0gTVDq1AmJXYQZ9dLRX+37ygXvt
         sEs+fKWiXxP5gnF2Z6QBLynnUsqPtMI8gOcSLQKIYdgwjiNuWLjF8qREUBA8/vt4YvgT
         0tlw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=o1MlYIRFwPyp7DNS7RLx2cApmpxtnADbp+obdGkNuL8=;
        b=eeyiZKcu4Zz6A3K55emjqPPW921RYYZIT08JWpkcQrxmoeta0Lhn7C/+B+gADQz8Fg
         HbrOzWNjiLXClWZpZn8GtVofjNrNnrDpbfWk7yM6gD44PAtrpJ2ViROgnv2d8P8U6EbS
         S0xRtfLX+nwKmC2xKV6Fi+FTrV5l7pjvUWbQOh2HdX1/Bwzxs+acUVSqS0vC85l4056P
         Rl/K4tehisMU3Fv3DiW9Sjihlrig4rBfBhquXhr8zzQ4+IGKN/kNnA2xppWAcBeqeo86
         gJzc7BbTOyd3s3ZvoHQoYlWBChCOL4ifhBnwdGIvm2wr5fGvf7rbhjHqzNVLr3/PbcFK
         0X+A==
X-Gm-Message-State: AA+aEWYp2ieiiMvaYoiG43CLZm1G+/yoXinQkrj3qZGP5UGGIlp+iqDh
        KXFRChM0R1RP5VtI/n41j4U=
X-Google-Smtp-Source: AFSGD/Un2YpQzLosqGy/469pHdDxqnb4XDwcpWNfwHooxNRgEHdM5VwOiGVfLXVtCei5VMf36KJing==
X-Received: by 2002:a6b:fc05:: with SMTP id r5mr10208584ioh.129.1544459467154;
        Mon, 10 Dec 2018 08:31:07 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id o18sm4349834ioh.31.2018.12.10.08.31.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:31:06 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGV5wO031083;
        Mon, 10 Dec 2018 16:31:05 GMT
Subject: [PATCH v3 20/24] xprtrdma: Trace mapping, alloc, and dereg failures
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:31:05 -0500
Message-ID: <20181210163105.4198.1796.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
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
index 727786f..f4537a6 100644
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
+	TP_printk("mr=%p addr=%llx (%s) sg_nents=%d",
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
+	TP_printk("mr=%p addr=%llx (%s) nents=%d of %d",
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
index 6d6cc80..529865a 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -104,8 +104,7 @@
 
 	rc = ib_dereg_mr(mr->frwr.fr_mr);
 	if (rc)
-		pr_err("rpcrdma: final ib_dereg_mr for %p returned %i\n",
-		       mr, rc);
+		trace_xprtrdma_frwr_dereg(mr, rc);
 	kfree(mr->mr_sg);
 	kfree(mr);
 }
@@ -158,8 +157,7 @@
 
 out_mr_err:
 	rc = PTR_ERR(frwr->fr_mr);
-	dprintk("RPC:       %s: ib_alloc_mr status %i\n",
-		__func__, rc);
+	trace_xprtrdma_frwr_alloc(mr, rc);
 	return rc;
 
 out_list_err:
@@ -421,15 +419,13 @@
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
index b89342d..422d793 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -668,7 +668,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 out_mapping_err:
 	rpcrdma_unmap_sendctx(sc);
-	pr_err("rpcrdma: Send mapping error\n");
+	trace_xprtrdma_dma_maperr(sge[sge_no].addr);
 	return false;
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4afed9f..1ee55d1 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1419,8 +1419,10 @@ struct rpcrdma_regbuf *
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

