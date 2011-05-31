Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23308 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932858Ab1EaWtS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 May 2011 18:49:18 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: trond@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 3/3] NFS: pnfs: loop over multipath addrs on connect
Date: Tue, 31 May 2011 18:48:58 -0400
Message-Id: <1306882138-6528-4-git-send-email-dros@netapp.com>
In-Reply-To: <1306882138-6528-1-git-send-email-dros@netapp.com>
References: <1306882138-6528-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Don't just use the first addr in the multipath list - instead, loop
over addresses when calling nfs4_set_ds_client() (which calls connect)
until it is successful.

Although this is not real multipath support, it's a quick fix to handle when
an MDS sends a list of addresses for a DS and some of the addr families are
unsupported or misconfigured (like no routable ipv6 addr assigned).
This will attempt all paths to the DS before giving up, instead of immediately
falling back to the MDS.

As before, an error encountered after a successful connect() will cause all
i/o to fall back to the MDS.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index f26c1cf..aff4d9a 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -169,7 +169,7 @@ _data_server_match_all_addrs_locked(struct list_head *dsaddrs1,
 static int
 nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 {
-	struct nfs_client *clp;
+	struct nfs_client *clp = ERR_PTR(-EIO);
 	struct nfs4_pnfs_ds_addr *da;
 	int status = 0;
 
@@ -178,13 +178,17 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 
 	BUG_ON(list_empty(&ds->ds_addrs));
 
-	da = list_first_entry(&ds->ds_addrs, struct nfs4_pnfs_ds_addr, da_node);
-	dprintk("%s: using the first address for DS %s: %s\n",
-		__func__, ds->ds_remotestr, da->da_remotestr);
+	list_for_each_entry(da, &ds->ds_addrs, da_node) {
+		dprintk("%s: DS %s: trying address %s\n",
+			__func__, ds->ds_remotestr, da->da_remotestr);
 
-	clp = nfs4_set_ds_client(mds_srv->nfs_client,
+		clp = nfs4_set_ds_client(mds_srv->nfs_client,
 				 (struct sockaddr *)&da->da_addr,
 				 da->da_addrlen, IPPROTO_TCP);
+		if (!IS_ERR(clp))
+			break;
+	}
+
 	if (IS_ERR(clp)) {
 		status = PTR_ERR(clp);
 		goto out;
-- 
1.7.5.2

