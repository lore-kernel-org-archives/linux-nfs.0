From: andros@netapp.com
Subject: [PATCH 13/13] SQUASHME pnfs_submit: cleanup nfs4_pnfs_ds_add
Date: Thu, 29 Apr 2010 16:34:51 -0400
Message-ID: <1272573291-8986-14-git-send-email-andros@netapp.com>
References: <1272573291-8986-1-git-send-email-andros@netapp.com>
 <1272573291-8986-2-git-send-email-andros@netapp.com>
 <1272573291-8986-3-git-send-email-andros@netapp.com>
 <1272573291-8986-4-git-send-email-andros@netapp.com>
 <1272573291-8986-5-git-send-email-andros@netapp.com>
 <1272573291-8986-6-git-send-email-andros@netapp.com>
 <1272573291-8986-7-git-send-email-andros@netapp.com>
 <1272573291-8986-8-git-send-email-andros@netapp.com>
 <1272573291-8986-9-git-send-email-andros@netapp.com>
 <1272573291-8986-10-git-send-email-andros@netapp.com>
 <1272573291-8986-11-git-send-email-andros@netapp.com>
 <1272573291-8986-12-git-send-email-andros@netapp.com>
 <1272573291-8986-13-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52310 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757558Ab0D3Qs7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 12:48:59 -0400
In-Reply-To: <1272573291-8986-13-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Only initialize struct nfs4_pnfs_ds_add when using it.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index d80b132..4b2b8ac 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -273,31 +273,29 @@ nfs4_pnfs_ds_add(struct inode *inode, struct nfs4_pnfs_ds **dsp,
 	if (!ds)
 		return;
 
-	/* Initialize ds */
-	ds->ds_ip_addr = ip_addr;
-	ds->ds_port = port;
-	strncpy(ds->r_addr, r_addr, len);
-	atomic_set(&ds->ds_count, 1);
-	INIT_LIST_HEAD(&ds->ds_node);
-	ds->ds_clp = NULL;
-
 	spin_lock(&nfs4_ds_cache_lock);
 	tmp_ds = _data_server_lookup(ip_addr, port);
 	if (tmp_ds == NULL) {
-		dprintk("%s add new data server ip 0x%x\n", __func__,
-				ds->ds_ip_addr);
+		ds->ds_ip_addr = ip_addr;
+		ds->ds_port = port;
+		strncpy(ds->r_addr, r_addr, len);
+		atomic_set(&ds->ds_count, 1);
+		INIT_LIST_HEAD(&ds->ds_node);
+		ds->ds_clp = NULL;
 		list_add(&ds->ds_node, &nfs4_data_server_cache);
 		*dsp = ds;
+		dprintk("%s add new data server ip 0x%x\n", __func__,
+				ds->ds_ip_addr);
+		spin_unlock(&nfs4_ds_cache_lock);
 	} else {
 		atomic_inc(&tmp_ds->ds_count);
+		*dsp = tmp_ds;
 		dprintk("%s data server found ip 0x%x, inc'ed ds_count to %d\n",
 				__func__, tmp_ds->ds_ip_addr,
 				atomic_read(&tmp_ds->ds_count));
-		*dsp = tmp_ds;
+		spin_unlock(&nfs4_ds_cache_lock);
+		kfree(ds);
 	}
-	spin_unlock(&nfs4_ds_cache_lock);
-	if (tmp_ds != NULL)
-		destroy_ds(ds);
 }
 
 static struct nfs4_pnfs_ds *
-- 
1.6.6

