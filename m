Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:15659 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751179AbdAQUcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:52 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 07/10] NFS: Remove unnecessary goto in nfs4_lookup_root_sec()
Date: Tue, 17 Jan 2017 15:32:02 -0500
Message-ID: <20170117203205.29033-8-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
References: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Once again, it's easier and cleaner just to return the error directly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bde48f02bd28..67aa9cf5f569 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3412,16 +3412,11 @@ static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandl
 		.pseudoflavor = flavor,
 	};
 	struct rpc_auth *auth;
-	int ret;
 
 	auth = rpcauth_create(&auth_args, server->client);
-	if (IS_ERR(auth)) {
-		ret = -EACCES;
-		goto out;
-	}
-	ret = nfs4_lookup_root(server, fhandle, info);
-out:
-	return ret;
+	if (IS_ERR(auth))
+		return -EACCES;
+	return nfs4_lookup_root(server, fhandle, info);
 }
 
 /*
-- 
2.11.0

