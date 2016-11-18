Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33944 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754460AbcKRPLQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 10:11:16 -0500
Subject: [PATCH v2 08/10] svcrdma: Remove unused variable in rdma_copy_tail()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 18 Nov 2016 10:11:14 -0500
Message-ID: <20161118151114.13658.22001.stgit@klimt.1015granger.net>
In-Reply-To: <20161118145940.13658.59105.stgit@klimt.1015granger.net>
References: <20161118145940.13658.59105.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

linux-2.6/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c: In function
 ‘rdma_copy_tail’:
linux-2.6/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c:376:6: warning:
 variable ‘ret’ set but not used [-Wunused-but-set-variable]
  int ret;
      ^

Fixes: a97c331f9aa9 ("svcrdma: Handle additional inline content")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 428ab4ef..57d35fb 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -373,9 +373,7 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	       u32 position, u32 byte_count, u32 page_offset, int page_no)
 {
 	char *srcp, *destp;
-	int ret;
 
-	ret = 0;
 	srcp = head->arg.head[0].iov_base + position;
 	byte_count = head->arg.head[0].iov_len - position;
 	if (byte_count > PAGE_SIZE) {

