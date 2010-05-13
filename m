From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: SQUASHME: missing from FIXME: async layout return
Date: Thu, 13 May 2010 17:39:09 +0300
Message-ID: <4BEC0F0D.5060408@panasas.com>
References: <4BEBBAE9.8090605@panasas.com> <AANLkTilE4ao7UadJD58EzbExdfwE4zU5DF-6Nit29Yjq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Boaz Harrosh <bharrosh@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31117 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752852Ab0EMOjM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 10:39:12 -0400
In-Reply-To: <AANLkTilE4ao7UadJD58EzbExdfwE4zU5DF-6Nit29Yjq-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 13, 2010, 17:07 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
> Hi Boaz
> 
> I've been chasing this bug. Where is the rest of the FIXME: async
> layout return patch?
> I can't find it.

Sorry, it's not released yet.
I wanted to do more testing with it to make sure
it does the right thing.

Here it is:

>From 8052205dab7c8493bbd5837997ba79d95c8151cc Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@panasas.com>
Date: Wed, 14 Apr 2010 19:05:13 +0300
Subject: [PATCH] FIXME: async layout return

FIXME: currently there's only one path that requires async layout return
to avoid blocking of the rpciod like the stack below.

We really neee the pnfs state machine instead.

rpciod/0      D 0000003d8c2d83b0     0  1029      2 0x00000000
778ccdd0 60264f00 77a6a000 778ccb20 77a6ba20 6001375b 77a6ba20 77a6a000
       77a6a000 778cc8a0 77a6ba70 601b192f 77a6ba50 601b35a6 6ed537f0 77a6a000
       77a6bb00 63506fd8 7b1870c8 77a6bb10 77a6ba90 7b187100 63506fd8 77a6a000
Call Trace:
77a6b9f8:  [<6001375b>] _switch_to+0x5e/0xae
77a6ba28:  [<601b192f>] schedule+0x1dd/0x21b
77a6ba38:  [<601b35a6>] _raw_spin_unlock_irqrestore+0x18/0x1c
77a6ba60:  [<7b1870c8>] rpc_wait_bit_killable+0x0/0x3c [sunrpc]
77a6ba78:  [<7b187100>] rpc_wait_bit_killable+0x38/0x3c [sunrpc]
77a6ba98:  [<601b1d9f>] __wait_on_bit+0x43/0x76
77a6bae8:  [<601b1e43>] out_of_line_wait_on_bit+0x71/0x7c
77a6baf8:  [<7b1870c8>] rpc_wait_bit_killable+0x0/0x3c [sunrpc]
77a6bb20:  [<600430d6>] wake_bit_function+0x0/0x2e
77a6bb68:  [<7b18709d>] __rpc_wait_for_completion_task+0x34/0x36 [sunrpc]
77a6bb78:  [<7bf36048>] nfs4_wait_for_completion_rpc_task+0xb/0xd [nfs]
77a6bb88:  [<7bf369ac>] pnfs4_proc_layoutreturn+0xae/0xe6 [nfs]
77a6bbc8:  [<6007c8b1>] kmem_cache_alloc+0xaf/0xbe
77a6bc08:  [<7bf4dc39>] _pnfs_return_layout+0x450/0x4d4 [nfs]
77a6bc38:  [<7bf3cb79>] decode_attr_time+0x17/0x4d [nfs]
77a6bc58:  [<7bf429d7>] decode_getfattr+0xaae/0xc02 [nfs]
77a6bcb8:  [<7bf4601b>] __nfs4_close+0x15d/0x17a [nfs]
77a6bd28:  [<7bf46053>] nfs4_close_state+0xb/0xd [nfs]
77a6bd38:  [<7bf34183>] nfs4_close_context+0x26/0x28 [nfs]
77a6bd48:  [<7bf2315c>] __put_nfs_open_context+0x79/0xa1 [nfs]
77a6bd78:  [<7bf23227>] put_nfs_open_context+0xb/0xd [nfs]
77a6bd88:  [<7bf4b763>] pnfs_layoutcommit_done+0xa5/0xad [nfs]
77a6bdb8:  [<7bf3b12e>] pnfs_layoutcommit_rpc_done+0x39/0x56 [nfs]
77a6bde8:  [<7b18712b>] rpc_exit_task+0x27/0x52 [sunrpc]
77a6be08:  [<7b187817>] __rpc_execute+0x88/0x23a [sunrpc]
77a6be30:  [<7b1879ee>] rpc_async_schedule+0x0/0x12 [sunrpc]
77a6be48:  [<7b1879fe>] rpc_async_schedule+0x10/0x12 [sunrpc]
77a6be58:  [<6003fc45>] worker_thread+0x114/0x1a5
77a6be80:  [<600430a2>] autoremove_wake_function+0x0/0x34
77a6beb8:  [<6003fb31>] worker_thread+0x0/0x1a5
77a6bed8:  [<60042cf7>] kthread+0x8e/0x96
77a6bf48:  [<60021429>] run_kernel_thread+0x41/0x4a
77a6bf58:  [<60042c69>] kthread+0x0/0x96
77a6bf98:  [<60021410>] run_kernel_thread+0x28/0x4a
77a6bfc8:  [<600136d3>] new_thread_handler+0x71/0x9b

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |    7 ++++---
 fs/nfs/inode.c         |    2 +-
 fs/nfs/nfs4proc.c      |   17 ++++++++++-------
 fs/nfs/nfs4state.c     |    2 +-
 fs/nfs/pnfs.c          |   21 +++++++++++++--------
 fs/nfs/pnfs.h          |    9 +++++----
 6 files changed, 34 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index ebf86df..33ef5c0 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -214,7 +214,7 @@ static int pnfs_recall_layout(void *data)
 
 	if (rl.cbl_recall_type == RETURN_FILE) {
 		status = pnfs_return_layout(inode, &rl.cbl_seg, &rl.cbl_stateid,
-					    RETURN_FILE);
+					    RETURN_FILE, true);
 		if (status)
 			dprintk("%s RETURN_FILE error: %d\n", __func__, status);
 		goto out;
