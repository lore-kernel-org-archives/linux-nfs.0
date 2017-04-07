Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:41488 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933820AbdDGSQD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:03 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 20/34] NFS: Clean up nfs4_check_serverowner_major_id()
Date: Fri, 7 Apr 2017 14:15:14 -0400
Message-ID: <20170407181528.2832-21-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4client.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 8853c32eedf5..ce6f2ef62595 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -612,17 +612,8 @@ nfs4_check_serverowner_major_id(struct nfs41_server_owner *o1,
 				struct nfs41_server_owner *o2)
 {
 	if (o1->major_id_sz != o2->major_id_sz)
-		goto out_major_mismatch;
-	if (memcmp(o1->major_id, o2->major_id, o1->major_id_sz) != 0)
-		goto out_major_mismatch;
-
-	dprintk("NFS: --> %s server owner major IDs match\n", __func__);
-	return true;
-
-out_major_mismatch:
-	dprintk("NFS: --> %s server owner major IDs do not match\n",
-		__func__);
-	return false;
+		return false;
+	return memcmp(o1->major_id, o2->major_id, o1->major_id_sz) == 0;
 }
 
 /*
-- 
2.12.2

