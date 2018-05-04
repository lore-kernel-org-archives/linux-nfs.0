Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35928 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751747AbeEDTgE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:36:04 -0400
Subject: [PATCH v1 18/19] xprtrdma: Add trace_xprtrdma_dma_map(mr)
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:36:02 -0400
Message-ID: <20180504193602.31688.34637.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Matches trace_xprtrdma_dma_unmap(mr).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |    1 +
 net/sunrpc/xprtrdma/fmr_ops.c  |    1 +
 net/sunrpc/xprtrdma/frwr_ops.c |    1 +
 3 files changed, 3 insertions(+)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index ac82849..c4494a2 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -650,6 +650,7 @@
 DEFINE_FRWR_DONE_EVENT(xprtrdma_wc_li_wake);
 
 DEFINE_MR_EVENT(xprtrdma_localinv);
+DEFINE_MR_EVENT(xprtrdma_dma_map);
 DEFINE_MR_EVENT(xprtrdma_dma_unmap);
 DEFINE_MR_EVENT(xprtrdma_remoteinv);
 DEFINE_MR_EVENT(xprtrdma_recover_mr);
diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 0815f9e..58b4726 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -241,6 +241,7 @@ enum {
 				     mr->mr_sg, i, mr->mr_dir);
 	if (!mr->mr_nents)
 		goto out_dmamap_err;
+	trace_xprtrdma_dma_map(mr);
 
 	for (i = 0, dma_pages = mr->fmr.fm_physaddrs; i < mr->mr_nents; i++)
 		dma_pages[i] = sg_dma_address(&mr->mr_sg[i]);
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index cf5095d6..d46dc7e 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -415,6 +415,7 @@
 	mr->mr_nents = ib_dma_map_sg(ia->ri_device, mr->mr_sg, i, mr->mr_dir);
 	if (!mr->mr_nents)
 		goto out_dmamap_err;
+	trace_xprtrdma_dma_map(mr);
 
 	ibmr = frwr->fr_mr;
 	n = ib_map_mr_sg(ibmr, mr->mr_sg, mr->mr_nents, NULL, PAGE_SIZE);

