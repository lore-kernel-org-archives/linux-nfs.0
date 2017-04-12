Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40267 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752672AbdDLKZP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Apr 2017 06:25:15 -0400
From: Jan Kara <jack@suse.cz>
To: Jens Axboe <axboe@kernel.dk>
Cc: <linux-block@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        Jan Kara <jack@suse.cz>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 21/25] nfs: Convert to separately allocated bdi
Date: Wed, 12 Apr 2017 12:24:45 +0200
Message-Id: <20170412102449.16901-22-jack@suse.cz>
In-Reply-To: <20170412102449.16901-1-jack@suse.cz>
References: <20170412102449.16901-1-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allocate struct backing_dev_info separately instead of embedding it
inside the superblock. This unifies handling of bdi among users.

CC: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Anna Schumaker <anna.schumaker@netapp.com>
CC: linux-nfs@vger.kernel.org
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/client.c           | 10 ----------
 fs/nfs/internal.h         |  6 +++---
 fs/nfs/super.c            | 34 +++++++++++++++++++---------------
 fs/nfs/write.c            | 13 ++++++-------
 include/linux/nfs_fs_sb.h |  1 -
 5 files changed, 28 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 390ada8741bc..04d15a0045e3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -761,9 +761,6 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 		server->rsize = NFS_MAX_FILE_IO_SIZE;
 	server->rpages = (server->rsize + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
-	server->backing_dev_info.name = "nfs";
-	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
-
 	if (server->wsize > max_rpc_payload)
 		server->wsize = max_rpc_payload;
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
@@ -917,12 +914,6 @@ struct nfs_server *nfs_alloc_server(void)
 		return NULL;
 	}
 
-	if (bdi_init(&server->backing_dev_info)) {
-		nfs_free_iostats(server->io_stats);
-		kfree(server);
-		return NULL;
-	}
-
 	ida_init(&server->openowner_id);
 	ida_init(&server->lockowner_id);
 	pnfs_init_server(server);
@@ -953,7 +944,6 @@ void nfs_free_server(struct nfs_server *server)
 	ida_destroy(&server->lockowner_id);
 	ida_destroy(&server->openowner_id);
 	nfs_free_iostats(server->io_stats);
-	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
 	dprintk("<-- nfs_free_server()\n");
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7b38fedb7e03..9dc65d7ae754 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -139,7 +139,7 @@ struct nfs_mount_request {
 };
 
 struct nfs_mount_info {
-	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
+	int (*fill_super)(struct super_block *, struct nfs_mount_info *);
 	int (*set_security)(struct super_block *, struct dentry *, struct nfs_mount_info *);
 	struct nfs_parsed_mount_data *parsed;
 	struct nfs_clone_mount *cloned;
@@ -407,7 +407,7 @@ struct dentry *nfs_fs_mount(struct file_system_type *, int, const char *, void *
 struct dentry * nfs_xdev_mount_common(struct file_system_type *, int,
 		const char *, struct nfs_mount_info *);
 void nfs_kill_super(struct super_block *);
-void nfs_fill_super(struct super_block *, struct nfs_mount_info *);
+int nfs_fill_super(struct super_block *, struct nfs_mount_info *);
 
 extern struct rpc_stat nfs_rpcstat;
 
@@ -458,7 +458,7 @@ extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 
 /* super.c */
-void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
+int nfs_clone_super(struct super_block *, struct nfs_mount_info *);
 void nfs_umount_begin(struct super_block *);
 int  nfs_statfs(struct dentry *, struct kstatfs *);
 int  nfs_show_options(struct seq_file *, struct dentry *);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 54e0f9f2dd94..8d97aa70407e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2315,18 +2315,17 @@ inline void nfs_initialise_sb(struct super_block *sb)
 		sb->s_blocksize = nfs_block_bits(server->wsize,
 						 &sb->s_blocksize_bits);
 
-	sb->s_bdi = &server->backing_dev_info;
-
 	nfs_super_set_maxbytes(sb, server->maxfilesize);
 }
 
 /*
  * Finish setting up an NFS2/3 superblock
  */
-void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
+int nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 {
 	struct nfs_parsed_mount_data *data = mount_info->parsed;
 	struct nfs_server *server = NFS_SB(sb);
+	int ret;
 
 	sb->s_blocksize_bits = 0;
 	sb->s_blocksize = 0;
@@ -2344,13 +2343,21 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 	}
 
  	nfs_initialise_sb(sb);
+
+	ret = super_setup_bdi_name(sb, "%u:%u", MAJOR(server->s_dev),
+				   MINOR(server->s_dev));
+	if (ret)
+		return ret;
+	sb->s_bdi->ra_pages = server->rpages * NFS_MAX_READAHEAD;
+	return 0;
+
 }
 EXPORT_SYMBOL_GPL(nfs_fill_super);
 
 /*
  * Finish setting up a cloned NFS2/3/4 superblock
  */
