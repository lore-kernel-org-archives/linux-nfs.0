From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/7] SUNRPC: Don't report a connect delay of 0 seconds
Date: Wed, 07 Oct 2009 18:02:25 -0400
Message-ID: <20091007220224.1844.3775.stgit@matisse.1015granger.net>
References: <20091007215019.1844.17414.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:52161
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754758AbZJGWDB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2009 18:03:01 -0400
Received: from matisse.1015granger.net (matisse.1015granger.net [127.0.0.1])
	by matisse.1015granger.net (8.14.3/8.14.3) with ESMTP id n97M2PDH001941
	for <linux-nfs@vger.kernel.org>; Wed, 7 Oct 2009 18:02:25 -0400
In-Reply-To: <20091007215019.1844.17414.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reduce debugging noise.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 37c5475..032d714 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2034,9 +2034,10 @@ static void xs_connect(struct rpc_task *task)
 		return;
 
 	if (transport->sock != NULL) {
-		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
-				"seconds\n",
-				xprt, xprt->reestablish_timeout / HZ);
+		if (xprt->reestablish_timeout != 0)
+			dprintk("RPC:       xs_connect delayed xprt %p "
+				"for %lu seconds\n",
+					xprt, xprt->reestablish_timeout / HZ);
 		queue_delayed_work(rpciod_workqueue,
 				   &transport->connect_worker,
 				   xprt->reestablish_timeout);

