Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:34965 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758312AbbGHSZ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 14:25:27 -0400
Received: by labgy5 with SMTP id gy5so78796863lab.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2015 11:25:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4: Leases are renewed in sequence_done when we have sessions
Date: Wed,  8 Jul 2015 20:25:13 +0200
Message-Id: <1436379913-3338-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1436379913-3338-4-git-send-email-trond.myklebust@primarydata.com>
References: <1436379913-3338-1-git-send-email-trond.myklebust@primarydata.com>
 <1436379913-3338-2-git-send-email-trond.myklebust@primarydata.com>
 <1436379913-3338-3-git-send-email-trond.myklebust@primarydata.com>
 <1436379913-3338-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the calls to renew_lease() in open_done() etc. only apply
to session-less versions of NFSv4.x (i.e. NFSv4.0).

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1607b41a6d84..9f24238032f8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -467,7 +467,10 @@ static void do_renew_lease(struct nfs_client *clp, unsigned long timestamp)
 
 static void renew_lease(const struct nfs_server *server, unsigned long timestamp)
 {
-	do_renew_lease(server->nfs_client, timestamp);
+	struct nfs_client *clp = server->nfs_client;
+
+	if (!nfs4_has_session(clp))
+		do_renew_lease(clp, timestamp);
 }
 
 struct nfs4_call_sync_data {
@@ -7572,13 +7575,8 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 		goto out;
 	}
 	ret = rpc_wait_for_completion_task(task);
-	if (!ret) {
-		struct nfs4_sequence_res *res = task->tk_msg.rpc_resp;
-
-		if (task->tk_status == 0)
-			nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
+	if (!ret)
 		ret = task->tk_status;
-	}
 	rpc_put_task(task);
 out:
 	dprintk("<-- %s status=%d\n", __func__, ret);
-- 
2.4.3

