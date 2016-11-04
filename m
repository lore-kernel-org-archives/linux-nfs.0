Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:46358 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754278AbcKDNJL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Nov 2016 09:09:11 -0400
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>, <jlayton@redhat.com>
Subject: [PATCH] NFS: Don't print a pNFS error if we aren't using pNFS
Date: Fri, 4 Nov 2016 09:08:41 -0400
Message-ID: <20161104130841.17150-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

We used to check for a valid layout type id before verifying pNFS flags
as an indicator for if we are using pNFS.  This changed in 3132e49ece
with the introduction of multiple layout types, since now we are passing
an array of ids instead of just one.  Since then, users have been seeing
a KERN_ERR printk show up whenever mounting NFS v4 without pNFS.  This
patch restores the original behavior of exiting set_pnfs_layoutdriver()
early if we aren't using pNFS.

Fixes 3132e49ece ("pnfs: track multiple layout types in fsinfo
structure")
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pnfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 56b2d96..259ef85 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -146,6 +146,8 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
 	u32 id;
 	int i;
 
+	if (fsinfo->nlayouttypes == 0)
+		goto out_no_driver;
 	if (!(server->nfs_client->cl_exchange_flags &
 		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
 		printk(KERN_ERR "NFS: %s: cl_exchange_flags 0x%x\n",
-- 
2.10.1

