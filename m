Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:61755 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754701AbcBXR4z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2016 12:56:55 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 4/8] NFS refactor nfs4_check_serverowner_major_id
Date: Wed, 24 Feb 2016 12:56:23 -0500
Message-ID: <1456336587-17374-5-git-send-email-andros@netapp.com>
In-Reply-To: <1456336587-17374-1-git-send-email-andros@netapp.com>
References: <1456336587-17374-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For session trunking, to compare nfs41_exchange_id_res with
existing nfs_client

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4client.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index c9177a4..5a14fda 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -578,11 +578,9 @@ static bool nfs4_match_clientids(u64 a, u64 b)
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

