From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] nfs: obliterate NFS_FLAGS macro
Date: Wed, 23 Jan 2008 08:58:59 +0200
Message-ID: <1201071539-25479-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, NFSv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: 1201028301.30335.39.camel@heimdal.trondhjem.org
References: 1201028301.30335.39.camel@heimdal.trondhjem.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

use NFS_I(inode)->flags instead

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/dir.c           |    8 ++++----
 fs/nfs/inode.c         |    6 +++---
 fs/nfs/read.c          |    2 +-
 include/linux/nfs_fs.h |    5 ++---
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f697b5c..30c1614 100644
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
@@ -1731,7 +1731,7 @@ static void __nfs_access_zap_cache(struct inode *inode)
 void nfs_access_zap_cache(struct inode *inode)
 {
 	/* Remove from global LRU init */
-	if (test_and_clear_bit(NFS_INO_ACL_LRU_SET, &NFS_FLAGS(inode))) {
+	if (test_and_clear_bit(NFS_INO_ACL_LRU_SET, &NFS_I(inode)->flags)) {
 		spin_lock(&nfs_access_lru_lock);
 		list_del_init(&NFS_I(inode)->access_cache_inode_lru);
 		spin_unlock(&nfs_access_lru_lock);
@@ -1845,7 +1845,7 @@ static void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *s
 	smp_mb__after_atomic_inc();
 
 	/* Add inode to global LRU list */
-	if (!test_and_set_bit(NFS_INO_ACL_LRU_SET, &NFS_FLAGS(inode))) {
+	if (!test_and_set_bit(NFS_INO_ACL_LRU_SET, &NFS_I(inode)->flags)) {
 		spin_lock(&nfs_access_lru_lock);
 		list_add_tail(&NFS_I(inode)->access_cache_inode_lru, &nfs_access_lru_list);
 		spin_unlock(&nfs_access_lru_lock);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index db5d96d..e790d6e 100644
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
@@ -659,7 +659,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		if (status == -ESTALE) {
 			nfs_zap_caches(inode);
 			if (!S_ISDIR(inode->i_mode))
-				set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
+				set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
 		}
 		goto out;
 	}
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 4587a86..a6c9f23 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -338,7 +338,7 @@ int nfs_readpage_result(struct rpc_task *task, struct nfs_read_data *data)
 	nfs_add_stats(data->inode, NFSIOS_SERVERREADBYTES, data->res.count);
 
 	if (task->tk_status == -ESTALE) {
-		set_bit(NFS_INO_STALE, &NFS_FLAGS(data->inode));
+		set_bit(NFS_INO_STALE, &NFS_I(data->inode)->flags);
 		nfs_mark_for_revalidate(data->inode);
 	}
 	return 0;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 2d15d4a..e53b091 100644
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
-- 
1.5.3.3
