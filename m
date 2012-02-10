Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11202 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760264Ab2BJWCc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:32 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 20/21] Export symbols for v4 module
Date: Fri, 10 Feb 2012 17:02:04 -0500
Message-Id: <1328911325-1566-20-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch should be squashed with the previous one for everything to work.  I
also need to double check that all of these are actually needed...

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c    |    6 ++++++
 fs/nfs/dir.c       |    4 ++++
 fs/nfs/file.c      |    1 +
 fs/nfs/inode.c     |    5 +++++
 fs/nfs/namespace.c |    2 ++
 fs/nfs/pagelist.c  |    3 +++
 fs/nfs/pnfs.c      |   15 +++++++++++++++
 fs/nfs/pnfs_dev.c  |    1 +
 fs/nfs/read.c      |    3 +++
 fs/nfs/super.c     |    3 +++
 fs/nfs/write.c     |    4 ++++
 11 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 6743a28..abd7d86 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -57,6 +57,7 @@ EXPORT_SYMBOL_GPL(nfs_client_lock);
 static DEFINE_SPINLOCK(nfs_version_lock);
 static LIST_HEAD(nfs_versions);
 LIST_HEAD(nfs_client_list);
+EXPORT_SYMBOL_GPL(nfs_client_list);
 static LIST_HEAD(nfs_volume_list);
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
 #if IS_ENABLED(CONFIG_NFS_V4)
@@ -558,6 +559,7 @@ void nfs_mark_client_ready(struct nfs_client *clp, int state)
 	clp->cl_cons_state = state;
 	wake_up_all(&nfs_client_active_wq);
 }
+EXPORT_SYMBOL_GPL(nfs_mark_client_ready);
 
 /*
  * With sessions, the client is not marked ready until after a
@@ -574,6 +576,7 @@ int nfs4_check_client_ready(struct nfs_client *clp)
 		return -EPROTONOSUPPORT;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs4_check_client_ready);
 
 /*
  * Initialise the timeout values for a connection
@@ -1171,6 +1174,7 @@ nfs4_find_client_ident(int cb_ident)
 	spin_unlock(&nfs_client_lock);
 	return clp;
 }
+EXPORT_SYMBOL_GPL(nfs4_find_client_ident);
 
 #if defined(CONFIG_NFS_V4_1)
 /*
@@ -1206,6 +1210,7 @@ nfs4_find_client_sessionid(const struct sockaddr *addr,
 	spin_unlock(&nfs_client_lock);
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(nfs4_find_client_sessionid);
 
 #else /* CONFIG_NFS_V4_1 */
 
