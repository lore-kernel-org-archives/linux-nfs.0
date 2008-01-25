From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 003/112] NFSv4: Clean up the OPEN/CLOSE serialisation code
Date: Fri, 25 Jan 2008 11:37:24 -0500
Message-ID: <20080125163724.31887.25280.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756330AbYAYRAZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:25 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Lmg010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:23 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reduce the time spent locking the rpc_sequence structure by queuing the
nfs_seqid only when we are ready to take the lock (when calling
nfs_wait_on_sequence).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c  |   30 +++++++++++-------------------
 fs/nfs/nfs4state.c |   32 ++++++++++++++++----------------
 2 files changed, 27 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9e2e1c7..a51a753 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3331,15 +3331,12 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 
 	p->arg.fh = NFS_FH(inode);
 	p->arg.fl = &p->fl;
-	if (!(lsp->ls_seqid.flags & NFS_SEQID_CONFIRMED)) {
-		p->arg.open_seqid = nfs_alloc_seqid(&lsp->ls_state->owner->so_seqid);
-		if (p->arg.open_seqid == NULL)
-			goto out_free;
-
-	}
+	p->arg.open_seqid = nfs_alloc_seqid(&lsp->ls_state->owner->so_seqid);
+	if (p->arg.open_seqid == NULL)
+		goto out_free;
 	p->arg.lock_seqid = nfs_alloc_seqid(&lsp->ls_seqid);
 	if (p->arg.lock_seqid == NULL)
-		goto out_free;
+		goto out_free_seqid;
 	p->arg.lock_stateid = &lsp->ls_stateid;
 	p->arg.lock_owner.clientid = server->nfs_client->cl_clientid;
 	p->arg.lock_owner.id = lsp->ls_id.id;
@@ -3348,9 +3345,9 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->ctx = get_nfs_open_context(ctx);
 	memcpy(&p->fl, fl, sizeof(p->fl));
 	return p;
+out_free_seqid:
+	nfs_free_seqid(p->arg.open_seqid);
 out_free:
-	if (p->arg.open_seqid != NULL)
-		nfs_free_seqid(p->arg.open_seqid);
 	kfree(p);
 	return NULL;
 }
@@ -3368,20 +3365,16 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	};
 
 	dprintk("%s: begin!\n", __FUNCTION__);
+	if (nfs_wait_on_sequence(data->arg.lock_seqid, task) != 0)
+		return;
 	/* Do we need to do an open_to_lock_owner? */
 	if (!(data->arg.lock_seqid->sequence->flags & NFS_SEQID_CONFIRMED)) {
 		if (nfs_wait_on_sequence(data->arg.open_seqid, task) != 0)
 			return;
 		data->arg.open_stateid = &state->stateid;
 		data->arg.new_lock_owner = 1;
-		/* Retest in case we raced... */
-		if (!(data->arg.lock_seqid->sequence->flags & NFS_SEQID_CONFIRMED))
-			goto do_rpc;
-	}
-	if (nfs_wait_on_sequence(data->arg.lock_seqid, task) != 0)
-		return;
-	data->arg.new_lock_owner = 0;
-do_rpc:	
+	} else
+		data->arg.new_lock_owner = 0;
 	data->timestamp = jiffies;
 	rpc_call_setup(task, &msg, 0);
 	dprintk("%s: done!, ret = %d\n", __FUNCTION__, data->rpc_status);
@@ -3419,6 +3412,7 @@ static void nfs4_lock_release(void *calldata)
 	struct nfs4_lockdata *data = calldata;
 
 	dprintk("%s: begin!\n", __FUNCTION__);
+	nfs_free_seqid(data->arg.open_seqid);
 	if (data->cancelled != 0) {
 		struct rpc_task *task;
 		task = nfs4_do_unlck(&data->fl, data->ctx, data->lsp,
@@ -3428,8 +3422,6 @@ static void nfs4_lock_release(void *calldata)
 		dprintk("%s: cancelling lock!\n", __FUNCTION__);
 	} else
 		nfs_free_seqid(data->arg.lock_seqid);
-	if (data->arg.open_seqid != NULL)
-		nfs_free_seqid(data->arg.open_seqid);
 	nfs4_put_lock_state(data->lsp);
 	put_nfs_open_context(data->ctx);
 	kfree(data);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5a39c6f..bf94c6e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -644,27 +644,26 @@ void nfs4_copy_stateid(nfs4_stateid *dst, struct nfs4_state *state, fl_owner_t f
 
 struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter)
 {
-	struct rpc_sequence *sequence = counter->sequence;
 	struct nfs_seqid *new;
 
 	new = kmalloc(sizeof(*new), GFP_KERNEL);
 	if (new != NULL) {
 		new->sequence = counter;
-		spin_lock(&sequence->lock);
-		list_add_tail(&new->list, &sequence->list);
-		spin_unlock(&sequence->lock);
+		INIT_LIST_HEAD(&new->list);
 	}
 	return new;
 }
 
 void nfs_free_seqid(struct nfs_seqid *seqid)
 {
-	struct rpc_sequence *sequence = seqid->sequence->sequence;
+	if (!list_empty(&seqid->list)) {
+		struct rpc_sequence *sequence = seqid->sequence->sequence;
 
-	spin_lock(&sequence->lock);
-	list_del(&seqid->list);
-	spin_unlock(&sequence->lock);
-	rpc_wake_up(&sequence->wait);
+		spin_lock(&sequence->lock);
+		list_del(&seqid->list);
+		spin_unlock(&sequence->lock);
+		rpc_wake_up(&sequence->wait);
+	}
 	kfree(seqid);
 }
 
@@ -675,6 +674,7 @@ void nfs_free_seqid(struct nfs_seqid *seqid)
  */
 static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 {
+	BUG_ON(list_first_entry(&seqid->sequence->sequence->list, struct nfs_seqid, list) != seqid);
 	switch (status) {
 		case 0:
 			break;
@@ -726,15 +726,15 @@ int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task)
 	struct rpc_sequence *sequence = seqid->sequence->sequence;
 	int status = 0;
 
-	if (sequence->list.next == &seqid->list)
-		goto out;
 	spin_lock(&sequence->lock);
-	if (sequence->list.next != &seqid->list) {
-		rpc_sleep_on(&sequence->wait, task, NULL, NULL);
-		status = -EAGAIN;
-	}
+	if (list_empty(&seqid->list))
+		list_add_tail(&seqid->list, &sequence->list);
+	if (list_first_entry(&sequence->list, struct nfs_seqid, list) == seqid)
+		goto unlock;
+	rpc_sleep_on(&sequence->wait, task, NULL, NULL);
+	status = -EAGAIN;
+unlock:
 	spin_unlock(&sequence->lock);
-out:
 	return status;
 }
 
