Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8292 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751925Ab2AZSck (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 13:32:40 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/2] NFS: start printks w/ NFS: even if __func__ shown
Date: Thu, 26 Jan 2012 13:32:23 -0500
Message-Id: <1327602743-1152-3-git-send-email-dros@netapp.com>
In-Reply-To: <1327602743-1152-1-git-send-email-dros@netapp.com>
References: <1327602743-1152-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch addresses printks that have some context to show that they are
from fs/nfs/, but for the sake of consistency now start with NFS:

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/blocklayout/blocklayoutdev.c |    2 +-
 fs/nfs/blocklayout/blocklayoutdm.c  |    2 +-
 fs/nfs/callback.c                   |    2 +-
 fs/nfs/callback_xdr.c               |    6 +++---
 fs/nfs/idmap.c                      |    6 ++++--
 fs/nfs/inode.c                      |    2 +-
 fs/nfs/nfs4filelayout.c             |    6 ++++--
 fs/nfs/nfs4filelayoutdev.c          |   10 +++++-----
 fs/nfs/nfs4proc.c                   |    7 ++++---
 fs/nfs/nfs4state.c                  |   12 ++++++------
 fs/nfs/nfs4xdr.c                    |   10 +++++-----
 fs/nfs/objlayout/objio_osd.c        |    6 +++---
 fs/nfs/objlayout/objlayout.c        |    6 +++---
 fs/nfs/pnfs.c                       |   14 +++++++-------
 14 files changed, 48 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 94ed978..b48f782 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -46,7 +46,7 @@ static int decode_sector_number(__be32 **rp, sector_t *sp)
 
 	*rp = xdr_decode_hyper(*rp, &s);
 	if (s & 0x1ff) {
-		printk(KERN_WARNING "%s: sector not aligned\n", __func__);
+		printk(KERN_WARNING "NFS: %s: sector not aligned\n", __func__);
 		return -1;
 	}
 	*sp = s >> SECTOR_SHIFT;
diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
index 970490f..a0f588f 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -91,7 +91,7 @@ static void nfs4_blk_metadev_release(struct pnfs_block_dev *bdev)
 	dprintk("%s Releasing\n", __func__);
 	rv = nfs4_blkdev_put(bdev->bm_mdev);
 	if (rv)
