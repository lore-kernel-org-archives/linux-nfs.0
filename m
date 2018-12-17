Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E24BAC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 983152133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OUUQfBsw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388269AbeLQQkN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:40:13 -0500
Received: from mail-io1-f52.google.com ([209.85.166.52]:43622 "EHLO
        mail-io1-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388108AbeLQQkM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:12 -0500
Received: by mail-io1-f52.google.com with SMTP id l3so10437258ioc.10;
        Mon, 17 Dec 2018 08:40:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Dg+whjZAs2Icbyk5ZQI3ii1G3YobxUwf7YswtT07HvI=;
        b=OUUQfBsw5IKvl/z95eAFAOs3ipArRiJlM6kOrXlw/xh1GvopcaAiP9t0xRFEQBb+2o
         pcYLMGUOs93saNSORRMCDKkzMqlyPXaXq+usvl3HzKgnpLUG6NEYnmKh8RrEyTLc7gcz
         TS0kWExdbqA/X1bY+AS19hgS9D8oW1ggnIUhT1P07dxcdemCXSNN3dH9X6JayxA0rOKr
         fghttavlMegGdw7e8k7fTZulyc5P9zP5Jg5rCOgWGIXDFfTClbET0XZWIZysOUcZm1j9
         eWGnGyUVVm7yxkgTWaHxcE2Otmg3ODT6y4PgSPYoN0jrY8k59quXVZ9QgfVvv4GX7MRv
         C3pg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Dg+whjZAs2Icbyk5ZQI3ii1G3YobxUwf7YswtT07HvI=;
        b=InjgN/+DBS/2H1iwTP2pUyAdjgpytIZQrm8FCAFuGEAekzch+GGLGL1xnTtOnABlei
         Vng8QREbKn1LTGb6DIb3xFRymX3lmsdQqrN6jqXst8br6zGXY3RIBNQjHClC7B9tJSA5
         gkDyTavs0E6owDln6p83EMgoGoynEa2NL3dOcBx1M70nPWw/XklPziEm6txZSmeuA/zP
         7VDPumie+PoI7KMa57xkPicSVN1/rtH0kLlg7yKwDQ0A4NRfT5EQEM6SkhyFc2AlB5Q3
         jaE6E8KFPJEL2ddL5S79TFBx6uoUh2BmpgBE8TgE9w0GQ/ZvVRC+wC8eqT17WC4RgKCQ
         d+uw==
X-Gm-Message-State: AA+aEWadjer3FejB2spfIrKEL/Oh3TWCsH/VAAwo6KfRHkB8RKA6GX4N
        aCWnyswZPX1+gh6XAQUyvRu/yHuP
X-Google-Smtp-Source: AFSGD/Vc1ZC5xAurywRKc2Z8GrELMBBq+44SFtbM3qqjSTZkdEQ5mmO7gU+wUm5FdNSbYY1zUoI1Mw==
X-Received: by 2002:a6b:f404:: with SMTP id i4mr10513839iog.281.1545064810814;
        Mon, 17 Dec 2018 08:40:10 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u25sm5552536iob.23.2018.12.17.08.40.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:40:10 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGe9V8018605;
        Mon, 17 Dec 2018 16:40:09 GMT
Subject: [PATCH v4 09/30] xprtrdma: Remove support for FMR memory
 registration
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:40:09 -0500
Message-ID: <20181217164009.24133.51523.stgit@manet.1015granger.net>
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

FMR is not supported on most recent RDMA devices. It is also less
secure than FRWR because an FMR memory registration can expose
adjacent bytes to remote reading or writing. As discussed during the
RDMA BoF at LPC 2018, it is time to remove support for FMR in the
NFS/RDMA client stack.

Note that NFS/RDMA server-side uses either local memory registration
or FRWR. FMR is not used.

There are a few Infiniband/RoCE devices in the kernel tree that do
not appear to support MEM_MGT_EXTENSIONS (FRWR), and therefore will
not support client-side NFS/RDMA after this patch. These are:

 - mthca
 - qib
 - hns (RoCE)

Users of these devices can use NFS/TCP on IPoIB instead.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/Makefile    |    3 
 net/sunrpc/xprtrdma/fmr_ops.c   |  340 ---------------------------------------
 net/sunrpc/xprtrdma/verbs.c     |    6 -
 net/sunrpc/xprtrdma/xprt_rdma.h |   12 -
 4 files changed, 2 insertions(+), 359 deletions(-)
 delete mode 100644 net/sunrpc/xprtrdma/fmr_ops.c

diff --git a/net/sunrpc/xprtrdma/Makefile b/net/sunrpc/xprtrdma/Makefile
index 8bf19e1..8ed0377 100644
--- a/net/sunrpc/xprtrdma/Makefile
+++ b/net/sunrpc/xprtrdma/Makefile
@@ -1,8 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0
 obj-$(CONFIG_SUNRPC_XPRT_RDMA) += rpcrdma.o
 
-rpcrdma-y := transport.o rpc_rdma.o verbs.o \
-	fmr_ops.o frwr_ops.o \
+rpcrdma-y := transport.o rpc_rdma.o verbs.o frwr_ops.o \
 	svc_rdma.o svc_rdma_backchannel.o svc_rdma_transport.o \
 	svc_rdma_sendto.o svc_rdma_recvfrom.o svc_rdma_rw.o \
 	module.o
diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
deleted file mode 100644
index 78a0224..0000000
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ /dev/null
@@ -1,340 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Copyright (c) 2015, 2017 Oracle.  All rights reserved.
- * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
- */
-
-/* Lightweight memory registration using Fast Memory Regions (FMR).
- * Referred to sometimes as MTHCAFMR mode.
- *
- * FMR uses synchronous memory registration and deregistration.
- * FMR registration is known to be fast, but FMR deregistration
- * can take tens of usecs to complete.
- */
-
-/* Normal operation
- *
- * A Memory Region is prepared for RDMA READ or WRITE using the
- * ib_map_phys_fmr verb (fmr_op_map). When the RDMA operation is
- * finished, the Memory Region is unmapped using the ib_unmap_fmr
- * verb (fmr_op_unmap).
- */
-
-#include <linux/sunrpc/svc_rdma.h>
-
-#include "xprt_rdma.h"
-#include <trace/events/rpcrdma.h>
-
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-# define RPCDBG_FACILITY	RPCDBG_TRANS
-#endif
-
-/* Maximum scatter/gather per FMR */
-#define RPCRDMA_MAX_FMR_SGES	(64)
-
-/* Access mode of externally registered pages */
-enum {
-	RPCRDMA_FMR_ACCESS_FLAGS	= IB_ACCESS_REMOTE_WRITE |
-					  IB_ACCESS_REMOTE_READ,
-};
-
-bool
-fmr_is_supported(struct rpcrdma_ia *ia)
-{
-	if (!ia->ri_device->alloc_fmr) {
-		pr_info("rpcrdma: 'fmr' mode is not supported by device %s\n",
-			ia->ri_device->name);
-		return false;
-	}
-	return true;
-}
-
-static void
-__fmr_unmap(struct rpcrdma_mr *mr)
-{
-	LIST_HEAD(l);
-	int rc;
-
-	list_add(&mr->fmr.fm_mr->list, &l);
-	rc = ib_unmap_fmr(&l);
-	list_del(&mr->fmr.fm_mr->list);
-	if (rc)
-		pr_err("rpcrdma: final ib_unmap_fmr for %p failed %i\n",
-		       mr, rc);
-}
-
-/* Release an MR.
- */
-static void
-fmr_op_release_mr(struct rpcrdma_mr *mr)
-{
-	int rc;
-
-	kfree(mr->fmr.fm_physaddrs);
-	kfree(mr->mr_sg);
-
-	/* In case this one was left mapped, try to unmap it
-	 * to prevent dealloc_fmr from failing with EBUSY
-	 */
-	__fmr_unmap(mr);
-
-	rc = ib_dealloc_fmr(mr->fmr.fm_mr);
-	if (rc)
-		pr_err("rpcrdma: final ib_dealloc_fmr for %p returned %i\n",
-		       mr, rc);
-
-	kfree(mr);
-}
-
-/* MRs are dynamically allocated, so simply clean up and release the MR.
- * A replacement MR will subsequently be allocated on demand.
- */
-static void
-fmr_mr_recycle_worker(struct work_struct *work)
-{
-	struct rpcrdma_mr *mr = container_of(work, struct rpcrdma_mr, mr_recycle);
-	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
-
-	trace_xprtrdma_mr_recycle(mr);
-
-	trace_xprtrdma_mr_unmap(mr);
-	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
-			mr->mr_sg, mr->mr_nents, mr->mr_dir);
-
-	spin_lock(&r_xprt->rx_buf.rb_mrlock);
-	list_del(&mr->mr_all);
-	r_xprt->rx_stats.mrs_recycled++;
-	spin_unlock(&r_xprt->rx_buf.rb_mrlock);
-	fmr_op_release_mr(mr);
-}
-
-static int
-fmr_op_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
-{
-	static struct ib_fmr_attr fmr_attr = {
-		.max_pages	= RPCRDMA_MAX_FMR_SGES,
-		.max_maps	= 1,
-		.page_shift	= PAGE_SHIFT
-	};
-
-	mr->fmr.fm_physaddrs = kcalloc(RPCRDMA_MAX_FMR_SGES,
-				       sizeof(u64), GFP_KERNEL);
-	if (!mr->fmr.fm_physaddrs)
-		goto out_free;
-
-	mr->mr_sg = kcalloc(RPCRDMA_MAX_FMR_SGES,
-			    sizeof(*mr->mr_sg), GFP_KERNEL);
-	if (!mr->mr_sg)
-		goto out_free;
-
-	sg_init_table(mr->mr_sg, RPCRDMA_MAX_FMR_SGES);
-
-	mr->fmr.fm_mr = ib_alloc_fmr(ia->ri_pd, RPCRDMA_FMR_ACCESS_FLAGS,
-				     &fmr_attr);
-	if (IS_ERR(mr->fmr.fm_mr))
-		goto out_fmr_err;
-
-	INIT_LIST_HEAD(&mr->mr_list);
-	INIT_WORK(&mr->mr_recycle, fmr_mr_recycle_worker);
-	return 0;
-
-out_fmr_err:
-	dprintk("RPC:       %s: ib_alloc_fmr returned %ld\n", __func__,
-		PTR_ERR(mr->fmr.fm_mr));
-
-out_free:
-	kfree(mr->mr_sg);
-	kfree(mr->fmr.fm_physaddrs);
-	return -ENOMEM;
-}
-
-/* On success, sets:
- *	ep->rep_attr.cap.max_send_wr
- *	ep->rep_attr.cap.max_recv_wr
- *	cdata->max_requests
- *	ia->ri_max_segs
- */
-static int
-fmr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
-	    struct rpcrdma_create_data_internal *cdata)
-{
-	int max_qp_wr;
-
-	max_qp_wr = ia->ri_device->attrs.max_qp_wr;
-	max_qp_wr -= RPCRDMA_BACKWARD_WRS;
-	max_qp_wr -= 1;
-	if (max_qp_wr < RPCRDMA_MIN_SLOT_TABLE)
-		return -ENOMEM;
-	if (cdata->max_requests > max_qp_wr)
-		cdata->max_requests = max_qp_wr;
-	ep->rep_attr.cap.max_send_wr = cdata->max_requests;
-	ep->rep_attr.cap.max_send_wr += RPCRDMA_BACKWARD_WRS;
-	ep->rep_attr.cap.max_send_wr += 1; /* for ib_drain_sq */
-	ep->rep_attr.cap.max_recv_wr = cdata->max_requests;
-	ep->rep_attr.cap.max_recv_wr += RPCRDMA_BACKWARD_WRS;
-	ep->rep_attr.cap.max_recv_wr += 1; /* for ib_drain_rq */
-
-	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
-				RPCRDMA_MAX_FMR_SGES);
-	/* Reply chunks require segments for head and tail buffers */
-	ia->ri_max_segs += 2;
-	if (ia->ri_max_segs > RPCRDMA_MAX_HDR_SEGS)
-		ia->ri_max_segs = RPCRDMA_MAX_HDR_SEGS;
-	return 0;
-}
-
-/* FMR mode conveys up to 64 pages of payload per chunk segment.
- */
-static size_t
-fmr_op_maxpages(struct rpcrdma_xprt *r_xprt)
-{
-	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-		     (ia->ri_max_segs - 2) * RPCRDMA_MAX_FMR_SGES);
-}
-
-/* Use the ib_map_phys_fmr() verb to register a memory region
- * for remote access via RDMA READ or RDMA WRITE.
- */
-static struct rpcrdma_mr_seg *
-fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
-	   int nsegs, bool writing, struct rpcrdma_mr **out)
-{
-	struct rpcrdma_mr_seg *seg1 = seg;
-	int len, pageoff, i, rc;
-	struct rpcrdma_mr *mr;
-	u64 *dma_pages;
-
-	mr = rpcrdma_mr_get(r_xprt);
-	if (!mr)
-		return ERR_PTR(-EAGAIN);
-
-	pageoff = offset_in_page(seg1->mr_offset);
-	seg1->mr_offset -= pageoff;	/* start of page */
-	seg1->mr_len += pageoff;
-	len = -pageoff;
-	if (nsegs > RPCRDMA_MAX_FMR_SGES)
-		nsegs = RPCRDMA_MAX_FMR_SGES;
-	for (i = 0; i < nsegs;) {
-		if (seg->mr_page)
-			sg_set_page(&mr->mr_sg[i],
-				    seg->mr_page,
-				    seg->mr_len,
-				    offset_in_page(seg->mr_offset));
-		else
-			sg_set_buf(&mr->mr_sg[i], seg->mr_offset,
-				   seg->mr_len);
-		len += seg->mr_len;
-		++seg;
-		++i;
-		/* Check for holes */
-		if ((i < nsegs && offset_in_page(seg->mr_offset)) ||
-		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
-			break;
-	}
-	mr->mr_dir = rpcrdma_data_dir(writing);
-
-	mr->mr_nents = ib_dma_map_sg(r_xprt->rx_ia.ri_device,
-				     mr->mr_sg, i, mr->mr_dir);
-	if (!mr->mr_nents)
-		goto out_dmamap_err;
-	trace_xprtrdma_mr_map(mr);
-
-	for (i = 0, dma_pages = mr->fmr.fm_physaddrs; i < mr->mr_nents; i++)
-		dma_pages[i] = sg_dma_address(&mr->mr_sg[i]);
-	rc = ib_map_phys_fmr(mr->fmr.fm_mr, dma_pages, mr->mr_nents,
-			     dma_pages[0]);
-	if (rc)
-		goto out_maperr;
-
-	mr->mr_handle = mr->fmr.fm_mr->rkey;
-	mr->mr_length = len;
-	mr->mr_offset = dma_pages[0] + pageoff;
-
-	*out = mr;
-	return seg;
-
-out_dmamap_err:
-	pr_err("rpcrdma: failed to DMA map sg %p sg_nents %d\n",
-	       mr->mr_sg, i);
-	rpcrdma_mr_put(mr);
-	return ERR_PTR(-EIO);
-
-out_maperr:
-	pr_err("rpcrdma: ib_map_phys_fmr %u@0x%llx+%i (%d) status %i\n",
-	       len, (unsigned long long)dma_pages[0],
-	       pageoff, mr->mr_nents, rc);
-	rpcrdma_mr_unmap_and_put(mr);
-	return ERR_PTR(-EIO);
-}
-
-/* Post Send WR containing the RPC Call message.
- */
-static int
-fmr_op_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
-{
-	return ib_post_send(ia->ri_id->qp, &req->rl_sendctx->sc_wr, NULL);
-}
-
-/* Invalidate all memory regions that were registered for "req".
- *
- * Sleeps until it is safe for the host CPU to access the
- * previously mapped memory regions.
- *
- * Caller ensures that @mrs is not empty before the call. This
- * function empties the list.
- */
-static void
-fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct list_head *mrs)
-{
-	struct rpcrdma_mr *mr;
-	LIST_HEAD(unmap_list);
-	int rc;
-
-	/* ORDER: Invalidate all of the req's MRs first
-	 *
-	 * ib_unmap_fmr() is slow, so use a single call instead
-	 * of one call per mapped FMR.
-	 */
-	list_for_each_entry(mr, mrs, mr_list) {
-		dprintk("RPC:       %s: unmapping fmr %p\n",
-			__func__, &mr->fmr);
-		trace_xprtrdma_mr_localinv(mr);
-		list_add_tail(&mr->fmr.fm_mr->list, &unmap_list);
-	}
-	r_xprt->rx_stats.local_inv_needed++;
-	rc = ib_unmap_fmr(&unmap_list);
-	if (rc)
-		goto out_release;
-
-	/* ORDER: Now DMA unmap all of the req's MRs, and return
-	 * them to the free MW list.
-	 */
-	while (!list_empty(mrs)) {
-		mr = rpcrdma_mr_pop(mrs);
-		list_del(&mr->fmr.fm_mr->list);
-		rpcrdma_mr_unmap_and_put(mr);
-	}
-
-	return;
-
-out_release:
-	pr_err("rpcrdma: ib_unmap_fmr failed (%i)\n", rc);
-
-	while (!list_empty(mrs)) {
-		mr = rpcrdma_mr_pop(mrs);
-		list_del(&mr->fmr.fm_mr->list);
-		rpcrdma_mr_recycle(mr);
-	}
-}
-
-const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
-	.ro_map				= fmr_op_map,
-	.ro_send			= fmr_op_send,
-	.ro_unmap_sync			= fmr_op_unmap_sync,
-	.ro_open			= fmr_op_open,
-	.ro_maxpages			= fmr_op_maxpages,
-	.ro_init_mr			= fmr_op_init_mr,
-	.ro_release_mr			= fmr_op_release_mr,
-	.ro_displayname			= "fmr",
-	.ro_send_w_inv_ok		= 0,
-};
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 38a757c..389b617 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -397,12 +397,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 			break;
 		}
 		/*FALLTHROUGH*/