-void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
+int nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 {
 	const struct super_block *old_sb = mount_info->cloned->sb;
 	struct nfs_server *server = NFS_SB(sb);
@@ -2370,6 +2377,11 @@ void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 	}
 
  	nfs_initialise_sb(sb);
+
+	sb->s_bdi = bdi_get(old_sb->s_bdi);
+	sb->s_iflags |= SB_I_DYNBDI;
+
+	return 0;
 }
 
 static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b, int flags)
@@ -2522,11 +2534,6 @@ static void nfs_get_cache_cookie(struct super_block *sb,
 }
 #endif
 
-static int nfs_bdi_register(struct nfs_server *server)
-{
-	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
-}
-
 int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
 			struct nfs_mount_info *mount_info)
 {
@@ -2594,17 +2601,14 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 		nfs_free_server(server);
 		server = NULL;
 	} else {
-		error = nfs_bdi_register(server);
-		if (error) {
-			mntroot = ERR_PTR(error);
-			goto error_splat_super;
-		}
 		server->super = s;
 	}
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		mount_info->fill_super(s, mount_info);
+		error = mount_info->fill_super(s, mount_info);
+		if (error)
+			goto error_splat_super;
 		nfs_get_cache_cookie(s, mount_info->parsed, mount_info->cloned);
 	}
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index abb2c8a3be42..cc341fc7fd44 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -263,16 +263,15 @@ int nfs_congestion_kb;
 
 static void nfs_set_page_writeback(struct page *page)
 {
-	struct nfs_server *nfss = NFS_SERVER(page_file_mapping(page)->host);
+	struct inode *inode = page_file_mapping(page)->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	int ret = test_set_page_writeback(page);
 
 	WARN_ON_ONCE(ret != 0);
 
 	if (atomic_long_inc_return(&nfss->writeback) >
-			NFS_CONGESTION_ON_THRESH) {
-		set_bdi_congested(&nfss->backing_dev_info,
-					BLK_RW_ASYNC);
-	}
+			NFS_CONGESTION_ON_THRESH)
+		set_bdi_congested(inode_to_bdi(inode), BLK_RW_ASYNC);
 }
 
 static void nfs_end_page_writeback(struct nfs_page *req)
@@ -285,7 +284,7 @@ static void nfs_end_page_writeback(struct nfs_page *req)
 
 	end_page_writeback(req->wb_page);
 	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+		clear_bdi_congested(inode_to_bdi(inode), BLK_RW_ASYNC);
 }
 
 
@@ -1808,7 +1807,7 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 	}
 	nfss = NFS_SERVER(data->inode);
 	if (atomic_long_read(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+		clear_bdi_congested(inode_to_bdi(data->inode), BLK_RW_ASYNC);
 
 	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
 	nfs_commit_end(cinfo.mds);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b34097c67848..e1502c55741e 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -133,7 +133,6 @@ struct nfs_server {
 	struct rpc_clnt *	client_acl;	/* ACL RPC client handle */
 	struct nlm_host		*nlm_host;	/* NLM client handle */
 	struct nfs_iostats __percpu *io_stats;	/* I/O statistics */
-	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */
 	int			flags;		/* various flags */
 	unsigned int		caps;		/* server capabilities */
-- 
2.12.0

