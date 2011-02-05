Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59733 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754662Ab1BHOoK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 09:44:10 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 29/29] SQUASHME pnfs-submit wave3 fix nfs4_ds_connect bug
Date: Sat,  5 Feb 2011 00:59:55 -0500
Message-Id: <1296885595-8879-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

MDS/DS dual role nfs_client not assigned to the nfs4_pnfs_ds->clp

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 96e9e6a..673e31e 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -131,13 +131,13 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	}
 
 	if ((clp->cl_exchange_flags & EXCHGID4_FLAG_MASK_PNFS) != 0) {
-		dprintk("%s [existing] ip=%x, port=%hu\n", __func__,
-			ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
-
 		if (!is_ds_client(clp)) {
 			status = -ENODEV;
 			goto out_put;
 		}
+		ds->ds_clp = clp;
+		dprintk("%s [existing] ip=%x, port=%hu\n", __func__,
+			ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
 		goto out;
 	}
 
@@ -155,9 +155,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	if (status)
 		goto out_put;
 
-
 	ds->ds_clp = clp;
-
 	dprintk("%s [new] ip=%x, port=%hu\n", __func__, ntohl(ds->ds_ip_addr),
 		ntohs(ds->ds_port));
 out:
-- 
1.6.6