-	case RPCRDMA_MTHCAFMR:
-		if (fmr_is_supported(ia)) {
-			ia->ri_ops = &rpcrdma_fmr_memreg_ops;
-			break;
-		}
-		/*FALLTHROUGH*/
 	default:
 		pr_err("rpcrdma: Device %s does not support memreg mode %d\n",
 		       ia->ri_device->name, xprt_rdma_memreg_strategy);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 7c1b519..dc8e178 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -262,20 +262,12 @@ struct rpcrdma_frwr {
 	};
 };
 
-struct rpcrdma_fmr {
-	struct ib_fmr		*fm_mr;
-	u64			*fm_physaddrs;
-};
-
 struct rpcrdma_mr {
 	struct list_head	mr_list;
 	struct scatterlist	*mr_sg;
 	int			mr_nents;
 	enum dma_data_direction	mr_dir;
-	union {
-		struct rpcrdma_fmr	fmr;
-		struct rpcrdma_frwr	frwr;
-	};
+	struct rpcrdma_frwr	frwr;
 	struct rpcrdma_xprt	*mr_xprt;
 	u32			mr_handle;
 	u32			mr_length;
@@ -490,7 +482,6 @@ struct rpcrdma_memreg_ops {
 	const int	ro_send_w_inv_ok;
 };
 
-extern const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops;
 extern const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops;
 
 /*
@@ -545,7 +536,6 @@ struct rpcrdma_xprt {
 void rpcrdma_ia_remove(struct rpcrdma_ia *ia);
 void rpcrdma_ia_close(struct rpcrdma_ia *);
 bool frwr_is_supported(struct rpcrdma_ia *);
-bool fmr_is_supported(struct rpcrdma_ia *);
 
 /*
  * Endpoint calls - xprtrdma/verbs.c