@@ -226,12 +226,13 @@ static int pnfs_recall_layout(void *data)
 	/* FIXME: This loop is inefficient, running in O(|s_inodes|^2) */
 	while ((ino = nfs_layoutrecall_find_inode(clp, &rl)) != NULL) {
 		/* XXX need to check status on pnfs_return_layout */
-		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RETURN_FILE);
+		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RETURN_FILE, true);
 		iput(ino);
 	}
 
 	/* send final layoutreturn */
-	status = pnfs_return_layout(inode, &rl.cbl_seg, NULL, rl.cbl_recall_type);
+	status = pnfs_return_layout(inode, &rl.cbl_seg, NULL,
+				    rl.cbl_recall_type, true);
 	if (status)
 		printk(KERN_INFO "%s: ignoring pnfs_return_layout status=%d\n",
 				__func__, status);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f0b8676..42fac75 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1320,7 +1320,7 @@ void nfs4_clear_inode(struct inode *inode)
 	/* First call standard NFS clear_inode() code */
 	nfs_clear_inode(inode);
 #ifdef CONFIG_NFS_V4_1
-	pnfs_return_layout(inode, NULL, NULL, RETURN_FILE);
+	pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
 #endif /* CONFIG_NFS_V4_1 */
 }
 #endif
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 82cd2ea..c01ecd7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1081,7 +1081,8 @@ static void pnfs4_layout_reclaim(struct nfs4_state *state)
 	/* FIXME: send gratuitous layout commits and return with the reclaim
 	 * flag during grace period
 	 */
-	pnfs_return_layout(state->inode, NULL, &state->open_stateid, RETURN_FILE);
+	pnfs_return_layout(state->inode, NULL, &state->open_stateid,
+			   RETURN_FILE, true);
 	pnfs_set_layout_stateid(&NFS_I(state->inode)->layout, &zero_stateid);
 #endif /* CONFIG_NFS_V4_1 */
 }
@@ -2375,7 +2376,7 @@ pnfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 	if (pnfs_enabled_sb(server) && has_layout(nfsi) &&
 	    pnfs_ld_layoutret_on_setattr(server->pnfs_curr_ld))
-		pnfs_return_layout(inode, NULL, NULL, RETURN_FILE);
+		pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
 	return nfs4_proc_setattr(dentry, fattr, sattr);
 }
 #endif /* CONFIG_NFS_V4_1 */
@@ -5736,7 +5737,7 @@ static const struct rpc_call_ops nfs4_pnfs_layoutreturn_call_ops = {
 	.rpc_release = nfs4_pnfs_layoutreturn_release,
 };
 
-int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp)
+int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait)
 {
 	struct inode *ino = lrp->args.inode;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -5753,7 +5754,7 @@ int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp)
 		.callback_data = lrp,
 		.flags = RPC_TASK_ASYNC,
 	};
-	int status;
+	int status = 0;
 
 	dprintk("--> %s\n", __func__);
 	lrp->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
@@ -5762,9 +5763,11 @@ int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp)
 		status = PTR_ERR(task);
 		goto out;
 	}
