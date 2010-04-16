From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/24] NFS: Add helper functions for allocating filehandles and fattr structs
Date: Fri, 16 Apr 2010 16:30:59 -0400
Message-ID: <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43811 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932442Ab0DPUbY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:24 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMku026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:23 -0700 (PDT)
In-Reply-To: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS Filehandles and struct fattr are really too large to be allocated on
the stack. This patch adds in a couple of helper functions to allocate them
dynamically instead.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c         |   20 ++++++++++++++++++++
 include/linux/nfs_fs.h |   14 ++++++++++++++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 50a56ed..6e257c3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -916,6 +916,26 @@ void nfs_fattr_init(struct nfs_fattr *fattr)
 	fattr->gencount = nfs_inc_attr_generation_counter();
 }
 
+struct nfs_fattr *nfs_alloc_fattr(void)
+{
+	struct nfs_fattr *fattr;
+
+	fattr = kmalloc(sizeof(*fattr), GFP_KERNEL);
+	if (fattr != NULL)
+		nfs_fattr_init(fattr);
+	return fattr;
+}
+
+struct nfs_fh *nfs_alloc_fhandle(void)
+{
+	struct nfs_fh *fh;
+
+	fh = kmalloc(sizeof(struct nfs_fh), GFP_KERNEL);
+	if (fh != NULL)
+		fh->size = 0;
+	return fh;
+}
+
 /**
  * nfs_inode_attrs_need_update - check if the inode attributes need updating
  * @inode - pointer to inode
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1a0b85a..8f65903 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -355,6 +355,20 @@ extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struc
 extern u64 nfs_compat_user_ino64(u64 fileid);
 extern void nfs_fattr_init(struct nfs_fattr *fattr);
 
+extern struct nfs_fattr *nfs_alloc_fattr(void);
+
+static inline void nfs_free_fattr(const struct nfs_fattr *fattr)
+{
+	kfree(fattr);
+}
+
+extern struct nfs_fh *nfs_alloc_fhandle(void);
+
+static inline void nfs_free_fhandle(const struct nfs_fh *fh)
+{
+	kfree(fh);
+}
+
 /* linux/net/ipv4/ipconfig.c: trims ip addr off front of name, too. */
 extern __be32 root_nfs_parse_addr(char *name); /*__init*/
 extern unsigned long nfs_inc_attr_generation_counter(void);
-- 
1.6.6.1

