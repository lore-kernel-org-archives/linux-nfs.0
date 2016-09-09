Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:60728 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754814AbcIINYQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 09:24:16 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 10 03/12] NFS refactor nfs4_check_serverowner_major_id
Date: Fri, 9 Sep 2016 09:22:20 -0400
Message-ID: <1473427349-13265-4-git-send-email-andros@netapp.com>
In-Reply-To: <1473427349-13265-1-git-send-email-andros@netapp.com>
References: <1473427349-13265-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For session trunking, to compare nfs41_exchange_id_res with
existing nfs_client

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4client.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index d77a1ad..f356d50 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -578,17 +578,15 @@ static bool nfs4_match_clientids(u64 a, u64 b)
  * Returns true if the server major ids match
  */
 static bool
-nfs4_check_clientid_trunking(struct nfs_client *a, struct nfs_client *b)
+nfs4_check_serverowner_major_id(struct nfs41_server_owner *o1,
+				struct nfs41_server_owner *o2)
 {
-	struct nfs41_server_owner *o1 = a->cl_serverowner;
-	struct nfs41_server_owner *o2 = b->cl_serverowner;
-
 	if (o1->major_id_sz != o2->major_id_sz)
 		goto out_major_mismatch;
 	if (memcmp(o1->major_id, o2->major_id, o1->major_id_sz) != 0)
 		goto out_major_mismatch;
 
-	dprintk("NFS: --> %s server owners match\n", __func__);
+	dprintk("NFS: --> %s server owner major IDs match\n", __func__);
 	return true;
 
 out_major_mismatch:
@@ -658,7 +656,8 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		 * client id trunking. In either case, we want to fall back
 		 * to using the existing nfs_client.
 		 */
-		if (!nfs4_check_clientid_trunking(pos, new))
+		if (!nfs4_check_serverowner_major_id(pos->cl_serverowner,
+						     new->cl_serverowner))
 			continue;
 
 		/* Unlike NFSv4.0, we know that NFSv4.1 always uses the
-- 
1.8.3.1

