From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 110/112] nfs: convert NFS_*(inode) helpers to static inline
Date: Fri, 25 Jan 2008 11:38:03 -0500
Message-ID: <20080125163803.31887.85464.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14368 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755825AbYAYRAG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:06 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxsew010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:03 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c         |    2 +
 include/linux/nfs_fs.h |   76 +++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 59 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9d7b08c..5d381cf 100644
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
index 9e7c24a..099ddb4 100644
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
