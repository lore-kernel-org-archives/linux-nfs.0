Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36807 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753322AbdFPPWk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jun 2017 11:22:40 -0400
Subject: [PATCH v2 17/19] svcrdma: use offset_in_page() macro
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Jun 2017 11:22:38 -0400
Message-ID: <20170616152238.14210.91494.stgit@klimt.1015granger.net>
In-Reply-To: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
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
index 4cdea69..f385da0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -371,8 +371,9 @@ static void svc_rdma_pagelist_to_sg(struct svc_rdma_write_info *info,
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

