Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40643 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753676Ab2FEOMl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jun 2012 10:12:41 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Convert a trivial printk into a dprintk
Date: Tue,  5 Jun 2012 10:12:38 -0400
Message-Id: <1338905558-20343-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no need to bug the user about the server returning an error
on destroy_session. The error will be handled by the state manager,
without any need for further input from anyone else.
So convert that printk into a debugging dprintk.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ad15155..7c218fd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5766,8 +5766,7 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 
 	if (status)
-		printk(KERN_WARNING
-			"NFS: Got error %d from the server on DESTROY_SESSION. "
+		dprintk("NFS: Got error %d from the server on DESTROY_SESSION. "
 			"Session has been destroyed regardless...\n", status);
 
 	dprintk("<-- nfs4_proc_destroy_session\n");
-- 
1.7.10.2

