Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17119 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757730Ab1BKQzB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 11:55:01 -0500
Received: from localhost.localdomain (manjua-lxp.hq.netapp.com [10.58.49.248] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p1BGshZA002533
	for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 08:54:48 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/7] wave4: nfs_pageio_do_add_request needs to distinguish between read and write
Date: Fri, 11 Feb 2011 11:54:39 -0500
Message-Id: <1297443279-19813-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
References: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is so that it can send the appropriate mode in LAYOUTGET.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pagelist.c        |    7 +++----
 fs/nfs/pnfs.c            |    8 ++++++++
 fs/nfs/pnfs.h            |    7 +++++++
 fs/nfs/write.c           |    2 +-
 include/linux/nfs_page.h |    1 +
 5 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index f0aa20b..0518d62a 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -299,10 +299,9 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 	} else {
 		put_lseg(desc->pg_lseg);
 		desc->pg_base = req->wb_pgbase;
-		if (desc->pg_test)
-			desc->pg_lseg = pnfs_update_layout(desc->pg_inode,
-							   req->wb_context,
-							   IOMODE_READ);
+		desc->pg_lseg = pnfs_update_layout(desc->pg_inode,
+						   req->wb_context,
+						   desc->pg_iomode);
 	}
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &desc->pg_list);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9d2351a..a2ee472 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -889,6 +889,14 @@ void
 pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 		  struct inode *inode)
 {
+	pgio->pg_iomode = IOMODE_READ;
+	pnfs_set_pg_test(inode, pgio);
+}
+
+void
+pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
+{
+	pgio->pg_iomode = IOMODE_RW;
 	pnfs_set_pg_test(inode, pgio);
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 50bcb1f..16f9fa5 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -179,6 +179,7 @@ enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
 enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
+void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
@@ -297,6 +298,12 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *ino)
 	pgio->pg_test = NULL;
 }
 
+static inline void
+pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *ino)
+{
+	pgio->pg_test = NULL;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5757b06..4c21045 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1001,7 +1001,7 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 {
 	size_t wsize = NFS_SERVER(inode)->wsize;
 
-	pgio->pg_test = NULL;
+	pnfs_pageio_init_write(pgio, inode);
 
 	if (wsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index ba88ff4..fd57be2 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -63,6 +63,7 @@ struct nfs_pageio_descriptor {
 	int 			pg_ioflags;
 	int			pg_error;
 	struct pnfs_layout_segment *pg_lseg;
+	int			pg_iomode;
 	int			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 };
 
-- 
1.7.2.1

