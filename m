Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:29698 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755357Ab2KVSmf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:42:35 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/20] NFSv4.1: We must bump the clientid sequence number after CREATE_SESSION
Date: Wed, 21 Nov 2012 17:43:02 -0500
Message-Id: <1353537799-60488-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353537799-60488-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1353537799-60488-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-3-git-send-email-Trond.Myklebust@netapp.com>
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

