Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10285 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755445Ab2KZUQ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:16:57 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/28] NFSv4.1: We must bump the clientid sequence number after CREATE_SESSION
Date: Mon, 26 Nov 2012 15:16:21 -0500
Message-Id: <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must always bump the clientid sequence number after a successful
call to CREATE_SESSION on the server. The result of
nfs4_verify_channel_attrs() is irrelevant to that requirement.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ee82cdd..1ac339b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5917,10 +5917,9 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
 
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 
-	if (!status)
+	if (!status) {
 		/* Verify the session's negotiated channel_attrs values */
 		status = nfs4_verify_channel_attrs(&args, session);
-	if (!status) {
 		/* Increment the clientid slot sequence id */
 		clp->cl_seqid++;
 	}
-- 
1.7.11.7

