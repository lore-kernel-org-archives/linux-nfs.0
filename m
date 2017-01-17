Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:13901 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751184AbdAQUcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:52 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 06/10] NFS: Remove nfs4_recover_expired_lease()
Date: Tue, 17 Jan 2017 15:32:01 -0500
Message-ID: <20170117203205.29033-7-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
References: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This function doesn't add much, since all it does is access the server's
nfs_client variable.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 02767aced45c..bde48f02bd28 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2308,11 +2308,6 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	return 0;
 }
 
-static int nfs4_recover_expired_lease(struct nfs_server *server)
-{
-	return nfs4_client_recover_expired_lease(server->nfs_client);
-}
-
 /*
  * OPEN_EXPIRED:
  * 	reclaim state on the server after a network partition.
@@ -2689,7 +2684,7 @@ static int _nfs4_do_open(struct inode *dir,
 		dprintk("nfs4_do_open: nfs4_get_state_owner failed!\n");
 		goto out_err;
 	}
-	status = nfs4_recover_expired_lease(server);
+	status = nfs4_client_recover_expired_lease(server->nfs_client);
 	if (status != 0)
 		goto err_put_state_owner;
 	if (d_really_is_positive(dentry))
-- 
2.11.0

