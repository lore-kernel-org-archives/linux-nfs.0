Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:36506 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbbIQUpv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 16:45:51 -0400
Subject: [PATCH v1 12/18] SUNRPC: Remove the TCP-only restriction in
 bc_svc_process()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 17 Sep 2015 16:45:49 -0400
Message-ID: <20150917204549.19671.26366.stgit@manet.1015granger.net>
In-Reply-To: <20150917202829.19671.90044.stgit@manet.1015granger.net>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the use of other transport classes when handling a backward
direction RPC call.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svc.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a8f579d..bc5b7b5 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1367,11 +1367,6 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	/* reset result send buffer "put" position */
 	resv->iov_len = 0;
 
-	if (rqstp->rq_prot != IPPROTO_TCP) {
-		printk(KERN_ERR "No support for Non-TCP transports!\n");
-		BUG();
-	}
-
 	/*
 	 * Skip the next two words because they've already been
 	 * processed in the transport

