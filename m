Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:36934 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755483AbdDGSQF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:05 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 22/34] NFS: Clean up nfs4_set_client()
Date: Fri, 7 Apr 2017 14:15:16 -0400
Message-ID: <20170407181528.2832-23-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

If we cut out the dprintk()s, then we can return error codes directly
and cut out the goto.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4client.c | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index c9016de3e5bd..a380255e85ed 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -854,9 +854,6 @@ static int nfs4_set_client(struct nfs_server *server,
 		.timeparms = timeparms,
 	};
 	struct nfs_client *clp;
-	int error;
-
-	dprintk("--> nfs4_set_client()\n");
 
 	if (server->flags & NFS_MOUNT_NORESVPORT)
 		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
@@ -865,15 +862,11 @@ static int nfs4_set_client(struct nfs_server *server,
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(&cl_init);
-	if (IS_ERR(clp)) {
-		error = PTR_ERR(clp);
-		goto error;
-	}
+	if (IS_ERR(clp))
+		return PTR_ERR(clp);
 
-	if (server->nfs_client == clp) {
-		error = -ELOOP;
-		goto error;
-	}
+	if (server->nfs_client == clp)
+		return -ELOOP;
 
 	/*
 	 * Query for the lease time on clientid setup or renewal
@@ -885,11 +878,7 @@ static int nfs4_set_client(struct nfs_server *server,
 	set_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state);
 
 	server->nfs_client = clp;
-	dprintk("<-- nfs4_set_client() = 0 [new %p]\n", clp);
 	return 0;
-error:
-	dprintk("<-- nfs4_set_client() = xerror %d\n", error);
-	return error;
 }
 
 /*
-- 
2.12.2

