From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] nfs: convert NFS_*(inode) helpers to static inline
Date: Wed, 23 Jan 2008 08:59:08 +0200
Message-ID: <1201071548-25498-1-git-send-email-bhalevy@panasas.com>
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

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/inode.c         |    2 +-
 include/linux/nfs_fs.h |   76 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 59 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e790d6e..aadf22d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -229,7 +229,7 @@ nfs_init_locked(struct inode *inode, void *opaque)
 	struct nfs_find_desc	*desc = (struct nfs_find_desc *)opaque;
 	struct nfs_fattr	*fattr = desc->fattr;
 
-	NFS_FILEID(inode) = fattr->fileid;
+	set_nfs_fileid(inode, fattr->fileid);
 	nfs_copy_fh(NFS_FH(inode), desc->fh);
 	return 0;
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e53b091..de0e2bd 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -196,27 +196,67 @@ struct nfs_inode {
 #define NFS_INO_STALE		(2)		/* possible stale inode */
 #define NFS_INO_ACL_LRU_SET	(3)		/* Inode is on the LRU list */
 
-static inline struct nfs_inode *NFS_I(struct inode *inode)
+static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {
 	return container_of(inode, struct nfs_inode, vfs_inode);
 }
-#define NFS_SB(s)		((struct nfs_server *)(s->s_fs_info))
-
-#define NFS_FH(inode)			(&NFS_I(inode)->fh)
-#define NFS_SERVER(inode)		(NFS_SB(inode->i_sb))
-#define NFS_CLIENT(inode)		(NFS_SERVER(inode)->client)
-#define NFS_PROTO(inode)		(NFS_SERVER(inode)->nfs_client->rpc_ops)
-#define NFS_COOKIEVERF(inode)		(NFS_I(inode)->cookieverf)
-#define NFS_MINATTRTIMEO(inode) \
-	(S_ISDIR(inode->i_mode)? NFS_SERVER(inode)->acdirmin \
-			       : NFS_SERVER(inode)->acregmin)
-#define NFS_MAXATTRTIMEO(inode) \
-	(S_ISDIR(inode->i_mode)? NFS_SERVER(inode)->acdirmax \
-			       : NFS_SERVER(inode)->acregmax)
-
-#define NFS_STALE(inode)		(test_bit(NFS_INO_STALE, &NFS_I(inode)->flags))
-
-#define NFS_FILEID(inode)		(NFS_I(inode)->fileid)
+
+static inline struct nfs_server *NFS_SB(const struct super_block *s)
+{
+	return (struct nfs_server *)(s->s_fs_info);
+}
+
+static inline struct nfs_fh *NFS_FH(const struct inode *inode)
+{
+	return &NFS_I(inode)->fh;
+}
+
+static inline struct nfs_server *NFS_SERVER(const struct inode *inode)
+{
+	return NFS_SB(inode->i_sb);
+}
+
+static inline struct rpc_clnt *NFS_CLIENT(const struct inode *inode)
+{
+	return NFS_SERVER(inode)->client;
+}
+
+static inline const struct nfs_rpc_ops *NFS_PROTO(const struct inode *inode)
+{
+	return NFS_SERVER(inode)->nfs_client->rpc_ops;
+}
+
+static inline __be32 *NFS_COOKIEVERF(const struct inode *inode)
+{
+	return NFS_I(inode)->cookieverf;
+}
+
+static inline unsigned NFS_MINATTRTIMEO(const struct inode *inode)
+{
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	return S_ISDIR(inode->i_mode) ? nfss->acdirmin : nfss->acregmin;
+}
+
+static inline unsigned NFS_MAXATTRTIMEO(const struct inode *inode)
+{
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	return S_ISDIR(inode->i_mode) ? nfss->acdirmax : nfss->acregmax;
+}
+
+static inline int NFS_STALE(const struct inode *inode)
+{
+	return test_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
+}
+
+static inline __u64 NFS_FILEID(const struct inode *inode)
+{
+	return NFS_I(inode)->fileid;
+}
+
+static inline void set_nfs_fileid(struct inode *inode, __u64 fileid)
+{
+	NFS_I(inode)->fileid = fileid;
+}
 
 static inline void nfs_mark_for_revalidate(struct inode *inode)
 {
-- 
1.5.3.3
