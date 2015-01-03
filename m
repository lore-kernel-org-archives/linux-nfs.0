Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:62014 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbbACVKB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Jan 2015 16:10:01 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so17944866ier.32
        for <linux-nfs@vger.kernel.org>; Sat, 03 Jan 2015 13:10:00 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 1/4] NFSv4.1: Fix client id trunking on Linux
Date: Sat,  3 Jan 2015 16:09:54 -0500
Message-Id: <1420319397-37704-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, our trunking code will check for session trunking, but will
fail to detect client id trunking. This is a problem, because it means
that the client will fail to recognise that the two connections represent
shared state, even if they do not permit a shared session.
By removing the check for the server minor id, and only checking the
major id, we will end up doing the right thing in both cases: we close
down the new nfs_client and fall back to using the existing one.

Fixes: 05f4c350ee02e ("NFS: Discover NFSv4 server trunking when mounting")
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org # 3.7.x
Tested-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4client.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 03311259b0c4..d949d0f378ec 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -566,20 +566,14 @@ static bool nfs4_match_clientids(struct nfs_client *a, struct nfs_client *b)
 }
 
 /*
- * Returns true if the server owners match
+ * Returns true if the server major ids match
  */
 static bool
-nfs4_match_serverowners(struct nfs_client *a, struct nfs_client *b)
+nfs4_check_clientid_trunking(struct nfs_client *a, struct nfs_client *b)
 {
 	struct nfs41_server_owner *o1 = a->cl_serverowner;
 	struct nfs41_server_owner *o2 = b->cl_serverowner;
 
-	if (o1->minor_id != o2->minor_id) {
-		dprintk("NFS: --> %s server owner minor IDs do not match\n",
-			__func__);
-		return false;
-	}
-
 	if (o1->major_id_sz != o2->major_id_sz)
 		goto out_major_mismatch;
 	if (memcmp(o1->major_id, o2->major_id, o1->major_id_sz) != 0)
@@ -654,7 +648,12 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		if (!nfs4_match_clientids(pos, new))
 			continue;
 
-		if (!nfs4_match_serverowners(pos, new))
+		/*
+		 * Note that session trunking is just a special subcase of
+		 * client id trunking. In either case, we want to fall back
+		 * to using the existing nfs_client.
+		 */
+		if (!nfs4_check_clientid_trunking(pos, new))
 			continue;
 
 		atomic_inc(&pos->cl_count);
-- 
2.1.0

