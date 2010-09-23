Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9684 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752781Ab0IWRUy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 13:20:54 -0400
Message-ID: <4C9B8C72.2020405@panasas.com>
Date: Thu, 23 Sep 2010 19:20:50 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [bfields@pop.test.fieldses.org: all f08d6374 Merge branch 'nfs-for-next'
 into linux-next results]
References: <20100918171546.GA9859@fieldses.org>	<1284831680.2787.1.camel@heimdal.trondhjem.org>	<20100919184549.GD32071@fieldses.org>	<20100920130106.GB4580@fieldses.org>	<20100920131025.GC4580@fieldses.org>	<1285091815.30222.19.camel@heimdal.trondhjem.org>	<20100921111657.330e7838@corrin.poochiereds.net>	<20100921192005.GC4385@fieldses.org>	<1285097787.30222.24.camel@heimdal.trondhjem.org>	<1285099232.30222.25.camel@heimdal.trondhjem.org>	<20100921202411.GA10570@fieldses.org>	<1285101981.30222.27.camel@heimdal.trondhjem.org> <20100921145823.2ec2a81c@corrin.poochiereds.net>
In-Reply-To: <20100921145823.2ec2a81c@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-21 23:58, Jeff Layton wrote:
> On Tue, 21 Sep 2010 16:46:21 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
>> On Tue, 2010-09-21 at 16:24 -0400, J. Bruce Fields wrote:
>>> On Tue, Sep 21, 2010 at 04:00:32PM -0400, Trond Myklebust wrote:
>>>> On Tue, 2010-09-21 at 15:36 -0400, Trond Myklebust wrote:
>>>>> On Tue, 2010-09-21 at 15:20 -0400, J. Bruce Fields wrote:
>>>>>> All I need to do is mount nfs4.1 and run cthon -s.  The last output I
>>>>>> see from the test is:
>>>>>>
>>>>>> check for proper open/unlink operation
>>>>>> nfsjunk files before unlink:
>>>>>>   
>>>>>
>>>>> Oh... I bet I see what it is.
>>>>>
>>>>> It's that damned res->sr_slotid = NFS4_MAX_SLOT_TABLE and related
>>>>> initialisation junk that's biting us in the arse again...
>>>>>
>>>>> I'll fix it...
>>>>
>>>> Does this work?
>>>
>>> Yup.
>>
>> It seems to fix things for me too... Once you mentioned NFSv4.1 it was
>> easy to reproduce the bug.
>>
>> OK. I'll merge these into nfs-for-2.6.37...
> 
> Thanks for fixing it. I should have mentioned that the 4.1 parts were
> written using the "cargo-cult" programming method of copying what
> unlink does, and that they needed careful review. Mea culpa!
> 

I still hate it that the sr_slotid requires explicit, non-trivial initialization.
Once upon a time, the equivalent of sr_slotid used to be a pointer to
struct slot.  Using a pointer, implicitly initialized to NULL is significantly
more straight forward as in the patch below.
(passes cthon tests over your nfs-for-2.6.37 branch + the patch I
sent earlier that fixes __put_nfs_open_context. w/o it I readily reproduce the
crash reported on this thread)

>From 50221fb5bd8fbd46f6cabe1fc795db7efc71bff7 Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@panasas.com>
Date: Thu, 23 Sep 2010 19:08:21 +0200
Subject: [PATCH] NFSv4.1: keep seq_res.sr_slot as pointer rather than an index

Having to explicitly initialize sr_slotid to NFS4_MAX_SLOT_TABLE
resulted in numerous bugs.  Keeping the current slot as a pointer
to the slot table is more straight forward and robust as it's
implicitly set up to NULL wherever the seq_res member is initialized
to zeroes.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |   52 +++++++++++++++++++----------------------------
 fs/nfs/nfs4xdr.c        |    6 +---
 fs/nfs/read.c           |    1 -
 fs/nfs/unlink.c         |    3 +-
 fs/nfs/write.c          |    2 -
 include/linux/nfs_xdr.h |    2 +-
 6 files changed, 25 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 72aa706..7f8cc33 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -334,10 +334,12 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
  * Must be called while holding tbl->slot_tbl_lock
  */
 static void
-nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
+nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *free_slot)
 {
+	int free_slotid = free_slot - tbl->slots;
 	int slotid = free_slotid;
 
+	BUG_ON(slotid < 0 || slotid >= NFS4_MAX_SLOT_TABLE); 
 	/* clear used bit in bitmap */
 	__clear_bit(slotid, tbl->used_slots);
 
@@ -379,7 +381,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	struct nfs4_slot_table *tbl;
 
 	tbl = &res->sr_session->fc_slot_table;
-	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE) {
+	if (!res->sr_slot) {
 		/* just wake up the next guy waiting since
 		 * we may have not consumed a slot after all */
 		dprintk("%s: No slot\n", __func__);
@@ -387,17 +389,15 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	}
 
 	spin_lock(&tbl->slot_tbl_lock);
-	nfs4_free_slot(tbl, res->sr_slotid);
+	nfs4_free_slot(tbl, res->sr_slot);
 	nfs41_check_drain_session_complete(res->sr_session);
 	spin_unlock(&tbl->slot_tbl_lock);
-	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
+	res->sr_slot = NULL;
 }
 
 static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
 	unsigned long timestamp;
-	struct nfs4_slot_table *tbl;
-	struct nfs4_slot *slot;
 	struct nfs_client *clp;
 
 	/*
@@ -410,17 +410,14 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		res->sr_status = NFS_OK;
 
 	/* -ERESTARTSYS can result in skipping nfs41_sequence_setup */
-	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE)
+	if (!res->sr_slot)
 		goto out;
 
-	tbl = &res->sr_session->fc_slot_table;
-	slot = tbl->slots + res->sr_slotid;
-
 	/* Check the SEQUENCE operation status */
 	switch (res->sr_status) {
 	case 0:
 		/* Update the slot's sequence and clientid lease timer */
-		++slot->seq_nr;
+		++res->sr_slot->seq_nr;
 		timestamp = res->sr_renewal_time;
 		clp = res->sr_session->clp;
 		do_renew_lease(clp, timestamp);
@@ -433,12 +430,14 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		 * returned NFS4ERR_DELAY as per Section 2.10.6.2
 		 * of RFC5661.
 		 */
-		dprintk("%s: slot=%d seq=%d: Operation in progress\n",
-				__func__, res->sr_slotid, slot->seq_nr);
+		dprintk("%s: slot=%ld seq=%d: Operation in progress\n",
+			__func__,
+			res->sr_slot - res->sr_session->fc_slot_table.slots,
+			res->sr_slot->seq_nr);
 		goto out_retry;
 	default:
 		/* Just update the slot sequence no. */
-		++slot->seq_nr;
+		++res->sr_slot->seq_nr;
 	}
 out:
 	/* The session may be reset by one of the error handlers. */
@@ -505,10 +504,9 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 
 	dprintk("--> %s\n", __func__);
 	/* slot already allocated? */
-	if (res->sr_slotid != NFS4_MAX_SLOT_TABLE)
+	if (res->sr_slot != NULL)
 		return 0;
 
-	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
 	tbl = &session->fc_slot_table;
 
 	spin_lock(&tbl->slot_tbl_lock);
@@ -550,7 +548,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slotid, slot->seq_nr);
 
 	res->sr_session = session;
