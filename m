Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:33990 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238Ab3EPCAN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 22:00:13 -0400
Received: by mail-ie0-f179.google.com with SMTP id c13so5355601ieb.10
        for <linux-nfs@vger.kernel.org>; Wed, 15 May 2013 19:00:13 -0700 (PDT)
Subject: [PATCH] NFS: Fix SETCLIENTID fallback if GSS is not available
To: trond.myklebust@netapp.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 May 2013 22:00:10 -0400
Message-ID: <20130516015848.34251.51432.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 79d852bf "NFS: Retry SETCLIENTID with AUTH_SYS instead of
AUTH_NONE" did not take into account commit 23631227 "NFSv4: Fix the
fallback to AUTH_NULL if krb5i is not available".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Trond -

If we end up keeping the krb5i -> sys logic, I think this change is
also needed.  Build-tested only.

 fs/nfs/nfs4client.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 947b0c9..4cbad5d 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -203,7 +203,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
 	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
 	if (error == -EINVAL)
-		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_NULL);
+		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
 	if (error < 0)
 		goto error;
 

