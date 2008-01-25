From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 033/112] SUNRPC: Check a return result
Date: Fri, 25 Jan 2008 11:37:32 -0500
Message-ID: <20080125163732.31887.43707.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756887AbYAYRCG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:06 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0WPf020490
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:56 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Minor: Replace an empty if statement with a debugging dprintk.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtrdma/verbs.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 44b0fb9..ffbf22a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -522,7 +522,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 				struct rpcrdma_create_data_internal *cdata)
 {
 	struct ib_device_attr devattr;
-	int rc;
+	int rc, err;
 
 	rc = ib_query_device(ia->ri_id->device, &devattr);
 	if (rc) {
@@ -648,8 +648,10 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	return 0;
 
 out2:
-	if (ib_destroy_cq(ep->rep_cq))
-		;
+	err = ib_destroy_cq(ep->rep_cq);
+	if (err)
+		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
+			__func__, err);
 out1:
 	return rc;
 }
