Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36420 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756637AbcLQS1Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 13:27:24 -0500
Received: by mail-it0-f67.google.com with SMTP id n68so6178446itn.3
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 10:27:23 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] NFS: Clean up nfs_attribute_timeout()
Date: Sat, 17 Dec 2016 13:27:11 -0500
Message-Id: <20161217182711.10643-10-trond.myklebust@primarydata.com>
In-Reply-To: <20161217182711.10643-9-trond.myklebust@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
 <20161217182711.10643-3-trond.myklebust@primarydata.com>
 <20161217182711.10643-4-trond.myklebust@primarydata.com>
 <20161217182711.10643-5-trond.myklebust@primarydata.com>
 <20161217182711.10643-6-trond.myklebust@primarydata.com>
 <20161217182711.10643-7-trond.myklebust@primarydata.com>
 <20161217182711.10643-8-trond.myklebust@primarydata.com>
 <20161217182711.10643-9-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It can be made static.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c         | 14 +++++++-------
 include/linux/nfs_fs.h |  1 -
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 8224e96b5808..a0cd79646c1b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -160,6 +160,13 @@ int nfs_sync_mapping(struct address_space *mapping)
 	return ret;
 }
 
+static int nfs_attribute_timeout(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	return !time_in_range_open(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
+}
+
 static bool nfs_check_cache_invalid_delegated(struct inode *inode, unsigned long flags)
 {
 	unsigned long cache_validity = READ_ONCE(NFS_I(inode)->cache_validity);
@@ -1076,13 +1083,6 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	return status;
 }
 
-int nfs_attribute_timeout(struct inode *inode)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-
-	return !time_in_range_open(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
-}
-
 int nfs_attribute_cache_expired(struct inode *inode)
 {
 	if (nfs_have_delegated_attributes(inode))
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index fe2e7810ae80..f1da8c8dd473 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -340,7 +340,6 @@ extern void nfs_access_add_cache(struct inode *, struct nfs_access_entry *);
 extern void nfs_access_set_mask(struct nfs_access_entry *, u32);
 extern int nfs_permission(struct inode *, int);
 extern int nfs_open(struct inode *, struct file *);
-extern int nfs_attribute_timeout(struct inode *inode);
 extern int nfs_attribute_cache_expired(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
-- 
2.9.3