-	status = nfs4_wait_for_completion_rpc_task(task);
-	if (status == 0)
-		status = task->tk_status;
+	if (wait) {
+		status = nfs4_wait_for_completion_rpc_task(task);
+		if (status == 0)
+			status = task->tk_status;
+	}
 	rpc_put_task(task);
 out:
 	dprintk("<-- %s\n", __func__);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 15c8bc8..cfaa1be 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -598,7 +598,7 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fm
 			range.offset = 0;
 			range.length = NFS4_MAX_UINT64;
 			pnfs_return_layout(state->inode, &range, NULL,
-					   RETURN_FILE);
+					   RETURN_FILE, wait);
 		}
 #endif /* CONFIG_NFS_V4_1 */
 		nfs4_do_close(path, state, wait);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3739c38..06f20b9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -675,7 +675,8 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 static int
 return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	      const nfs4_stateid *stateid, /* optional */
-	      enum pnfs_layoutreturn_type type, struct pnfs_layout_type *lo)
+	      enum pnfs_layoutreturn_type type, struct pnfs_layout_type *lo,
+	      bool wait)
 {
 	struct nfs4_pnfs_layoutreturn *lrp;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -700,7 +701,7 @@ return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	else if (lo)
 		pnfs_get_layout_stateid(&lrp->args.stateid, lo);
 
-	status = pnfs4_proc_layoutreturn(lrp);
+	status = pnfs4_proc_layoutreturn(lrp, wait);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
@@ -709,7 +710,8 @@ out:
 int
 _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		    const nfs4_stateid *stateid, /* optional */
-		    enum pnfs_layoutreturn_type type)
+		    enum pnfs_layoutreturn_type type,
+		    bool wait)
 {
 	struct pnfs_layout_type *lo = NULL;
 	struct nfs_inode *nfsi = NFS_I(ino);
@@ -727,7 +729,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	}
 	if (type == RETURN_FILE) {
 		if (nfsi->layoutcommit_ctx) {
-			status = pnfs_layoutcommit_inode(ino, 1);
+			status = pnfs_layoutcommit_inode(ino, wait);
 			if (status) {
 				dprintk("%s: layoutcommit failed, status=%d. "
 					"Returning layout anyway\n",
@@ -765,7 +767,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		}
 	}
 send_return:
-	status = return_layout(ino, &arg, stateid, type, lo);
+	status = return_layout(ino, &arg, stateid, type, lo, wait);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
@@ -1680,7 +1682,8 @@ pnfs_writeback_done(struct nfs_write_data *data)
 			.length = data->args.count,
 		};
 		dprintk("%s: retrying\n", __func__);
-		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE);
+		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE,
+				    true);
 		pnfs_initiate_write(data, NFS_CLIENT(data->inode),
 				    pdata->call_ops, pdata->how);
 	}
@@ -1811,7 +1814,8 @@ pnfs_read_done(struct nfs_read_data *data)
 			.length = data->args.count,
 		};
 		dprintk("%s: retrying\n", __func__);
-		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE);
+		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE,
+				    true);
 		pnfs_initiate_read(data, NFS_CLIENT(data->inode),
 				   pdata->call_ops);
 	}
@@ -2037,7 +2041,8 @@ pnfs_commit_done(struct nfs_write_data *data)
 			.length = data->args.count,
 		};
 		dprintk("%s: retrying\n", __func__);
-		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE);
+		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE,
+				    true);
 		pnfs_initiate_commit(data, NFS_CLIENT(data->inode),
 				     pdata->call_ops, pdata->how);
 	}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 47160c5..524a7cd 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -29,7 +29,7 @@ extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
 extern int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp);
 extern int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data);
-extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp);
+extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait);
 
 /* pnfs.c */
 extern const nfs4_stateid zero_stateid;
@@ -40,7 +40,7 @@ int pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 
 int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
 			const nfs4_stateid *stateid, /* optional */
-			enum pnfs_layoutreturn_type);
+			enum pnfs_layoutreturn_type, bool wait);
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *mntfh, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_use_read(struct inode *inode, ssize_t count);
@@ -247,14 +247,15 @@ static inline void pnfs_modify_new_request(struct nfs_page *req,
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct nfs4_pnfs_layout_segment *lseg,
 				     const nfs4_stateid *stateid, /* optional */
-				     enum pnfs_layoutreturn_type type)
+				     enum pnfs_layoutreturn_type type,
+				     bool wait)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_server *nfss = NFS_SERVER(ino);
 
 	if (pnfs_enabled_sb(nfss) &&
 	    (type != RETURN_FILE || has_layout(nfsi)))
-		return _pnfs_return_layout(ino, lseg, stateid, type);
+		return _pnfs_return_layout(ino, lseg, stateid, type, wait);
 
 	return 0;
 }
-- 
1.6.6.1

