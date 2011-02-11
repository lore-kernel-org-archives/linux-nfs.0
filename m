Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757749Ab1BKSAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:42 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 01/17] SQUASHME pnfs-submit wave3 fix nfs4_ds_connect bug
Date: Thu, 10 Feb 2011 20:52:34 -0500
Message-Id: <1297389170-26702-2-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-1-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

MDS/DS dual role nfs_client not assigned to the nfs4_pnfs_ds->clp

squash into: pnfs-submit-wave3-data-server-connection.patch

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

