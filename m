Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10802C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B5C4620672
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZQvkkJlw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5C4620672
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727056AbeK0HBQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:16 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:40835 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HBP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:15 -0500
Received: by mail-io1-f65.google.com with SMTP id n9so15016433ioh.7;
        Mon, 26 Nov 2018 12:06:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=E7HkUm33UJtGM4gg3Rk53KN0kbQHBgfOsn1pkVReScI=;
        b=ZQvkkJlwkfAR8Hie3lm8boSOcd/qvT8aJ61IiWl+qv1Jk4erqHodvxb+fczrmRIpE9
         gqXNgnUjr38+vojWCUBkct+0JsLkDuHKj5r9TMJ6f8uq6qkiG92PjqE54Zr8aQjr9aVF
         aSq9O88ORrY11RGElUnBHdVZV8gqZpfMUKagAFm+SNVtzi/qAtVTysin5G8Yi8riC9h6
         hUNsGLq6UhbrurY2LSzkAAtqlvHIGTaEMsUGrAzsVFWV2rspg7uFcCYVksqMu1kCPZ6F
         9MAPrLEb13rA6KWEa77Wj2b/sXC1vA2g5rTHOJ4Mu0r9u/WBZjXTRprLDepOSX5QWWKu
         x1fw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=E7HkUm33UJtGM4gg3Rk53KN0kbQHBgfOsn1pkVReScI=;
        b=fWYK10WMaIFs5Pu/JzGxttfH6SxHo7S+FTU7/k/XMCIPaM/5g638k5NamgnYOFD/bq
         nY3arOt9BhbwDf2DJTBlw/jAcbBmmHpP+s27Y1Nyr3V+Hb9hz2HZa5d7vLgUST5x35dN
         5l8i+130oA/HGcOBbNQuJ+H5MhaKezY2Jll/Msl1KBIXGGXFzFssNZ4zbEq4Qef7vpK0
         tG5l7T4kMfRQAumwzNdXt2KDGXeDjU3pIAUF9+6D19QCc9zM0KfNvIli6HifBj81UXqY
         d3EQBQZO4fzG1N7aYZVrqALRrdJXufO9itUCSP0fYRTogfznoKuS6sc+en2EDb0OKYBn
         ts9w==
X-Gm-Message-State: AA+aEWbK/Yv8sHh+yLS2v/gp29MbLV1icWra0YrwpP5bSIvZQvh4Asjw
        jKyYcIR9DBi2TivYaDxiKmMywYy5
X-Google-Smtp-Source: AFSGD/XqjD1u+128MX/OV4ni4UW62FX12bqdTEwkOjrCq8vwrLzD4kkW1u1jOzS5h8f57Zc63WrwzQ==
X-Received: by 2002:a5d:938b:: with SMTP id c11mr2657221iol.149.1543262760175;
        Mon, 26 Nov 2018 12:06:00 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q197sm696673itb.22.2018.11.26.12.05.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:05:58 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK5vuq010647;
        Mon, 26 Nov 2018 20:05:57 GMT
Subject: [PATCH v2 02/20] xprtrdma: Remove support for FMR memory
 registration
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:05:57 -0500
Message-ID: <20181126200557.10321.6169.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/Makefile  |    3 
 net/sunrpc/xprtrdma/fmr_ops.c |  337 -----------------------------------------
 net/sunrpc/xprtrdma/verbs.c   |    6 -
 3 files changed, 1 insertion(+), 345 deletions(-)
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
index 7f5632c..0000000
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ /dev/null
@@ -1,337 +0,0 @@
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
-	ia->ri_max_segs += 2;	/* segments for head and tail buffers */
-	return 0;
-}
-
-/* FMR mode conveys up to 64 pages of payload per chunk segment.
- */
-static size_t
-fmr_op_maxpages(struct rpcrdma_xprt *r_xprt)
-{
-	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-		     RPCRDMA_MAX_HDR_SEGS * RPCRDMA_MAX_FMR_SGES);
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
index 3ddba94..a8d4def 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -434,12 +434,6 @@
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

