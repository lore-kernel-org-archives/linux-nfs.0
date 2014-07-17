Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.ispras.ru ([83.149.199.45]:48286 "EHLO mail.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755200AbaGQXL4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2014 19:11:56 -0400
From: Alexey Khoroshilov <khoroshilov@ispras.ru>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
Subject: [PATCH] NFS: add checks for returned value of try_module_get()
Date: Fri, 18 Jul 2014 03:11:45 +0400
Message-Id: <1405638705-320-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a couple of places in client code where returned value
of try_module_get() is ignored. As a result there is a small chance
to premature unload module because of unbalanced refcounting.

The patch adds error handling in that places.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 fs/nfs/client.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1d09289c8f0e..a3531fcdc58a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -110,8 +110,8 @@ struct nfs_subversion *get_nfs_version(unsigned int version)
 		mutex_unlock(&nfs_version_mutex);
 	}
 
-	if (!IS_ERR(nfs))
-		try_module_get(nfs->owner);
+	if (!IS_ERR(nfs) && !try_module_get(nfs->owner))
+		return ERR_PTR(-EAGAIN);
 	return nfs;
 }
 
@@ -158,7 +158,8 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 		goto error_0;
 
 	clp->cl_nfs_mod = cl_init->nfs_mod;
-	try_module_get(clp->cl_nfs_mod->owner);
+	if (!try_module_get(clp->cl_nfs_mod->owner))
+		goto error_dealloc;
 
 	clp->rpc_ops = clp->cl_nfs_mod->rpc_ops;
 
@@ -190,6 +191,7 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 
 error_cleanup:
 	put_nfs_version(clp->cl_nfs_mod);
+error_dealloc:
 	kfree(clp);
 error_0:
 	return ERR_PTR(err);
-- 
1.9.1