-	res->sr_slotid = slotid;
+	res->sr_slot = slot;
 	res->sr_renewal_time = jiffies;
 	res->sr_status_flags = 0;
 	/*
@@ -576,8 +574,9 @@ int nfs4_setup_sequence(const struct nfs_server *server,
 		goto out;
 	}
 
-	dprintk("--> %s clp %p session %p sr_slotid %d\n",
-		__func__, session->clp, session, res->sr_slotid);
+	dprintk("--> %s clp %p session %p sr_slot %ld\n",
+		__func__, session->clp, session, res->sr_slot ?
+			res->sr_slot - session->fc_slot_table.slots : -1);
 
 	ret = nfs41_setup_sequence(session, args, res, cache_reply,
 				   task);
@@ -650,7 +649,7 @@ static int nfs4_call_sync_sequence(struct nfs_server *server,
 		.callback_data = &data
 	};
 
-	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
+	res->sr_slot = NULL;
 	if (privileged)
 		task_setup.callback_ops = &nfs41_call_priv_sync_ops;
 	task = rpc_run_task(&task_setup);
@@ -735,7 +734,6 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 	p->o_res.server = p->o_arg.server;
 	nfs_fattr_init(&p->f_attr);
 	nfs_fattr_init(&p->dir_attr);
-	p->o_res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 }
 
 static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
@@ -1975,7 +1973,6 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
-	calldata->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	path_get(path);
 	calldata->path = *path;
 
@@ -2550,7 +2547,7 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 
 	args->bitmask = server->cache_consistency_bitmask;
 	res->server = server;
-	res->seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
+	res->seq_res.sr_slot = NULL;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
 }
 
@@ -2576,7 +2573,6 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
 	arg->bitmask = server->attr_bitmask;
 	res->server = server;
-	res->seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 }
 
 static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
@@ -3646,7 +3642,6 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	memcpy(&data->stateid, stateid, sizeof(data->stateid));
 	data->res.fattr = &data->fattr;
 	data->res.server = server;
-	data->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	nfs_fattr_init(data->res.fattr);
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
@@ -3799,7 +3794,6 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	p->arg.fl = &p->fl;
 	p->arg.seqid = seqid;
 	p->res.seqid = seqid;
-	p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	p->arg.stateid = &lsp->ls_stateid;
 	p->lsp = lsp;
 	atomic_inc(&lsp->ls_count);
@@ -3979,7 +3973,6 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->arg.lock_owner.clientid = server->nfs_client->cl_clientid;
 	p->arg.lock_owner.id = lsp->ls_id.id;
 	p->res.lock_seqid = p->arg.lock_seqid;
-	p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	p->lsp = lsp;
 	p->server = server;
 	atomic_inc(&lsp->ls_count);
@@ -4612,7 +4605,6 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	};
 	int status;
 
-	res.lr_seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	dprintk("--> %s\n", __func__);
 	task = rpc_run_task(&task_setup);
 
@@ -5105,12 +5097,11 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_
 
 	if (!atomic_inc_not_zero(&clp->cl_count))
 		return ERR_PTR(-EIO);
-	calldata = kmalloc(sizeof(*calldata), GFP_NOFS);
+	calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
 	if (calldata == NULL) {
 		nfs_put_client(clp);
 		return ERR_PTR(-ENOMEM);
 	}
-	calldata->res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	msg.rpc_argp = &calldata->args;
 	msg.rpc_resp = &calldata->res;
 	calldata->clp = clp;
@@ -5242,7 +5233,6 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
 		goto out;
 	calldata->clp = clp;
 	calldata->arg.one_fs = 0;
-	calldata->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 
 	msg.rpc_argp = &calldata->arg;
 	msg.rpc_resp = &calldata->res;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b0bd7ef..ccf09c4 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4668,7 +4668,6 @@ static int decode_sequence(struct xdr_stream *xdr,
 			   struct rpc_rqst *rqstp)
 {
 #if defined(CONFIG_NFS_V4_1)
-	struct nfs4_slot *slot;
 	struct nfs4_sessionid id;
 	u32 dummy;
 	int status;
@@ -4700,15 +4699,14 @@ static int decode_sequence(struct xdr_stream *xdr,
 		goto out_overflow;
 
 	/* seqid */
-	slot = &res->sr_session->fc_slot_table.slots[res->sr_slotid];
 	dummy = be32_to_cpup(p++);
-	if (dummy != slot->seq_nr) {
+	if (dummy != res->sr_slot->seq_nr) {
 		dprintk("%s Invalid sequence number\n", __func__);
 		goto out_err;
 	}
 	/* slot id */
 	dummy = be32_to_cpup(p++);
-	if (dummy != res->sr_slotid) {
+	if (dummy != res->sr_slot - res->sr_session->fc_slot_table.slots) {
 		dprintk("%s Invalid slot id\n", __func__);
 		goto out_err;
 	}
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 87adc27..79859c8 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -46,7 +46,6 @@ struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
 		p->npages = pagecount;
-		p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 		if (pagecount <= ARRAY_SIZE(p->page_array))
 			p->pagevec = p->page_array;
 		else {
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 47530aa..9a16bad 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -262,7 +262,6 @@ nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 		status = PTR_ERR(data->cred);
 		goto out_free;
 	}
-	data->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	data->res.dir_attr = &data->dir_attr;
 
 	status = -EBUSY;
@@ -427,7 +426,7 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 		.flags = RPC_TASK_ASYNC,
 	};
 
-	data = kmalloc(sizeof(*data), GFP_KERNEL);
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (data == NULL)
 		return ERR_PTR(-ENOMEM);
 	task_setup_data.callback_data = data,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 874972d..4d6d35d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -55,7 +55,6 @@ struct nfs_write_data *nfs_commitdata_alloc(void)
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
-		p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	}
 	return p;
 }
@@ -75,7 +74,6 @@ struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
 		p->npages = pagecount;
-		p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 		if (pagecount <= ARRAY_SIZE(p->page_array))
 			p->pagevec = p->page_array;
 		else {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 172df83..5772b2c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -170,7 +170,7 @@ struct nfs4_sequence_args {
 
 struct nfs4_sequence_res {
 	struct nfs4_session	*sr_session;
-	u8			sr_slotid;	/* slot used to send request */
+	struct nfs4_slot	*sr_slot;	/* slot used to send request */
 	int			sr_status;	/* sequence operation status */
 	unsigned long		sr_renewal_time;
 	u32			sr_status_flags;
-- 
1.7.2.3

