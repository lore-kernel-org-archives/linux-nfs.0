Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:46149 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbbAMQCl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:02:41 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 01/10] svcrdma: Clean up dprintk
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 13 Jan 2015 11:02:37 -0500
Message-ID: <20150113160237.8118.29686.stgit@klimt.1015granger.net>
In-Reply-To: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
References: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nit: Fix inconsistent white space in dprintk messages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index e011027..2c67de0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -501,8 +501,8 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 	ret = rqstp->rq_arg.head[0].iov_len
 		+ rqstp->rq_arg.page_len
 		+ rqstp->rq_arg.tail[0].iov_len;
-	dprintk("svcrdma: deferred read ret=%d, rq_arg.len =%d, "
-		"rq_arg.head[0].iov_base=%p, rq_arg.head[0].iov_len = %zd\n",
+	dprintk("svcrdma: deferred read ret=%d, rq_arg.len=%u, "
+		"rq_arg.head[0].iov_base=%p, rq_arg.head[0].iov_len=%zu\n",
 		ret, rqstp->rq_arg.len,	rqstp->rq_arg.head[0].iov_base,
 		rqstp->rq_arg.head[0].iov_len);
 
@@ -591,8 +591,8 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		+ rqstp->rq_arg.tail[0].iov_len;
 	svc_rdma_put_context(ctxt, 0);
  out:
-	dprintk("svcrdma: ret = %d, rq_arg.len =%d, "
-		"rq_arg.head[0].iov_base=%p, rq_arg.head[0].iov_len = %zd\n",
+	dprintk("svcrdma: ret=%d, rq_arg.len=%u, "
+		"rq_arg.head[0].iov_base=%p, rq_arg.head[0].iov_len=%zd\n",
 		ret, rqstp->rq_arg.len,
 		rqstp->rq_arg.head[0].iov_base,
 		rqstp->rq_arg.head[0].iov_len);

