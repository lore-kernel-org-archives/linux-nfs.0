Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:26640 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751162AbdAQUcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:51 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 02/10] NFS: Clean up _nfs4_is_integrity_protected()
Date: Tue, 17 Jan 2017 15:31:57 -0500
Message-ID: <20170117203205.29033-3-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
References: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

We can cut out the if statement and return the results of the comparison
directly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e10ec98ef5ce..00cb8b6c2c70 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -578,12 +578,7 @@ nfs4_async_handle_error(struct rpc_task *task, struct nfs_server *server,
 static bool _nfs4_is_integrity_protected(struct nfs_client *clp)
 {
 	rpc_authflavor_t flavor = clp->cl_rpcclient->cl_auth->au_flavor;
-
-	if (flavor == RPC_AUTH_GSS_KRB5I ||
-	    flavor == RPC_AUTH_GSS_KRB5P)
-		return true;
-
-	return false;
+	return (flavor == RPC_AUTH_GSS_KRB5I) || (flavor == RPC_AUTH_GSS_KRB5P);
 }
 
 static void do_renew_lease(struct nfs_client *clp, unsigned long timestamp)
-- 
2.11.0

