Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:38573 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751860AbdHAQAQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 12:00:16 -0400
Received: by mail-io0-f194.google.com with SMTP id o9so1832828iod.5
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 09:00:16 -0700 (PDT)
Subject: [PATCH v1 4/4] svcrdma: Clean up svc_rdma_build_read_chunk()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 01 Aug 2017 12:00:14 -0400
Message-ID: <20170801160014.14944.36631.stgit@klimt.1015granger.net>
In-Reply-To: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
References: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> observed that the while()
loop in svc_rdma_build_read_chunk() does not document the assumption
that the loop interior is always executed at least once.

Defensive: the function now returns -EINVAL if this assumption
fails.

Suggested-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_rw.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 933f79b..1f34fae 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -660,19 +660,21 @@ static int svc_rdma_build_read_segment(struct svc_rdma_read_info *info,
 	return -EIO;
 }
 
+/* Walk the segments in the Read chunk starting at @p and construct
+ * RDMA Read operations to pull the chunk to the server.
+ */
 static int svc_rdma_build_read_chunk(struct svc_rqst *rqstp,
 				     struct svc_rdma_read_info *info,
 				     __be32 *p)
 {
 	int ret;
 
+	ret = -EINVAL;
 	info->ri_chunklen = 0;
-	while (*p++ != xdr_zero) {
+	while (*p++ != xdr_zero && be32_to_cpup(p++) == info->ri_position) {
 		u32 rs_handle, rs_length;
 		u64 rs_offset;
 
-		if (be32_to_cpup(p++) != info->ri_position)
-			break;
 		rs_handle = be32_to_cpup(p++);
 		rs_length = be32_to_cpup(p++);
 		p = xdr_decode_hyper(p, &rs_offset);

