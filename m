Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16446 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756567Ab2IZRNJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Sep 2012 13:13:09 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Always use the open stateid when checking for expired opens
Date: Wed, 26 Sep 2012 13:12:59 -0400
Message-Id: <1348679579-7888-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1348679579-7888-1-git-send-email-bjschuma@netapp.com>
References: <1348679579-7888-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

If we are reading through a delegation, and the delegation is OK then
state->stateid will still point to a delegation stateid and not an open
stateid.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e47ec55..df7e1a3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1792,7 +1792,7 @@ static void nfs41_clear_delegation_stateid(struct nfs4_state *state)
 static int nfs41_check_open_stateid(struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	nfs4_stateid *stateid = &state->stateid;
+	nfs4_stateid *stateid = &state->open_stateid;
 	int status;
 
 	/* If a state reset has been done, test_stateid is unneeded */
-- 
1.7.12.1

