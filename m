From: andros@netapp.com
Subject: [PATCH 3/3] SQUASHME pnfs_submit: cleanup DS exchange flag processing
Date: Wed, 12 May 2010 13:39:40 -0400
Message-ID: <1273685980-3340-4-git-send-email-andros@netapp.com>
References: <1273685980-3340-1-git-send-email-andros@netapp.com>
 <1273685980-3340-2-git-send-email-andros@netapp.com>
 <1273685980-3340-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35537 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756497Ab0ELRkL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 13:40:11 -0400
In-Reply-To: <1273685980-3340-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Squash into "pnfs: filelayout: device ops"

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index b41f437..b04c9d9 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -173,18 +173,16 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 
 	clp = tmp.nfs_client;
 
-	/* Set exchange id and create session flags and setup session */
+	/* Ask for only the EXCHGID4_FLAG_USE_PNFS_DS pNFS role */
 	dprintk("%s EXCHANGE_ID for clp %p\n", __func__, clp);
 	clp->cl_exchange_flags = EXCHGID4_FLAG_USE_PNFS_DS;
+
 	err = nfs4_recover_expired_lease(clp);
 	if (!err)
 		err = nfs4_check_client_ready(clp);
 	if (err)
 		goto out_put;
 
-	/* mask out the server's MDS capability flag */
-	clp->cl_exchange_flags &= ~EXCHGID4_FLAG_USE_PNFS_MDS;
-
 	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
 		printk(KERN_INFO "ip:port %s is not a pNFS Data Server\n",
 			ds->r_addr);
@@ -193,6 +191,12 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	}
 
 	/*
+	 * Mask the (possibly) returned EXCHGID4_FLAG_USE_PNFS_MDS pNFS role
+	 * The is_ds_only_session depends on this.
+	 */
+	clp->cl_exchange_flags &= ~EXCHGID4_FLAG_USE_PNFS_MDS;
+
+	/*
 	 * Set DS lease equal to the MDS lease, renewal is scheduled in
 	 * create_session
 	 */
-- 
1.6.6