@@ -1215,6 +1220,7 @@ nfs4_find_client_sessionid(const struct sockaddr *addr,
 {
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(nfs4_find_client_sessionid);
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 840a811..39c71ed 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -103,6 +103,7 @@ const struct inode_operations nfs4_dir_inode_operations = {
 	.listxattr	= generic_listxattr,
 	.removexattr	= generic_removexattr,
 };
+EXPORT_SYMBOL_GPL(nfs4_dir_inode_operations);
 
 #endif /* CONFIG_NFS_V4 */
 
@@ -958,6 +959,7 @@ void nfs_force_lookup_revalidate(struct inode *dir)
 {
 	NFS_I(dir)->cache_change_attribute++;
 }
+EXPORT_SYMBOL_GPL(nfs_force_lookup_revalidate);
 
 /*
  * A check for whether or not the parent directory has changed.
@@ -1311,6 +1313,7 @@ const struct dentry_operations nfs4_dentry_operations = {
 	.d_automount	= nfs_d_automount,
 	.d_release	= nfs_d_release,
 };
+EXPORT_SYMBOL_GPL(nfs4_dentry_operations);
 
 /*
  * Use intent information to determine whether we need to substitute
@@ -2276,6 +2279,7 @@ int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
 {
 	return nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
 }
+EXPORT_SYMBOL_GPL(nfs_may_open);
 
 int nfs_permission(struct inode *inode, int mask)
 {
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5158bd3..219bb22 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -889,4 +889,5 @@ const struct file_operations nfs4_file_operations = {
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
+EXPORT_SYMBOL_GPL(nfs4_file_operations);
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2ee6259..e2c372c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -83,6 +83,7 @@ int nfs_wait_bit_killable(void *word)
 	freezable_schedule();
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_wait_bit_killable);
 
 /**
  * nfs_compat_user_ino64 - returns the user-visible inode number
@@ -421,6 +422,7 @@ out_no_inode:
 	dprintk("nfs_fhget: iget failed with error %ld\n", PTR_ERR(inode));
 	goto out;
 }
+EXPORT_SYMBOL_GPL(nfs_fhget);
 
 #define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_ATIME_SET|ATTR_MTIME|ATTR_MTIME_SET|ATTR_FILE|ATTR_OPEN)
 
@@ -686,6 +688,7 @@ struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 		atomic_inc(&ctx->lock_context.count);
 	return ctx;
 }
+EXPORT_SYMBOL_GPL(get_nfs_open_context);
 
 static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 {
@@ -712,6 +715,7 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
 {
 	__put_nfs_open_context(ctx, 0);
 }
+EXPORT_SYMBOL_GPL(put_nfs_open_context);
 
 /*
  * Ensure that mmap has a recent RPC credential for use when writing out
@@ -1536,6 +1540,7 @@ static void nfs_destroy_inodecache(void)
 }
 
 struct workqueue_struct *nfsiod_workqueue;
+EXPORT_SYMBOL_GPL(nfsiod_workqueue);
 
 /*
  * start up the nfsiod workqueue
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 289560d..69ec69b 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -119,6 +119,7 @@ Elong_unlock:
 Elong:
 	return ERR_PTR(-ENAMETOOLONG);
 }
+EXPORT_SYMBOL_GPL(nfs_path);
 
 #if IS_ENABLED(CONFIG_NFS_V4)
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
@@ -149,6 +150,7 @@ rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 
 	return pseudoflavor;
 }
+EXPORT_SYMBOL_GPL(nfs_find_best_sec);
 
 static int nfs_negotiate_security(const struct dentry *parent,
 				  const struct dentry *dentry,
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 77a184e..0864530 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -249,6 +249,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init);
 
 /**
  * nfs_can_coalesce_requests - test two requests for compatibility
@@ -390,6 +391,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	} while (ret);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_add_request);
 
 /**
  * nfs_pageio_complete - Complete I/O on an nfs_pageio_descriptor
@@ -405,6 +407,7 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 			break;
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_complete);
 
 /**
  * nfs_pageio_cond_complete - Conditional I/O completion
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9292787..f7edc4a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -189,6 +189,7 @@ get_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	atomic_inc(&lo->plh_refcount);
 }
+EXPORT_SYMBOL_GPL(get_layout_hdr);
 
 static struct pnfs_layout_hdr *
 pnfs_alloc_layout_hdr(struct inode *ino, gfp_t gfp_flags)
@@ -232,6 +233,7 @@ put_layout_hdr(struct pnfs_layout_hdr *lo)
 		spin_unlock(&inode->i_lock);
 	}
 }
+EXPORT_SYMBOL_GPL(put_layout_hdr);
 
 static void
 init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
@@ -412,6 +414,7 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Return %i\n", __func__, invalid - removed);
 	return invalid - removed;
 }
+EXPORT_SYMBOL_GPL(mark_matching_lsegs_invalid);
 
 /* note free_me must contain lsegs from a single layout_hdr */
 void
@@ -439,6 +442,7 @@ pnfs_free_lseg_list(struct list_head *free_me)
 		free_lseg(lseg);
 	}
 }
+EXPORT_SYMBOL_GPL(pnfs_free_lseg_list);
 
 void
 pnfs_destroy_layout(struct nfs_inode *nfsi)
@@ -455,6 +459,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 }
+EXPORT_SYMBOL_GPL(pnfs_destroy_layout);
 
 /*
  * Called by the state manger to remove all layouts established under an
@@ -488,6 +493,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 		pnfs_destroy_layout(NFS_I(lo->plh_inode));
 	}
 }
+EXPORT_SYMBOL_GPL(pnfs_destroy_all_layouts);
 
 /* update lo->plh_stateid with new if is more recent */
 void
@@ -518,6 +524,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 		}
 	}
 }
+EXPORT_SYMBOL_GPL(pnfs_set_layout_stateid);
 
 /* lget is set to 1 if called from inside send_layoutget call chain */
 static bool
@@ -558,6 +565,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 	dprintk("<-- %s\n", __func__);
 	return status;
 }
