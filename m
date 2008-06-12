From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 34/37] NFS: Ensure we zap only the access and acl caches
	when setting new acls
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.10436.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755179AbYFLTeK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:10 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJY9oX003121
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:34:09 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and ensure that we obey the NFS_INO_INVALID_ACL flag when retrieving the
acls.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c    |    4 +---
 fs/nfs/internal.h |    1 +
 fs/nfs/nfs3acl.c  |    9 ++++++---
 fs/nfs/nfs4proc.c |    5 ++++-
 4 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2e4ab4a..2c23d06 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -57,8 +57,6 @@ static int enable_ino64 = NFS_64_BIT_INODE_NUMBERS_ENABLED;
 static void nfs_invalidate_inode(struct inode *);
 static int nfs_update_inode(struct inode *, struct nfs_fattr *);
 
-static void nfs_zap_acl_cache(struct inode *);
-
 static struct kmem_cache * nfs_inode_cachep;
 
 static inline unsigned long
@@ -167,7 +165,7 @@ void nfs_zap_mapping(struct inode *inode, struct address_space *mapping)
 	}
 }
 
-static void nfs_zap_acl_cache(struct inode *inode)
+void nfs_zap_acl_cache(struct inode *inode)
 {
 	void (*clear_acl_cache)(struct inode *);
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 04ae867..24241fc 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -150,6 +150,7 @@ extern void nfs_clear_inode(struct inode *);
 #ifdef CONFIG_NFS_V4
 extern void nfs4_clear_inode(struct inode *);
 #endif
+void nfs_zap_acl_cache(struct inode *inode);
 
 /* super.c */
 extern struct file_system_type nfs_xdev_fs_type;
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 9b73625..423842f 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -5,6 +5,8 @@
 #include <linux/posix_acl_xattr.h>
 #include <linux/nfsacl.h>
 
+#include "internal.h"
+
 #define NFSDBG_FACILITY	NFSDBG_PROC
 
 ssize_t nfs3_listxattr(struct dentry *dentry, char *buffer, size_t size)
@@ -205,6 +207,8 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 	status = nfs_revalidate_inode(server, inode);
 	if (status < 0)
 		return ERR_PTR(status);
+	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
+		nfs_zap_acl_cache(inode);
 	acl = nfs3_get_cached_acl(inode, type);
 	if (acl != ERR_PTR(-EAGAIN))
 		return acl;
@@ -319,9 +323,8 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	dprintk("NFS call setacl\n");
 	msg.rpc_proc = &server->client_acl->cl_procinfo[ACLPROC3_SETACL];
 	status = rpc_call_sync(server->client_acl, &msg, 0);
-	spin_lock(&inode->i_lock);
-	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ACCESS;
-	spin_unlock(&inode->i_lock);
+	nfs_access_zap_cache(inode);
+	nfs_zap_acl_cache(inode);
 	dprintk("NFS reply setacl: %d\n", status);
 
 	/* pages may have been allocated at the xdr layer. */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0fc1068..66f13dc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2705,6 +2705,8 @@ static ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen)
 	ret = nfs_revalidate_inode(server, inode);
 	if (ret < 0)
 		return ret;
+	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
+		nfs_zap_acl_cache(inode);
 	ret = nfs4_read_cached_acl(inode, buf, buflen);
 	if (ret != -ENOENT)
 		return ret;
@@ -2732,7 +2734,8 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	nfs_inode_return_delegation(inode);
 	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
 	ret = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	nfs_zap_caches(inode);
+	nfs_access_zap_cache(inode);
+	nfs_zap_acl_cache(inode);
 	return ret;
 }
 

