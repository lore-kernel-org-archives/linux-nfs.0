Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36293 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754564AbdFWVT2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jun 2017 17:19:28 -0400
Subject: [PATCH v3 17/18] svcrdma: use offset_in_page() macro
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 23 Jun 2017 17:19:21 -0400
Message-ID: <20170623211921.5162.43512.stgit@klimt.1015granger.net>
In-Reply-To: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
References: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use offset_in_page() macro instead of open-coding.

Reported-by: Geliang Tang <geliangtang@gmail.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_rw.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 9d7a151..9859736 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -372,8 +372,9 @@ static void svc_rdma_pagelist_to_sg(struct svc_rdma_write_info *info,
 	struct scatterlist *sg;
 	struct page **page;
 
-	page_off = (info->wi_next_off + xdr->page_base) & ~PAGE_MASK;
-	page_no = (info->wi_next_off + xdr->page_base) >> PAGE_SHIFT;
+	page_off = info->wi_next_off + xdr->page_base;
+	page_no = page_off >> PAGE_SHIFT;
+	page_off = offset_in_page(page_off);
 	page = xdr->pages + page_no;
 	info->wi_next_off += remaining;
 	sg = ctxt->rw_sg_table.sgl;

