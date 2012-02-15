Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1380 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754878Ab2BOVAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 16:00:00 -0500
From: andros@netapp.com
To: trond.myklebust.netapp.com@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 set the cl_hostname for data servers
Date: Wed, 15 Feb 2012 15:59:06 -0500
Message-Id: <1329339546-1899-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Used by /proc/fs/nfsfs files.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d0f850f..9e9cb50 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1468,7 +1468,21 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 	 */
 	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
 			     mds_clp->cl_rpcclient->cl_auth->au_flavor, 0);
+	if (IS_ERR(clp))
+		return clp;
 
+	/*
+	 * cl_init.servername is NULL so the cl_hostname is not set for new
+	 * ds nfs_clients
+	 */
+	if (clp->cl_hostname == NULL) {
+		clp->cl_hostname = kstrdup(clp->cl_rpcclient->cl_server,
+					   GFP_KERNEL);
+		if (clp->cl_hostname == NULL) {
+			nfs_put_client(clp);
+			return ERR_PTR(-ENOMEM);
+		}
+	}
 	dprintk("<-- %s %p\n", __func__, clp);
 	return clp;
 }
-- 
1.7.6.4