-		printk(KERN_ERR "%s nfs4_blkdev_put returns %d\n",
+		printk(KERN_ERR "NFS: %s nfs4_blkdev_put returns %d\n",
 				__func__, rv);
 
 	dev_remove(bdev->net, bdev->bm_mdev->bd_dev);
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index d81040a..4a122ae 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -85,7 +85,7 @@ nfs4_callback_svc(void *vrqstp)
 		}
 		if (err < 0) {
 			if (err != preverr) {
-				printk(KERN_WARNING "%s: unexpected error "
+				printk(KERN_WARNING "NFS: %s: unexpected error "
 					"from svc_recv (%d)\n", __func__, err);
 				preverr = err;
 			}
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index d50b274..2f45aa7 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -73,7 +73,7 @@ static __be32 *read_buf(struct xdr_stream *xdr, int nbytes)
 
 	p = xdr_inline_decode(xdr, nbytes);
 	if (unlikely(p == NULL))
-		printk(KERN_WARNING "NFSv4 callback reply buffer overflowed!\n");
+		printk(KERN_WARNING "NFS: NFSv4 callback reply buffer overflowed!\n");
 	return p;
 }
 
@@ -155,7 +155,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 		return status;
 	/* We do not like overly long tags! */
 	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ - 12) {
-		printk("NFSv4 CALLBACK %s: client sent tag of length %u\n",
+		printk("NFS: NFSv4 CALLBACK %s: client sent tag of length %u\n",
 				__func__, hdr->taglen);
 		return htonl(NFS4ERR_RESOURCE);
 	}
@@ -167,7 +167,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	if (hdr->minorversion <= 1) {
 		hdr->cb_ident = ntohl(*p++); /* ignored by v4.1 */
 	} else {
-		printk(KERN_WARNING "%s: NFSv4 server callback with "
+		printk(KERN_WARNING "NFS: %s: NFSv4 server callback with "
 			"illegal minor version %u!\n",
 			__func__, hdr->minorversion);
 		return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 91b1e2a..62264e0 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -558,11 +558,13 @@ static int __rpc_pipefs_event(struct nfs_client *clp, unsigned long event,
 			 * here.
 			 */
 			if (rpc_rmdir(parent))
-				printk(KERN_ERR "%s: failed to remove clnt dir!\n", __func__);
+				printk(KERN_ERR "NFS: %s: failed to remove "
+					"clnt dir!\n", __func__);
 		}
 		break;
 	default:
-		printk(KERN_ERR "%s: unknown event: %ld\n", __func__, event);
+		printk(KERN_ERR "NFS: %s: unknown event: %ld\n", __func__,
+			event);
 		return -ENOTSUPP;
 	}
 	return err;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index d2c760e..028464b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1407,7 +1407,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	/*
 	 * Big trouble! The inode has become a different object.
 	 */
-	printk(KERN_DEBUG "%s: inode %ld mode changed, %07o to %07o\n",
+	printk(KERN_DEBUG "NFS: %s: inode %ld mode changed, %07o to %07o\n",
 			__func__, inode->i_ino, inode->i_mode, fattr->mode);
  out_err:
 	/*
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9a058b8..79be7ac 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -367,7 +367,8 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	idx = nfs4_fl_calc_ds_index(lseg, j);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds) {
-		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
+		printk(KERN_ERR "NFS: %s: prepare_ds failed, use MDS\n",
+			__func__);
 		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
 		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
 		return PNFS_NOT_ATTEMPTED;
@@ -797,7 +798,8 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
 	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds) {
-		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
+		printk(KERN_ERR "NFS: %s: prepare_ds failed, use MDS\n",
+			__func__);
 		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
 		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
 		prepare_to_resend_writes(data);
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 6eb59b0..80fce8d 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -554,7 +554,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
 	cnt = be32_to_cpup(p);
 	dprintk("%s stripe count  %d\n", __func__, cnt);
 	if (cnt > NFS4_PNFS_MAX_STRIPE_CNT) {
-		printk(KERN_WARNING "%s: stripe count %d greater than "
+		printk(KERN_WARNING "NFS: %s: stripe count %d greater than "
 		       "supported maximum %d\n", __func__,
 			cnt, NFS4_PNFS_MAX_STRIPE_CNT);
 		goto out_err_free_scratch;
@@ -585,7 +585,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
 	num = be32_to_cpup(p);
 	dprintk("%s ds_num %u\n", __func__, num);
 	if (num > NFS4_PNFS_MAX_MULTI_CNT) {
-		printk(KERN_WARNING "%s: multipath count %d greater than "
+		printk(KERN_WARNING "NFS: %s: multipath count %d greater than "
 			"supported maximum %d\n", __func__,
 			num, NFS4_PNFS_MAX_MULTI_CNT);
 		goto out_err_free_stripe_indices;
@@ -593,7 +593,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
 
 	/* validate stripe indices are all < num */
 	if (max_stripe_index >= num) {
-		printk(KERN_WARNING "%s: stripe index %u >= num ds %u\n",
+		printk(KERN_WARNING "NFS: %s: stripe index %u >= num ds %u\n",
 			__func__, max_stripe_index, num);
 		goto out_err_free_stripe_indices;
 	}
@@ -687,7 +687,7 @@ decode_and_add_device(struct inode *inode, struct pnfs_device *dev, gfp_t gfp_fl
 
 	new = decode_device(inode, dev, gfp_flags);
 	if (!new) {
-		printk(KERN_WARNING "%s: Could not decode or add device\n",
+		printk(KERN_WARNING "NFS: %s: Could not decode or add device\n",
 			__func__);
 		return NULL;
 	}
@@ -836,7 +836,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	struct nfs4_pnfs_ds *ds = dsaddr->ds_list[ds_idx];
 
 	if (ds == NULL) {
-		printk(KERN_ERR "%s: No data server for offset index %d\n",
+		printk(KERN_ERR "NFS: %s: No data server for offset index %d\n",
 			__func__, ds_idx);
 		return NULL;
 	}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0773bbb..d574532 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4549,7 +4549,8 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	/* Note: we always want to sleep here! */
 	request->fl_flags = fl_flags | FL_SLEEP;
 	if (do_vfs_lock(request->fl_file, request) < 0)
-		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __func__);
+		printk(KERN_WARNING "NFS: %s: VFS is out of sync with lock "
+			"manager!\n", __func__);
 out_unlock:
 	up_read(&nfsi->rwsem);
 out:
@@ -4629,8 +4630,8 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
 		err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
 		switch (err) {
 			default:
-				printk(KERN_ERR "%s: unhandled error %d.\n",
-						__func__, err);
+				printk(KERN_ERR "NFS: %s: unhandled error "
+					"%d.\n", __func__, err);
 			case 0:
 			case -ESTALE:
 				goto out;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b43a65d..4e37818 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1138,8 +1138,8 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
 				goto out;
 			default:
-				printk(KERN_ERR "%s: unhandled error %d. Zeroing state\n",
-						__func__, status);
+				printk(KERN_ERR "NFS: %s: unhandled error %d. "
+					"Zeroing state\n", __func__, status);
 			case -ENOMEM:
 			case -NFS4ERR_DENIED:
 			case -NFS4ERR_RECLAIM_BAD:
@@ -1185,8 +1185,8 @@ restart:
 				spin_lock(&state->state_lock);
 				list_for_each_entry(lock, &state->lock_states, ls_locks) {
 					if (!(lock->ls_flags & NFS_LOCK_INITIALIZED))
-						printk("%s: Lock reclaim failed!\n",
-							__func__);
+						printk("NFS: %s: Lock reclaim "
+							"failed!\n", __func__);
 				}
 				spin_unlock(&state->state_lock);
 				nfs4_put_open_state(state);
@@ -1195,8 +1195,8 @@ restart:
 		}
 		switch (status) {
 			default:
-				printk(KERN_ERR "%s: unhandled error %d. Zeroing state\n",
-						__func__, status);
+				printk(KERN_ERR "NFS: %s: unhandled error %d. "
+					"Zeroing state\n", __func__, status);
 			case -ENOENT:
 			case -ENOMEM:
 			case -ESTALE:
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0f24f14..96db441 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4464,8 +4464,8 @@ static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
 		return 0;
 	}
 	if (num > 1)
-		printk(KERN_INFO "%s: Warning: Multiple pNFS layout drivers "
-			"per filesystem not supported\n", __func__);
+		printk(KERN_INFO "NFS: %s: Warning: Multiple pNFS layout "
+			"drivers per filesystem not supported\n", __func__);
 
 	/* Decode and set first layout type, move xdr->p past unused types */
 	p = xdr_inline_decode(xdr, num * 4);
@@ -5286,8 +5286,8 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 	attrs->max_reqs = be32_to_cpup(p++);
 	nr_attrs = be32_to_cpup(p);
 	if (unlikely(nr_attrs > 1)) {
-		printk(KERN_WARNING "%s: Invalid rdma channel attrs count %u\n",
-			__func__, nr_attrs);
+		printk(KERN_WARNING "NFS: %s: Invalid rdma channel attrs "
+			"count %u\n", __func__, nr_attrs);
 		return -EINVAL;
 	}
 	if (nr_attrs == 1) {
@@ -5444,7 +5444,7 @@ static int decode_getdevicelist(struct xdr_stream *xdr,
 	dprintk("%s: num_dev %d\n", __func__, res->num_devs);
 
 	if (res->num_devs > NFS4_PNFS_GETDEVLIST_MAXNUM) {
-		printk(KERN_ERR "%s too many result dev_num %u\n",
+		printk(KERN_ERR "NFS: %s too many result dev_num %u\n",
 				__func__, res->num_devs);
 		return -EIO;
 	}
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 55d0128..405a62b 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -582,10 +582,10 @@ objlayout_init(void)
 
 	if (ret)
 		printk(KERN_INFO
-			"%s: Registering OSD pNFS Layout Driver failed: error=%d\n",
+			"NFS: %s: Registering OSD pNFS Layout Driver failed: error=%d\n",
 			__func__, ret);
 	else
-		printk(KERN_INFO "%s: Registered OSD pNFS Layout Driver\n",
+		printk(KERN_INFO "NFS: %s: Registered OSD pNFS Layout Driver\n",
 			__func__);
 	return ret;
 }
@@ -594,7 +594,7 @@ static void __exit
 objlayout_exit(void)
 {
 	pnfs_unregister_layoutdriver(&objlayout_type);
-	printk(KERN_INFO "%s: Unregistered OSD pNFS Layout Driver\n",
+	printk(KERN_INFO "NFS: %s: Unregistered OSD pNFS Layout Driver\n",
 	       __func__);
 }
 
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index b3c2903..2bd1852 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -490,9 +490,9 @@ encode_accumulated_error(struct objlayout *objlay, __be32 *p)
 			if (!ioerr->oer_errno)
 				continue;
 
-			printk(KERN_ERR "%s: err[%d]: errno=%d is_write=%d "
-				"dev(%llx:%llx) par=0x%llx obj=0x%llx "
-				"offset=0x%llx length=0x%llx\n",
+			printk(KERN_ERR "NFS: %s: err[%d]: errno=%d "
+				"is_write=%d dev(%llx:%llx) par=0x%llx "
+				"obj=0x%llx offset=0x%llx length=0x%llx\n",
 				__func__, i, ioerr->oer_errno,
 				ioerr->oer_iswrite,
 				_DEVID_LO(&ioerr->oer_component.oid_device_id),
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9292787..a534216 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -101,8 +101,8 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
 		goto out_no_driver;
 	if (!(server->nfs_client->cl_exchange_flags &
 		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
-		printk(KERN_ERR "%s: id %u cl_exchange_flags 0x%x\n", __func__,
-		       id, server->nfs_client->cl_exchange_flags);
+		printk(KERN_ERR "NFS: %s: id %u cl_exchange_flags 0x%x\n",
+			__func__, id, server->nfs_client->cl_exchange_flags);
 		goto out_no_driver;
 	}
 	ld_type = find_pnfs_driver(id);
@@ -122,8 +122,8 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
 	server->pnfs_curr_ld = ld_type;
 	if (ld_type->set_layoutdriver
 	    && ld_type->set_layoutdriver(server, mntfh)) {
-		printk(KERN_ERR "%s: Error initializing pNFS layout driver %u.\n",
-				__func__, id);
+		printk(KERN_ERR "NFS: %s: Error initializing pNFS layout "
+			"driver %u.\n", __func__, id);
 		module_put(ld_type->owner);
 		goto out_no_driver;
 	}
@@ -143,11 +143,11 @@ pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 	struct pnfs_layoutdriver_type *tmp;
 
 	if (ld_type->id == 0) {
-		printk(KERN_ERR "%s id 0 is reserved\n", __func__);
+		printk(KERN_ERR "NFS: %s id 0 is reserved\n", __func__);
 		return status;
 	}
 	if (!ld_type->alloc_lseg || !ld_type->free_lseg) {
-		printk(KERN_ERR "%s Layout driver must provide "
+		printk(KERN_ERR "NFS: %s Layout driver must provide "
 		       "alloc_lseg and free_lseg.\n", __func__);
 		return status;
 	}
@@ -160,7 +160,7 @@ pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 		dprintk("%s Registering id:%u name:%s\n", __func__, ld_type->id,
 			ld_type->name);
 	} else {
-		printk(KERN_ERR "%s Module with id %d already loaded!\n",
+		printk(KERN_ERR "NFS: %s Module with id %d already loaded!\n",
 			__func__, ld_type->id);
 	}
 	spin_unlock(&pnfs_spinlock);
-- 
1.7.4.4

