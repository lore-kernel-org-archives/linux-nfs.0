Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33937 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752160AbdAGRSR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:18:17 -0500
Subject: [PATCH v1 22/22] svcrdma: Re-order fields in svc_rdma_op_ctxt
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:18:15 -0500
Message-ID: <20170107171815.14126.40856.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attempt to group fields accessed during completion handling into one
cacheline.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 30c3ae9..6994039 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -77,7 +77,6 @@ enum {
  */
 struct svc_rdma_op_ctxt {
 	struct list_head list;
-	struct xdr_buf arg;
 	struct ib_cqe cqe;
 	u32 byte_len;
 	u32 position;
@@ -86,6 +85,7 @@ struct svc_rdma_op_ctxt {
 	int count;
 	unsigned int mapped_sges;
 	int hdr_count;
+	struct xdr_buf arg;
 	struct ib_send_wr send_wr;
 	struct ib_sge sge[1 + RPCRDMA_MAX_REQ_SIZE / PAGE_SIZE];
 	struct page *pages[RPCSVC_MAXPAGES];

