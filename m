Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:19787 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757928AbcG0SpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2016 14:45:05 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 7 2/8] NFS refactor nfs4_match_clientids
Date: Wed, 27 Jul 2016 14:43:14 -0400
Message-ID: <1469645000-19791-3-git-send-email-andros@netapp.com>
In-Reply-To: <1469645000-19791-1-git-send-email-andros@netapp.com>
References: <1469645000-19791-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For session trunking, to compare nfs41_exchange_id_res with
exiting nfs_client.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4client.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 8d7d08d..d77a1ad 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -562,15 +562,15 @@ out:
 /*
  * Returns true if the client IDs match
  */
-static bool nfs4_match_clientids(struct nfs_client *a, struct nfs_client *b)
+static bool nfs4_match_clientids(u64 a, u64 b)
 {
-	if (a->cl_clientid != b->cl_clientid) {
+	if (a != b) {
 		dprintk("NFS: --> %s client ID %llx does not match %llx\n",
-			__func__, a->cl_clientid, b->cl_clientid);
+			__func__, a, b);
 		return false;
 	}
 	dprintk("NFS: --> %s client ID %llx matches %llx\n",
-		__func__, a->cl_clientid, b->cl_clientid);
+		__func__, a, b);
 	return true;
 }
 
@@ -650,7 +650,7 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		if (pos->cl_cons_state != NFS_CS_READY)
 			continue;
 
-		if (!nfs4_match_clientids(pos, new))
+		if (!nfs4_match_clientids(pos->cl_clientid, new->cl_clientid))
 			continue;
 
 		/*
-- 
1.8.3.1

