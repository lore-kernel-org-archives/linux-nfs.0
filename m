From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 32/46] nfs41: set up seq_res.sr_slotid
Date: Wed,  4 Mar 2009 01:59:33 +0200
Message-ID: <1236124773-3864-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17743
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752284AbZCCX7r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:59:47 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Initialize nfs4_sequence_res sr_slotid to NFS4_MAX_SLOT_TABLE.

[was nfs41: sequence res use slotid]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    5 +++++
 fs/nfs/read.c     |    1 +
 fs/nfs/unlink.c   |    1 +
 fs/nfs/write.c    |    2 ++
 4 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3760750..f5e7c72 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -447,6 +447,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
+	p->o_res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	if (flags & O_EXCL) {
 		u32 *s = (u32 *) p->o_arg.u.verifier.data;
 		s[0] = jiffies;
@@ -1539,6 +1540,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
+	calldata->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	calldata->path.mnt = mntget(path->mnt);
 	calldata->path.dentry = dget(path->dentry);
 
@@ -3156,6 +3158,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	memcpy(&data->stateid, stateid, sizeof(data->stateid));
 	data->res.fattr = &data->fattr;
 	data->res.server = server;
+	data->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	nfs_fattr_init(data->res.fattr);
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
@@ -3308,6 +3311,7 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	p->arg.fl = &p->fl;
 	p->arg.seqid = seqid;
 	p->res.seqid = seqid;
+	p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	p->arg.stateid = &lsp->ls_stateid;
 	p->lsp = lsp;
 	atomic_inc(&lsp->ls_count);
@@ -3480,6 +3484,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->arg.lock_owner.clientid = server->nfs_client->cl_clientid;
 	p->arg.lock_owner.id = lsp->ls_id.id;
 	p->res.lock_seqid = p->arg.lock_seqid;
+	p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	p->lsp = lsp;
 	atomic_inc(&lsp->ls_count);
 	p->ctx = get_nfs_open_context(ctx);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index f856004..9d72124 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -45,6 +45,7 @@ struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
 		p->npages = pagecount;
+		p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 		if (pagecount <= ARRAY_SIZE(p->page_array))
 			p->pagevec = p->page_array;
 		else {
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index ecc2953..83d0ce2 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -241,6 +241,7 @@ nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 		status = PTR_ERR(data->cred);
 		goto out_free;
 	}
+	data->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 
 	status = -EBUSY;
 	spin_lock(&dentry->d_lock);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9f98458..a48afb4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -52,6 +52,7 @@ struct nfs_write_data *nfs_commitdata_alloc(void)
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
+		p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	}
 	return p;
 }
@@ -71,6 +72,7 @@ struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
 		p->npages = pagecount;
+		p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 		if (pagecount <= ARRAY_SIZE(p->page_array))
 			p->pagevec = p->page_array;
 		else {
-- 
1.6.1.3

