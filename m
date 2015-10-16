Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33114 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259AbbJPN0G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 09:26:06 -0400
Subject: [PATCH v3 15/16] SUNRPC: Remove the TCP-only restriction in
 bc_svc_process()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Oct 2015 09:26:04 -0400
Message-ID: <20151016132604.6819.92088.stgit@oracle-122.nfsv4bat.org>
In-Reply-To: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
References: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the use of other transport classes when handling a backward
direction RPC call.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
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

