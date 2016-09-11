Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35614 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932160AbcIKTMT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Sep 2016 15:12:19 -0400
Received: by mail-oi0-f67.google.com with SMTP id 2so18854172oif.2
        for <linux-nfs@vger.kernel.org>; Sun, 11 Sep 2016 12:12:19 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Fix the CREATE_SESSION slot number accounting
Date: Sun, 11 Sep 2016 15:11:50 -0400
Message-Id: <1473621110-51372-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we conform to the algorithm described in RFC5661, section
18.36.4 for when to bump the sequence id. In essence we do it for all
cases except when the RPC call timed out, or in case of the server returning
NFS4ERR_DELAY or NFS4ERR_STALE_CLIENTID.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/nfs4proc.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c380d2ee4137..a9dec32ba9ba 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7570,12 +7570,20 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	trace_nfs4_create_session(clp, status);
 
+	switch (status) {
+	case -NFS4ERR_STALE_CLIENTID:
+	case -NFS4ERR_DELAY:
+	case -ETIMEDOUT:
+	case -EACCES:
+	case -EAGAIN:
+		goto out;
+	};
+
+	clp->cl_seqid++;
 	if (!status) {
 		/* Verify the session's negotiated channel_attrs values */
 		status = nfs4_verify_channel_attrs(&args, &res);
 		/* Increment the clientid slot sequence id */
-		if (clp->cl_seqid == res.seqid)
-			clp->cl_seqid++;
 		if (status)
 			goto out;
 		nfs4_update_session(session, &res);
-- 
2.7.4