+EXPORT_SYMBOL_GPL(pnfs_choose_layoutget_stateid);
 
 /*
 * Get layout from server.
@@ -693,6 +701,7 @@ out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
 }
+EXPORT_SYMBOL_GPL(_pnfs_return_layout);
 
 bool pnfs_roc(struct inode *ino)
 {
@@ -723,6 +732,7 @@ out_nolayout:
 	spin_unlock(&ino->i_lock);
 	return false;
 }
+EXPORT_SYMBOL_GPL(pnfs_roc);
 
 void pnfs_roc_release(struct inode *ino)
 {
@@ -734,6 +744,7 @@ void pnfs_roc_release(struct inode *ino)
 	put_layout_hdr_locked(lo);
 	spin_unlock(&ino->i_lock);
 }
+EXPORT_SYMBOL_GPL(pnfs_roc_release);
 
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
 {
@@ -745,6 +756,7 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
 		lo->plh_barrier = barrier;
 	spin_unlock(&ino->i_lock);
 }
+EXPORT_SYMBOL_GPL(pnfs_roc_set_barrier);
 
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier)
 {
@@ -770,6 +782,7 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier)
 	spin_unlock(&ino->i_lock);
 	return found;
 }
+EXPORT_SYMBOL_GPL(pnfs_roc_drain);
 
 /*
  * Compare two layout segments for sorting into layout cache.
@@ -1080,6 +1093,7 @@ out_forget_reply:
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(pnfs_layout_process);
 
 void
 pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
@@ -1473,6 +1487,7 @@ void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data)
 	if (nfss->pnfs_curr_ld->cleanup_layoutcommit)
 		nfss->pnfs_curr_ld->cleanup_layoutcommit(data);
 }
+EXPORT_SYMBOL_GPL(pnfs_cleanup_layoutcommit);
 
 /*
  * For the LAYOUT4_NFSV4_1_FILES layout type, NFS_DATA_SYNC WRITEs and
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 4f359d2..e0041f3 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -255,6 +255,7 @@ nfs4_deviceid_purge_client(const struct nfs_client *clp)
 	for (h = 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++)
 		_deviceid_purge_client(clp, h);
 }
+EXPORT_SYMBOL_GPL(nfs4_deviceid_purge_client);
 
 /*
  * Stop use of all deviceids associated with an nfs_client
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 3c2540d..cdeffdc 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -70,6 +70,7 @@ void nfs_readdata_release(struct nfs_read_data *rdata)
 	put_nfs_open_context(rdata->args.context);
 	nfs_readdata_free(rdata);
 }
+EXPORT_SYMBOL_GPL(nfs_readdata_release);
 
 static
 int nfs_return_empty_page(struct page *page)
@@ -115,6 +116,7 @@ void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
 	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops,
 			NFS_SERVER(inode)->rsize, 0);
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init_read_mds);
 
 void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 {
@@ -368,6 +370,7 @@ int nfs_generic_pagein(struct nfs_pageio_descriptor *desc, struct list_head *hea
 		return nfs_pagein_multi(desc, head);
 	return nfs_pagein_one(desc, head);
 }
+EXPORT_SYMBOL_GPL(nfs_generic_pagein);
 
 static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 427865f..ad5b528 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -358,6 +358,7 @@ void nfs_sb_active(struct super_block *sb)
 	if (atomic_inc_return(&server->active) == 1)
 		atomic_inc(&sb->s_active);
 }
+EXPORT_SYMBOL_GPL(nfs_sb_active);
 
 void nfs_sb_deactive(struct super_block *sb)
 {
@@ -366,6 +367,7 @@ void nfs_sb_deactive(struct super_block *sb)
 	if (atomic_dec_and_test(&server->active))
 		deactivate_super(sb);
 }
+EXPORT_SYMBOL_GPL(nfs_sb_deactive);
 
 /*
  * Deliver file system statistics to userspace
@@ -2439,5 +2441,6 @@ int nfs4_validate_text_mount_data(void *options,
 				   &args->nfs_server.export_path,
 				   NFS4_MAXPATHLEN);
 }
+EXPORT_SYMBOL_GPL(nfs4_validate_text_mount_data);
 
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9788bee..87437e3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -104,6 +104,7 @@ void nfs_writedata_release(struct nfs_write_data *wdata)
 	put_nfs_open_context(wdata->args.context);
 	nfs_writedata_free(wdata);
 }
+EXPORT_SYMBOL_GPL(nfs_writedata_release);
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 {
@@ -1034,6 +1035,7 @@ int nfs_generic_flush(struct nfs_pageio_descriptor *desc, struct list_head *head
 		return nfs_flush_multi(desc, head);
 	return nfs_flush_one(desc, head);
 }
+EXPORT_SYMBOL_GPL(nfs_generic_flush);
 
 static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
@@ -1058,6 +1060,7 @@ void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
 	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops,
 				NFS_SERVER(inode)->wsize, ioflags);
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init_write_mds);
 
 void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 {
@@ -1623,6 +1626,7 @@ int nfs_wb_all(struct inode *inode)
 
 	return sync_inode(inode, &wbc);
 }
+EXPORT_SYMBOL_GPL(nfs_wb_all);
 
 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 {
-- 
1.7.9

