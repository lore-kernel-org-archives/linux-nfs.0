From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 109/112] nfs: obliterate NFS_FLAGS macro
Date: Fri, 25 Jan 2008 11:38:03 -0500
Message-ID: <20080125163802.31887.44506.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755126AbYAYQ77 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:59 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxlnx019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:54 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

use NFS_I(inode)->flags instead

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c           |    8 ++++----
 fs/nfs/inode.c         |    6 +++---
 fs/nfs/read.c          |    2 +-
 include/linux/nfs_fs.h |    5 ++---
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 410449d..ab06b0b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -192,7 +192,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 		/* We requested READDIRPLUS, but the server doesn't grok it */
 		if (error == -ENOTSUPP && desc->plus) {
 			NFS_SERVER(inode)->caps &= ~NFS_CAP_READDIRPLUS;
-			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
+			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			desc->plus = 0;
 			goto again;
 		}
@@ -579,7 +579,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 			break;
 		}
 		if (res == -ETOOSMALL && desc->plus) {
-			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
+			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			nfs_zap_caches(inode);
 			desc->plus = 0;
 			desc->entry->eof = 0;
@@ -1746,7 +1746,7 @@ static void __nfs_access_zap_cache(struct inode *inode)
 void nfs_access_zap_cache(struct inode *inode)
 {
 	/* Remove from global LRU init */
-	if (test_and_clear_bit(NFS_INO_ACL_LRU_SET, &NFS_FLAGS(inode))) {
+	if (test_and_clear_bit(NFS_INO_ACL_LRU_SET, &NFS_I(inode)->flags)) {
 		spin_lock(&nfs_access_lru_lock);
 		list_del_init(&NFS_I(inode)->access_cache_inode_lru);
 		spin_unlock(&nfs_access_lru_lock);
@@ -1860,7 +1860,7 @@ static void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *s
 	smp_mb__after_atomic_inc();
 
 	/* Add inode to global LRU list */
-	if (!test_and_set_bit(NFS_INO_ACL_LRU_SET, &NFS_FLAGS(inode))) {
+	if (!test_and_set_bit(NFS_INO_ACL_LRU_SET, &NFS_I(inode)->flags)) {
 		spin_lock(&nfs_access_lru_lock);
 		list_add_tail(&NFS_I(inode)->access_cache_inode_lru, &nfs_access_lru_list);
 		spin_unlock(&nfs_access_lru_lock);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5747d49..9d7b08c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -192,7 +192,7 @@ void nfs_invalidate_atime(struct inode *inode)
  */
 static void nfs_invalidate_inode(struct inode *inode)
 {
-	set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
+	set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
 	nfs_zap_caches_locked(inode);
 }
 
@@ -291,7 +291,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 			inode->i_fop = &nfs_dir_operations;
 			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS)
 			    && fattr->size <= NFS_LIMIT_READDIRPLUS)
-				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
+				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			/* Deal with crossing mountpoints */
 			if (!nfs_fsid_equal(&NFS_SB(sb)->fsid, &fattr->fsid)) {
 				if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
@@ -668,7 +668,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		if (status == -ESTALE) {
 			nfs_zap_caches(inode);
 			if (!S_ISDIR(inode->i_mode))
-				set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
+				set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
 		}
 		goto out;
 	}
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index efc121c..8fd6dfb 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -336,7 +336,7 @@ int nfs_readpage_result(struct rpc_task *task, struct nfs_read_data *data)
 	nfs_add_stats(data->inode, NFSIOS_SERVERREADBYTES, data->res.count);
 
 	if (task->tk_status == -ESTALE) {
-		set_bit(NFS_INO_STALE, &NFS_FLAGS(data->inode));
+		set_bit(NFS_INO_STALE, &NFS_I(data->inode)->flags);
 		nfs_mark_for_revalidate(data->inode);
 	}
 	return 0;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 7095aaa..9e7c24a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -214,8 +214,7 @@ static inline struct nfs_inode *NFS_I(struct inode *inode)
 	(S_ISDIR(inode->i_mode)? NFS_SERVER(inode)->acdirmax \
 			       : NFS_SERVER(inode)->acregmax)
 
-#define NFS_FLAGS(inode)		(NFS_I(inode)->flags)
-#define NFS_STALE(inode)		(test_bit(NFS_INO_STALE, &NFS_FLAGS(inode)))
+#define NFS_STALE(inode)		(test_bit(NFS_INO_STALE, &NFS_I(inode)->flags))
 
 #define NFS_FILEID(inode)		(NFS_I(inode)->fileid)
 
@@ -237,7 +236,7 @@ static inline int nfs_server_capable(struct inode *inode, int cap)
 
 static inline int NFS_USE_READDIRPLUS(struct inode *inode)
 {
-	return test_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
+	return test_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 }
 
 static inline void nfs_set_verifier(struct dentry * dentry, unsigned long verf)
