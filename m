Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:36934 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933017AbdDGSP6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:58 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 21/34] NFS: Clean up nfs4_check_server_scope()
Date: Fri, 7 Apr 2017 14:15:15 -0400
Message-ID: <20170407181528.2832-22-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4client.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index ce6f2ef62595..c9016de3e5bd 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -624,18 +624,9 @@ nfs4_check_server_scope(struct nfs41_server_scope *s1,
 			struct nfs41_server_scope *s2)
 {
 	if (s1->server_scope_sz != s2->server_scope_sz)
-		goto out_scope_mismatch;
-	if (memcmp(s1->server_scope, s2->server_scope,
-		   s1->server_scope_sz) != 0)
-		goto out_scope_mismatch;
-
-	dprintk("NFS: --> %s server scopes match\n", __func__);
-	return true;
-
-out_scope_mismatch:
-	dprintk("NFS: --> %s server scopes do not match\n",
-		__func__);
-	return false;
+		return false;
+	return memcmp(s1->server_scope, s2->server_scope,
+					s1->server_scope_sz) == 0;
 }
 
 /**
-- 
2.12.2

