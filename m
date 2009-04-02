From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 21/67] nfs41: set up seq_res.sr_slotid
Date: Thu,  2 Apr 2009 16:53:05 +0300
Message-ID: <1238680385-14056-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28668 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755613AbZDBNxN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:53:13 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Initialize nfs4_sequence_res sr_slotid to NFS4_MAX_SLOT_TABLE.

[was nfs41: sequence res use slotid]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pulled definition of struct nfs4_sequence_res.sr_slotid to here]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |    5 +++++
 fs/nfs/read.c           |    1 +
 fs/nfs/unlink.c         |    1 +
 fs/nfs/write.c          |    2 ++
 include/linux/nfs_xdr.h |    1 +
 5 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index df2a786..2e70c7e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -371,6 +371,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
+	p->o_res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	if (flags & O_EXCL) {
 		u32 *s = (u32 *) p->o_arg.u.verifier.data;
 		s[0] = jiffies;
@@ -1463,6 +1464,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
+	calldata->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	calldata->path.mnt = mntget(path->mnt);
 	calldata->path.dentry = dget(path->dentry);
 
@@ -3091,6 +3093,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	memcpy(&data->stateid, stateid, sizeof(data->stateid));
 	data->res.fattr = &data->fattr;
 	data->res.server = server;
+	data->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	nfs_fattr_init(data->res.fattr);
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
@@ -3243,6 +3246,7 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	p->arg.fl = &p->fl;
 	p->arg.seqid = seqid;
 	p->res.seqid = seqid;
+	p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	p->arg.stateid = &lsp->ls_stateid;
 	p->lsp = lsp;
 	atomic_inc(&lsp->ls_count);
@@ -3415,6 +3419,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->arg.lock_owner.clientid = server->nfs_client->cl_clientid;
 	p->arg.lock_owner.id = lsp->ls_id.id;
 	p->res.lock_seqid = p->arg.lock_seqid;
+	p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	p->lsp = lsp;
 	atomic_inc(&lsp->ls_count);
 	p->ctx = get_nfs_open_context(ctx);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 4ace3c5..70ba2b4 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -46,6 +46,7 @@ struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
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
index e560a78..035e6fb 100644
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
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f933413..892fd27 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -167,6 +167,7 @@ struct nfs4_sequence_args {
 
 struct nfs4_sequence_res {
 	struct nfs4_session	*sr_session;
+	u8			sr_slotid;	/* slot used to send request */
 };
 
 /*
-- 
1.6.2.1

