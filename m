Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39591 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753072Ab2BSHu1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Feb 2012 02:50:27 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 2/2] NFS: Ensure struct nfs_client holds a reference to the net namespace
Date: Sun, 19 Feb 2012 08:50:21 +0100
Message-Id: <1329637821-6986-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1329637821-6986-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1329637821-6986-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise we have no guarantee that the net namespace won't just
disappear from underneath us once the task that created it
is destroyed.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/client.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d0f850f..8563585 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -172,7 +172,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_rpcclient = ERR_PTR(-EINVAL);
 
 	clp->cl_proto = cl_init->proto;
-	clp->net = cl_init->net;
+	clp->net = get_net(cl_init->net);
 
 #ifdef CONFIG_NFS_V4
 	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
@@ -300,6 +300,7 @@ static void nfs_free_client(struct nfs_client *clp)
 
 	nfs4_deviceid_purge_client(clp);
 
+	put_net(clp->net);
 	kfree(clp->cl_hostname);
 	kfree(clp->server_scope);
 	kfree(clp);
-- 
1.7.7.6

