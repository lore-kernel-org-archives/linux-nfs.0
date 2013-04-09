Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16712 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934726Ab3DIRBK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 13:01:10 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix another potential state manager deadlock
Date: Tue,  9 Apr 2013 13:01:05 -0400
Message-Id: <1365526865-12698-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't hold the NFSv4 sequence id while we check for open permission.
The call to ACCESS may block due to reboot recovery.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 20d10c2..ce87287 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1096,6 +1096,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		/* Save the delegation */
 		nfs4_stateid_copy(&stateid, &delegation->stateid);
 		rcu_read_unlock();
+		nfs_release_seqid(opendata->o_arg.seqid);
 		ret = nfs_may_open(state->inode, state->owner->so_cred, open_mode);
 		if (ret != 0)
 			goto out;
-- 
1.8.1.4

