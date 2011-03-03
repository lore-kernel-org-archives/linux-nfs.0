Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32592 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756708Ab1CCPOq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 10:14:46 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/9] NFSv4.1: trigger LAYOUTGET for writes
Date: Thu,  3 Mar 2011 10:13:44 -0500
Message-Id: <1299165229-3148-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1299165229-3148-1-git-send-email-iisaman@netapp.com>
References: <1299165229-3148-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c  |   22 ++++++++++++++++++++++
 fs/nfs/pnfs.h  |    7 +++++++
 fs/nfs/write.c |   32 ++++++++++++++++++++------------
 3 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3e54514..5f205d3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -873,6 +873,28 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 	pgio->pg_test = (ld && ld->pg_test) ? pnfs_read_pg_test : NULL;
 }
 
+static int pnfs_write_pg_test(struct nfs_pageio_descriptor *pgio,
+			      struct nfs_page *prev,
+			      struct nfs_page *req)
+{
+	if (pgio->pg_count == prev->wb_bytes) {
+		/* This is first coelesce call for a series of nfs_pages */
+		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+						   prev->wb_context,
+						   IOMODE_RW);
+	}
+	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
+}
+
+void
+pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
+{
+	struct pnfs_layoutdriver_type *ld;
+
+	ld = NFS_SERVER(inode)->pnfs_curr_ld;
+	pgio->pg_test = (ld && ld->pg_test) ? pnfs_write_pg_test : NULL;
+}
+
 /*
  * Call the appropriate parallel I/O subsystem read function.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index acbb778..1d4e631 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -123,6 +123,7 @@ void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
+void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
@@ -235,6 +236,12 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *ino)
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
index 0df18ae..c618d41 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -919,6 +919,8 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
 	} while (nbytes != 0);
 	atomic_set(&req->wb_complete, requests);
 
+	BUG_ON(lseg);
+	lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_RW);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = count;
@@ -940,6 +942,7 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
 		nbytes -= wsize;
 	} while (nbytes != 0);
 
+	put_lseg(lseg);
 	return ret;
 
 out_bad:
@@ -965,11 +968,18 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_write_data	*data;
+	int ret;
 
 	data = nfs_writedata_alloc(npages);
-	if (!data)
-		goto out_bad;
-
+	if (!data) {
+		while (!list_empty(head)) {
+			req = nfs_list_entry(head->next);
+			nfs_list_remove_request(req);
+			nfs_redirty_request(req);
+		}
+		ret = -ENOMEM;
+		goto out;
+	}
 	pages = data->pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
@@ -979,16 +989,14 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 		*pages++ = req->wb_page;
 	}
 	req = nfs_list_entry(data->pages.next);
+	if ((!lseg) && list_is_singular(&data->pages))
+		lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_RW);
 
 	/* Set up the argument struct */
-	return nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, lseg, how);
- out_bad:
-	while (!list_empty(head)) {
-		req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_redirty_request(req);
-	}
-	return -ENOMEM;
+	ret = nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, lseg, how);
+out:
+	put_lseg(lseg); /* Cleans any gotten in ->pg_test */
+	return ret;
 }
 
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
@@ -996,7 +1004,7 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 {
 	size_t wsize = NFS_SERVER(inode)->wsize;
 
-	pgio->pg_test = NULL;
+	pnfs_pageio_init_write(pgio, inode);
 
 	if (wsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
-- 
1.7.2.1

