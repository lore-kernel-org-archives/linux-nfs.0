Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:55398 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375AbaEOP5R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2014 11:57:17 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so8115714igb.2
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2014 08:57:16 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v3 07/18] nfs: page group syncing in read path
Date: Thu, 15 May 2014 11:56:46 -0400
Message-Id: <1400169417-28245-8-git-send-email-dros@primarydata.com>
In-Reply-To: <1400169417-28245-1-git-send-email-dros@primarydata.com>
References: <1400169417-28245-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Operations that modify state for a whole page must be syncronized across
all requests within a page group. In the read path, this is calling
unlock_page and SetPageUptodate. Both of these functions should not be
called until all requests in a page group have reached the point where
they would call them.

This patch should have no effect yet since all page groups currently
have one request, but will come into play when pg_test functions are
modified to split pages into sub-page regions.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c        |  2 ++
 fs/nfs/read.c            | 22 +++++++++++++++++-----
 include/linux/nfs_page.h |  2 ++
 3 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 517c617..87cdb4b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -395,6 +395,8 @@ static void nfs_free_request(struct nfs_page *req)
 
 	/* extra debug: make sure no sync bits are still set */
 	WARN_ON_ONCE(test_bit(PG_TEARDOWN, &req->wb_flags));
+	WARN_ON_ONCE(test_bit(PG_UNLOCKPAGE, &req->wb_flags));
+	WARN_ON_ONCE(test_bit(PG_UPTODATE, &req->wb_flags));
 
 	/* Release struct file and open context */
 	nfs_clear_request(req);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 902ba2c..53d5b83 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -105,10 +105,16 @@ static void nfs_readpage_release(struct nfs_page *req)
 {
 	struct inode *d_inode = req->wb_context->dentry->d_inode;
 
-	if (PageUptodate(req->wb_page))
-		nfs_readpage_to_fscache(d_inode, req->wb_page, 0);
+	dprintk("NFS: read done (%s/%llu %d@%lld)\n", d_inode->i_sb->s_id,
+		(unsigned long long)NFS_FILEID(d_inode), req->wb_bytes,
+		(long long)req_offset(req));
 
-	unlock_page(req->wb_page);
+	if (nfs_page_group_sync_on_bit(req, PG_UNLOCKPAGE)) {
+		if (PageUptodate(req->wb_page))
+			nfs_readpage_to_fscache(d_inode, req->wb_page, 0);
+
+		unlock_page(req->wb_page);
+	}
 
 	dprintk("NFS: read done (%s/%Lu %d@%Ld)\n",
 			req->wb_context->dentry->d_inode->i_sb->s_id,
@@ -118,6 +124,12 @@ static void nfs_readpage_release(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
+static void nfs_page_group_set_uptodate(struct nfs_page *req)
+{
+	if (nfs_page_group_sync_on_bit(req, PG_UPTODATE))
+		SetPageUptodate(req->wb_page);
+}
+
 /* Note io was page aligned */
 static void nfs_read_completion(struct nfs_pgio_header *hdr)
 {
@@ -140,9 +152,9 @@ static void nfs_read_completion(struct nfs_pgio_header *hdr)
 		bytes += req->wb_bytes;
 		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
 			if (bytes <= hdr->good_bytes)
-				SetPageUptodate(page);
+				nfs_page_group_set_uptodate(req);
 		} else
-			SetPageUptodate(page);
+			nfs_page_group_set_uptodate(req);
 		nfs_list_remove_request(req);
 		nfs_readpage_release(req);
 	}
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 986c0c2..6385175 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -29,6 +29,8 @@ enum {
 	PG_INODE_REF,		/* extra ref held by inode (head req only) */
 	PG_HEADLOCK,		/* page group lock of wb_head */
 	PG_TEARDOWN,		/* page group sync for destroy */
+	PG_UNLOCKPAGE,		/* page group sync bit in read path */
+	PG_UPTODATE,		/* page group sync bit in read path */
 };
 
 struct nfs_inode;
-- 
1.8.5.2 (Apple Git-48)

